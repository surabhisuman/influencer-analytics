class InfluencerAnalyticsService
    MAX_RETREIES_ON_FAILURE = 2
    class << self
        def fetch_from_provider(id, provider)
            retries ||= 0
            data = provider.get(id)
            data = data.transform_keys { |key| key.to_s.underscore }.with_indifferent_access
            data[:influencer_id] = data[:pk]
            data[:retrieved_at] = (Time.now().to_f * 1000).to_i
            return data
        rescue StandardError => e
            Rails.logger.error("failed to store data from provider, try: #{retries}, error: #{e.message}")
            retry if (e.is_a? AppErrors::Retryable) && (retries += 1) <= MAX_RETREIES_ON_FAILURE
            return {}
        end

        def store_to_db(data)
            influencer_analytic = InfluencerAnalytic.new_from_hash(data)
            influencer_analytic.save!
            return true
        rescue StandardError => e
            Rails.logger.error("failed to store to db, error: #{e.message}")
            return false
        end

        def push_to_processing_queue(sqs_client, data)
            sqs_client.write(data)
        end

        def store_all_to_db(data_points)
            sliced_data_points = data_points.map { |data_point|
                sliced_data_point = data_point.transform_keys{|key| key.to_sym }.slice(*InfluencerAnalytic::REQUIRED_ATTRIBUTES)
                sliced_data_point[:created_at] = Time.now
                sliced_data_point[:updated_at] = Time.now
                sliced_data_point
            }
            InfluencerAnalytic.insert_all(sliced_data_points)
        end

        def update_average_influencer_count(influencer_id, current_follower_count)
            influencer_avg_data = AverageInfluencerFollower.find_by(influencer_id: influencer_id)
            if !influencer_avg_data
                influencer_avg_data = AverageInfluencerFollower.create(influencer_id: influencer_id, average_count: current_follower_count, no_of_entries: 1)
            else
                new_average = (current_follower_count * 1 + influencer_avg_data.average_count * influencer_avg_data.no_of_entries) / (influencer_avg_data.no_of_entries+ 1)
                influencer_avg_data.update(average_count: new_average, no_of_entries: influencer_avg_data.no_of_entries + 1)
            end
            return influencer_avg_data
        end

        def read_from_db(influencer_id, start_time_in_ms, end_time_in_ms)
            return InfluencerAnalytic.where(influencer_id: influencer_id, retrieved_at: (start_time_in_ms..end_time_in_ms))
                .select("time_bucket(60000, retrieved_at) as time, max(follower_count) as follower_count, max(following_count) as following_count, max(follower_ratio) as follower_ratio")
                .group('time')
                .order('time')
                .map {|result| [result.time, result.follower_count, result.following_count, result.follower_ratio]}
        end
    end
end

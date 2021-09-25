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
    end
end

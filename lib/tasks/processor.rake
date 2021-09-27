
namespace :influencer do
    task :processor => :environment do
        client = SqsClient.new("http://localhost:4100", "influencer_id_store", {
            max_number_of_messages: 100,
            visibility_timeout: 60
        }, "http://localhost:4100/influencer_id_store")
        publish_sqs_client = SqsClient.new("http://localhost:4100", "influencer_data_points", {}, "http://localhost:4100/influencer_data_points")
        provider = MockstagramDataProvider.new("http://localhost:3000")
        client.read do |message|
            json_message = JSON.parse(message.body).with_indifferent_access
            influencer_id = json_message["influencer_id"]
            last_processed_at = json_message["last_processed_at"] || current_timestamp_in_ms
            Rails.logger.info("processing influencer_id: #{influencer_id}, processing again in: #{current_timestamp_in_ms - last_processed_at} ms")

            data_point = InfluencerAnalyticsService.fetch_from_provider(influencer_id, provider)
            response = InfluencerAnalyticsService.update_average_influencer_count(influencer_id, data_point[:follower_count])
            Rails.logger.info("updated average influencers", response)
            InfluencerAnalyticsService.push_to_processing_queue(publish_sqs_client, data_point)
        rescue StandardError => e
            Rails.logger.error("failed to store data point for influencer_id: #{influencer_id}, error: #{e.message}")
        ensure 
            client.write({
                influencer_id: influencer_id,
                last_processed_at: current_timestamp_in_ms
            }) unless influencer_id.nil?
        end
    end

    def current_timestamp_in_ms
        (Time.now().to_f * 1000).to_i
    end
end

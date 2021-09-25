
namespace :influencer do
    task :processor => :environment do
        client = SqsClient.new("http://localhost:4100", "default", {
            max_number_of_messages: 100,
            visibility_timeout: 60
        }, "http://localhost:4100/default")
        provider = MockstagramDataProvider.new("http://localhost:3000")
        client.read do |message|
            json_message = JSON.parse(message.body).with_indifferent_access
            influencer_id = json_message["influencer_id"]
            last_processed_at = json_message["last_processed_at"] || current_timestamp_in_ms
            Rails.logger.info("processing influencer_id: #{influencer_id}, processing again in: #{current_timestamp_in_ms - last_processed_at} ms")

            data = InfluencerAnalyticsService.fetch_from_provider(influencer_id, provider)
            InfluencerAnalyticsService.store_to_db(data)
        rescue StandardError => e
            byebug
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

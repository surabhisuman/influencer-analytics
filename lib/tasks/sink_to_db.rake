namespace :influencer do
    task :sink_to_db => :environment do
        client = SqsClient.new("http://localhost:4100", "influencer_data_points", {
            max_number_of_messages: 100,
            visibility_timeout: 60
        }, "http://localhost:4100/influencer_data_points")

        client.read_in_batches do |messages|
            puts("Processing #{messages.size} messages at #{Time.now}")
            data_points = messages.map {|message| JSON.parse(message.body)}
            InfluencerAnalyticsService.store_all_to_db(data_points)
        end
    end
end
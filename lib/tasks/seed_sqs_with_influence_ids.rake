# INFLUENCER_IDS = Array(1000000..1999999)
INFLUENCER_IDS = Array(1..10)

namespace :sqs do
    namespace :seed do
        desc 'Seeds sqs with a million influencer ids'
        task :million_influencer_id => :environment do
            client = SqsClient.new("http://localhost:9324", "default")
            INFLUENCER_IDS.each do |id|
                client.write({
                    "influencer_id": id
                })
            end
        end
    end
end

batches = [
    Array(1000000..1100000),
    Array(1100001..1200000),
    Array(1200001..1300000),
    Array(1300001..1400000),
    Array(1400001..1500000),
    Array(1500001..1600000),
    Array(1600001..1700000),
    Array(1700001..1800000),
    Array(180001..1900000),
    Array(1900000..1999999)
]

namespace :sqs do
    namespace :seed do
        desc 'Seeds sqs with a million influencer ids'
        task :million_influencer_id => :environment do
            client = SqsClient.new("http://localhost:4100", "influencer_id_store", {}, "http://localhost:4100/influencer_id_store")
            Array(1000000..1001000).each do |id|
                client.write({
                    "influencer_id": id
                })
            end
            # Parallel.map(batches, in_threads: 10) do |batch|
                # batch.each do |id|
                #     client.write({
                #         "influencer_id": id
                #     })
                # end
            # end
        end
    end
end

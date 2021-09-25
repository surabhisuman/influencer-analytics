class InfluencerAnalytic < ApplicationRecord
    REQUIRED_ATTRIBUTES = [:influencer_id, :follower_count, :following_count, :retrieved_at, :username]

    class << self
        def new_from_hash(data)
            REQUIRED_ATTRIBUTES.each do |attribute|
                raise AppErrors::MissingAttributes if data[attribute].nil?
            end

            influencer_analytic = InfluencerAnalytic.new(
                influencer_id: data[:influencer_id],
                follower_count: data[:follower_count],
                following_count: data[:following_count],
                username: data[:username],
                follower_ratio: data[:follower_count] / data[:following_count],
                retrieved_at: data[:retrieved_at]
            )

            return influencer_analytic
        end
    end
end

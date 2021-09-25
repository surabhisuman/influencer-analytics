require "rails_helper"

RSpec.describe InfluencerAnalytic, type: :model do
    let(:valid_hash) {
        {
            influencer_id: 1,
            username: "influencer-100001",
            follower_count: 57166,
            following_count: 1328,
            retrieved_at: (Time.now().to_f * 1000).to_i
        }
    }

    let(:invalid_hash) { {
        influencer_id: 1,
        retrieved_at: (Time.now().to_f * 1000).to_i
    }}

    context ".new_from_hash" do
        it "should return an instance of InfluencerAnalytic on valid hash object" do
            influencer_analytic = InfluencerAnalytic.new_from_hash(valid_hash)
            expect(influencer_analytic).to be_a InfluencerAnalytic
            expect(influencer_analytic.influencer_id).to eq(valid_hash[:influencer_id])
        end

        it "should throw an error for invalid hash" do
            expect {
                InfluencerAnalytic.new_from_hash(invalid_hash)
            }.to raise_error(AppErrors::MissingAttributes)
        end
    end
end

require "rails_helper"

RSpec.describe InfluencerAnalyticsService, type: :service do
    let(:valid_provider_data) {
        {
            "pk": 1000001,
            "username": "influencer-100001",
            "followerCount": 57166,
            "followingCount": 1328
        }
    }
    let(:valid_data) {
        {
            influencer_id: 1000001,
            username: "influencer-100001",
            follower_count: 57166,
            following_count: 1328,
            retrieved_at: (Time.now().to_f * 1000).to_i
        }.with_indifferent_access
    }

    let(:mock_provider) { MockstagramDataProvider.new("http://example.com") }
    
    context ".fetch_from_provider" do
        it "should fetch and create a new entry in db" do
            allow(mock_provider).to receive(:get).and_return(valid_provider_data)
            data = InfluencerAnalyticsService.fetch_from_provider(1000001, mock_provider)
            expect(data[:retrieved_at]).not_to be_nil
            expect(data[:influencer_id]).to eq(1000001)
        end

        it "should return false for invalid data" do
            allow(mock_provider).to receive(:get).and_raise(AppErrors::NetworkError)
            data = InfluencerAnalyticsService.fetch_from_provider(1, mock_provider)
            expect(data).to eq({})
        end
    end

    context ".save_to_db" do
        it "should store to db for valid data" do
            expect { 
                InfluencerAnalyticsService.store_to_db(valid_data)
            }.to change { InfluencerAnalytic.count }.by(1)
        end

        it "shouldn't store to db for invalid data" do
            expect { 
                InfluencerAnalyticsService.store_to_db({})
            }.not_to change { InfluencerAnalytic.count }
        end
    end
end

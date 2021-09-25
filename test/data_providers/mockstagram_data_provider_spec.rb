require "rails_helper"

RSpec.describe MockstagramDataProvider, type: :data_providers do
    let(:stubs) { Faraday::Adapter::Test::Stubs.new }
    let(:url) { "https://mockstagram.mock" }
    let(:conn)   { Faraday.new { |b| b.adapter(:test, stubs) } }
    let(:client) { MockstagramDataProvider.new(url, conn) }
    let(:success_response) { {
        "pk" => 1000001,
        "username" => "influencer-100001",
        "followerCount" => 57166,
        "followingCount" => 1328
    }}

    before do
        stubs.get(MockstagramDataProvider::PATH + "/1000001") { |env| [200, {}, success_response.to_json]}

        stubs.get(MockstagramDataProvider::PATH + "/1000002") { |env| [400, {}, ''] }

        stubs.get(MockstagramDataProvider::PATH + "/1000003") { |env| raise Faraday::ConnectionFailed, nil }
    end

    context "#get" do
        it "should successfully fetch data from mockstagram for status code 200" do
            expect(client.get(1000001)).to eq(success_response)
        end

        it "should fail to fetch data in case of non 200 status code" do
            expect(client.get(1000002)).to eq({})
        end

        it "should fail to fetch data in exception" do
            expect(client.get(1000003)).to eq({})
        end
    end
end

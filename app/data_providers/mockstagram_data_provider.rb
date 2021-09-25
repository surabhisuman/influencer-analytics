require 'faraday'

class MockstagramDataProvider < InfluencerDataProvider
    PATH = "/api/v1/influencers"

    def initialize(url, http_client=nil)
        @http_client = http_client || Faraday.new(url)
    end

    def get(id)
        response = @http_client.get("#{PATH}/#{id}")
        if response.status == 200
            return JSON.parse(response.body)
        else
            return {}
        end
    rescue StandardError => e
        Rails.logger.error "Failed to fetch data for id: #{id}"
        return {}
    end
end

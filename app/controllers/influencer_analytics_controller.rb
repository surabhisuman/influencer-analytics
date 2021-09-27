class InfluencerAnalyticsController < ApplicationController
    def show
        start_time = (params[:start_time].to_f * 1000).to_i
        end_time = (params[:end_time].to_f * 1000).to_i
        influencer_id = params[:id]
        data = InfluencerAnalyticsService.read_from_db(influencer_id, start_time, end_time)
        render json: { data: data, success: true }
    end
end

class AddHypertableForInfluencerAnalytics < ActiveRecord::Migration[6.1]
  def change
    remove_column :influencer_analytics, :id
    execute "SELECT create_hypertable('influencer_analytics', 'retrieved_at', chunk_time_interval => 86400000);"
  end
end

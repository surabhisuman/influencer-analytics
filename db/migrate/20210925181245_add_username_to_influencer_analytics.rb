class AddUsernameToInfluencerAnalytics < ActiveRecord::Migration[6.1]
  def change
    add_column :influencer_analytics, :username, :string
  end
end

class CreateInfluencerAnalytics < ActiveRecord::Migration[6.1]
  def change
    create_table :influencer_analytics do |t|
      t.integer :follower_count
      t.integer :following_count
      t.float :follower_ratio
      t.bigint :retrieved_at

      t.timestamps
    end
    add_index :influencer_analytics, :id, unique: true
  end
end

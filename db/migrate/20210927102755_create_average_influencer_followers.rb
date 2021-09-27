class CreateAverageInfluencerFollowers < ActiveRecord::Migration[6.1]
  def change
    create_table :average_influencer_followers do |t|
      t.string :influencer_id
      t.bigint :average_count
      t.integer :no_of_entries

      t.timestamps
    end
  end
end

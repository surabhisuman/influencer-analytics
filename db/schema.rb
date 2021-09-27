# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_09_27_102755) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "timescaledb"

  create_table "average_influencer_followers", force: :cascade do |t|
    t.string "influencer_id"
    t.bigint "average_count"
    t.integer "no_of_entries"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "influencer_analytics", id: false, force: :cascade do |t|
    t.bigint "influencer_id"
    t.integer "follower_count"
    t.integer "following_count"
    t.float "follower_ratio"
    t.bigint "retrieved_at", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "username"
    t.index ["retrieved_at"], name: "influencer_analytics_retrieved_at_idx", order: :desc
  end

end

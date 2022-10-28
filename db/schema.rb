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

ActiveRecord::Schema[7.0].define(version: 2022_10_22_100350) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "algos", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cities", force: :cascade do |t|
    t.string "name"
    t.integer "s_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "links", force: :cascade do |t|
    t.string "name"
    t.string "url"
    t.integer "s_id"
    t.bigint "city_id", null: false
    t.bigint "algo_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.boolean "fetch_floorplan_images", default: true
    t.index ["algo_id"], name: "index_links_on_algo_id"
    t.index ["city_id"], name: "index_links_on_city_id"
    t.index ["discarded_at"], name: "index_links_on_discarded_at"
  end

  create_table "scrape_entries", force: :cascade do |t|
    t.bigint "scrape_id", null: false
    t.bigint "link_id", null: false
    t.integer "status"
    t.integer "retries"
    t.string "notes"
    t.text "raw_hash"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["link_id"], name: "index_scrape_entries_on_link_id"
    t.index ["scrape_id"], name: "index_scrape_entries_on_scrape_id"
  end

  create_table "scrapes", force: :cascade do |t|
    t.string "name"
    t.datetime "scheduled_at"
    t.datetime "started_at"
    t.datetime "ended_at"
    t.integer "status"
    t.integer "retries"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "frequency"
  end

  add_foreign_key "links", "algos"
  add_foreign_key "links", "cities"
  add_foreign_key "scrape_entries", "links"
  add_foreign_key "scrape_entries", "scrapes"
end

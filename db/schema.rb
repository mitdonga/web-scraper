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

ActiveRecord::Schema[7.0].define(version: 2023_01_06_101915) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.boolean "fetch_floorplan_images", default: true
    t.string "units_url"
    t.boolean "success"
    t.string "notes"
    t.datetime "last_scraped"
    t.index ["city_id"], name: "index_links_on_city_id"
    t.index ["discarded_at"], name: "index_links_on_discarded_at"
  end

  create_table "scrape_entries", force: :cascade do |t|
    t.bigint "scrape_id", null: false
    t.bigint "link_id", null: false
    t.string "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["link_id"], name: "index_scrape_entries_on_link_id"
    t.index ["scrape_id"], name: "index_scrape_entries_on_scrape_id"
  end

  create_table "scrape_entry_histories", force: :cascade do |t|
    t.bigint "scrape_history_id", null: false
    t.bigint "scrape_entry_id", null: false
    t.text "raw_hash"
    t.integer "status"
    t.integer "retries"
    t.string "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["scrape_entry_id"], name: "index_scrape_entry_histories_on_scrape_entry_id"
    t.index ["scrape_history_id"], name: "index_scrape_entry_histories_on_scrape_history_id"
  end

  create_table "scrape_histories", force: :cascade do |t|
    t.bigint "scrape_id", null: false
    t.datetime "started_at"
    t.datetime "ended_at"
    t.integer "status"
    t.integer "retries"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "run_time"
    t.json "scrape_result", default: {}
    t.index ["scrape_id"], name: "index_scrape_histories_on_scrape_id"
  end

  create_table "scrapes", force: :cascade do |t|
    t.string "name"
    t.datetime "scheduled_at"
    t.datetime "started_at"
    t.datetime "ended_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "frequency"
    t.datetime "discarded_at"
    t.integer "avg_run_time"
  end

  add_foreign_key "links", "cities"
  add_foreign_key "scrape_entries", "links"
  add_foreign_key "scrape_entries", "scrapes"
  add_foreign_key "scrape_entry_histories", "scrape_entries"
  add_foreign_key "scrape_entry_histories", "scrape_histories"
  add_foreign_key "scrape_histories", "scrapes"
end

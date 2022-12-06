class CreateScrapeHistories < ActiveRecord::Migration[7.0]
  def change
    create_table :scrape_histories do |t|
			t.references :scrape, null: false, foreign_key: true
			t.datetime "started_at"
			t.datetime "ended_at"
			t.integer "status"
			t.integer "retries"

      t.timestamps
    end
  end
end

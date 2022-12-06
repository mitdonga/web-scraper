class CreateScrapeEntryHistories < ActiveRecord::Migration[7.0]
  def change
    create_table :scrape_entry_histories do |t|
			t.references :scrape_history, null: false, foreign_key: true
			t.references :scrape_entry, null: false, foreign_key: true
			t.text "raw_hash"
			t.integer "status"
			t.integer "retries"
			t.string "notes"
			
      t.timestamps
    end
  end
end

class CreateScrapeEntries < ActiveRecord::Migration[7.0]
  def change
    create_table :scrape_entries do |t|
      t.references :scrape, null: false, foreign_key: true
      t.references :link, null: false, foreign_key: true
      t.integer :status
      t.integer :retries
      t.string :notes
      t.text :raw_hash

      t.timestamps
    end
  end
end

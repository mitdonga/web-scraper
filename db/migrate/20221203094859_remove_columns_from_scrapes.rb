class RemoveColumnsFromScrapes < ActiveRecord::Migration[7.0]
  def change
		remove_column :scrapes, :status
		remove_column :scrapes, :retries
		remove_column :scrape_entries, :status
		remove_column :scrape_entries, :retries
		remove_column :scrape_entries, :raw_hash
  end
end

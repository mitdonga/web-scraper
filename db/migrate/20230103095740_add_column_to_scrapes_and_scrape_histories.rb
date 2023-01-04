class AddColumnToScrapesAndScrapeHistories < ActiveRecord::Migration[7.0]
  def change
		add_column :scrapes, :avg_run_time, :integer
		add_column :scrape_histories, :run_time, :integer
		add_column :scrape_histories, :scrape_result, :json, default: {}
  end
end

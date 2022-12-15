namespace :scrape_histories do
	desc "Delete 7 days old scrape histories"
	task delete_scrape_histories: :environment do
		old_sh = ScrapeHistory.where("created_at < ?", Time.now - 7.days)
		old_sh.destroy_all
	end
end
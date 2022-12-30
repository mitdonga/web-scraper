require 'rufus/scheduler'
require 'rake'

Rake::Task.clear
Rails.application.load_tasks
scheduler = Rufus::Scheduler.new

# scheduler.every '6h10m' do
#   Rake::Task['scrape:run_chicago'].execute
# end

scheduler.every '24h' do
  Rake::Task['scrape_histories:delete_scrape_histories'].execute
end

# scheduler.cron '0 0 * * *' do
#   Rake::Task['scrape:run_austin'].execute
#   Rake::Task['scrape:run_houston'].execute
#   Rake::Task['scrape:run_dfw'].execute
#   Rake::Task['scrape:run_san_antonio'].execute
# end


scheduler.every '1m' do 
  running_scrape_history = ScrapeHistory.find_by(status: "inprogress")
  unless running_scrape_history
    upcoming_scrapes = Scrape.where('scheduled_at < ? AND discard = ?', Time.now, false).reverse
		if upcoming_scrapes.any?
			scrape = upcoming_scrapes.first
			if scrape.kept?
				scraper = Scraper::Runner.new(scrape.id)
				scraper.run
			end
		end
  else
    t = Time.now - running_scrape_history.scrape.started_at 
    if t > 3*60*60
      running_scrape_history.scrape.cancel
    end
  end
end
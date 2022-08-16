require 'rufus/scheduler'
require 'rake'

Rake::Task.clear
Rails.application.load_tasks
scheduler = Rufus::Scheduler.new

scheduler.every '6h10m' do
  Rake::Task['scrape:run_chicago'].execute
end

scheduler.cron '0 0 * * *' do
  Rake::Task['scrape:run_austin'].execute
  Rake::Task['scrape:run_houston'].execute
  # Rake::Task['scrape:run_dfw'].execute
end

# scheduler.cron '0 10 * * *' do
#   Rake::Task['send_follow_up:send_reminder_text'].execute
# end

scheduler.every '1m' do 

  running_scrape = Scrape.find_by(status: "inprogress")

    unless running_scrape

      scrape = Scrape.where(status: "scheduled").order(:scheduled_at)[-1]

      if scrape.scheduled_at < Time.now
        s = Scraper::Runner.new(scrape.id)
        s.run
      end

    else

      t = Time.now - running_scrape.started_at 

      if t > 4*60*60
        running_scrape.completed!
      end

    end
end
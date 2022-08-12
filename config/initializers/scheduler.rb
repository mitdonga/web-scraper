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
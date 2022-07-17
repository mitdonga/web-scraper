require 'rufus/scheduler'
require 'rake'

Rake::Task.clear
Rails.application.load_tasks
scheduler = Rufus::Scheduler.new

scheduler.every '6h10m' do
  Rake::Task['scrape:run1'].execute
  Rake::Task['scrape:run2'].execute
end

# scheduler.cron '0 0 * * *' do
#   Rake::Task['scrape:run1'].execute
#   Rake::Task['scrape:run2'].execute
# end

# scheduler.cron '0 10 * * *' do
#   Rake::Task['send_follow_up:send_reminder_text'].execute
# end
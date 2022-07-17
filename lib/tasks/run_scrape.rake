namespace :scrape do
  desc "Run first scrape"
  task run1: :environment do
    s = Scraper::Runner.new(1)
    s.run
  end

  desc "Run first scrape"
  task run2: :environment do
    s = Scraper::Runner.new(2)
    s.run
  end
end
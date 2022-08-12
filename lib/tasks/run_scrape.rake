namespace :scrape do
  desc "Run Austin scrape"
  task run_austin: :environment do
    s = Scraper::Runner.new(1)
    s.run
  end

  desc "Run Chicago scrape"
  task run_chicago: :environment do
    s = Scraper::Runner.new(2)
    s.run
  end

  desc "Run Houston scrape"
  task run_houston: :environment do
    s = Scraper::Runner.new(170)
    s.run
  end

  desc "Run DFW scrape"
  task run_dfw: :environment do
    s = Scraper::Runner.new(162)
    s.run
  end

end
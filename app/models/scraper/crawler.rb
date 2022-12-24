require 'kimurai'
require "graphql/client"
require "graphql/client/http"
require 'selenium-webdriver'

class Scraper::Crawler < Scraper::BaseScraper
	
	@is_scraping_property = false

	def self.close_spider
    if failed?
			puts "=============== Oops! Something went wrong ============="
    end
  end

	def self.is_scraping_property
		@is_scraping_property
	end

	def self.is_scraping_property=(is_scraping_property=false)
		@is_scraping_property = is_scraping_property
	end

	def parse(response, url:, data: {})
		urls = Scraper::Crawler.url_hash.pluck(:url)

		apartments_property_scrape(response, url, {scraper: Scraper::Crawler, property_scrape: true}) if Scraper::Crawler.runner.link.url.include? "apartments.com"
		rentcafe_property_scrape(response, url, {scraper: Scraper::Crawler, property_scrape: true}) if Scraper::Crawler.runner.link.url.include? "rentcafe.com"

		Scraper::Crawler.is_scraping_property = false		
	end

end
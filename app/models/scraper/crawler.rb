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
		scrape_url = Scraper::Crawler.runner.link.url
		data = {scraper: Scraper::Crawler, property_scrape: true}
		
		apartments_property_scrape(response, url, data) 		if scrape_url.include? "apartments.com"
		rentcafe_property_scrape(response, url, data) 			if scrape_url.include? "rentcafe.com"
		missionrock_scrape(response, url, data)	        		if scrape_url.include? "missionrockresidential.com"
		landmark_scrape(response, url, data) 	        		  if scrape_url.include? "landmarkconservancy.com"

		Scraper::Crawler.is_scraping_property = false		
	end

end
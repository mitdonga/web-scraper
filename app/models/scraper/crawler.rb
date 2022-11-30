require 'kimurai'
require "graphql/client"
require "graphql/client/http"
require 'selenium-webdriver'

class Scraper::Crawler < Scraper::Apt

	@is_scraping_property = false

	def self.is_scraping_property
		@is_scraping_property
	end

	def self.is_scraping_property=(is_scraping_property=false)
		@is_scraping_property = is_scraping_property
	end

	def parse(response, url:, data: {})
		urls = Scraper::Crawler.url_hash.pluck(:url)
		in_parallel(:parse_property, urls, threads: 3, config: self.config, data: {scraper: Scraper::Crawler, property_scrape: true})
		Scraper::Crawler.is_scraping_property = false		
	end

end
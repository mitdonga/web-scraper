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

		domain = URI.parse(url).host.gsub("www.", "")
		template = Algos::Template.get(domain)

		data = {scraper: Scraper::Crawler, property_scrape: true, template: template}

		correct_algo = Scraper::AlgoMapper.new(url, template).get_algo
		eval(correct_algo)

		Scraper::Crawler.is_scraping_property = false
	end

end
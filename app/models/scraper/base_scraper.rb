require 'kimurai'
require "graphql/client"
require "graphql/client/http"
require 'selenium-webdriver'

class Saver < Kimurai::Pipeline
	include Scraper::SaverMethods
end

class Scraper::BaseScraper < Kimurai::Base
  include Scraper::Utils
	include Algos::AptAlgo
	include Algos::RentcafeAlgo

  USER_AGENTS = [
    "Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1",
    "Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.34 (KHTML, like Gecko) Version/11.0 Mobile/15A5341f Safari/604.1",
    "Mozilla/5.0 (Linux; Android 7.1.1; Google Pixel Build/NMF26F; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/54.0.2840.85 Mobile Safari/537.36",
    # "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)",
    # "Mozilla/5.0 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm)"
  ]

  @name = "SparkAPT"
  # @engine = :mechanize
  @engine = :selenium_chrome

  @runner = nil

	@scrape_property = false

  @pipelines = [:saver]
	
	PROXIES = [
		"p.webshare.io:10000:socks5",
		"p.webshare.io:10001:socks5",
		"p.webshare.io:10002:socks5",
		"p.webshare.io:10003:socks5",
		"p.webshare.io:10004:socks5",
		"p.webshare.io:10005:socks5",
		"p.webshare.io:10006:socks5",
		"p.webshare.io:10007:socks5",
		"p.webshare.io:10008:socks5",
		"p.webshare.io:10009:socks5",
		"p.webshare.io:10010:socks5",
		"p.webshare.io:10011:socks5",
		"p.webshare.io:10012:socks5",
		"p.webshare.io:10013:socks5",
		"p.webshare.io:10014:socks5",
		"p.webshare.io:10015:socks5",
		"p.webshare.io:10016:socks5",
		"p.webshare.io:10017:socks5",
		"p.webshare.io:10018:socks5",
		"p.webshare.io:10019:socks5",
		"p.webshare.io:10020:socks5",
		"p.webshare.io:10021:socks5",
		"p.webshare.io:10022:socks5",
		"p.webshare.io:10023:socks5",
		"p.webshare.io:10024:socks5",
		"p.webshare.io:10025:socks5",
		"p.webshare.io:10026:socks5",
		"p.webshare.io:10027:socks5",
		"p.webshare.io:10028:socks5",
		"p.webshare.io:10029:socks5",
		"p.webshare.io:10030:socks5",
		"p.webshare.io:10031:socks5",
		"p.webshare.io:10032:socks5",
		"p.webshare.io:10033:socks5",
		"p.webshare.io:10034:socks5",
		"p.webshare.io:10035:socks5",
		"p.webshare.io:10036:socks5",
		"p.webshare.io:10037:socks5",
		"p.webshare.io:10038:socks5",
		"p.webshare.io:10039:socks5",
		"p.webshare.io:10040:socks5",
		"p.webshare.io:10041:socks5",
		"p.webshare.io:10042:socks5",
		"p.webshare.io:10043:socks5",
		"p.webshare.io:10044:socks5",
		"p.webshare.io:10045:socks5",
		"p.webshare.io:10046:socks5",
		"p.webshare.io:10047:socks5",
		"p.webshare.io:10048:socks5",
		"p.webshare.io:10049:socks5"
	]

  @config = {
    # user_agent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.84 Safari/537.36",
    user_agent: -> { USER_AGENTS.sample },
    # skip_request_errors: [{ error: RuntimeError, message: "404 => Net::HTTPNotFound"},
    skip_request_errors: [{ error: RuntimeError, skip_on_failure: true }],
		proxy: -> { PROXIES.sample },
		retry_request_errors: [Net::ReadTimeout],
    session: {
      before_request: {
        change_user_agent: true,
    
        # Clear all cookies before each request, works for all drivers
        clear_cookies: true,

        # If you want to clear all cookies + set custom cookies (`cookies:` option above should be presented)
        # use this option instead (works for all drivers)
        clear_and_set_cookies: true,
      }
    },
  }
  
  @url_hash = []
  @start_urls = []
	@scrape_history = nil

  def self.runner
    @runner
  end

  def config
    @config
  end

  def self.runner=(runner=nil)
    @runner = runner
  end

	def self.scraper_name=(name = "SparkAPT")                  
		@name = name
	end

  def self.url_hash
    @url_hash
  end

  def self.url_hash=(url_hash=[])
    @url_hash = url_hash
  end

	def self.scrape_history
		@scrape_history
	end

	def self.scrape_history=(scrape_history = nil)
		@scrape_history = scrape_history
	end

  def self.start_urls=(urls=[])
    @start_urls = urls
  end

  def city_name(entry, scraper)
    entry ? scraper.runner.entry(entry[:entry_id]).link.city.name : nil
  end

	def city_id(entry, scraper)
    entry ? scraper.runner.entry(entry[:entry_id]).link.city.s_id : nil
	end

  def scrape_property_city_name(scraper)                 #For Single Property Scrape
    scraper.runner.link.city.name
  end

  def scrape_property_city_id(scraper)                   #For Single Property Scrape
    scraper.runner.link.city.s_id
  end

  def start_entry(entry)
    entry ? ScrapeEntry.find(entry[:entry_id]) : nil
  end

  def finish_entry(entry, property, scraper)
    se = ScrapeEntry.find(entry[:entry_id])
		seh = scraper.scrape_history.scrape_entry_histories.find_by(scrape_entry: se)
    l = se.link
    l ? l.update(name: property[:name], s_id: property[:id], success: true, notes: nil) : nil
		seh.update(status: "completed", raw_hash: property.to_json)

		SprapeSchema.subscriptions.trigger(:scrape_progress, {}, {scrape_history: seh.scrape_history})

  end

	def self.close_spider
    if failed?
			Scraper::BaseScraper.scrape_history&.cancel
    end
		Scraper::BaseScraper.scrape_history&.scrape_entry_histories&.where(status: "inprogress").update_all(status: "canceled")
  end

	def parse(response, url:, data: {})

		urls = Scraper::BaseScraper.url_hash.pluck(:url)

		in_parallel(:map_algo, urls, threads: 3, delay: rand(2..5), config: self.config, data: {scraper: Scraper::BaseScraper, property_scrape: false})

  end

	def map_algo(response, url:, data: {})

		apartments_property_scrape(response, url, data)   if url.include? "apartments.com"
		rentcafe_property_scrape(response, url, data) 	  if url.include? "rentcafe.com"
		
	end

end
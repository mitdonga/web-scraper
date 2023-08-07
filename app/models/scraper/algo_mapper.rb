class Scraper::AlgoMapper
	
	def initialize(url, template=nil)
		@url = url
		@template = template
	end

	def get_algo
		return "rentcafe_sites_scrape(response, url, data)"           if @template.present?
		return "apartments_property_scrape(response, url, data)"      if @url.include? "apartments.com"
		return "rentcafe_property_scrape(response, url, data)"        if @url.include? "rentcafe.com"
		return "missionrock_scrape(response, url, data)"              if @url.include? "missionrockresidential.com"

		return ""
	end
end
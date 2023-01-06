class Scraper::PropertyRunner
	attr_accessor :link

  def initialize(link_id)
    return unless link_id

    if get_link_info(link_id)
			@link = get_link_info(link_id)
      populate_entries
      Scraper::Crawler.start_urls = self.url
      Scraper::Crawler.url_hash = [@url]
      Scraper::Crawler.runner = self
      Scraper::Crawler.is_scraping_property = true

    else
      raise "Link not found..."
    end
  end

  def run
    puts "Scraping: #{@link.url}"

    result = Scraper::Crawler.crawl!

		if result[:visits][:requests] == 1 && result[:visits][:responses] == 0
			result = Scraper::Crawler.crawl!
		end

		if result[:visits][:requests] == 1 && result[:visits][:responses] == 0
			result = Scraper::Crawler.crawl!
		end

		if result[:status].to_s == "completed" && result[:events][:requests_errors] == {} && result[:events][:drop_items_errors] == {} && result[:error] == nil && result[:events][:custom] == {}
			@link.update(success: true, notes: nil, last_scraped: Time.now)
		else
			@link.update(last_scraped: Time.now, success: false, notes: result[:events][:requests_errors].to_s + "|" + result[:events][:drop_items_errors].to_s + "|" + result[:error].to_s)
		end

  end

  def link
    @link   
  end

  def entry(entry_id)
    @entries.find {|e| e.id == entry_id}
  end

  def url
    [@url[:url]]
  end

  private
  def get_link_info(link_id)
		Link.includes(:city).find_by(id:link_id)
  end

  def populate_entries
    @url = {url: @link.url, fetch_floorplan_images: @link.fetch_floorplan_images, units_url: filter_url(@link.units_url)}
  end

	def filter_url(url)
		return nil if url.nil?
		url[-1] == "/" ? url.chop : url
	end
end
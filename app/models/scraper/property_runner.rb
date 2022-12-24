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

    Scraper::Crawler.crawl!

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
    @url = {url: @link.url, fetch_floorplan_images: @link.fetch_floorplan_images, units_url: @link.units_url}

  end

end
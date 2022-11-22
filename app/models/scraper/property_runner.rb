class Scraper::PropertyRunner

  def initialize(link_id)
    return unless link_id

    if get_link_info(link_id)
			@link = get_link_info(link_id)
      populate_entries
      Scraper::Apt.start_urls = self.url
      Scraper::Apt.url_hash = @url
      Scraper::Apt.runner = self
      Scraper::Apt.scraper_name = "Scraper #{link_id}"
      Scraper::Apt.scrape_property = true
    else
      raise "Link not found..."
    end
  end

  def run
    puts "Scraping: #{@link.url}"
    # Create and schedule next scrape
    # next_scrape =  @scrape.schedule_next
    # puts "Scheduled at #{next_scrape.scheduled_at}"
   
    # puts "Starting Scrape: #{@scrape.name}"
    # @scrape.update(started_at: Time.now,
    #   retries: @scrape.retries.to_i + 1, 
    #   status: "inprogress")

    Scraper::Apt.crawl!

    # @scrape.update(started_at: result[:start_time], 
    #         ended_at: result[:stop_time], 
    #         retries: @scrape.retries.to_i + 1, 
    #         status: result[:status].to_s == "completed" ? "completed" : "terminated")
  end

  def link
    @link   
  end

  # def entry(url)
  #   @entries.find_all {|e| e.link.url == url}
  # end

  def entry(entry_id)
    @entries.find {|e| e.id == entry_id}
  end

  # def entries
  #   @entries   
  # end

  def url
    [@url[:url]]
  end

  private
  def get_link_info(link_id)
    # Scrape.includes(scrape_entries: [link: :city]).references(:scrape_entries).find_by(id:scrape_id)
		Link.includes(:city).find_by(id:link_id)
  end

  def populate_entries
    # @entries = []
    @url = {url: @link.url, fetch_floorplan_images: @link.fetch_floorplan_images}
    # @scrape.scrape_entries.each do |entry|
    #   # TODO: Temporarily commenting this to run daily scrapes. Uncomment this condition for actual behavior
    #   if entry.link.kept? #and entry.status != 'completed' and entry.status != 'canceled'
    #     @entries << entry
    #     @urls << {entry_id: entry.id, url: entry.link.url, fetch_floorplan_images: entry.link.fetch_floorplan_images}
    #   end
    # end
  end
end
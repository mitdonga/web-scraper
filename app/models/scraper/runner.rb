class Scraper::Runner
  def initialize(scrape_id, run_mode='run')
    return unless scrape_id

    if @scrape = get_scrape_info(scrape_id)
			@scrape_entries = get_scrape_entries
      run_mode == 'run' ? populate_entries : populate_entries(false)
      Scraper::BaseScraper.start_urls = [self.urls.sample]
      Scraper::BaseScraper.url_hash = @urls
      Scraper::BaseScraper.runner = self
    else
      raise "Scrape not found..."
    end
  end

  def run
    puts "Scheduling Scrape: #{@scrape.name}"
    # Create and schedule next scrape
    # next_scrape =  @scrape.schedule_next
    new_scrape_history =  @scrape.scrape_histories.create(status: "inprogress", started_at: Time.now)

		@scrape_entries.each do |se|
			new_scrape_history.scrape_entry_histories.create(scrape_entry: se, status: "inprogress")
		end

    puts "========= Scrape History Created ========="
    puts "Starting Scrape: #{@scrape.name}"

    @scrape.update(started_at: Time.now, scheduled_at: @scrape.next_run_timestamp)

		SprapeSchema.subscriptions.trigger(:scrape_progress, {}, {scrape_history: new_scrape_history})
		
		# @scrape.scrape_entries.update_all(status: "inprogress")

    Scraper::BaseScraper.scrape_history = new_scrape_history
		
    result = Scraper::BaseScraper.crawl!

		if result[:visits][:requests] == 1 && result[:visits][:responses] == 0
			puts "[INFO] Retrying scraping - 1"
			result = Scraper::BaseScraper.crawl!
		end

		if result[:visits][:requests] == 1 && result[:visits][:responses] == 0
			puts "[INFO] Retrying scraping - 2"
			result = Scraper::BaseScraper.crawl!
		end

		scrape_run_time = result[:running_time]

    @scrape.update(started_at: result[:start_time], 
            ended_at: result[:stop_time], avg_run_time: avg_scrape_time(scrape_run_time, @scrape))

		new_scrape_history.update(started_at: result[:start_time], 
			ended_at: result[:stop_time], 
			status: result[:status].to_s == "completed" ? "completed" : "terminated",
			scrape_result: result, run_time: scrape_run_time)
			
		SprapeSchema.subscriptions.trigger(:scrape_progress, {}, {scrape_history: new_scrape_history})

  end

  def scrape
    @scrape   
  end

  # def entry(url)
  #   @entries.find_all {|e| e.link.url == url}
  # end
	
  def entry(entry_id)
    @entries.find {|e| e.id == entry_id}
  end

  def entries
    @entries   
  end

  def urls
    @urls.pluck(:url)
  end

	def avg_scrape_time(seconds, scrape)
		shs = scrape.scrape_histories.limit(10)
		return seconds unless shs.any?
		count = 0
		total_time = 0
		shs.each do |sh|
			if sh.run_time.present?
				total_time += sh.run_time
				count += 1
			end
		end
		total_time += seconds
		count += 1
		return total_time/count
	end

  private

  def get_scrape_info(scrape_id)
    Scrape.includes(scrape_entries: [link: :city]).references(:scrape_entries).find_by(id:scrape_id)
  end

	def get_scrape_entries
		ScrapeEntry.includes(:link).where(scrape_id: @scrape.id).order("links.last_scraped ASC")
	end

  def populate_entries(include_completed = true)
    @entries = []
    @urls = []
    @scrape_entries.each do |entry|
      # TODO: Temporarily commenting this to run daily scrapes. Uncomment this condition for actual behavior
      if entry.link.kept? #and entry.status != 'completed' and entry.status != 'canceled'
        @entries << entry
        @urls << {entry_id: entry.id, url: entry.link.url, fetch_floorplan_images: entry.link.fetch_floorplan_images, units_url: filter_url(entry.link.units_url), last_scraped: entry.link.last_scraped.strftime('%d %b %Y %H:%M:%S')}
      end
    end
  end

	def filter_url(url)
		return nil if url.nil?
		url[-1] == "/" ? url.chop : url
	end
end
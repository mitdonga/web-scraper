class Scraper::Runner
  def initialize(scrape_id, run_mode='run')
    return unless scrape_id

    if @scrape = get_scrape_info(scrape_id)
      run_mode == 'run' ? populate_entries : populate_entries(false)
      Scraper::Apt.start_urls = self.urls
      Scraper::Apt.url_hash = @urls
      Scraper::Apt.runner = self
    else
      raise "Scrape not found..."
    end
  end

  def run
    puts "Scheduling Next Scrape: #{@scrape.name}"
    # Create and schedule next scrape
    next_scrape =  @scrape.schedule_next
    puts "Scheduled at #{next_scrape.scheduled_at}"
   
    puts "Starting Scrape: #{@scrape.name}"
    @scrape.update(started_at: Time.now,
      retries: @scrape.retries.to_i + 1, 
      status: "inprogress")

    result = Scraper::Apt.crawl!

    @scrape.update(started_at: result[:start_time], 
            ended_at: result[:stop_time], 
            retries: @scrape.retries.to_i + 1, 
            status: result[:status].to_s == "completed" ? "completed" : "terminated")
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

  private
  def get_scrape_info(scrape_id)
    Scrape.includes(scrape_entries: [link: :city]).references(:scrape_entries).find_by(id:scrape_id)
  end

  def populate_entries(include_completed = true)
    @entries = []
    @urls = []
    @scrape.scrape_entries.each do |entry|
      if entry.link.kept? and entry.status != 'completed' and entry.status != 'canceled'
        @entries << entry
        @urls << {entry_id: entry.id, url: entry.link.url}
      end
    end
  end
end
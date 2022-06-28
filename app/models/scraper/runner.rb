class Scraper::Runner
  def initialize(scrape_id)
    return unless scrape_id

    if @scrape = get_scrape_info(scrape_id)
      populate_entries
      Scraper::Apt.start_urls = self.urls
      Scraper::Apt.url_hash = @urls
      Scraper::Apt.runner = self
    else
      raise "Scrape not found..."
    end
  end

  def run
    puts "Starting Scrape: #{@scrape.name}"
    @scrape.inprogress!

    result = Scraper::Apt.crawl!

    @scrape.update(started_at: result[:start_time], 
            ended_at: result[:stop_time], 
            retries: @scrape.retries.to_i + 1, 
            status: result[:status].to_s == "completed" ? "completed" : "terminated")

    # puts "STATUS: #{result[:status]}"
    # puts "error: #{result[:error]}"
    # puts "start_time: #{result[:start_time]}"
    # puts "stop_time: #{result[:stop_time]}"
    # puts "running_time: #{result[:running_time]}"
    # puts "items sent: #{result[:items][:sent]}"
    # puts "items processed: #{result[:items][:processed]}"
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

  def populate_entries
    @entries = []
    @urls = []
    @scrape.scrape_entries.each do |entry|
      if entry.link.kept?
        @entries << entry
        @urls << {entry_id: entry.id, url: entry.link.url}
      end
    end
  end
end
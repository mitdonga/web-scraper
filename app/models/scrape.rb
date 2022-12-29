class Scrape < ApplicationRecord
	include Discard::Model
	# after_update :trigger_scrape_progress
	validates :name, uniqueness: { case_sensitive: false, message: "Scrape name must be unique" }

  has_many :scrape_entries, dependent: :destroy
	has_many :scrape_histories, dependent: :destroy

  # enum :status, { scheduled: 0, inprogress: 1, completed: 2, canceled: 3, terminated: 4 }, scopes: true
  enum :frequency, { daily: 0, daily2: 1, daily3: 2, daily4: 3, weekly: 4, monthly: 5}

  default_scope { order(scheduled_at: :desc) }

  def next_run_timestamp
    Time.now + hours_for(self.frequency).hours
  end

	def status
		self.scrape_histories.first ? self.scrape_histories.first.status : nil
	end

	def links
		self.scrape_entries.map {|se| se.link }
	end

  private

  def hours_for(frequency)
    case frequency
  
      when "daily"  
        24
        
      when "daily2"  
        12
        
      when "daily3"  
        8
        
      when "daily4"  
        6

      when "weekly"  
        168

      when "monthly"  
        720
        
      else  
        0

      end 
  end

end

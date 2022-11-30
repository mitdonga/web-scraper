class Scrape < ApplicationRecord
	after_update :trigger_scrape_progress

  has_many :scrape_entries, dependent: :destroy

  enum :status, { scheduled: 0, inprogress: 1, completed: 2, canceled: 3, terminated: 4 }, scopes: true
  enum :frequency, { daily: 0, daily2: 1, daily3: 2, daily4: 3, weekly: 4, monthly: 5}

  default_scope { order(scheduled_at: :desc) }

  def cancel
    self.status = 'canceled'
    self.save
    scrape_entries.update_all(status: 'canceled')
  end

  def schedule_next
    next_scrape_scheduled = Scrape.find_by(name: self.name, scheduled_at: self.next_run_timestamp)
    if next_scrape_scheduled
      return next_scrape_scheduled
    else
      return self.dup
    end
  end

  def next_run_timestamp(from_now=false)
    (from_now ? Time.now : self.scheduled_at) + hours_for(self.frequency).hours
  end

	def trigger_scrape_progress
		SprapeSchema.subscriptions.trigger(:scrape_progress, {}, {scrape: self})
	end

  private

  def initialize_dup(original_scrape)
    super
    self.scheduled_at = original_scrape.next_run_timestamp(true)
    self.started_at = nil
    self.ended_at = nil
    self.status = "scheduled"
    self.retries = 0
    self.save
    original_scrape.scrape_entries.each do |entry|
      new_entry = entry.dup
      self.scrape_entries << new_entry
    end
  end

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

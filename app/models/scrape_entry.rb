class ScrapeEntry < ApplicationRecord
  belongs_to :scrape
  belongs_to :link
	has_many :scrape_entry_histories, dependent: :destroy

  # enum :status, { scheduled: 0, inprogress: 1, completed: 2, canceled: 3, terminated: 4 }, scopes: true

  # def initialize_dup(original_scrape_entry)
  #   super
  #   self.status = "scheduled"
  #   self.raw_hash = nil
  #   self.retries = 0
  #   self.scrape_id = nil
  # end

  def cancel
    self.status = 'canceled'
    self.save
		SprapeSchema.subscriptions.trigger(:scrape_progress, {}, {scrape_history: self})
  end
end

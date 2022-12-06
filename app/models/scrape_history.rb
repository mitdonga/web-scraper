class ScrapeHistory < ApplicationRecord
	belongs_to :scrape
	has_many :scrape_entry_histories, dependent: :destroy

  enum :status, { scheduled: 0, inprogress: 1, completed: 2, canceled: 3, terminated: 4 }, scopes: true
  default_scope { order(created_at: :desc) }

	def cancel
    self.status = 'canceled'
    self.save
    self.scrape_entry_histories.where(status: 'inprogress').update_all(status: 'canceled')
  end
	
end

class ScrapeEntryHistory < ApplicationRecord
	belongs_to :scrape_history
	belongs_to :scrape_entry

  enum :status, { scheduled: 0, inprogress: 1, completed: 2, canceled: 3, terminated: 4 }, scopes: true
  default_scope { order(created_at: :desc) }

end

class ScrapeEntry < ApplicationRecord
  belongs_to :scrape
  belongs_to :link

  enum :status, { scheduled: 0, inprogress: 1, completed: 2, canceled: 3, terminated: 4 }, scopes: true

  def cancel
    self.status = 'canceled'
    self.save
  end
end

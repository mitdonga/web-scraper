class Scrape < ApplicationRecord
  has_many :scrape_entries, dependent: :destroy

  enum :status, { scheduled: 0, inprogress: 1, completed: 2, canceled: 3, terminated: 4 }, scopes: true

  default_scope { order(scheduled_at: :desc) }

  def cancel
    self.status = 'canceled'
    self.save
    scrape_entries.update_all(status: 'canceled')
  end
end

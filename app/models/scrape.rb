class Scrape < ApplicationRecord
  has_many :scrape_entries, dependent: :destroy

  enum :status, { scheduled: 0, inprogress: 1, completed: 2, canceled: 3, terminated: 4 }, scopes: true
  enum :frequency, { daily: 0, daily2: 1, daily3: 2, daily4: 3, weekly: 4, monthly: 5}

  default_scope { order(scheduled_at: :desc) }

  def cancel
    self.status = 'canceled'
    self.save
    scrape_entries.update_all(status: 'canceled')
  end
end

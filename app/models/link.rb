class Link < ApplicationRecord
  include Discard::Model
  belongs_to :city
  belongs_to :algo

  has_many :scrape_entries, dependent: :destroy

  after_discard do
    scrape_entries.cancel
  end
end

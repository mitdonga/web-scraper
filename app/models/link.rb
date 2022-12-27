class Link < ApplicationRecord
  include Discard::Model

	validates_with Validations::LinkValidator, fields: [:url, :units_url]

  belongs_to :city
  has_many :scrape_entries, dependent: :destroy

  # after_discard do
  #   scrape_entries.update_all(status: 'canceled')
  # end
end

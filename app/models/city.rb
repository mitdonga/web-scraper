class City < ApplicationRecord
  has_many :links, dependent: :destroy
end

class Algo < ApplicationRecord
  has_many :links, dependent: :destroy
end

class Product < ApplicationRecord
  has_many :requests

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :points_cost, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :available, -> { where(available: true) }
end
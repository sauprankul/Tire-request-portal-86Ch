class Points < ApplicationRecord
  belongs_to :user

  validates :available, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :pending, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :redeemed, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def total
    available + pending + redeemed
  end

  def add_available(amount)
    self.available += amount
    save
  end

  def add_pending(amount)
    self.pending += amount
    self.available -= amount
    save
  end

  def add_redeemed(amount)
    self.redeemed += amount
    self.pending -= amount
    save
  end

  def cancel_pending(amount)
    self.pending -= amount
    self.available += amount
    save
  end

  def tires_available
    available / 4
  end
end

class Request < ApplicationRecord
  belongs_to :user
  belongs_to :product
  belongs_to :representative, class_name: 'User', foreign_key: 'assigned_rep_id', optional: true
  has_many :messages, dependent: :destroy

  # Define enum mappings for PostgreSQL enum types
  enum payment_type: {
    paypal: 'paypal',
    credit_card: 'credit_card',
    points: 'points'
  }, _prefix: true

  enum status: {
    submitted: 'SUBMITTED',
    awaiting_payment: 'AWAITING_PAYMENT',
    paid: 'PAID',
    shipped: 'SHIPPED',
    received: 'RECEIVED',
    backordered: 'BACKORDERED',
    canceled: 'CANCELED'
  }, _prefix: true

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :payment_type, presence: true
  validates :status, presence: true

  scope :unassigned, -> { where(assigned_rep_id: nil) }
  scope :by_status, ->(status) { where(status: status) }

  # Class methods for dashboard controller
  def self.find_by_user_id(user_id)
    where(user_id: user_id)
  end

  def self.find_by_representative_id(rep_id)
    where(assigned_rep_id: rep_id)
  end

  def self.find_unassigned
    unassigned
  end

  def self.find_by_status(status)
    by_status(status)
  end

  def assign_to_representative(rep_id)
    update(assigned_rep_id: rep_id)
  end

  def update_status(new_status)
    return false unless self.class.statuses.keys.include?(new_status.downcase)
    
    old_status = status
    
    # Handle points logic for status changes
    if payment_type == 'points' && user.participant?
      points = user.points
      
      if old_status == 'SUBMITTED' && new_status == 'CANCELED'
        # Return points to available if request is canceled
        points_needed = product.points_cost * quantity
        points.cancel_pending(points_needed)
      elsif old_status == 'PAID' && new_status == 'SHIPPED'
        # Move points from pending to redeemed when shipped
        points_needed = product.points_cost * quantity
        points.add_redeemed(points_needed)
      end
    end
    
    update(status: new_status)
  end

  def can_be_withdrawn?
    status == 'SUBMITTED'
  end

  def can_be_marked_paid?
    status == 'AWAITING_PAYMENT'
  end

  def can_be_marked_received?
    status == 'SHIPPED'
  end

  def total_cost
    if payment_type == 'points'
      product.points_cost * quantity
    else
      product.price * quantity
    end
  end
end

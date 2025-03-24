class User < ApplicationRecord
  has_one :points, dependent: :destroy
  has_many :requests, dependent: :destroy
  has_many :assigned_requests, class_name: 'Request', foreign_key: 'assigned_rep_id'
  has_many :messages

  validates :email, presence: true, uniqueness: true
  validates :uid, presence: true, uniqueness: true
  validates :display_name, presence: true
  
  # Define enum mappings for PostgreSQL enum types
  enum role: {
    participant: 'participant',
    representative: 'representative',
    admin: 'admin'
  }, _prefix: true
  
  enum status: {
    pending: 'pending',
    approved: 'approved',
    rejected: 'rejected'
  }, _prefix: true

  # Class methods
  def self.find_by_uid(uid)
    find_by(uid: uid)
  end

  # Convenience methods
  def admin?
    role == 'admin'
  end

  def representative?
    role == 'representative'
  end

  def participant?
    role == 'participant'
  end

  def approved?
    status == 'approved'
  end

  def pending?
    status == 'pending'
  end

  def rejected?
    status == 'rejected'
  end
end

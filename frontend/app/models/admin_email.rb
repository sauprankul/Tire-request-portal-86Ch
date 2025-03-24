class AdminEmail < ApplicationRecord
  validates :email, presence: true, uniqueness: true
end

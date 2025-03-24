class Message < ApplicationRecord
  belongs_to :request
  belongs_to :user

  validates :content, presence: true

  scope :ordered, -> { order(created_at: :asc) }

  after_create :notify_other_party

  private

  def notify_other_party
    # This would be implemented to send an email notification
    # In a real application, this would use ActionMailer or a background job
    # For now, we'll just log the notification
    Rails.logger.info("Message notification: New message from #{user.display_name} on request #{request_id}")
  end
end

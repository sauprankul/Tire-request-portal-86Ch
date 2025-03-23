module UsersHelper
  # Returns the appropriate Bootstrap badge class based on user role
  def user_role_badge_class(role)
    case role.to_s.downcase
    when 'participant'
      'bg-primary'
    when 'representative'
      'bg-info'
    when 'admin'
      'bg-dark'
    else
      'bg-secondary'
    end
  end

  # Returns the appropriate icon class for user role
  def user_role_icon(role)
    case role.to_s.downcase
    when 'participant'
      'fa-user-circle'
    when 'representative'
      'fa-user-tie'
    when 'admin'
      'fa-user-shield'
    else
      'fa-user'
    end
  end

  # Returns the appropriate Bootstrap badge class based on approval status
  def approval_status_badge_class(approved)
    approved ? 'bg-success' : 'bg-warning text-dark'
  end

  # Returns the appropriate text for approval status
  def approval_status_text(approved)
    approved ? 'Approved' : 'Pending Approval'
  end

  # Returns the appropriate icon for approval status
  def approval_status_icon(approved)
    approved ? 'fa-check-circle' : 'fa-clock'
  end

  # Formats the user's last activity date
  def format_last_activity(date)
    return 'Never' unless date
    
    if date.today?
      "Today at #{date.strftime('%I:%M %p')}"
    elsif date.yesterday?
      "Yesterday at #{date.strftime('%I:%M %p')}"
    elsif date > 7.days.ago
      date.strftime('%A at %I:%M %p')
    else
      date.strftime('%b %d, %Y')
    end
  end

  # Returns the appropriate CSS class for activity status
  def activity_status_class(date)
    return 'text-muted' unless date
    
    if date > 1.hour.ago
      'text-success'
    elsif date > 24.hours.ago
      'text-primary'
    elsif date > 7.days.ago
      'text-warning'
    else
      'text-danger'
    end
  end

  # Returns the appropriate icon for activity status
  def activity_status_icon(date)
    return 'fa-question-circle' unless date
    
    if date > 1.hour.ago
      'fa-circle'
    elsif date > 24.hours.ago
      'fa-circle'
    elsif date > 7.days.ago
      'fa-circle'
    else
      'fa-circle'
    end
  end

  # Returns a tooltip text for activity status
  def activity_status_tooltip(date)
    return 'No activity recorded' unless date
    
    if date > 1.hour.ago
      "Active within the last hour"
    elsif date > 24.hours.ago
      "Active today"
    elsif date > 7.days.ago
      "Active this week"
    else
      "Last active on #{date.strftime('%b %d, %Y')}"
    end
  end

  # Returns the appropriate text for user status
  def user_status_text(active)
    active ? 'Active' : 'Inactive'
  end

  # Returns the appropriate Bootstrap badge class for user status
  def user_status_badge_class(active)
    active ? 'bg-success' : 'bg-danger'
  end

  # Returns the appropriate icon for user status
  def user_status_icon(active)
    active ? 'fa-check-circle' : 'fa-times-circle'
  end

  # Returns the display name for a user, falling back to email if name not available
  def user_display_name(user)
    return 'Unknown User' unless user
    
    if user.first_name.present? && user.last_name.present?
      "#{user.first_name} #{user.last_name}"
    elsif user.first_name.present?
      user.first_name
    else
      user.email.split('@').first
    end
  end
end

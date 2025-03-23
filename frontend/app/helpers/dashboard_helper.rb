module DashboardHelper
  # Returns the appropriate Bootstrap card class based on request count
  def request_count_card_class(count)
    if count == 0
      'border-success'
    elsif count < 5
      'border-warning'
    else
      'border-danger'
    end
  end

  # Returns the appropriate Bootstrap text class based on request count
  def request_count_text_class(count)
    if count == 0
      'text-success'
    elsif count < 5
      'text-warning'
    else
      'text-danger'
    end
  end

  # Returns the appropriate icon for dashboard stats
  def dashboard_stat_icon(stat_type)
    case stat_type.to_s.downcase
    when 'users'
      'fa-users'
    when 'participants'
      'fa-user-circle'
    when 'representatives'
      'fa-user-tie'
    when 'admins'
      'fa-user-shield'
    when 'pending_approval'
      'fa-user-clock'
    when 'requests'
      'fa-file-alt'
    when 'unassigned'
      'fa-inbox'
    when 'assigned'
      'fa-tasks'
    when 'completed'
      'fa-check-circle'
    when 'points'
      'fa-star'
    when 'available_points'
      'fa-coins'
    when 'redeemed_points'
      'fa-exchange-alt'
    when 'products'
      'fa-boxes'
    when 'low_stock'
      'fa-exclamation-triangle'
    when 'out_of_stock'
      'fa-ban'
    else
      'fa-chart-bar'
    end
  end

  # Returns the appropriate Bootstrap background class for dashboard stats
  def dashboard_stat_bg_class(stat_type)
    case stat_type.to_s.downcase
    when 'users', 'participants'
      'bg-primary'
    when 'representatives'
      'bg-info'
    when 'admins'
      'bg-dark'
    when 'pending_approval'
      'bg-warning'
    when 'requests', 'unassigned'
      'bg-secondary'
    when 'assigned'
      'bg-info'
    when 'completed'
      'bg-success'
    when 'points', 'available_points'
      'bg-warning'
    when 'redeemed_points'
      'bg-primary'
    when 'products'
      'bg-success'
    when 'low_stock'
      'bg-warning'
    when 'out_of_stock'
      'bg-danger'
    else
      'bg-light'
    end
  end

  # Returns the appropriate Bootstrap text class for dashboard stats
  def dashboard_stat_text_class(stat_type)
    case stat_type.to_s.downcase
    when 'users', 'participants', 'representatives', 'admins', 
         'requests', 'unassigned', 'assigned', 'completed',
         'redeemed_points', 'products'
      'text-white'
    when 'pending_approval', 'points', 'available_points', 'low_stock'
      'text-dark'
    when 'out_of_stock'
      'text-white'
    else
      'text-dark'
    end
  end

  # Formats a date for dashboard display
  def format_dashboard_date(date)
    return 'N/A' unless date
    
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

  # Returns the appropriate CSS class for activity indicator
  def activity_indicator_class(date)
    return 'activity-none' unless date
    
    if date > 1.hour.ago
      'activity-high'
    elsif date > 24.hours.ago
      'activity-medium'
    elsif date > 7.days.ago
      'activity-low'
    else
      'activity-none'
    end
  end

  # Returns a tooltip text for activity indicator
  def activity_indicator_tooltip(date)
    return 'No activity' unless date
    
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

  # Calculates the percentage for a dashboard progress bar
  def dashboard_progress_percentage(current, total)
    return 0 if total.to_i <= 0
    percentage = (current.to_f / total.to_f) * 100
    [percentage, 100].min # Cap at 100%
  end
end

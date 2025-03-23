module PointsHelper
  # Calculates the number of tires available based on points
  def tires_available(points)
    (points / 4).floor
  end

  # Returns the appropriate Bootstrap badge class based on points transaction type
  def points_transaction_badge_class(transaction_type)
    case transaction_type
    when 'add'
      'bg-success'
    when 'redeem'
      'bg-warning text-dark'
    when 'reserve'
      'bg-info'
    when 'release'
      'bg-secondary'
    else
      'bg-secondary'
    end
  end

  # Formats points amount with appropriate styling and sign
  def format_points_amount(transaction_type, amount)
    case transaction_type
    when 'add', 'release'
      content_tag(:span, "+#{amount}", class: 'text-success')
    when 'redeem', 'reserve'
      content_tag(:span, "-#{amount}", class: 'text-danger')
    else
      content_tag(:span, amount.to_s)
    end
  end

  # Calculates the percentage of points progress toward a goal
  def points_progress_percentage(current_points, goal_points)
    return 0 if goal_points <= 0
    percentage = (current_points.to_f / goal_points) * 100
    [percentage, 100].min # Cap at 100%
  end

  # Returns the appropriate progress bar class based on points progress
  def points_progress_class(current_points, goal_points)
    percentage = points_progress_percentage(current_points, goal_points)
    
    if percentage >= 100
      'bg-success'
    elsif percentage >= 75
      'bg-info'
    elsif percentage >= 50
      'bg-primary'
    elsif percentage >= 25
      'bg-warning'
    else
      'bg-danger'
    end
  end
end

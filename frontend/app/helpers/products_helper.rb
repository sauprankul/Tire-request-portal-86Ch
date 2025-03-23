module ProductsHelper
  # Returns the appropriate Bootstrap badge class based on product availability
  def product_availability_badge_class(availability)
    case availability
    when 'in_stock'
      'bg-success'
    when 'low_stock'
      'bg-warning text-dark'
    when 'out_of_stock'
      'bg-danger'
    when 'discontinued'
      'bg-secondary'
    else
      'bg-secondary'
    end
  end

  # Returns the appropriate Bootstrap progress bar class based on stock level
  def product_stock_progress_class(stock_level, low_stock_threshold)
    if stock_level <= 0
      'bg-danger'
    elsif stock_level < low_stock_threshold
      'bg-warning'
    else
      'bg-success'
    end
  end

  # Calculates the percentage for stock level visualization
  def product_stock_percentage(stock_level, max_stock)
    return 0 if max_stock <= 0
    percentage = (stock_level.to_f / max_stock) * 100
    [percentage, 100].min # Cap at 100%
  end
end

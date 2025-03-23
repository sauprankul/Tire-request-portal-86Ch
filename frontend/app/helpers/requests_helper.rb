module RequestsHelper
  # Returns the appropriate Bootstrap badge class based on request status
  def request_status_badge_class(status)
    case status.to_s.downcase
    when 'submitted'
      'bg-secondary'
    when 'awaiting_payment'
      'bg-warning text-dark'
    when 'paid'
      'bg-info'
    when 'shipped'
      'bg-primary'
    when 'received'
      'bg-success'
    when 'backordered'
      'bg-danger'
    when 'canceled'
      'bg-danger'
    else
      'bg-secondary'
    end
  end

  # Returns the appropriate icon class for request status
  def request_status_icon(status)
    case status.to_s.downcase
    when 'submitted'
      'fa-file-alt'
    when 'awaiting_payment'
      'fa-credit-card'
    when 'paid'
      'fa-check-circle'
    when 'shipped'
      'fa-shipping-fast'
    when 'received'
      'fa-box-open'
    when 'backordered'
      'fa-exclamation-triangle'
    when 'canceled'
      'fa-ban'
    else
      'fa-question-circle'
    end
  end

  # Returns the appropriate Bootstrap badge class based on payment type
  def payment_type_badge_class(payment_type)
    case payment_type.to_s.downcase
    when 'points'
      'bg-primary'
    when 'cash'
      'bg-success'
    when 'credit_card'
      'bg-info'
    else
      'bg-secondary'
    end
  end

  # Returns the appropriate icon class for payment type
  def payment_type_icon(payment_type)
    case payment_type.to_s.downcase
    when 'points'
      'fa-star'
    when 'cash'
      'fa-money-bill-wave'
    when 'credit_card'
      'fa-credit-card'
    else
      'fa-question-circle'
    end
  end

  # Formats the shipping address for display
  def format_shipping_address(request)
    address = []
    address << request.shipping_name if request.shipping_name.present?
    address << request.shipping_address_line1 if request.shipping_address_line1.present?
    address << request.shipping_address_line2 if request.shipping_address_line2.present?
    address << "#{request.shipping_city}, #{request.shipping_state} #{request.shipping_zip}" if request.shipping_city.present?
    address << request.shipping_country if request.shipping_country.present?
    
    address.join('<br>').html_safe
  end

  # Determines if a request can be edited based on its status
  def request_editable?(status)
    ['submitted', 'awaiting_payment'].include?(status.to_s.downcase)
  end

  # Determines if a request can be canceled based on its status
  def request_cancelable?(status)
    ['submitted', 'awaiting_payment', 'paid', 'backordered'].include?(status.to_s.downcase)
  end

  # Returns the appropriate progress value for the request timeline
  def request_timeline_progress(status)
    case status.to_s.downcase
    when 'submitted'
      0
    when 'awaiting_payment'
      20
    when 'paid'
      40
    when 'shipped'
      60
    when 'received'
      100
    when 'backordered'
      30
    when 'canceled'
      100
    else
      0
    end
  end

  # Returns the appropriate CSS class for the timeline step
  def timeline_step_class(step_status, current_status)
    statuses = ['submitted', 'awaiting_payment', 'paid', 'shipped', 'received']
    
    current_index = statuses.index(current_status.to_s.downcase)
    step_index = statuses.index(step_status.to_s.downcase)
    
    return 'timeline-step-canceled' if current_status.to_s.downcase == 'canceled'
    return 'timeline-step-backordered' if current_status.to_s.downcase == 'backordered' && step_index > 2
    
    if step_index.nil? || current_index.nil?
      'timeline-step-pending'
    elsif step_index < current_index
      'timeline-step-complete'
    elsif step_index == current_index
      'timeline-step-current'
    else
      'timeline-step-pending'
    end
  end
end

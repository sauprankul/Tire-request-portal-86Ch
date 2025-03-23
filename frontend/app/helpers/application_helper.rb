module ApplicationHelper
  # Returns the full title for a page
  def full_title(page_title = '')
    base_title = "Tire Request Portal"
    page_title.empty? ? base_title : "#{page_title} | #{base_title}"
  end

  # Generates a Bootstrap alert box
  def bootstrap_alert(message, type = "info")
    alert_class = case type.to_s
                  when "success" then "alert-success"
                  when "error", "danger" then "alert-danger"
                  when "warning" then "alert-warning"
                  else "alert-info"
                  end

    content_tag(:div, class: "alert #{alert_class} alert-dismissible fade show") do
      concat message
      concat content_tag(:button, '&times;'.html_safe, class: 'btn-close', 'data-bs-dismiss': 'alert', 'aria-label': 'Close')
    end
  end

  # Formats a date in a user-friendly way
  def format_date(date, format = :default)
    return '' unless date

    case format
    when :short
      date.strftime("%m/%d/%Y")
    when :long
      date.strftime("%B %d, %Y")
    when :with_time
      date.strftime("%B %d, %Y at %I:%M %p")
    when :time_only
      date.strftime("%I:%M %p")
    when :relative
      time_ago_in_words(date) + " ago"
    else
      date.strftime("%m/%d/%Y")
    end
  end

  # Creates a back button with customizable text and path
  def back_button(text = "Back", path = :back, options = {})
    default_options = { class: "btn btn-outline-secondary" }
    options = default_options.merge(options)
    
    link_to path, options do
      content_tag(:i, '', class: 'fas fa-arrow-left me-1') + text
    end
  end

  # Generates a Bootstrap badge with appropriate styling
  def status_badge(text, type = "primary")
    badge_class = case type.to_s
                  when "success" then "bg-success"
                  when "danger", "error" then "bg-danger"
                  when "warning" then "bg-warning text-dark"
                  when "info" then "bg-info text-dark"
                  when "secondary" then "bg-secondary"
                  when "dark" then "bg-dark"
                  when "light" then "bg-light text-dark"
                  else "bg-primary"
                  end

    content_tag(:span, text, class: "badge #{badge_class}")
  end

  # Checks if the current user has a specific role
  def user_has_role?(role)
    current_user && current_user.role.to_s.downcase == role.to_s.downcase
  end

  # Shorthand methods for role checking
  def admin?
    user_has_role?('admin')
  end

  def representative?
    user_has_role?('representative')
  end

  def participant?
    user_has_role?('participant')
  end

  # Generates pagination links with Bootstrap styling
  def bootstrap_paginate(collection)
    will_paginate collection, 
      renderer: WillPaginate::ActionView::Bootstrap4LinkRenderer,
      class: 'pagination justify-content-center',
      previous_label: '&laquo;',
      next_label: '&raquo;'
  end

  # Creates a card with standardized styling
  def bootstrap_card(title = nil, options = {}, &block)
    default_options = { 
      class: "card shadow-sm mb-4",
      header_class: "card-header bg-light",
      body_class: "card-body"
    }
    options = default_options.merge(options)

    content_tag(:div, class: options[:class]) do
      output = ""
      if title.present?
        output += content_tag(:div, class: options[:header_class]) do
          content_tag(:h5, title, class: "mb-0")
        end
      end
      output += content_tag(:div, class: options[:body_class], &block)
      output.html_safe
    end
  end

  # Formats a currency amount
  def format_currency(amount)
    number_to_currency(amount, precision: 2)
  end

  # Formats a large number with commas
  def format_number(number)
    number_with_delimiter(number)
  end

  # Generates a confirmation dialog for dangerous actions
  def confirmation_dialog(message = "Are you sure?", options = {})
    {
      data: {
        confirm: message,
        confirm_title: options[:title] || "Confirmation Required",
        confirm_btn_text: options[:confirm_text] || "Yes",
        cancel_btn_text: options[:cancel_text] || "No"
      }
    }
  end

  # Generates a tooltip
  def tooltip(text)
    { data: { bs_toggle: "tooltip", bs_placement: "top" }, title: text }
  end
end

module ApplicationHelper
  ["categories", "transactions", "pricing_plans"].each do |page|
    define_method("#{page}_active?") do
      [page.to_sym].include?(controller_name.to_sym)
    end
  end

  def show_devise_links ()
    links = []

    if controller_name != 'sessions'
      links << [ "Log in", new_session_path(resource_name) ]
    end
    if devise_mapping.recoverable? && controller_name != 'passwords' && controller_name != 'registrations'
      links <<  [ "Forgot your password?", new_password_path(resource_name) ]
    end
    if controller_name != 'registrations'
      links << [ "Register now", new_registration_path(resource_name) ]
    end
    if devise_mapping.confirmable? && controller_name != 'confirmations'
      links << [ "Didn't receive confirmation instructions?", new_confirmation_path(resource_name) ]
    end

    raw links.collect { |l| link_to l.first, l.last }.join(" | ")
  end

  def body_attributes
    { class: body_class, id: body_id }
  end

  def body_class
    [controller.controller_name.dasherize]
  end

  def body_id
    "#{controller.controller_name.dasherize}-#{controller.action_name.dasherize}"
  end
end

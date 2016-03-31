class Users::RegistrationsController < Devise::RegistrationsController
  before_filter :configure_sign_up_params, only: [:create]
  before_filter :configure_account_update_params, only: [:update]
  before_filter :build_photo, only: [:edit]
  layout 'devise', only: [:new, :create]
  layout 'application', only: [:edit, :update, :destroy]

  def edit
    super
  end

  protected
  def build_photo
    current_user.build_photo if current_user.photo.blank?
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.for(:sign_up) << [:first_name, :last_name]
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.for(:account_update) << [:first_name, :last_name, :time_zone, :stripe_id, photo_attributes: [:file, :remote_file_url]]
  end

  def update_resource(resource, params)
    resource.update_without_password(params)
  end
end

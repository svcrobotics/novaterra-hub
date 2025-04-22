class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters, if: :devise_controller?

  private

  def sign_up_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation, :langue, :niveau)
  end

  def account_update_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation, :current_password, :langue, :niveau)
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :username, :langue, :niveau ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :username, :langue, :niveau ])
  end

  # Permettre de mettre à jour le profil sans exiger le mot de passe sauf si celui-ci est modifié
  def update_resource(resource, params)
    if params[:password].present? || params[:password_confirmation].present?
      super
    else
      resource.update_without_password(params.except(:current_password))
    end
  end

  def after_update_path_for(resource)
    dashboard_home_path
  end
end

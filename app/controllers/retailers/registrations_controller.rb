class Retailers::RegistrationsController < Devise::RegistrationsController
  protected
  def after_sign_up_path_for(resource)
    edit_retailers_profile_path
  end
end

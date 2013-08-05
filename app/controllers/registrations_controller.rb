class RegistrationsController < Devise::RegistrationsController
  protected

  def after_inactive_sign_up_path_for(resource)
    signed_up_path
  end

  def create
    logger.debug "DEBUG - CREATE WebApollo user here!"
  end
end
class RegistrationsController < Devise::RegistrationsController

	def create
	logger.debug "DEBUG - HELLO WORLD"
	super
	end

  protected

  def after_inactive_sign_up_path_for(resource)
    signed_up_path
  end

end
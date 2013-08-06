class RegistrationsController < Devise::RegistrationsController
  protected

	def new
		logger.debug "DEBUG - HELLO WORLD"
      super
    end

  def after_inactive_sign_up_path_for(resource)
    signed_up_path
  end

end
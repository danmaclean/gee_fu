class RegistrationsController < Devise::RegistrationsController
  

	def create
		user = params[:user]
		logger.error "Hello #{user}"
		user
		super
  	end

	protected

  	def after_inactive_sign_up_path_for(resource)
    	signed_up_path
  	end

end
class RegistrationsController < Devise::RegistrationsController
  

	def create
		email = params[:user][:email]
		password = params[:user][:password]
		logger.error "Hello #{email} #{password}"
		user
		super
  	end

	protected

  	def after_inactive_sign_up_path_for(resource)
    	signed_up_path
  	end

end
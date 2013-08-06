class RegistrationsController < Devise::RegistrationsController
  

	def create
		email = params[:user][:email]
		password = params[:user][:password]
		logger.error "Hello #{email} #{password}"
		waUserAdded = system('sudo su postgres; createuser #{email} --createdb --no-superuser --no-createrole')
		waUserAddedTwo = system('#{WebApolloPath}/tools/user/add_user.pl -D #{WebApolloDatabase} -U #{WebApolloDatabaseUsername} -P #{WebApolloDatabasePassword} -u #{email} -p #{password}')
		if(waUserAdded)
			logger.error "{email} user added to database"
		end
		if(waUserAddedTwo)
			logger.error "{email} user added to WebApollo"
		end
		super
  	end

	protected

  	def after_inactive_sign_up_path_for(resource)
    	signed_up_path
  	end

end
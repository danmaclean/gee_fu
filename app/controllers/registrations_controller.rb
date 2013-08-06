class RegistrationsController < Devise::RegistrationsController
  

	def create
		email = params[:user][:email]
		password = params[:user][:password]
		logger.error "Hello #{email} #{password}"
		WAUserAdded = `sudo su postgres; createuser #{email} --createdb --no-superuser --no-createrole`
		WAUserAddedTwo = `#{WebApolloPath}/tools/user/add_user.pl -D #{WebApolloDatabase} -U #{WebApolloDatabaseUsername} -P #{WebApolloDatabasePassword} -u #{email} -p #{password}`
		# if(WAUserAdded)
			logger.error "{email} user added to database. #{WAUserAdded}"
		# end
		# if(WAUserAddedTwo)
			logger.error "{email} user added to WebApollo. #{WAUserAddedTwo}"
		end
		super
  	end

	protected

  	def after_inactive_sign_up_path_for(resource)
    	signed_up_path
  	end

end
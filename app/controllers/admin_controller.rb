class AdminController < ApplicationController
  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      # Handle a successful update.
      @user.save
      redirect_to action: 'index'
      #    else
      #      render 'edit'
      
      value = params[:user][:admin]
      email = params[:user][:email]
        
      logger.error "value #{value} email #{email}"
        
      if(value > 0)
            boolval = '-a'
          else
            boolval = '-r -w'  
          end
      
          `#{WebApolloPath}/tools/user/set_track_permissions.pl -D #{WebApolloDatabase} -U #{WebApolloDatabaseUsername} -P #{WebApolloDatabasePassword} #{boolval} -u #{email} -t #{WebApolloPath}/data/scratch/seqids.txt  > /dev/null`
    end
  end
end
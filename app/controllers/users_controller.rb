class UsersController < ApplicationController
  def show
#    @user = User.find(params[:id])
    @users = User.all
  end
end
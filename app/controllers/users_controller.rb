class UsersController < ApplicationController
  def show
#    @user = User.find(params[:id])
    @user = User.all
  end
end
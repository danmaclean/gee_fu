class AdminController < ApplicationController
  def index
    @users = User.all
  end

  def edit
    user = User.find(params[:user_id])
  end
end
class AdminController < ApplicationController
  def index
    @users = User.all
  end

  def edit
    @project = User.find(params[:user_id])
  end
end
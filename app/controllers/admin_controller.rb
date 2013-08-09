class AdminController < ApplicationController
  def index
    @users = User.all
  end

  def edit
    @project = Project.find(params[:user_id])
  end
end
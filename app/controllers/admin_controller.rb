class AdminController < ApplicationController
  def show
    @users = User.all
  end

  def edit

  end
end
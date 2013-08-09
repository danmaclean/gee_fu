class UsersController < ApplicationController
  def show
    @users = User.all
  end

  def edit

  end
end
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
    @user.merge(params[:user])
    if @user.valid?
      @user.save
      # Handle a successful update.
      render 'index'
    else
      render 'edit'
    end
  end
end
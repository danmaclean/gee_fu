class UsersController < ApplicationController
    def show
      @users = User.all
    end
  end
class PagesController < ApplicationController
  def index
#  	flash[:notice] = "Hello World!."
    template = user_signed_in? ? :signed_in : :index
    render template
  end

  def signed_up
  end

  def browse
    render layout: false
  end
end
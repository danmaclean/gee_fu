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

  def getcard
  	url = "http://127.0.0.1:3000"
  	Badge.getCard(url, params[:email], params[:badge])
  end

  def getbadge
  	url = "http://127.0.0.1:3000"
	Badge.getBadge(url, params[:badge])
  end

end
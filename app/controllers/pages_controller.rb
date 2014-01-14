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
  	@card = Badge.getCard(url, params[:email], params[:badge])
  	render json: @card
  end

  def getbadge
  	url = "http://127.0.0.1:3000"
	@badge = Badge.getBadge(url, params[:badge])
	render json: @badge
  end

end
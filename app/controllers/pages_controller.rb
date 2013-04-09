class PagesController < ApplicationController
  def index
  end

  def browse
    render layout: false
  end
end
class ApplicationController < ActionController::Base
  protect_from_forgery

  helper :all # include all helpers, all the time
  
  def respond(response)
    respond_to do |format|
      format.html
      format.json { render :json => response, :layout => false }
      format.xml  { render :xml => response, :layout => false }
    end
  end

  def after_sign_in_path_for(resource)
    root_path
  end

  def has_organisms?
    Organism.count > 0
  end
  helper_method :has_organisms?
end
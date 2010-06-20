class ReferencesController < ApplicationController
  
  def index #regular web request
    @references = Reference.all
    
    respond_to do |format|
      format.json { render :json => @references, :layout => false }
      format.xml  { render :xml => @references, :layout => false }
    end
  end
  
  def show #regular web request for individual reference set slightly different in that it returns not by reference id, but by the
            #id of the genome the reference belongs to ... 
    @references = Reference.find(:all, :conditions => {:genome_id => params[:id]} )
    
    respond_to do |format|
      format.json { render :json => @references, :layout => false }
      format.xml  { render :xml => @references, :layout => false }
    end
    
  end
  
end

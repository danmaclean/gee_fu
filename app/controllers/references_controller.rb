#Implements the REST interface for returning the references that belong to a Genome
class ReferencesController < ApplicationController
  
  #returns the list of references and associated data in the database
  # use /references.format?params
  # where format = xml or json
  def index #regular web request
    @references = Reference.all
    respond @references
  end
  
  #returns the list of references belonging to Genome id and associated data in the database
  # use /references/id.format?params
  # where format = xml or json
  # optional params: 
  # => name (some_reference_name) returns the reference with name
  def show  
    #result = Hash.new {|h,k| h[k]={}}
    if params[:name]
      if Genome.exists?(params[:id])
        @reference = Reference.find(:first, :conditions => {:genome_id => params[:id], :name => params[:name] } )
        if @reference
          respond @reference
        else
          respond nil
        end
      end
    else  
      if Genome.exists?(params[:id])
        @references = Reference.find(:all, :conditions => {:genome_id => params[:id]} )
        respond @references
      else
        respond :false
      end
    end
    
    
  end
  
  def respond(response)
    respond_to do |format|
      format.json { render :json => response, :layout => false }
      format.xml  { render :xml => response, :layout => false }
    end
  end
  
end

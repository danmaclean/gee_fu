#Implements the REST interface for returning the references that belong to a Genome
class ReferencesController < ApplicationController
  
  #returns the list of references and associated data in the database
  # use /references.format?params
  # where format = xml or json
  # optional params: 
  # => sequence, (true or false) returns sequence of the reference in the response
  def index #regular web request
    @references = Reference.all
    result = Hash.new {|h,k| h[k]={}}
    @references.each do |ref|
      result['ref-' + "#{ref.id}"]["name"] = "#{ref.name}"
      result['ref-' + "#{ref.id}"]["length"] = "#{ref.length}"
      result['ref-' + "#{ref.id}"]["sequence"] = "#{ref.sequence.sequence}" if params[:sequence]
    end
    respond_to do |format|
      format.json { render :json => result, :layout => false }
      format.xml  { render :xml => result, :layout => false }
    end
  end
  
  #returns the list of references belonging to Genome id and associated data in the database
  # use /references/id.format?params
  # where format = xml or json
  # optional params: 
  # => sequence (true or false) returns sequence of the reference in the response
  # => name (some_reference_name) returns the sequence with name
  def show  
    result = Hash.new {|h,k| h[k]={}}
    if params[:name]
      if Genome.exists?(params[:id])
        @reference = Reference.find(:first, :conditions => {:genome_id => params[:id], :name => params[:name] } )
        if @reference
          result['ref-' + "#{@reference.id}"]["name"] = "#{@reference.name}"
          result['ref-' + "#{@reference.id}"]["length"] = "#{@reference.length}"
          result['ref-' + "#{@reference.id}"]["sequence"] = "#{@reference.sequence.sequence}" if params[:sequence]
        end
      end
    else  
      if Genome.exists?(params[:id])
        @references = Reference.find(:all, :conditions => {:genome_id => params[:id]} )
        @references.each do |ref|
          result['ref-' + "#{ref.id}"]["name"] = "#{ref.name}"
          result['ref-' + "#{ref.id}"]["length"] = "#{ref.length}"
          result['ref-' + "#{ref.id}"]["sequence"] = "#{ref.sequence.sequence}" if params[:sequence]
        end
      end
    end
    
    respond_to do |format|
      format.json { render :json => result, :layout => false }
      format.xml  { render :xml => result, :layout => false }
    end
    
  end
  
end

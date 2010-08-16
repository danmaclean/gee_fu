class OrganismsController < ApplicationController
  # GET /organisms
  # GET /organisms.xml
  def respond(response)
    respond_to do |format|
      format.html
      format.json { render :json => response, :layout => false }
      format.xml  { render :xml => response, :layout => false }
    end
  end


  def index
    @organisms = Organism.all
    respond @organisms
  end

  # GET /organisms/1
  # GET /organisms/1.xml
  def show
    @organism = Organism.find(params[:id])
    respond @organism
  end

  # GET /organisms/new
  # GET /organisms/new.xml
  def new
    @organism = Organism.new
    respond @organism
  end

  # GET /organisms/1/edit
  def edit
    @organism = Organism.find(params[:id])
  end

  # POST /organisms
  # POST /organisms.xml
  def create
    @organism = Organism.new(params[:organism])

    respond_to do |format|
      if @organism.save
        flash[:notice] = 'Organism was successfully created.'
        format.html { redirect_to(@organism) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /organisms/1
  # PUT /organisms/1.xml
  def update
    @organism = Organism.find(params[:id])

    respond_to do |format|
      if @organism.update_attributes(params[:organism])
        flash[:notice] = 'Organism was successfully updated.'
        format.html { redirect_to(@organism) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /organisms/1
  # DELETE /organisms/1.xml
  def destroy
    @organism = Organism.find(params[:id])
    @organism.destroy
    respond_to do |format|
      format.html { redirect_to(organisms_url) }
    end
  end
end

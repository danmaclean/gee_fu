#Implements the REST and AnnoJ requests for the Experiments table/model
# access via url
class ExperimentsController < ApplicationController
  
  #returns the list of experiments and associated meta-data in the database
  # use /experiments.format
  # where format = xml or json
  def index
    @experiments = Experiment.all
      @experiments.each do |exp|
        exp.meta = JSON::parse exp.meta if exp.meta
      end
      respond @experiments
  end
  
  #returns metadata for a selected experiment 
  # use /experiments/id.format
  # where format = xml or json
  def show 
    if Experiment.exists?(params[:id])
      @experiment = Experiment.find(params[:id])
      @experiment.meta = JSON::parse @experiment.meta if @experiment.meta
      respond @experiment
    else
      respond :false
    end
  end
  
  def new
    @experiment = Experiment.new
    #@genomes = Genome.all
    #respond @experiment
    respond_to do |format|
      format.html 
    end
  end

  def create
    require 'bio'
    @experiment = Experiment.new(params[:experiment])
    genome = Genome.find(@experiment.genome_id)
    
    #format the meta data string from a provided yaml file or get it from the parent genome
    if @experiment.yaml_file
      @experiment.meta = YAML::load_file(@experiment.yaml_file.path).to_json 
    else
      @experiment.meta = genome.meta
    end
    
    if @experiment.expected_file == "gff" and @experiment.gff_file
      File.open( "#{@experiment.gff_file.path}" ).each do |line|
        next if line =~ /^#/
        break if line =~ /^##fasta/ or line =~ /^>/
        record = Bio::GFF::GFF3::Record.new(line)

        #use only the first gff id as the linking one ... 
        gff_ids = record.attributes.select { |a| a.first == 'ID' }
        gff_id = nil
        gff_id = gff_ids[0][1] if ! gff_ids.empty?

        #get the sequence and quality if defined
        note = record.attributes.select{|a| a.first == 'Note'}
        seq = nil
        qual = nil

        if note
          note = note.flatten.last.to_s 
          note.match(/<sequence>(.*)<\/sequence>/)
          seq = $1
          note.match(/<quality>(.*)<\/quality>/)
          qual = $1
        end

       attribute = JSON.generate(record.attributes)

        ref = Reference.find(:first, :conditions => ["name = ? AND genome_id = ?", "#{ record.seqname }", "#{@experiment.genome_id}"])

        feature = Feature.new(
          :group => "#{attribute}",
          :feature => "#{record.feature}",
          :source => "#{record.source}",
          :start => "#{record.start}",
          :end => "#{record.end}", 
          :strand => "#{record.strand}",
          :phase => "#{record.frame}",
          :seqid => "#{record.seqname}",
          :score => "#{record.score}",
          #:experiment_id => "#{exp.id}",
          :gff_id =>  "#{gff_id}",
          :sequence => "#{seq}",
          :quality => "#{qual}",
          :reference_id => "#{ref.id}"
          )
    
    
          #### this bit isnt very rails-ish but I dont know a good rails way to do it... features are parents as well as 
          #### features so doesnt follow for auto update ... I think ... this works for now... although it is slow...
          ###sort out the Parents if any, but only connects up the parent via the first gff id
          if @experiment.find_parents
            parents = record.attributes.select { |a| a.first == 'Parent' }
            if !parents.empty?
              parents.each do |label, parentFeature_gff_id|
                parentFeats = Feature.find(:all, :conditions => ["gff_id = ?", "#{ parentFeature_gff_id }"] )
                if (parentFeats)
                  parentFeats.each do |pf|
                    parent = nil
                    parent = Parent.find(:first, :conditions => {:parent_feature => pf.id})
                    if parent
                      parent.save 
                    else
                      parent = Parent.new(:parent_feature => pf.id)
                      parent.save 
                    end
                    feature.parents << parent
                  end
                end
              end
            end
          end
          @experiment.features << feature
#      end
      end
    elsif @experiment.expected_file == "bam"
      @experiment.uses_bam_file = true
    end
      
      
    respond_to do |format|
      if @experiment.save
        flash[:notice] = "Experiment was successfully created."
        format.html { redirect_to(@experiment) }
     else
        format.html { render :action => "new" }
      end
    end

  end
  
  def edit
    @experiment = Experiment.find(params[:id])
  end
  
  def update
    require 'bio'
    genome = Genome.find(params[:experiment][:genome_id])
    @experiment = Experiment.find(params[:id])
 
    #setup the experiment attributes relevant only to form input 
    @experiment.yaml_file = params[:experiment][:yaml_file] 
    @experiment.gff_file = params[:experiment][:gff_file]
    @experiment.expected_file = params[:experiment][:expected_file]
    if params[:experiment][:find_parents] == "find_parents"
      @experiment.find_parents = true
    else
      @experiment.find_parents = false
    end
    @experiment.merge = params[:experiment][:merge]
    
    #format the meta data string from a provided yaml file or get it from the parent genome
    if @experiment.yaml_file
      @experiment.meta = YAML::load_file(params[:experiment][:yaml_file].path).to_json 
    end

    if @experiment.expected_file == "gff" and @experiment.gff_file
      
      load_gff(@experiment) #meh .. it works... 
      

    #elsif @experiment.expected_file == "bam"
      #@experiment.uses_bam_file = true
    end

    @experiment.gff_file = 'some_value_to_fake_out_the_validator' unless @experiment.gff_file
    
    respond_to do |format|
      if @experiment.update_attributes(params[:experiment])
        flash[:notice] = 'Experiment was successfully updated.'
        format.html { redirect_to(@experiment) }
      else
        format.html { render :action => "edit" }
      end
    end
  end
  
  def load_gff(experiment)
    
          #get rid of the old features from this experiment if needed...!
          unless experiment.merge == 'merge' #why doesnt this work if just left to true??
            experiment.features.delete_all
          end
          File.open( "#{experiment.gff_file.path}" ).each do |line|
            next if line =~ /^#/
            break if line =~ /^##fasta/ or line =~ /^>/
            record = Bio::GFF::GFF3::Record.new(line)

            #use only the first gff id as the linking one ... 
            gff_ids = record.attributes.select { |a| a.first == 'ID' }
            gff_id = nil
            gff_id = gff_ids[0][1] if ! gff_ids.empty?

            #get the sequence and quality if defined
            note = record.attributes.select{|a| a.first == 'Note'}
            seq = nil
            qual = nil

            if note
              note = note.flatten.last.to_s 
              note.match(/<sequence>(.*)<\/sequence>/)
              seq = $1
              note.match(/<quality>(.*)<\/quality>/)
              qual = $1
            end

           attribute = JSON.generate(record.attributes)

            ref = Reference.find(:first, :conditions => ["name = ? AND genome_id = ?", "#{ record.seqname }", "#{experiment.genome_id}"])

            feature = Feature.new(
              :group => "#{attribute}",
              :feature => "#{record.feature}",
              :source => "#{record.source}",
              :start => "#{record.start}",
              :end => "#{record.end}", 
              :strand => "#{record.strand}",
              :phase => "#{record.frame}",
              :seqid => "#{record.seqname}",
              :score => "#{record.score}",
              #:experiment_id => "#{exp.id}",
              :gff_id =>  "#{gff_id}",
              :sequence => "#{seq}",
              :quality => "#{qual}",
              :reference_id => "#{ref.id}"
              )


              #### this bit isnt very rails-ish but I dont know a good rails way to do it... features are parents as well as 
              #### features so doesnt follow for auto update ... I think ... this works for now... although it is slow...
              ###sort out the Parents if any, but only connects up the parent via the first gff id
              if experiment.find_parents
                parents = record.attributes.select { |a| a.first == 'Parent' }
                if !parents.empty?
                  parents.each do |label, parentFeature_gff_id|
                    parentFeats = Feature.find(:all, :conditions => ["gff_id = ?", "#{ parentFeature_gff_id }"] )
                    if (parentFeats)
                      parentFeats.each do |pf|
                        parent = nil
                        parent = Parent.find(:first, :conditions => {:parent_feature => pf.id})
                        if parent
                          parent.save 
                        else
                          parent = Parent.new(:parent_feature => pf.id)
                          parent.save 
                        end
                        feature.parents << parent
                      end
                    end
                  end
                end
              end
              experiment.features << feature
    #      end
          end
  end
  def destroy
    @experiment = Experiment.find(params[:id])
    @experiment.destroy
    respond_to do |format|
      format.html { redirect_to(experiments_url) }
    end
  end
  
end 

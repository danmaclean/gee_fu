#Implements the REST and AnnoJ requests for the Experiments table/model
# access via url
class ExperimentsController < ApplicationController


  #before_filter :authenticate_user!, :except => [:index, :show]

  #returns the list of experiments and associated meta-data in the database
  # use /experiments.format
  # where format = xml or json
  def index
    # Badge.give_badge
    @experiments = Experiment.all
    @experiments.each do |exp|
      #exp.meta = JSON::parse exp.meta if exp.meta
    end
    respond @experiments
  end

  #returns metadata for a selected experiment 
  # use /experiments/id.format
  # where format = xml or json
  def show
    if Experiment.exists?(params[:id])
      # featurelimit = 250
      # @types = Feature.where(experiment_id: params[:id]).limit(featurelimit).pluck(:feature).uniq
      logger.error "looking up exp: #{params[:id]}"
      @experiment = Experiment.find(params[:id])
      @seqs = @experiment.features.pluck(:seqid).uniq
      @firstseq = params[:segment]
      if @firstseq.nil?
        @firstseq = @seqs.first
      end
      #@experiment.meta = JSON::parse @experiment.meta if @experiment.meta
      respond @experiment
    else
      respond :false
    end
  end

  def new
    @experiment = Experiment.new
    respond_to do |format|
      format.html
    end
  end

  def create
    require 'bio'
    @experiment = Experiment.new(params[:experiment]) #TODO save experiment here?
    genome = Genome.find(params[:experiment][:genome_id])

    if genome.nil?
      logger.error "ERROR: There is no genome!"
    end

    #format the meta data string from a provided yaml file or get it from the parent genome
    if @experiment.yaml_file
      @experiment.meta = YAML::load_file(@experiment.yaml_file.path).to_json
    else
      @experiment.meta = genome.meta
    end

    if @experiment.expected_file == "gff" and @experiment.gff_file

      logger.debug "DEBUG: Going to pass #{@experiment.gff_file.path} to WebApollo as a GFF"

      filenamebase = @experiment.name.downcase.tr(" ", "_")

      typeText = ""

      if File.readlines(@experiment.gff_file.path).grep(/mRNA/).size > 0
        # do something
        logger.error "It is mRNA"
        cmdOne = `#{WebApolloAppPath}/jbrowse/bin/flatfile-to-json.pl --gff #{@experiment.gff_file.path} --getSubFeatures --trackLabel #{filenamebase} --type mRNA --out #{WebApolloAppPath}/jbrowse/data/`
      else
        logger.error "Its not mRNA"
        cmdOne = `#{WebApolloAppPath}/jbrowse/bin/flatfile-to-json.pl --gff #{@experiment.gff_file.path} --getSubFeatures --trackLabel #{filenamebase} --out #{WebApolloAppPath}/jbrowse/data/`
      end


      logger.error("output of command one: #{cmdOne}")

      #This task is becoming a hassle, the more experiments, the longer this takes
      cmdTwo = `#{WebApolloAppPath}/jbrowse/bin/generate-names.pl --out #{WebApolloAppPath}/jbrowse/data`

      #TODO return here? bg-job?

      File.open("#{@experiment.gff_file.path}").each do |line|
        next if line =~ /^#/
        break if line =~ /^##fasta/ or line =~ /^>/
        record = Bio::GFF::GFF3::Record.new(line)

        #use only the first gff id as the linking one ... 
        gff_ids = record.attributes.select { |a| a.first == 'ID' }
        gff_id = nil
        gff_id = gff_ids[0][1] if !gff_ids.empty?

        #get the sequence and quality if defined
        note = record.attributes.select { |a| a.first == 'Note' }
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
        #logger.error record.seqname
        ref = Reference.first(:conditions => ["name = ? AND genome_id = ?", "#{ record.seqname }", "#{genome.id}"])

        #logger.error "upto: #{record.seqname}"

        if ref.nil?
          #ref = Reference.first #TODO
          #90% of issues occur here!

          logger.error "------------------------------------------"
          logger.error "THE REFERENCE NAME IS WRONG, PLEASE CHECK! - #{ record.seqname } - #{genome.id}"
          logger.error "------------------------------------------"
          render :new
        end


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
            :gff_id => "#{gff_id}",
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
              parentFeats = Feature.find(:all, :conditions => ["gff_id = ?", "#{ parentFeature_gff_id }"])
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
        @experiment.features << feature #TODO save at each update?
                                        #      end
      end
    elsif @experiment.expected_file == "bam"
      @experiment.uses_bam_file = true

#      cmdZero = `ln -s #{@experiment.bam_file_path} {WebApolloAppPath}/jbrowse/data/bam/`
#      bamFileName = File.basename(@experiment.bam_file_path)
#      logger.error "DEBUG: #{@experiment.bam_file_path} #{WebApolloAppPath}/jbrowse/data/bam/ ...   #{WebApolloAppPath}/jbrowse/data/bam/#{bamFileName}"
#      cmdOne = `#{WebApolloAppPath}/jbrowse/bin/add_bam_track.pl --bam_url #{WebApolloAppPath}/jbrowse/data/bam/#{bamFileName} --label simulated_bam --key "simulated BAM" --out #{WebApolloAppPath}/jbrowse/data/trackList.json`
#      cmdComplete = "SUCCESSFUL"
#      if(!cmdOne)
#        logger.error "Add bam output: #{cmdOne}."
#      end
#      logger.debug "cmdOne #{cmdOne}"
    end

    if @experiment.save
      redirect_to experiment_path(@experiment), flash: {notice: "Experiment was successfully created."}
    else
      render :new
    end

  end

  def edit
    unless user_signed_in?
        redirect_to experiment_path(params[:id]), flash: {notice: "You must be logged in to edit."}
    end

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
    File.open("#{experiment.gff_file.path}").each do |line|
      next if line =~ /^#/
      break if line =~ /^##fasta/ or line =~ /^>/
      record = Bio::GFF::GFF3::Record.new(line)

      #use only the first gff id as the linking one ...
      gff_ids = record.attributes.select { |a| a.first == 'ID' }
      gff_id = nil
      gff_id = gff_ids[0][1] if !gff_ids.empty?

      #get the sequence and quality if defined
      note = record.attributes.select { |a| a.first == 'Note' }
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

      ref = Reference.first(:conditions => ["name = ? AND genome_id = ?", "#{ record.seqname }", "#{experiment.genome_id}"])

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
          :gff_id => "#{gff_id}",
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
            parentFeats = Feature.all(:conditions => ["gff_id = ?", "#{ parentFeature_gff_id }"])
            if (parentFeats)
              parentFeats.each do |pf|
                parent = nil
                parent = Parent.first(:conditions => {:parent_feature => pf.id})
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
    if (false)
      if (current_user.admin)
        @experiment = Experiment.find(params[:id])
        @experiment.destroy
      end
      respond_to do |format|
        format.html { redirect_to(experiments_url) }
      end
    end
  end

  def reference_list
    genome = Experiment.find(params[:id]).genome
    respond genome.references.collect { |x| x.name }
  end

  def findfromss
    @ssid = params[:id]
    @ssdb = params[:db]


    @gffas = Feature.where(gff_id: @ssid).pluck(:experiment_id).uniq
    @seqqs = Feature.where(seqid: @ssid).pluck(:experiment_id).uniq

    @experiments = @gffas + @seqqs
    @experiments = @experiments.uniq

    if @experiments.length == 1
      redirect_to :action => "show", :id => @experiments.first, segment => @ssid
    end
  end
end

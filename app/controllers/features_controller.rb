#Defines the URL methods that co-ordinate and respond to requests


class FeaturesController < ApplicationController
  def index
    @genomes = Genome.all
    @experiments = Experiment.all
  end
  
  def edit
    @feature = Feature.find(params[:id])
  end
  
  def update
    
    ##make the new feature for saving
    ##get the form stuff, use the old feature for missing or un-updatable fields
    old_feature = Feature.find(params[:old_feature_id])
    @feature = Feature.new
    @feature.seqid = params[:feature][:seqid] || old_feature.seqid
    @feature.source = params[:feature][:source] 
    @feature.feature = params[:feature][:feature] || old_feature.feature
    @feature.start = params[:feature][:start] || old_feature.start
    @feature.end = params[:feature][:end] || old_feature.end
    @feature.score = params[:feature][:score] 
    
    strand = nil
    strand = params[:feature][:strand]
    
    @feature.strand = strand || old_feature.strand
    @feature.phase = params[:feature][:phase] 
    
    
    ##get the genome from the reference, only look in the same reference... 
    genome_id = Reference.find(old_feature.reference_id).genome_id

    @feature.reference_id = Reference.find(:first, :conditions => {:genome_id => genome_id, :name => @feature.seqid} ).id || old_feature.ref_id
    
    @feature.group = []
    if params[:feature][:group]
      params[:feature][:group].keys.each do |old_group|
        ##this is a little messy.. 
        key = old_group.gsub(/"/,"").split(',')[0]
        value = params[:feature][:group][old_group]
        @feature.group << [key,value]
      end
    end
    if params[:feature][:new_group]
      params[:feature][:new_group].keys.each do |pair|
        @feature.group << [params[:feature][:new_group][pair][:key], params[:feature][:new_group][pair][:value] ]
      end
    end
    
    ##fill in the uneditable fields
    @feature.gff_id = old_feature.gff_id
    @feature.experiment_id = old_feature.experiment_id
    @feature.sequence = old_feature.sequence
    @feature.read_id = old_feature.read_id
    @feature.quality = old_feature.quality
    
    ##set up the parents of the new feature from the group info
    parents = @feature.group.select { |a| a.first == 'Parent' }
    puts "parents are #{parents}"
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
            @feature.parents << parent
          end
        end
      end
    end
    
    @feature.group = JSON.generate(@feature.group)
    
    @feature.save
    new_parent = Parent.new(:parent_feature => @feature.id)
    new_parent.save

    ##set up the children of the new feature from the old one..
    old_feature.children.each do |child|
      ##remove the old feature as a parent...
      new_parent_list = [new_parent] 
      child.parents.each do |parent|
          new_parent_list << parent unless parent.parent_feature == old_feature.id   
      end
      ##add the new feature as a parent to that child...
      child.parents = new_parent_list
      child.save
    end
    
    
    ##setup the predecessor record from the old feature... 
    predecessor = Predecessor.new(
    :seqid => old_feature.seqid,
    :source => old_feature.source,
    :feature => old_feature.feature,
    :start => old_feature.start,
    :end => old_feature.end,
    :score => old_feature.score,
    :strand => old_feature.strand,
    :phase => old_feature.phase,
    :gff_id => old_feature.gff_id,
    :reference_id => old_feature.reference_id,
    :experiment_id => old_feature.experiment_id,
    :created_at => old_feature.created_at,
    :group => old_feature.group,
    :old_id => old_feature.id
    )
    predecessor.save
    @feature.predecessors = [predecessor] + old_feature.predecessors

    
    respond_to do |format|
      if @feature.save and old_feature.destroy
        flash[:notice] = 'New feature was successfully created.'
        format.html { redirect_to :action => :show, :id => @feature.id }
      else
        flash[:notice] = 'New feature failed to save...'
        format.html { redirect_to :action => :edit, :id => params[:old_feature_id]}
      end
    end
  end

  def show 
    begin
      @feature = Feature.find(params[:id])
      respond @feature
    rescue
      respond :false
    end
  end

  def destroy
  ## gets the feature by id and deletes it and any relationships where it is a parent
  ## this is a horrid way of doing this.. check for a better RAILS-Y way...
  
    feature = Feature.find(params[:id])
    feature.children.each do |child|
      ##remove the old feature as a parent...
      new_parent_list = [] 
      child.parents.each do |parent|
          new_parent_list << parent unless parent.parent_feature == params[:id]   
      end
      ##add the updated feature list as a parent to the child...
      child.parents = new_parent_list
      child.save
    end
    if feature.destroy
      flash[:notice] = 'Feature was successfully destroyed.'
      redirect_to :action => :index 
    else
      flash[:notice] = 'Feature could not be deleted'
       redirect_to :action => :show, :id => params[:id] 
    end
    
  end
  
  def find_annotation
    flash[:error] = []
    @features = Feature.find(:all)
    @features.delete_if {|x| x.group !~ /#{params[:search_string]}/}


  end

  def graphic_range

    flash[:error] = []
    unless params[:genome_id]
      flash[:error] << 'A genome build must be selected'
    end
    unless params[:experiment]
      flash[:error] << 'An experiment must be selected'
    end
    if params[:reference].length == 0
      flash[:error] << 'A reference sequence name must be provided' 
    end
    params[:start] = 0 if params[:start].nil?
    params[:end] = 0 if params[:end].nil?
    if params[:start] =~ /\D/
      flash[:error] << 'Start must be a positive numeric value'
    end
    if params[:end] =~ /\D/
      flash[:error] << 'End must be a positive numeric value'
    end
    
    if params[:end] < params[:start]
      flash[:error] << 'End value must be greater than (or equal to) start value'
    end
     
    if not flash[:error].empty?
      redirect_to :back
      return
    end
    
    

    
  #method for returning preformatted feature objects in a range for plotting by the javascript feature renderer. Groups features with a parent that have type in list Features::aggregate_features.
    ref = Reference.find(:first, :conditions => {:genome_id => params[:genome_id], :name => params[:reference]})
    @features = []
    @start = params[:start]
    @end = params[:end]
    seen_features = []
    Feature.find_in_range_no_overlap(ref.id, params[:start], params[:end], params[:experiment]).each do |f|
      @features << f.descendants
      #if we have already used 
    end
        
  end
  
  def feature_summary
    @features = [Feature.find(params[:id])]
    summary_img
  end
  
  def summary
    reference     = params[:reference]
    start         = params[:start].presence || 0
    _end          = params[:end].presence || 0
    experiment_id = params[:experiment]

    flash[:error] = []

    flash[:error] << 'An experiment must be selected'unless experiment_id.present?
    flash[:error] << 'A reference sequence name must be provided' if reference.length == 0
    flash[:error] << 'Start must be a positive numeric value' if start =~ /\D/
    flash[:error] << 'End must be a positive numeric value' if _end =~ /\D/
    flash[:error] << 'End value must be greater than (or equal to) start value'if _end < start
     
    redirect_to(:back) and return unless flash[:error].empty?

    experiment  = Experiment.find(experiment_id)
    genome_id   = experiment.genome.id

    # method for returning preformatted feature objects in a range for plotting by the javascript feature renderer. 
    # Groups features with a parent that have type in list Features::aggregate_features.
    ref       = Reference.find(:first, :conditions => {:genome_id => genome_id, :name => reference})
    @start    = start
    @end      = _end
    @features = Feature.find_in_range_no_overlap(ref.id, start, _end, experiment.id)

    summary_img
  end
  
  #get a png of an svg from a bio-svgenes render of the features, dumps it in public pngs for
  #head of a summary page
  def summary_img
    num_tracks_needed = 1

    begin
    p = Bio::Graphics::Page.new(:width => 800, :height => 150, :number_of_intervals => 10) 
      
      #separate features into mRNA or gene features
     
      genes = @features.select {|x| x.feature == 'gene' }
      if not genes.empty?
        gene_track = p.add_track(:glyph => :directed,
                                 :fill_color => :green_white_radial,
                               :label => false
                              )
     # mrna_track = p.add_track(:glyph => :transcript,
     #                          :exon_fill_color => :red_white_h,
     #                          :utr_fill_color => :blue_white_h 
     #                          )
        genes.each do |gene|
          feat = Bio::Graphics::MiniFeature.new(:start => gene.start, 
                                              :end => gene.end, 
                                              :strand => gene.strand,
                                              :id => gene.gff_id)
          gene_track.add(feat)
        end   
      end
      
      proteins = @features.select {|x| x.feature == 'protein'}
      
      if not proteins.empty?
        protein_track = p.add_track(
                                    :glyph => :generic,
                                    :fill_color => :yellow_white_radial,
                                    :label => false
                                   )
        proteins.each do |protein|
          feat = Bio::Graphics::MiniFeature.new(:start => protein.start,
                                                :end => protein.end,
                                                :id => protein.gff_id
                                                )
          protein_track.add(feat)
        end
      end
      
      
      mrnas = @features.select {|x| x.feature == 'mRNA' }
      @mrnas = mrnas
      if not mrnas.empty?
        mrna_track = p.add_track(:glyph => :transcript,
                                 :exon_fill_color => :red_white_h,
                                 :utr_fill_color => :blue_white_h,
                                 :label => false,
                                 :gap_marker => 'angled' 
                               )
        mrnas.each do |m|
          exons = []
          utrs = []
          m.children.each do |d|
            if d.feature == 'exon'
              exons << d.start
              exons << d.end
            end
            if d.feature == 'five_prime_UTR' or d.feature == 'three_prime_UTR'
              utrs << d.start
              utrs << d.end
            end
            exons.sort!
            utrs.sort!
          end
          @exons = exons
          @utrs = utrs
          
          if exons.empty?
            exons = [m.start,m.end]
          end
          
          if utrs.empty?
            utrs = [m.start, m.end]
          end
          feat = Bio::Graphics::MiniFeature.new(
                                              :start => m.start,
                                              :end => m.end,
                                              :strand => m.strand,
                                              :exons => exons,
                                              :utrs => utrs,
                                             :id => m.gff_id
                                             )
          mrna_track.add(feat)                                     
        end                                              
      end
     @svg = p.get_markup 
     rescue
      @svg = ""
     end 
   
  end
  
  #Standard REST request method 
  #returns a hash summarising depth of feature object coverage for a nucleotides between start and stop on reference in experiment id
  # => use /features/coverage/id.format?params
  # => required params: reference_id, start, end, experiment_id  
  def coverage
    if Experiment.find(params[:id]).uses_bam_file  #return a pileup from samtools...

    else #return a position keyed hash of Positions objects
      features = Feature.find_in_range(params[:reference_id],params[:start],params[:end],params[:id])
      sequence = Reference.find(params[:reference_id]).sequence.sequence[params[:start].to_i - 1,(params[:end].to_i - params[:start].to_i) ]
      positions = SimpleDepth.new(params[:start],params[:end],sequence,features)
    #comp_hash = {'A' => 'T', 'T' => 'A', 'G' => 'C', 'C' => 'G', 'N' => 'N'}
    #positions = Hash.new {|h,k| h[k] = {
     #   '+' => {
    #      'A' => 0, 
    #      'T' => 0, 
    #      'G' => 0, 
    #      'C' => 0, 
    #      'N' => 0, 
    #      'strand_total' => 0
    #      }, 
    #    '-' => {
    #      'A' => 0, 
    #      'T' => 0, 
    #      'G' => 0, 
     #     'C' => 0, 
    #      'N' => 0, 
    #      'strand_total' => 0
    #      }, 
    #    'position_total' => 0
    #  } 
    #}
    #positions['region_total'] = 0
    #positions['1'] = 1
    #features = Feature.find_in_range_no_overlap(params[:reference_id],params[:start],params[:end],params[:id])
    #features.each do |f|
    #  if (f.sequence.match(/\w/))
    #    (f.start .. f.end - 1).each_with_index do |i, idx|
    #        positions[i][f.strand][f.sequence[idx,1]] += 1
    #        positions[i][f.strand]['strand_total'] += 1
    #        positions[i]['position_total'] += 1
    #        positions['region_total'] += 1
    #    end
    #  end
    end
    respond(positions)
  end
  
  #Standard REST request method 
  #returns array of feature objects within or overlapping the given start and end on the reference in experiment
  # => use /features/objects/id?params
  # => required params: reference_id, start, end, id
  # => optional params: overlap (true or false, default = false), type (some GFF feature type) restrict objects by feature type  
  def objects
    objects = []
    params[:format] = 'xml' unless params[:format]
    if !params[:overlap].nil? and params[:overlap] == "true" #if we want to include objects that can fall onto the edge of the range
      objects = Feature.find_in_range(params[:reference_id],params[:start],params[:end],params[:id])
    else #if we want to include only objects entirely within the range
      objects = Feature.find_in_range_no_overlap(params[:reference_id],params[:start],params[:end],params[:id])
    end
    objects.delete_if {|obj| obj.feature != params[:type] } if !params[:type].nil?
    #respond(objects, params[:format])
    respond objects
  end


  # Bio Dalliance
  def dalliance_get
    @experiment = Feature.where(experiment_id: params[:id]).limit(500)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  # index.xml.builder
    end

    #render :xml => @experiment,  :layout => false
  end

  #AnnoJ request method, not normally called directly used in config.yml and config.js. Gets features for an experiment at id
  # => use /features/annoj/id 
  def annoj_get
    case params[:annoj_action]
      when "syndicate"
        @response = syndicate(params[:id])
      when "describe"
        @response = describe(params["id"])
    end
    render :json => @response,  :layout => false
  end

  def annoj_post
    case params[:annoj_action]
      when "range" 
        @response = range(params['assembly'], params['left'], params['right'], params[:id], params['bases'], params['pixels'])
      when "lookup"
        @response = lookup(params["query"], params[:id])
    end
    render :json => @response, :layout => false
  end

  #AnnoJ request method, not normally called directly used in config.yml and config.js. Gets reference track that is saved as experiment at id
  # => use /features/chromosome/id
  def chromosome
    
    #a method for returning chromosome sequence as if it were a read to trick annoj into showing a reference sequence...
    if request.get?
      ##sort out the params from annoj's get
      annoj_params = {}
      request.url.split(/&/).each do |pair|
        k,v = pair.split(/=/)
        annoj_params[k] = v
      end#CGI.parse(URI.parse(request.url).query)
      annoj_params.each_pair {|k,v| annoj_params[k] = v.to_s}
      case annoj_params['action']
        when "syndicate"
          @response = syndicate(params[:id])
        when "describe"
          @response = [] ##to be done... 
      end
        render :json => @response,  :layout => false
    elsif request.post?
      annoj_params = {}
      request.raw_post.split(/&/).each do |pair|
        k,v = pair.split(/=/)
        annoj_params[k] = v
      end
      annoj_params.each_pair {|k,v| annoj_params[k] = v.to_s}
        #now do the specific stuff based on the annoj action... 
      if annoj_params['action'] == 'range'
          #remember params[:id] is genome id and annoj_params['assembly'] is the chromosome
          sequence = Reference.find(:first, :conditions => {:genome_id => params[:id], :name => annoj_params['assembly']}).sequence.sequence
          subseq = sequence[annoj_params['left'].to_i - 3..annoj_params['right'].to_i - 3]
          f = LightFeature.new(
            :group => '.',
            :feature => 'chromosome',
            :source => '.',
            :start => annoj_params['left'].to_i,
            :end => annoj_params['right'].to_i, 
            :strand => '+',
            :phase => '.',
            :seqid => annoj_params['assembly'],
            :score => '.',
            :experiment_id => nil,
            :gff_id =>  nil,
            :sequence => "#{subseq}",
            :quality => nil,
            :reference_id => nil
          )
          zoom_factor = annoj_params['bases'].to_i / annoj_params['pixels'].to_i
          response = new_response
          features = [f]
          #@response = #range(annoj_params['assembly'], annoj_params['left'], annoj_params['right'], params[:id], annoj_params['bases'], annoj_params['pixels'])
          if zoom_factor >= 10
            hist_data = get_histogram(features)
             response[:data] = {}
             response[:data][:read] = hist_data 

          elsif zoom_factor < 10 and zoom_factor > 0.1
              box_data = get_boxes(features)
              box_data[:watson][0][0] = f.seqid
              response[:data] = {}
              response[:data][:read] = box_data
          else
              read_data = get_reads(features)
              read_data[:watson][0][0] = f.seqid
              response[:data] = {}
              response[:data][:read] = read_data
          end
          @response = response

      elsif annoj_params["action"] == "lookup"
            @response = [] #to be done also #lookup(annoj_params["query"], params[:id])
      end
      render :json => @response, :layout => false
    end
  end
  #AnnoJ request method, returns metadata on a track required by AnnoJ
  def syndicate(id)
    experiment = Experiment.find(id) 
    response = new_response
    response[:data] = {}
    JSON::parse( "#{experiment.meta}" )
    
    response[:data] = JSON::parse( "#{experiment.meta}" )
    #response[:data][:engineer] = YAML::load( "#{experiment.engineer}")
    #response[:data][:service] = YAML::load( "#{experiment.service}")
    response
  end
  #AnnoJ request method, returns data formatted as per request parameters for particular view 
  def range(assembly, left, right, experiment_id, bases, pixels)
    zoom_factor = bases.to_i / pixels.to_i
    response = new_response
    exp = Experiment.find(experiment_id)
    reference = Reference.find(:first, :conditions => ["name = ? AND genome_id = ?", "#{ assembly }", "#{exp.genome_id}"])
    features = Feature.find_in_range_no_overlap(reference.id, left, right, experiment_id)
    return response if features.empty?
    #case features.first.feature
    
    #when 
    if Feature.allowed_read_types.include?(features.first.feature) #'polymerase_synthesis_read'
      if zoom_factor >= 10
       hist_data = get_histogram(features)
       response[:data] = {}
       response[:data][:read] = hist_data 
       return response
      elsif zoom_factor < 10 and zoom_factor > 0.1
        box_data = get_boxes(features)
        response[:data] = {}
        response[:data][:read] = box_data
      else
        read_data = get_reads(features)
        response[:data] = {}
        response[:data][:read] = read_data
      end   
       
    else
      response[:data] = []
      response[:data] = features.collect! {|f| f.to_annoj }
    end
    return response
  end
  # Formatting method for range, AnnoJ only
  def get_histogram(features)
     return [] if features.empty?
     results = []
     #lower limit
     left = features.first.start - (features.first.start % 10)
     #upper limit
     right = features.last.end + (features.last.end % 10)
     #number of arrays
     start = left
     while start <= right
       results << [start, 0, 0]
       start += 10
     end
     features.each do |f|
       window = f.start - (f.start % 10)
       start_index = nil
       if window == left 
          start_index = 0
       else
         start_index = (window - left) / 10
       end
       end_index = start_index + (((f.end - f.start) - ((f.end - f.start) % 10)) / 10)
       for index in start_index .. end_index
         break if index > results.length
         if f.strand.match(/\+/)
           results[index][1] += 1 
         else
           results[index][2] += 1
         end
       end
     end
     #temp = [start, 0, 0]
     #features.each do |f|
      # if f.start > start + 10
      #   results << temp
      #   start = start + 10
      #   temp = [start, 0,0]
      # end
      # if f.strand.match(/\+/)
      #   temp[1] += 1
      # else
      #   temp[2] += 1
      # end
     #end
     return results
     #pluses = Array.new(features.last.end - features.first.start + 1, 0)
     #minuses = Array.new(features.last.end - features.first.start + 1, 0)
     #features.each do |f|
     #  for i in f.start .. f.end
     #    case f.strand
     #    when '+'
     #      pluses[i - start] = pluses[i - start] + 1
     #   else
     #      minuses[i - start] = minuses[i - start] + 1
     #    end
     #  end
     #end
     #result = Array.new
     #while start < features.last.end
     #  result << [start, pluses.slice!(0 .. 8).max, minuses.slice!(0 .. 8).max]
     #  start += 10
     #end
     #return result
     #hist = {}
     #for pos in features.first.start .. features.last.end
     #  hist[pos] = {}
     #  hist[pos]['+'] = 0
     #  hist[pos]['-'] = 0
     #end
     #features.each do |f|
     #  for pos in f.start .. f.end
     #    hist[pos][f.strand] = hist[pos][f.strand] + 1 
     #  end
     #end
     #result = hist  
     #result = []
     ####go through the hist and send [start, plus_intens, minus_intens] for each window of bases
       ##send max intensity in steps of ten

     #start = features.first.start.to_i
     #while start < features.last.end
     #  plus_intens = 0
     #  minus_intens = 0
     #  for pos in start .. (start + 9)

     #    break if pos > features.last.end
     #    plus_intens = hist[pos]['+'] if hist[pos]['+'] > plus_intens      
     #    minus_intens = hist[pos]['-'] if hist[pos]['-'] > minus_intens
     #  end

     #  result << [start, plus_intens, minus_intens]
     #  start += 10
     #end
     #return result
  end
  # Formatting method for range, AnnoJ only
  def get_boxes(features)
    result = {}
    result[:watson] = features.select{|f| f.strand == '+' }.collect{|e| e.to_box}
    result[:crick] = features.select{|f| f.strand == '-' }.collect{|e| e.to_box}
    return result
  end
  # Formatting method for range, AnnoJ only
  def get_reads(features)
    result = {}
    result[:watson] = features.select{|f| f.strand == '+' }.collect{|e| e.to_read}
    result[:crick] = features.select{|f| f.strand == '-' }.collect{|e| e.to_read}
    return result
  end
  # Feature Metadata accessor, AnnoJ only
  def describe(id)
    f = Feature.find(:first, :conditions => {:gff_id => id} )
    response = new_response
    response[:data] = {}
    response[:data][:id] = f.gff_id
    response[:data][:assembly] = f.seqid
    response[:data][:start] = f.start
    response[:data][:end] = f.end
    response[:data][:description] = f.description
    return response
  end
  # Feature metadata accessor, AnnoJ only
  def lookup(query, id)
    response = new_response
    rows = Feature.find(:all, :conditions => ["experiment_id = ? and features.group like ?", id, "%" + query + "%"]).collect! {|f| f.to_lookup}
    response[:count] = rows.length
    response[:rows] = rows
    return response
  end
  #Empty response, AnnoJ only
  def new_response
    {:success => true }
  end

  def search_by_id
    feature_id = params[:feature][:id]
    if Feature.exists?(feature_id)
      redirect_to feature_path(feature_id)
    else
      redirect_to features_path, flash: { alert: "No feature found with that ID"}
    end
  end

  def search_by_attribute
    attribute = params[:feature][:group]
    @features = Feature.where{ group.matches("%#{attribute}%") }
    if @features.empty?
      redirect_to features_path, flash: { alert: "No features found searching for: '#{attribute}'"}
    else
      render
    end
  end
end
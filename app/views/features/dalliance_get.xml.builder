xml.instruct!
  xml.DASGFF do
    xml.GFF 'version' => '1.0' do
        # xml.SEGMENT 'id' => seq do
            # logger.error"-----------------------------#{seq}"
            @features = Feature.where(experiment_id: @eid, feature: ["five_prime_UTR", "exon", "intron","three_prime_UTR"]).take(50)
            logger.error "------------------------------------ found #{@features.length} features"
            @features.each do |feature|
              xml.FEATURE 'id' => feature.id, 'label' => feature.feature do
                xml.TYPE feature.feature ,'id' => feature.feature
                xml.METHOD feature.source
                xml.START feature.start
                xml.END feature.end
                xml.SCORE feature.score
                xml.ORIENTATION feature.strand
                xml.PHASE feature.phase #0-6
                if feature.has_parent?
                  feature.parents.collect {|x|
                    logger.error "------------------------------------ found parent!!!!!!!"
                    x.parent_obj.id.to_s
                  }
                end
                # Parent.find :first, :conditions => {:feature_id => feature.id} do |parent|
                  # xml.PARENT parent.id ,'id' => parent.id
                # end
              end
            end
            logger.error "------------------------------------ end of features"
      # end
    end
  end
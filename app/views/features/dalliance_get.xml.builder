xml.instruct!
  xml.DASGFF do
    xml.GFF 'version' => '1.0' do
        xml.SEGMENT 'id' => "seg1" do
            # logger.error"-----------------------------#{seq}"
            @features = Feature.where(experiment_id: @eid, feature: ["five_prime_UTR", "exon", "intron","three_prime_UTR"])
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
                    xmpar = x.parent_obj.id.to_s
                    xml.PARENT xmpar, 'id' => xmpar
                  }
                end
                feature.children do |c|
                  logger.error "------------------------------------ Child: #{c.id}"
                end
                # Parent.find :first, :conditions => {:feature_id => feature.id} do |parent|
                  # xml.PARENT parent.id ,'id' => parent.id
                # end
              end
            end
            logger.error "------------------------------------ end of features"
      end
    end
  end
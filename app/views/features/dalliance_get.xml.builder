xml.instruct!
  xml.DASGFF do
    xml.GFF 'version' => '1.0' do
        xml.SEGMENT 'id' => "seg1" do
            @features.each do |feature|
              xml.FEATURE 'id' => feature.id, 'label' => feature.feature do
                xml.TYPE feature.feature ,'id' => feature.feature
                xml.METHOD feature.source
                xml.START feature.start
                xml.END feature.end
                xml.SCORE feature.score
                xml.ORIENTATION feature.strand
                xml.PHASE feature.phase #0-6
                xml.GROUP "TEST" #JSON.parse(feature.group)
                # logger.error "feature id #{feature.id}"
                # logger.error "#{feature.quality}"
                if feature.has_children?
                  logger.error "HAS CHILDREN"
                  feature.children.each do |child|
                    xml.PART child.id, 'id' => child.id
                  end
                end


                if feature.has_parent?
                  feature.parents.collect {|x|
                    parent_obj = x.parent_obj
                    xmpar = parent_obj.id.to_s
                    # unless @features.include?(parent_obj)
                    #   @features << parent_obj
                    # end
                    # logger.error "parent is #{x.parent_feature}"
                    xml.PARENT xmpar, 'id' => xmpar
                  }
                end
                # logger.error "___________________________________________________"
              end
            end
            logger.error "------------------------------------ end of features"
            # Parent.all.each do |child|
            #     # xml.PART child.id, 'id' => child.id
            #     logger.error "#{child.id} has:"
            #     logger.error "child: #{child.features}"
            #   end
      end
    end
  end
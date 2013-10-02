xml.instruct!

Sequence.each do |seq|
  logger.error "---------------------- found seq!!"
end

  xml.DASGFF do
    xml.GFF 'version' => '1.0' do
      xml.SEGMENT 'id' => 1 do
        @experiment.each do |feature|
          xml.FEATURE 'id' => feature.id, 'label' => feature.feature do
            xml.TYPE feature.feature ,'id' => feature.feature
            xml.METHOD feature.source
            xml.START feature.start
            xml.END feature.end
            xml.SCORE feature.score
            xml.ORIENTATION feature.strand
            xml.PHASE feature.phase #0-6
            feature.parents.each do |parent|
              xml.PERENT 'id' =>parent.id
              logger.error "----- parent ID =  #{parent.id}"
            end
          end
        end
      end
    end
  end
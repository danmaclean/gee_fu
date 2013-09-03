xml.instruct!

  xml.DASGFF do
    xml.GFF do
      xml.SEGMENT do
        @experiment.each do |feature|
          xml.FEATURE 'id' => feature.id, 'label' => feature.feature do
            xml.TYPE feature.feature
            xml.METHOD feature.source
            xml.START feature.start
            xml.END feature.end
            xml.SCORE feature.score
            xml.ORIENTATION feature.phase
            xml.PHASE feature.strand #0-6
          end
        end
      end
    end
  end
xml.instruct!

  xml.DASGFF do
    xml.GFF do
      xml.SEGMENT do
        @experiment.each do |feature|
          xml.FEATURE 'id' => feature.id, 'label' => feature.feature do
            xml.TYPE 'id' => feature.feature do feature.feature
            xml.METHOD feature.source
            xml.START feature.start
            xml.END feature.end
            xml.SCORE feature.score
            xml.ORIENTATION feature.strand
            xml.PHASE feature.phase #0-6
              end
          end
        end
      end
    end
  end
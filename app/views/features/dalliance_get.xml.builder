xml.instruct!

  xml.DASGFF do
    xml.GFF do
      xml.SEGMENT do
        @experiment.each do |feature|
          xml.FEATURE do
            xml.TYPE feature.start
            xml.from feature.end
            xml.subject feature.quality
          end
        end
      end
    end
  end
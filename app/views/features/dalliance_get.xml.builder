xml.instruct!

  xml.feature do
    @experiment.each do |feature|
      xml.FEATURE do
        xml.TYPE feature.start
        xml.from feature.end
        xml.subject feature.quality
      end
    end
  end
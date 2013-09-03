xml.instruct!

  @experiment.each do |feature|
    #xml.DASGFF do
    #  xml.GFF do
        #xml.SEGMENT do
          xml.FEATURE do
            xml.TYPE feature.start
            xml.METHOD feature.start
            xml.START feature.start
            xml.END feature.start
            xml.SCORE feature.start
            xml.ORIENTATION feature.start
            xml.PHASE feature.start
          end
        end
      #end
    #end
  #end
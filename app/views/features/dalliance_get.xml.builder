xml.instruct!

@experiments.each do |experiment|

  xml.feature do
    xml.item('togive' => experiment.quality, 'totake' => experiment.quality )
  end

end

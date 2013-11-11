require 'rubygems'
require 'gollum/app'

gollum_path = File.expand_path(File.dirname("/opt/wiki")) # CHANGE THIS TO POINT TO YOUR OWN WIKI REPO
Precious::App.set(:gollum_path, gollum_path)
Precious::App.set(:default_markup, :markdown) # set your favorite markup language
Precious::App.set(:wiki_options, {:universal_toc => false})
Precious::App.set(:port, 8081)
run Precious::App
# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
GeeFu::Application.initialize!
SequenceServer::App.config_file = "config/sequenceserver.conf"
SequenceServer::App.init
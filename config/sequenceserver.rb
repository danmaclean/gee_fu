require 'sequenceserver'

SequenceServer::App.config_file = "config/sequenceserver.conf"
SequenceServer::App.init
run SequenceServer::App
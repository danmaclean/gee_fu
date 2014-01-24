require_relative "../config/boot"
require_relative "../config/environment"

require 'clockwork'

module Clockwork
  every(1.week, 'DataRepositoryWorker', :at => 'Sunday 01:00') do
    DataRepositoryWorker.perform_async
  end
end
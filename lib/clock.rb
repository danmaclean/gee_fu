require_relative "../config/boot"
require_relative "../config/environment"

require 'clockwork'

module Clockwork
  every(12.hours, 'DataRepositoryWorker') do
    DataRepositoryWorker.perform_async
  end
end
require_relative "../config/boot"
require_relative "../config/environment"

require 'clockwork'

module Clockwork
  every(7.days, 'DataRepositoryWorker') do
    DataRepositoryWorker.perform_async
  end
end
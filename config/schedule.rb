every 1.day, at: "12:20am" do
  runner "DataRepositoryWorker.new.perform_async"
end

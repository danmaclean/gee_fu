every 1.day, at: "12:20am" do
  runner "RepoWorker.perform_async"
end

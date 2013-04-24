class GitCommitter
  attr_reader :repo_path
  def initialize(repo_path)
    @repo_path = repo_path
  end

  def commit
    `cd #{repo_path}`
    `git add .`
    `git commit -am 'Add GeeFU data'`
    `git push origin master`
  end
end
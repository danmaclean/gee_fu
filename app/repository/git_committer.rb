class GitCommitter
  attr_reader :repo_path
  def initialize(repo_path)
    @repo_path
  end

  def commit
    `cd #{repo_path}`
    `git add .` if $?.success?
    `git commit -am 'Add GeeFU data'` if $?.success?
    `git push origin master` if $?.success?
    raise unless $?.success?
  end
end
class GitCommitter
  attr_reader :repo_path
  def initialize(repo_path)
    @repo_path = repo_path
  end

  def commit
    Dir.chdir(repo_path) do
      return unless File.directory?('.git')
      `git add .`
      `git commit -am 'Update GeeFU data'`
      `git push origin master`
    end
  end
end
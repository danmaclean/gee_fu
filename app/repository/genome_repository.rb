class GenomeRepository
  attr_reader :organism, :folder_path
  def initialize(organism, folder_path)
    @organism    = organism
    @folder_path = folder_path
  end

  def create
    
  end
end
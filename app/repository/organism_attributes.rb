class OrganismAttributes
  attr_reader :organism
  def initialize(organism)
    @organism = organism
  end

  def combine
    "#{ncbi_taxid}_#{genus}_#{species}_#{strain}"
  end

  private

  def ncbi_taxid
    organism.taxid || "no-ncbi-taxid"
  end

  def genus
    organism.genus
  end

  def species
    organism.species
  end

  def strain
    organism.strain || "no-strain"
  end
end
class RefWithSeq
  attr_reader :id, :name, :length, :genome_id, :created_at, :sequence

  def initialize(reference)
    @id = reference.id
    @name = reference.name
    @length = reference.length
    @genome_id = reference.genome_id
    @created_at = reference.created_at
    @sequence = reference.sequence.sequence
  end

end


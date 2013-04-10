module GeeFuHelpers
  def add_genome_build(genome_build, fasta_file, config_file)
    fill_in "Build version (required)", :with => genome_build
    attach_file "Fasta file of sequences (required)", "#{Rails.root}/#{fasta_file}"
    attach_file "YAML file of metadata about this genome (required for AnnoJ browsing only)", "#{Rails.root}/#{config_file}"
    click_button "Create"
  end
end
World(GeeFuHelpers)
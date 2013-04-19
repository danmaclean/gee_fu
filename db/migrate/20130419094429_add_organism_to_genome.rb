class AddOrganismToGenome < ActiveRecord::Migration
  def up
    add_column :genomes, :organism_id, :integer
    Genome.update_all(organism_id: Organism.first.id)
    add_foreign_key(:genomes, :organisms)
    change_column :genomes, :organism_id, :integer, null: false
  end

  def down
    remove_foreign_key :genomes, :organisms
    remove_column :genomes, :organism_id
  end
end

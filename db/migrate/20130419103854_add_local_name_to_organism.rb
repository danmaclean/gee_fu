class AddLocalNameToOrganism < ActiveRecord::Migration
  def change
    add_column :organisms, :local_name, :string
    Organism.all.each do |organism|
      organism.update_attributes(local_name: "Organism-#{organism.id}")
    end
    change_column :organisms, :local_name, :string, null: false
  end
end

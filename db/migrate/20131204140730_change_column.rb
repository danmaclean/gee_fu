class ChangeColumn < ActiveRecord::Migration
  def up
        change_column :features, :group, :text
  end

  def down
	change_column :features, :group, :string
  end
end

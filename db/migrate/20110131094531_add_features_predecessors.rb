class AddFeaturesPredecessors < ActiveRecord::Migration
  def self.up
    create_table "features_predecessors", :id => false, :force => true do |t|
      t.integer "feature_id"
      t.integer "predecessor_id"
    end
  end

  def self.down
    drop_table "features_predecessors"
  end
end

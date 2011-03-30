class AddPredecessors < ActiveRecord::Migration
  def self.up
    create_table "predecessors", :force => true do |t|
      t.string   "seqid",                      :null => false
      t.string   "source"
      t.string   "feature"
      t.integer  "start",                      :null => false
      t.integer  "end",                        :null => false
      t.string   "score"
      t.string   "strand",        :limit => 1
      t.string   "phase",         :limit => 1
      t.string   "group"
      t.string   "gff_id"
      t.integer  "experiment_id",              :null => false
      t.text     "sequence"
      t.text     "read_id"
      t.text     "quality"
      t.integer  "reference_id"
      t.datetime "created_at"
    end
  end

  def self.down
    drop_table "predecessors"
  end
end

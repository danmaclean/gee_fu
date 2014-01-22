# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20131204154317) do

  create_table "experiments", :force => true do |t|
    t.string   "name",                                             :null => false
    t.string   "description",   :limit => 1024,                    :null => false
    t.boolean  "uses_bam_file",                 :default => false
    t.string   "bam_file_path"
    t.integer  "genome_id",                                        :null => false
    t.datetime "created_at"
    t.text     "meta"
  end

  create_table "features", :force => true do |t|
    t.string   "seqid",                      :null => false
    t.string   "source"
    t.string   "feature"
    t.integer  "start",                      :null => false
    t.integer  "end",                        :null => false
    t.string   "score"
    t.string   "strand",        :limit => 1
    t.string   "phase",         :limit => 1
    t.text     "group"
    t.string   "gff_id"
    t.integer  "experiment_id",              :null => false
    t.text     "sequence"
    t.text     "read_id"
    t.text     "quality"
    t.integer  "reference_id"
    t.datetime "created_at"
  end

  add_index "features", ["experiment_id", "seqid", "start", "end"], :name => "index_features_on_ref_exp_start_and_end"

  create_table "features_parents", :id => false, :force => true do |t|
    t.integer "feature_id"
    t.integer "parent_id"
  end

  add_index "features_parents", ["feature_id", "parent_id"], :name => "index_features_parents_on_feature_id_and_parent_id"

  create_table "features_predecessors", :id => false, :force => true do |t|
    t.integer "feature_id"
    t.integer "predecessor_id"
  end

  create_table "genomes", :force => true do |t|
    t.datetime "created_at"
    t.text     "build_version"
    t.text     "meta"
    t.integer  "organism_id",   :null => false
  end

  create_table "organisms", :force => true do |t|
    t.string   "genus"
    t.string   "species"
    t.string   "strain"
    t.string   "pv"
    t.integer  "taxid"
    t.datetime "created_at"
    t.string   "local_name", :null => false
  end

  create_table "parents", :force => true do |t|
    t.integer "parent_feature", :null => false
  end

  add_index "parents", ["parent_feature"], :name => "index_parents_on_parent_feature"

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
    t.integer  "old_id"
  end

  create_table "references", :force => true do |t|
    t.string   "name",       :null => false
    t.integer  "length",     :null => false
    t.integer  "genome_id",  :null => false
    t.datetime "created_at"
  end

  create_table "sequences", :force => true do |t|
    t.binary   "sequence"
    t.integer  "reference_id"
    t.datetime "created_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "",    :null => false
    t.string   "encrypted_password",     :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "first_name",                                :null => false
    t.string   "last_name",                                 :null => false
    t.string   "affiliation"
    t.string   "role"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.boolean  "admin",                  :default => false, :null => false
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "versions", :force => true do |t|
    t.string   "item_type",      :null => false
    t.integer  "item_id",        :null => false
    t.string   "event",          :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.text     "object_changes"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

  add_foreign_key "genomes", "organisms", name: "genomes_organism_id_fk"

end

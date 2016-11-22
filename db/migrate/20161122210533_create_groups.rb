class CreateGroups < ActiveRecord::Migration[5.0]
  def change
    drop_table :instances
    create_table :groups do |t|
      t.string :name, null: false
    end
    create_table :instances do |t|
      t.integer  "group_id", null: false
      t.integer  "catalog_entry_id", null: false
      t.string   "description"
      t.string   "version"
      t.datetime "created_at",       null: false
      t.datetime "updated_at",       null: false
      t.index ["group_id"], name: "index_instances_on_group_id"
      t.index ["catalog_entry_id"], name: "index_instances_on_catalog_entry_id"
    end
  end
end

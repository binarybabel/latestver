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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20161121014928) do

  create_table "catalog_entries", force: :cascade do |t|
    t.string   "name",           null: false
    t.string   "type",           null: false
    t.string   "tag",            null: false
    t.string   "version"
    t.date     "version_date"
    t.boolean  "prereleases",    default: false
    t.text     "external_links"
    t.text     "data"
    t.datetime "refreshed_at"
    t.string   "last_error"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "catalog_log_entries", force: :cascade do |t|
    t.integer  "catalog_entry_id", null: false
    t.string   "version_from"
    t.string   "version_to"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.index ["catalog_entry_id"], name: "index_catalog_log_entries_on_catalog_entry_id"
  end

  create_table "instances", force: :cascade do |t|
    t.string   "group",            null: false
    t.integer  "catalog_entry_id", null: false
    t.string   "description"
    t.string   "version"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.index ["catalog_entry_id"], name: "index_instances_on_catalog_entry_id"
  end

end

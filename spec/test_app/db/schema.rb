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

ActiveRecord::Schema.define(version: 20170219175007) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "cas_contents", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "structure_id"
    t.string   "title"
    t.text     "text"
    t.uuid     "author_id"
    t.datetime "date"
    t.boolean  "published"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["author_id"], name: "index_cas_contents_on_author_id", using: :btree
    t.index ["published"], name: "index_cas_contents_on_published", using: :btree
    t.index ["structure_id"], name: "index_cas_contents_on_structure_id", using: :btree
  end

  create_table "cas_sites", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_cas_sites_on_name", using: :btree
  end

  create_table "cas_structures", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "name",           null: false
    t.string   "structure_type", null: false
    t.uuid     "site_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["site_id"], name: "index_cas_structures_on_site_id", using: :btree
  end

end

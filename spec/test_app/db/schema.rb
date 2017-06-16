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

ActiveRecord::Schema.define(version: 20170615235532) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "cas_categories", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "section_id",                null: false
    t.string   "name",                      null: false
    t.string   "slug"
    t.jsonb    "metadata",   default: "{}"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.index ["section_id"], name: "index_cas_categories_on_section_id", using: :btree
    t.index ["slug"], name: "index_cas_categories_on_slug", using: :btree
  end

  create_table "cas_contents", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "section_id",                null: false
    t.string   "title"
    t.text     "text"
    t.uuid     "author_id",                 null: false
    t.datetime "date"
    t.boolean  "published"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "pageviews"
    t.jsonb    "metadata",   default: "{}"
    t.text     "summary"
    t.jsonb    "details",    default: "{}"
    t.string   "slug"
    t.index ["author_id"], name: "index_cas_contents_on_author_id", using: :btree
    t.index ["published"], name: "index_cas_contents_on_published", using: :btree
    t.index ["section_id"], name: "index_cas_contents_on_section_id", using: :btree
    t.index ["slug"], name: "index_cas_contents_on_slug", using: :btree
  end

  create_table "cas_media_files", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "attachable_id"
    t.string   "attachable_type"
    t.uuid     "author_id",       null: false
    t.string   "service",         null: false
    t.text     "title"
    t.string   "url"
    t.string   "mime_type"
    t.string   "original_name"
    t.integer  "size"
    t.text     "file_data"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["attachable_id", "attachable_type"], name: "index_cas_media_files_on_attachable_id_and_attachable_type", using: :btree
    t.index ["author_id"], name: "index_cas_media_files_on_author_id", using: :btree
  end

  create_table "cas_sections", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "name",         null: false
    t.string   "section_type", null: false
    t.uuid     "site_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "slug"
    t.index ["site_id"], name: "index_cas_sections_on_site_id", using: :btree
    t.index ["slug"], name: "index_cas_sections_on_slug", using: :btree
  end

  create_table "cas_sites", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_cas_sites_on_name", using: :btree
  end

  create_table "cas_users", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "name",                                null: false
    t.string   "login"
    t.string   "password",                            null: false
    t.uuid     "author_id"
    t.string   "roles",                  default: [],              array: true
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.index ["author_id"], name: "index_cas_users_on_author_id", using: :btree
    t.index ["email"], name: "index_cas_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_cas_users_on_reset_password_token", unique: true, using: :btree
  end

end

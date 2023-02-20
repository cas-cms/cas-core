# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_02_20_165900) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "fuzzystrmatch"
  enable_extension "pg_trgm"
  enable_extension "plpgsql"
  enable_extension "unaccent"
  enable_extension "uuid-ossp"

  create_table "cas_activities", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "site_id"
    t.uuid "user_id"
    t.string "event_name"
    t.uuid "subject_id"
    t.string "subject_type"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "user_description"
    t.string "subject_description"
    t.index ["site_id"], name: "index_cas_activities_on_site_id"
    t.index ["subject_id", "subject_type"], name: "index_cas_activities_on_subject_id_and_subject_type"
    t.index ["user_id"], name: "index_cas_activities_on_user_id"
  end

  create_table "cas_categories", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "section_id", null: false
    t.string "name", null: false
    t.string "slug"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.jsonb "metadata", default: {}
    t.text "description"
    t.index ["section_id"], name: "index_cas_categories_on_section_id"
    t.index ["slug"], name: "index_cas_categories_on_slug"
  end

  create_table "cas_contents", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "section_id", null: false
    t.string "title"
    t.text "text"
    t.uuid "author_id", null: false
    t.datetime "date", precision: nil
    t.boolean "published"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "pageviews", default: 0
    t.jsonb "metadata", default: "{}"
    t.text "summary"
    t.jsonb "details", default: "{}"
    t.string "slug"
    t.uuid "category_id"
    t.string "location"
    t.string "url"
    t.string "embedded"
    t.datetime "published_at", precision: nil
    t.string "tags_cache"
    t.index "((((to_tsvector('simple'::regconfig, COALESCE((title)::text, ''::text)) || to_tsvector('simple'::regconfig, COALESCE(text, ''::text))) || to_tsvector('simple'::regconfig, COALESCE((location)::text, ''::text))) || to_tsvector('simple'::regconfig, COALESCE((tags_cache)::text, ''::text))))", name: "cas_contents_search_with_fulltext", using: :gist
    t.index ["author_id"], name: "index_cas_contents_on_author_id"
    t.index ["category_id"], name: "index_cas_contents_on_category_id"
    t.index ["published"], name: "index_cas_contents_on_published"
    t.index ["published_at"], name: "index_cas_contents_on_published_at"
    t.index ["section_id"], name: "index_cas_contents_on_section_id"
    t.index ["slug"], name: "index_cas_contents_on_slug"
  end

  create_table "cas_media_files", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "attachable_id"
    t.string "attachable_type"
    t.uuid "author_id"
    t.string "service", null: false
    t.text "description"
    t.string "path"
    t.string "mime_type"
    t.string "original_name"
    t.integer "size"
    t.text "file_data"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "cover", default: false, null: false
    t.integer "order", default: 1
    t.text "text"
    t.jsonb "metadata", default: {}
    t.string "media_type", null: false
    t.index ["attachable_id", "attachable_type"], name: "index_cas_media_files_on_attachable_id_and_attachable_type"
    t.index ["author_id"], name: "index_cas_media_files_on_author_id"
    t.index ["cover"], name: "index_cas_media_files_on_cover"
  end

  create_table "cas_sections", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "section_type", null: false
    t.uuid "site_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "slug"
    t.index ["site_id"], name: "index_cas_sections_on_site_id"
    t.index ["slug"], name: "index_cas_sections_on_slug"
  end

  create_table "cas_sites", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "slug"
    t.string "domains", default: [], array: true
    t.index ["domains"], name: "index_cas_sites_on_domains", using: :gin
    t.index ["name"], name: "index_cas_sites_on_name", unique: true
    t.index ["slug"], name: "index_cas_sites_on_slug", unique: true
  end

  create_table "cas_sites_users", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "site_id", null: false
    t.boolean "author_id"
    t.boolean "uuid"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["site_id", "user_id"], name: "index_cas_sites_users_on_site_id_and_user_id"
  end

  create_table "cas_users", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "login"
    t.uuid "author_id"
    t.string "roles", default: [], array: true
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "email"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.jsonb "metadata", default: {}
    t.index ["author_id"], name: "index_cas_users_on_author_id"
    t.index ["email"], name: "index_cas_users_on_email", unique: true
    t.index ["encrypted_password"], name: "index_cas_users_on_encrypted_password"
    t.index ["reset_password_token"], name: "index_cas_users_on_reset_password_token", unique: true
  end

  create_table "taggings", id: :serial, force: :cascade do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.string "tagger_type"
    t.string "context", limit: 128
    t.datetime "created_at", precision: nil
    t.uuid "taggable_id"
    t.uuid "tagger_id"
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

end

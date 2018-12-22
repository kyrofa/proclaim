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

ActiveRecord::Schema.define(version: 2019_04_01_011252) do

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
  end

  create_table "proclaim_comment_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id", null: false
    t.integer "descendant_id", null: false
    t.integer "generations", null: false
    t.index ["ancestor_id", "descendant_id", "generations"], name: "comment_anc_desc_udx", unique: true
    t.index ["descendant_id"], name: "comment_desc_idx"
  end

  create_table "proclaim_comments", force: :cascade do |t|
    t.integer "post_id"
    t.integer "parent_id"
    t.string "author"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id"], name: "index_proclaim_comments_on_post_id"
  end

  create_table "proclaim_posts", force: :cascade do |t|
    t.integer "author_id"
    t.string "title", default: "", null: false
    t.text "body", default: "", null: false
    t.text "quill_body", default: "", null: false
    t.string "state", default: "draft", null: false
    t.string "slug"
    t.datetime "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_proclaim_posts_on_author_id"
    t.index ["slug"], name: "index_proclaim_posts_on_slug", unique: true
    t.index ["state"], name: "index_proclaim_posts_on_state"
  end

  create_table "proclaim_subscriptions", force: :cascade do |t|
    t.integer "post_id"
    t.string "name", default: "", null: false
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id", "email"], name: "index_proclaim_subscriptions_on_post_id_and_email", unique: true
    t.index ["post_id"], name: "index_proclaim_subscriptions_on_post_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end

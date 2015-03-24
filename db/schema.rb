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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150319072045) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "hashtags", force: :cascade do |t|
    t.string   "tag"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "topic"
    t.integer  "topic_updater_id"
  end

  create_table "messages", force: :cascade do |t|
    t.string   "content"
    t.integer  "user_id"
    t.integer  "hashtag_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notifications", force: :cascade do |t|
    t.integer  "notification_type",                 null: false
    t.integer  "user_id",                           null: false
    t.integer  "tricker_user_id"
    t.integer  "tricker_hashtag_id"
    t.boolean  "visible",            default: true, null: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  create_table "user_hashtags", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "hashtag_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "favourite",  default: false, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "username"
    t.string   "email"
    t.string   "campus"
    t.string   "unit"
    t.text     "about"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.string   "name"
    t.string   "title"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
  end

end

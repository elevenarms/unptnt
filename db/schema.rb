# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20081215231214) do

  create_table "boms", :force => true do |t|
    t.string   "project_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "clone_trees", :force => true do |t|
    t.integer  "project_id"
    t.integer  "lft"
    t.integer  "rt"
    t.integer  "rootnode"
    t.string   "relationship_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "clone_trees", ["project_id"], :name => "index_clone_trees_on_project_id"
  add_index "clone_trees", ["rootnode"], :name => "index_clone_trees_on_rootnode"

  create_table "doc_versions", :force => true do |t|
    t.string   "doc_id",                             :null => false
    t.string   "title"
    t.text     "content"
    t.integer  "version_num"
    t.boolean  "current_version"
    t.integer  "editor_id",                          :null => false
    t.string   "doc_type"
    t.integer  "item_id",                            :null => false
    t.integer  "project_id",                         :null => false
    t.datetime "last_edited_at"
    t.integer  "num_edits"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "home_page",       :default => false
    t.text     "content_html"
  end

  add_index "doc_versions", ["editor_id"], :name => "index_doc_versions_on_editor_id"
  add_index "doc_versions", ["doc_id"], :name => "index_doc_versions_on_doc_id"
  add_index "doc_versions", ["item_id"], :name => "index_doc_versions_on_item_id"
  add_index "doc_versions", ["project_id"], :name => "index_doc_versions_on_project_id"
  add_index "doc_versions", ["last_edited_at"], :name => "index_doc_versions_on_last_edited"

  create_table "events", :force => true do |t|
    t.integer  "user_id",     :null => false
    t.integer  "project_id",  :null => false
    t.integer  "action",      :null => false
    t.string   "data"
    t.text     "body"
    t.integer  "target_id"
    t.string   "target_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "file_attachments", :force => true do |t|
    t.integer  "item_id"
    t.string   "name"
    t.integer  "parent_id"
    t.string   "content_type"
    t.string   "filename"
    t.string   "thumbnail"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "forums", :force => true do |t|
    t.string  "name"
    t.string  "description"
    t.integer "topics_count",     :default => 0
    t.integer "posts_count",      :default => 0
    t.integer "position"
    t.text    "description_html"
    t.integer "subject_id"
    t.string  "subject_type"
  end

  create_table "invitations", :force => true do |t|
    t.integer  "sender_id"
    t.string   "recipient_email"
    t.string   "token"
    t.datetime "sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "items", :force => true do |t|
    t.integer  "bom_id"
    t.string   "name"
    t.text     "notes"
    t.integer  "quantity"
    t.string   "info_url",             :limit => 1000
    t.string   "item_type"
    t.string   "item_image_file_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "licenses", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "url"
    t.string   "license_image_file_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "moderatorships", :force => true do |t|
    t.integer "forum_id"
    t.integer "user_id"
  end

  add_index "moderatorships", ["forum_id"], :name => "index_moderatorships_on_forum_id"

  create_table "monitorships", :force => true do |t|
    t.integer "topic_id"
    t.integer "user_id"
    t.boolean "active",   :default => true
  end

  create_table "posts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "topic_id"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "forum_id"
    t.text     "body_html"
    t.integer  "subject_id"
    t.string   "subject_type"
  end

  add_index "posts", ["forum_id", "created_at"], :name => "index_posts_on_forum_id"
  add_index "posts", ["user_id", "created_at"], :name => "index_posts_on_user_id"
  add_index "posts", ["topic_id", "created_at"], :name => "index_posts_on_topic_id"

  create_table "project_people", :force => true do |t|
    t.integer  "project_id"
    t.integer  "user_id"
    t.string   "relationship"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.integer  "license_id"
    t.string   "description"
    t.string   "unptntnumber"
    t.string   "status",                  :limit => 140
    t.string   "project_image_file_name"
    t.string   "owner"
    t.string   "project_type"
    t.string   "project_subtype"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "statuses", :force => true do |t|
    t.integer  "project_id"
    t.string   "status_text", :limit => 140
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "taggable_type", :limit => 1000
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "tiny_mce_photos", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "user_id"
    t.string   "content_type"
    t.string   "filename"
    t.integer  "size"
    t.integer  "parent_id"
    t.string   "thumbnail"
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "topics", :force => true do |t|
    t.integer  "forum_id"
    t.integer  "user_id"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "hits",         :default => 0
    t.integer  "sticky",       :default => 0
    t.integer  "posts_count",  :default => 0
    t.datetime "replied_at"
    t.boolean  "locked",       :default => false
    t.integer  "replied_by"
    t.integer  "last_post_id"
    t.integer  "subject_id"
    t.string   "subject_type"
  end

  add_index "topics", ["forum_id"], :name => "index_topics_on_forum_id"
  add_index "topics", ["forum_id", "sticky", "replied_at"], :name => "index_topics_on_sticky_and_replied_at"
  add_index "topics", ["forum_id", "replied_at"], :name => "index_topics_on_forum_id_and_replied_at"

  create_table "users", :force => true do |t|
    t.string   "login",                     :limit => 40
    t.string   "name",                      :limit => 100, :default => ""
    t.string   "email",                     :limit => 100
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.string   "user_image_file_name"
    t.integer  "invitation_id"
    t.integer  "invitation_limit"
    t.integer  "posts_count",                              :default => 0
    t.datetime "last_seen_at"
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

end

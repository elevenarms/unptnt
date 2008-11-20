class CreateDocVersions < ActiveRecord::Migration
  def self.up
    create_table :doc_versions do |t|
      t.string :doc_id, :null => false
      t.string :title
      t.text :content
      t.integer :version_num
      t.boolean :current_version
      t.integer :editor_id, :null => false
      t.string :doc_type
      t.integer :item_id, :null => false
      t.integer :project_id, :null => false
      t.datetime :last_edited_at
      t.integer :num_edits
      t.timestamps
    end
    
    drop_table :documents
    
    puts "Setting primary keys"
    execute "CREATE INDEX index_doc_versions_on_editor_id ON doc_versions (editor_id)" 
    execute "CREATE INDEX index_doc_versions_on_doc_id ON doc_versions (doc_id(10))" 
    execute "CREATE INDEX index_doc_versions_on_item_id ON doc_versions (item_id)"
    execute "CREATE INDEX index_doc_versions_on_project_id ON doc_versions (project_id)"
    execute "CREATE INDEX index_doc_versions_on_last_edited ON doc_versions (last_edited_at)"
  end
  
  def self.down
    drop_table :doc_versions
    create_table :documents do |t|
      t.string :foo
    end
  end
end

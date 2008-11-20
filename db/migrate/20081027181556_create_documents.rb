class CreateDocuments < ActiveRecord::Migration
  def self.up
    create_table :documents do |t|
      t.string :current_title
      t.string :doc_type
      t.integer :item_id
      t.integer :project_id
      t.datetime :last_edited_at
      t.integer :current_version_num
      t.string :last_editor
      t.timestamps
    end
  end
  
  def self.down
    drop_table :documents
  end
end

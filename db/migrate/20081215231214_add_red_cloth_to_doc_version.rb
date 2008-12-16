class AddRedClothToDocVersion < ActiveRecord::Migration
  def self.up
    add_column :doc_versions, :content_html, :text
  end

  def self.down
    remove_column :doc_versions, :content_html
  end
end

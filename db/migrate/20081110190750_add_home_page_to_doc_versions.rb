class AddHomePageToDocVersions < ActiveRecord::Migration
  def self.up
    add_column :doc_versions, :home_page, :boolean, :default => false
  end

  def self.down
    remove_column :doc_versions, :home_page
  end
end

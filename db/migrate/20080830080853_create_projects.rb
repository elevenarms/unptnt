class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.column :name  , :string
      t.column :license_id, :integer
      t.column :description  , :string
      t.column :unptntnumber , :string
      t.column :status, :string, :limit => 140
      t.column :project_image_file_name, :string
      t.column :owner, :string
      t.column :project_type, :string
      t.column :project_subtype, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :projects
  end
end

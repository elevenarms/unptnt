class CreateLicenses < ActiveRecord::Migration
  def self.up
    create_table :licenses do |t|
      t.string :name
      t.string :description
      t.string :url
      t.string :license_image_file_name
      t.timestamps
    end
  end

  def self.down
    drop_table :licenses
  end
end

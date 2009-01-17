class CreateUploadedImages < ActiveRecord::Migration
  def self.up
    create_table :uploaded_images do |t|
      t.string :name
      t.integer :size
      t.string :content_type
      t.string :filename
      t.integer :height
      t.integer :width
      t.integer :parent_id
      t.string :thumbnail
      t.string :image_type
      t.string :purpose
      t.integer :user_id, :default => 0
      t.integer :project_id, :default => 0
      t.integer :item_id, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :uploaded_images
  end
end

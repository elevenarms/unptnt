class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.column :bom_id       , :integer
      t.column :name         , :string
      t.column :notes        , :text
      t.column :quantity     , :integer
      t.column :info_url     , :string, :limit => 1000    
      t.column :item_type    , :string
      t.column :item_image_file_name, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :items
  end
end

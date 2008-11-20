class CreateBoms < ActiveRecord::Migration
  def self.up
    create_table :boms do |t|
      t.column :project_id, :string
      t.column :name      , :string
      t.timestamps
    end
  end

  def self.down
      drop_table :boms
  end
end   

class AddThingsForAepBeast < ActiveRecord::Migration
  def self.up
    add_column :forums, :subject_id, :integer
    add_column :forums, :subject_type, :string
  end

  def self.down
    remove_column :forums, :subject_id
    remove_column :forums, :subject_type
  end
end

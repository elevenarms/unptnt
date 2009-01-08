class Bom < ActiveRecord::Base
  belongs_to :project
  has_many :items, :dependent => :delete_all
  
  #return items for BOM grouped by item type
  def items_grouped
    if self.items.nil? then
      return nil
    end  
    items = { :Hardware => [], :Software => [], :Tools => [] }

    self.items.each do |i|
      case i.item_type
      when "Hardware" then  items[:Hardware] << i
      when "Software" then items[:Software] << i
      when "Tools" then items[:Tools] << i
      end
    end   
    return items
  end  
end

class Bom < ActiveRecord::Base
  belongs_to :project
  has_many :items
  
  #return items for BOM grouped by item type
  def items_grouped
    if self.items.nil? then
      return nil
    end  
    items = { :Hardware => [], :Software => [], :Tools => [] }

    self.items.each do |i|
      case i.item_type
      when "Hardware" :  items[:Hardware] << i 
      when "Software" : items[:Software] << i
      when "Tools" : items[:Tools] << i
      end
    end   
    return items
  end  
end

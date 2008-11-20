module ProjectCloning
  protected
  
  #QUESTIONS:
  #   1) do we want to add all the project people of the original project to the clone? 
  #   2) do we want to copy the photos, or just point to them?
  #
  def clone_elements(new_project, old_project)
    #takes a parent and recreates it under new
    #must do project, BOM, Items, item_images, file_attachments, project_image, documents, tiny_mce_images 
    old_project_bom = old_project.bom
    unless old_project_bom.nil? then 
      att = old_project_bom.attributes
      att['project_id'] = new_project.id.to_s
      att['name'] = new_project.name
      new_bom = Bom.create(att)
      new_bom_id = new_bom.id.to_s
    else
      new_bom_id = nil
    end
    new_project.update_attributes(:bom_id => new_bom_id, 
           :license_id => old_project.license_id, :project_image_file_name => old_project.project_image_file_name,
           :keyword_list => old_project.keyword_list)
         
    timenow = Time.now.to_s
         
    #items
    unless old_project_bom.nil? then 
      old_items = old_project_bom.items
    else
      old_items = nil
    end
    old_items.each  do |i|
      att = i.attributes
      att['bom_id'] = new_bom_id
      Item.create(att)

      #do docs for this item
      old_docs = DocVersion.find(:all, :conditions => "doc_type = 'item' AND item_id = '#{i.id}'")
      old_docs.each do |d|
        att = d.attributes
        att['editor_id'] = current_user.id.to_s
        att['item_id'] = i.d_to_s
        att['doc_id'] = d.doc_id + timenow
        DocVersion.create(att)
      end  unless old_docs.nil?
    end  unless old_items.nil?
    
    #docuements
    old_docs = DocVersion.find(:all, :conditions => "doc_type = 'project' AND project_id = '#{old_project.id}'")
    old_docs.each do |d|
      att = d.attributes
      att['editor_id'] = current_user.id.to_s
      att['project_id'] = new_project.id.to_s
      att['doc_id'] = d.doc_id + timenow
      DocVersion.create(att)
    end unless old_docs.nil?
    
  end
end

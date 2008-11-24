module DocVersioning
  protected
  
  def make_new_doc
    #makes a new document 
    doc_version = DocVersion.new
    doc_version.doc_id = params[:doc_version][:title].slice(0,7) + DateTime.now.to_s
    unless DocVersion.find_by_doc_id(doc_version.id).nil?
      doc_version.doc_id = params[:doc_version][:title].slice(1,10) + DateTime.now.to_s
    end
    doc_version.title =  params[:doc_version][:title]
    doc_version.content =  params[:doc_version][:content]
    doc_version.version_num =  1
    doc_version.editor = current_user
    doc_version.project_id = params[:projectidnum]
    doc_version.item_id = params[:itemidnum]
    if params[:itemidnum] == 0 then
      doc_version.doc_type = "project"
    else
      doc_version.doc_type = "item"
    end
    doc_version.current_version = true
    doc_version.num_edits = 1
    doc_version.last_edited_at = DateTime.now
    doc_version.home_page = params[:home_page]
    return doc_version
  end
  
  def doc_version_to_display(projectidnum, itemidnum)
    if itemidnum == 0
      doc_version = DocVersion.find(:first,
        :conditions => "project_id = '#{ projectidnum }' AND home_page = true AND current_version = true", 
        :order => 'created_at')
    else
      doc_version = DocVersion.find(:first,
        :conditions => "item_id = '#{ itemidnum }' AND home_page = true AND current_version = true", 
        :order => 'created_at')
    end        
    return doc_version
  end
  
  def save_current_or_make_new(doc_version)
    if current_user == doc_version.editor then
      params[:doc_version][:num_edits] = doc_version.num_edits + 1
      doc_version.update_attributes(params[:doc_version])
    else  
      #must create a new version
      old = doc_version
      doc_version = DocVersion.new(old.attributes)
      old.update_attribute(:current_version,  false)
      old.save
      doc_version.version_num = old.version_num + 1
      doc_version.editor = current_user
      doc_version.current_version = true
      doc_version.title = params[:doc_version][:title]
      doc_version.content = params[:doc_version][:content]
      doc_version.num_edits = 1
      doc_version.last_edited_at = DateTime.now 
    end          
  end
end


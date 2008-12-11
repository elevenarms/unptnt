# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  require 'ruby-debug'
  def action_and_body_for_event(event)
    target = event.target
    action = ""
    body = ""
    category = ""
    case event.action
      when Action::CREATE_PROJECT
        action = "<strong>created project</strong> #{link_to h(target.name), project_path(target)}"
        body = "<strong>#{target.name} - #{target.description}</strong>"
        category = "project"
      when Action::DELETE_PROJECT
        action = "<strong>deleted project</strong> - #{h(target.name)}"
        category = "project"
      when Action::UPDATE_PROJECT
        action = "<strong>updated project</strong> #{link_to h(target.name), project_path(target)}"
        category = "project"
      when Action::CREATE_ITEM
        bom = Bom.find(target.bom_id)
        action = "<strong>created item</strong> #{link_to h(target.name), bom_item_path(bom,target)}"
        body = "#{target.name} - #{target}"
        category = "materials"
      when Action::DELETE_ITEM
        action = "<strong>deleted item</strong> #{h(target.name)}"
        category = "materials"
      when Action::UPDATE_ITEM
        bom=Bom.find(target.bom_id)
        action = "<strong>updated item</strong> #{link_to h(target.name), bom_item_path(bom,target)}"
        body = "#{target.name} - "
        category = "materials"
      when Action::CREATE_DOC
        action = "<strong>created document</strong> #{link_to h(target.name), item_path(target)}"
        body = "#{target.title} - "
        category = "docs"
      when Action::UPDATE_DOC
        action = "<strong>created document</strong> #{link_to h(target.name), item_path(target)}"
        body = "#{target.title} - "
        category = "docs"
      when Action::DELETE_DOC
        action = "<strong>created document</strong> #{link_to h(target.name), item_path(target)}"
        body = "#{target.title} - "
        category = "docs"
      when Action::BEGIN_FOLLOW
        action = "<strong>created document</strong> #{link_to h(target.name), item_path(target)}"
        body = "#{target.title} - #{target.description}"
        category = "people"
      when Action::BEGIN_COLLAB
        action = "<strong>created document</strong> #{link_to h(target.name), item_path(target)}"
        body = "#{target.title} - #{target.description}"
        category = "people"
      when Action::CREATE_TOPIC
        action = "<strong>created document</strong> #{link_to h(target.name), item_path(target)}"
        body = "#{target.title} - #{target.description}"
        category = "discuss"
      when Action::UPDATE_TOPIC
        action = "<strong>created document</strong> #{link_to h(target.name), item_path(target)}"
        body = "#{target.title} - #{target.description}"
        category = "discuss"
      when Action::DELETE_POST
        action = "<strong>created document</strong> #{link_to h(target.name), item_path(target)}"
        body = "#{target.title} - #{target.description}"
        category = "discuss"
      when Action::CREATE_POST
        action = "<strong>created document</strong> #{link_to h(target.name), item_path(target)}"
        body = "#{target.title} - #{target.description}"
        category = "discuss"
      when Action::UPDATE_POST
        action = "<strong>created document</strong> #{link_to h(target.name), item_path(target)}"
        body = "#{target.title} - #{target.description}"
        category = "discuss"
      when Action::DELETE_POST
        action = "<strong>created document</strong> #{link_to h(target.name), item_path(target)}"
        body = "#{target.title} - #{target.description}"
        category = "discuss"
      when Action::CLONE_REPOSITORY
        original_repo = Repository.find_by_id(event.data.to_i)
        next if original_repo.nil?

        project = target.project

        action = "<strong>cloned</strong> #{link_to h(project.slug), project_path(project)}/#{link_to h(original_repo.name), project_repository_url(project, original_repo)} in #{link_to h(target.name), project_repository_url(project, target)}"
        category = "repository"

    end

    [action, body, category]
  end
end

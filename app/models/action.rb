class Action
  CREATE_PROJECT = 0
  DELETE_PROJECT = 1
  UPDATE_PROJECT = 2
  CREATE_ITEM = 3
  UPDATE_ITEM = 4
  DELETE_ITEM = 5
  CREATE_DOC = 6
  DELETE_DOC = 7
  UPDATE_DOC = 8
  DELETE_TAG = 9
  BEGIN_FOLLOW = 10
  BEGIN_COLLAB = 11
  COMMENT = 12
  REQUEST_MERGE = 13
  RESOLVE_MERGE_REQUEST = 14
  UPDATE_MERGE_REQUEST = 15
  DELETE_MERGE_REQUEST = 16
  
  def self.name(action_id)
    case action_id
      when CREATE_PROJECT
        "create project"
      when DELETE_PROJECT
        "delete project"
      when UPDATE_PROJECT
        "update project"
      when CREATE_ITEM
        "create item"
      when UPDATE_ITEM
        "update item"
      when DELETE_ITEM
        "delete item"
      when CREATE_DOC
        "create document"
      when DELETE_DOC
        "delete document"
      when UPDATE_DOC
        "update document"
      when BEGIN_FOLLOW
        "now following"
      when BEGIN_COLLAB
        "now collaborating"
      when REMOVE_COMMITTER
        "remove committer"
      when COMMENT
        "comment"
      when REQUEST_MERGE
        "request merge"
      when RESOLVE_MERGE_REQUEST
        "resolve merge request"
      when UPDATE_MERGE_REQUEST
        "update merge request"
      when DELETE_MERGE_REQUEST
        "delete merge request"
    end
  end
end

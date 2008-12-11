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
  NEW_TOPIC = 12
  EDIT_TOPIC = 13
  DELETE_TOPIC=14
  NEW_POST = 15
  EDIT_POST= 16
  DELETE_POST = 17

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
      when CREATE_TOPIC
        "create topic"
      when UPDATE_TOPIC
        "update topic"
      when DELETE_TOPIC
        "delete topic"
      when CREATE_POST
        "create post"
      when UPDATE_POST
        "update post"
      when DELETE_POST
        "delete post"
    end
  end
end

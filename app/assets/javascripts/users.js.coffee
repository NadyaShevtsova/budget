@module 'Users', ->
  @module 'EditForm', ->
    @init =->
      $('.glyphicon-link, .glyphicon-folder-open').click ->
        $(".form-group.hidden").removeClass 'hidden'
        $(@).closest('.form-group').addClass 'hidden'
        return

$ ->
  Users.EditForm.init() if $('#registrations-edit').length

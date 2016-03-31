@module 'Users', ->
  @module 'EditForm', ->
    @init =->
      $('.glyphicon-link, .glyphicon-folder-open').click ->
        $(".toggle_photo").closest('.form-group').toggleClass 'hidden'
        return

$ ->
  Users.EditForm.init() if $('#registrations-edit').length

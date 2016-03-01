@module 'Categories', ->
  @module 'IndexSortable', ->
    @init =->
      initSortable()
      initDelete()

    initSortable = ->
      $('#sortable').sortable
        axis: 'y'
        update: ->
          $.post($(this).data('update-url'), $(this).sortable('serialize'))

    initDelete = ->
      $("body").on 'click', ".ui-sortable li a.delete-category-js", (e) ->
        e.preventDefault()
        self = $(@)
        if confirm('Are you sure you want to delete this Category?')
          $.ajax
            method: 'DELETE'
            url: self.attr('href')
            success: (data) ->
              self.closest("li").remove()
              Notifications.info(data.success)
            error: (xhr, ajaxOptions, thrownError) ->
              response = $.parseJSON(xhr.responseText)
              Notifications.info(response.error)

$ ->
  Categories.IndexSortable.init() if $('#categories-index').length

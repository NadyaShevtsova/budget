@module 'Transactions', ->
  @module 'Index', ->
    @init =->
      table = initDatatable()
      initDelete(table)
      GoogleChart.init()

    initDatatable = ->
      $(".datatable table").DataTable({
        aLengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, "All"]],
        order: [[2, 'desc']],
        columnDefs: [{ orderable: false, targets: [5] }],
        processing: true,
        serverSide: true,
        ajax:
          url: $(@).data('source')
      })

    initDelete = (table) ->
      $("body .datatable").on 'click', "a.delete-transaction-js", (e) ->
        e.preventDefault()
        self = $(@)
        if confirm('Are you sure you want to delete this Transaction?')
          $.ajax
            method: 'DELETE'
            url: self.attr('href')
            success: (data) ->
              Notifications.info(data.success)
              table.ajax.reload()
            error: (xhr, ajaxOptions, thrownError) ->
              response = $.parseJSON(xhr.responseText)
              Notifications.info(response.error)


$ ->
  Transactions.Index.init() if $('#transactions-index').length

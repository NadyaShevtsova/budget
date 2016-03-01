@module 'Notifications', ->
  @info = (message) ->
    $('#flash_notice').remove()
    $('body #user_notices').after("<div id='flash_notice'>#{ message }</div>")

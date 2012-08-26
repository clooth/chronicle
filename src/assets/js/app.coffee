#= require requestanimframe
#= require logo_animation

canvas  = document.getElementById 'game'
context = canvas.getContext '2d'

socket = new io.connect 'http://localhost:8100'

# Main class to handle keystroes
class KeyMaster
    @UP    = 'UP'
    @RIGHT = 'RIGHT'
    @DOWN  = 'DOWN'
    @LEFT  = 'LEFT'

    constructor: () ->
        # Keycode map
        @Keys =
            37: KeyMaster.LEFT
            38: KeyMaster.UP
            39: KeyMaster.RIGHT
            40: KeyMaster.DOWN

    # Handler for a keystroke event
    handleStroke: (event) ->
        if event?
            keyCode = event.keyCode
        else
            keyCode = window.event.keyCode

        socket.send @Keys[keyCode]


# Main game class
class Chronicle
    constructor: (@players) ->

class Chronicle.Player
    constructor: (x, y) ->
        @x = x
        @y = y

socket.on 'news', (data) ->
    console.log data
    socket.emit 'my other event', my: 'data'

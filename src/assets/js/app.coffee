#= require includes/requestanimframe
#= require includes/logo_animation

$ ->
class Chronicle
    constructor: (@map) ->
        # This is where we hold all our currently viewable players
        @players = {}

    addPlayer: (player) ->
        @players[player.id] = player
        # Show on map
        @players[player.id].draw x: 0, y: 0

    setCurrentPlayer: (id) ->
        @currentPlayer = @getPlayer(id)

    getCurrentPlayer: () ->
        @currentPlayer

    getPlayer: (id) ->
        @players[id] or null

    # Remove a player from the game
    removePlayer: (id) ->
        delete @players[id]

    setMap: (map) ->
        @map = map


class Map
    constructor: () ->
        # Set up map layers
        @layers =
            bottom:  document.getElementById('bottom')
            decor:   document.getElementById('decor')
            solids:  document.getElementById('solids')
            players: document.getElementById('players')
            overlay: document.getElementById('overlay')

    initialize: (data) ->
        for layer, layerData of data
            @layers[layer].render(layerData)

    context: (layer) ->
        @layers[layer].getContext '2d'


# This is a character sheet for Chronicle, it holds sprite data for
# a player object.
class Chronicle.CharacterSheet
    # Directional offsets for sprites
    @SpriteOffets =
        south: 0
        west:  32
        east:  64
        north: 96

    constructor: (@dataURL, callback) ->
        # The image to hold our current sprite
        @image = new Image
        # Size of our character sprite
        @spriteSize =
            width:  32
            height: 32

        if dataURL?
            @createFromData @dataURL, callback

    createFromData: (dataURL, callback) ->
        image = @image

        image.onload = () =>
            @image = image
            callback @

        image.src = dataURL


# Main player class, handles movement and whatnot.
class Chronicle.Player
    constructor: (@sheet, @id) ->
        # Player position
        @position =
            x: 0
            y: 0
        # Current sprite
        @sprite = 'south'
        @spriteOffsets =
            x: 32
            y: 0

    draw: (@position) ->
        @clearSprite()
        chronicle.map.context('players').drawImage(
            @sheet.image,
            @spriteOffsets.x,
            @spriteOffsets.y,
            @sheet.spriteSize.width,
            @sheet.spriteSize.height,
            @position.x,
            @position.y,
            @sheet.spriteSize.width,
            @sheet.spriteSize.height
        )

    setSprite: (direction) ->
        switch direction
            when 'north'
                @sprite = 'north'
                @spriteOffsets = x: 32, y: 96
                break
            when 'west'
                @sprite = 'west'
                @spriteOffsets = x: 32, y: 32
                break
            when 'east'
                @sprite = 'east'
                @spriteOffsets = x: 32, y: 64
                break
            when 'south'
                @sprite = 'south'
                @spriteOffsets = x: 32, y: 0

    move: (direction) ->
        @clearSprite()
        @setSprite(direction)
        switch direction
            when 'west'
                @draw x: @position.x - 32, y: @position.y
                break
            when 'north'
                @draw x: @position.x, y: @position.y - 32
                break
            when 'east'
                @draw x: @position.x + 32, y: @position.y
                break
            when 'south'
                @draw x: @position.x, y: @position.y + 32

    setPosition: (position) ->
        @position = position

    clearSprite: () ->
        chronicle.map.context('players').clearRect(
            @position.x,
            @position.y,
            @sheet.spriteSize.width,
            @sheet.spriteSize.height
        )

    getPlayerInfo: () ->
        position: @position, sprite: @sprite


# Main class to handle keystroes
class KeyMaster
    @LEFT  = 37
    @UP    = 38
    @RIGHT = 39
    @DOWN  = 40

    constructor: () ->

    # Handler for a keystroke event
    handleStroke: (event) ->
        @player = chronicle.getCurrentPlayer()

        if event?
            keyCode = event.keyCode
        else
            keyCode = window.event.keyCode

        switch keyCode
            when KeyMaster.LEFT
                @player.move('west')
                break
            when KeyMaster.UP
                @player.move('north')
                break
            when KeyMaster.RIGHT
                @player.move('east')
                break
            when KeyMaster.DOWN
                @player.move('south')
            else
                return

        socket.json.send type: 'playerMoved', data: @player.getPlayerInfo()

$ ->
    window.chronicle = new Chronicle(new Map(document.getElementById('#world')))
    window.socket    = new io.connect 'http://localhost:8100'

    # Socket handler
    socket.on 'message', (message) ->
        switch message.type

            # Character sheet loaded
            when 'characterSheet'
                ((message)->
                    sheet = new Chronicle.CharacterSheet message.data, (sheet) ->
                        player = new Chronicle.Player(sheet, message.id)
                        chronicle.addPlayer(player)
                        chronicle.setCurrentPlayer(player.id)

                        socket.json.send type: 'playerJoined', data: player.getPlayerInfo()
                )(message)
                break

            # A player has joined
            when 'playerJoined'
                ((message)->
                    sheet = new Chronicle.CharacterSheet message.data.spriteSheetDataURL, (sheet) ->
                        player = new Chronicle.Player(sheet, message.id)
                        player.setSprite   message.data.sprite
                        player.setPosition message.data.position
                        player.draw        message.data.position
                        chronicle.addPlayer(player)
                )(message)
                break

            # A player has moved
            # TODO: Create PlayerManager
            # TODO: Move this to PlayerManager
            when 'playerMoved'
                ((player)->
                    player.clearSprite()
                    player.setSprite message.data.sprite
                    player.draw      message.data.position
                )(chronicle.getPlayer message.id)
                break

            # Player disconnected
            when 'playerLeft'
                ((player) ->
                    player.clearSprite()
                    chronicle.removePlayer(player.id)
                )(chronicle.getPlayer message.id)
                break

            else
                console.log message
                break

    keyMaster = new KeyMaster(socket)
    $(document).bind 'keyup', (event) ->
        keyMaster.handleStroke event
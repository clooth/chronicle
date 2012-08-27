# Required for our main system
require 'coffee-script'

# Logging
logger = require './shared/logger'

# Common
common = require './server/game/common'

# Setup server
logger.success 'Chronicle server starting...'
app     = common.express()
server  = common.http.createServer(app)
io      = common.io.listen(server)

server.listen 8100

# Directories
server_path = "#{__dirname}"
shared_path = "#{server_path}/shared"
client_path = "#{server_path}/client"
assets_path = "#{server_path}/assets"
views_path  = "#{server_path}/views"

# Views
app.set 'views', views_path
app.set 'view engine', 'jade'

# Static files
logger.info 'Setting up static files...'
app.use require('connect-assets') src: assets_path
app.use '/img', common.express.static("#{assets_path}/img")

# Routes
logger.info 'Setting up app routes...'
app.get '/', (request, response) ->
	response.render 'main/index', title: 'Home'

app.get '/world', (request, response) ->
	response.render 'main/world', title: 'World'

app.get '/tileset', (request, response) ->
	response.render ''

# Loading game specific libs
spritesheets = require './server/game/spritesheet_manager'
tilesets     = require './server/game/tileset_manager'
playerBuffer = require './server/game/player_buffer'

# Socket handlers
logger.info 'Setting up socket.io handlers'

# On client connection
io.sockets.on 'connection', (client) ->
	# Give the user their character sheet
	logger.info "Client connected: #{client.id}"
	spritesheets.load 'default', (sheet) ->
		logger.success 'Loaded `default` spritesheet.'
		common.sendClientMessage client, 'characterSheet', sheet.canvas.toDataURL()

	# Listen for client events
	client.on 'message', (message) ->
		switch message.type
			when 'playerJoined'
				message.data.spriteSheetDataURL = spritesheets.get('default').canvas.toDataURL()
				common.sendClientBroadcast client, 'playerJoined', message.data

				playerBuffer.send client
				playerBuffer.set  client.id, message.data

				logger.success "New player joined: #{client.id}"
				break
			when 'playerMoved'
				common.sendClientBroadcast client, 'playerMoved', message.data

				playerBuffer.set(client.id, message.data)

				logger.info "Player ##{client.id} moved"
				break

	client.on 'disconnect', () ->
		common.sendClientBroadcast client, 'playerLeft', null

		playerBuffer.remove client.id

		logger.info "Player ##{client.id} left"
logger.success 'Listening...'
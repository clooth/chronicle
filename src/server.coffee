# Required for our main system
require 'coffee-script'

# Logging
logger = require './shared/logger'

# Setup server
logger.success 'Chronicle server starting...'
express = require 'express'
http    = require 'http'
io      = require 'socket.io'
app     = express()
server  = http.createServer(app)
io      = io.listen(server)

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
app.use '/img', express.static("#{assets_path}/img")

# Routes
logger.info 'Setting up app routes...'
app.get '/', (request, response) ->
	response.render 'main/index', title: 'Foobar'

app.get '/map', (request, response) ->
	response.sendfile "#{client_path}/map.html"

# socket.io handlers
logger.info 'Setting up socket.io handlers'
io.sockets.on 'connection', (socket) ->
	socket.emit 'news', hello: 'world'
	socket.on 'my other event', (data) ->
		console.log data
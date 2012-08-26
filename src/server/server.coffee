express = require 'express'
app     = express()
http    = require 'http'
server  = http.createServer(app)
io      = require('socket.io').listen(server)

server_path = "#{__dirname}"
shared_path = "#{server_path}/../shared"
client_path = "#{server_path}/../client"

server.listen 8100

app.use '/assets', express.static "#{shared_path}/assets"

# Main index page
app.get '/', (request, response) ->
	response.sendfile "#{__dirname}/public/index.html"

# Map test page
app.get '/map', (request, response) ->
	response.sendfile "#{__dirname}/public/map.html"

io.sockets.on 'connection', (socket) ->
	socket.emit 'news', hello: 'world'
	socket.on 'my other event', (data) ->
		console.log data
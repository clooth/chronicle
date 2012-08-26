express = require 'express'
app     = express()
http    = require 'http'
server  = http.createServer(app)
io      = require('socket.io').listen(server)

server.listen 8100

app.use '/assets', express.static "#{__dirname}/assets"

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
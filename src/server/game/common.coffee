# Core
exports.fs      = require 'fs'
exports.express = require 'express'
exports.http    = require 'http'
exports.io      = require 'socket.io'

# node-canvas
Canvas = require 'canvas'
exports.Canvas = Canvas

# Paths
paths =
	tilesets: 		  "#{__dirname}/world/tilesets"
	character_sheets: "#{__dirname}/world/character_sheets"
	maps: 			  "#{__dirname}/world/maps"

exports.paths = paths

# Image loader
exports.loadImage = (path, callback) ->
	exports.fs.readFile path, (error, data) ->
		image     = new Canvas.Image
		image.src = data
		callback(image)

# Client communicator
exports.sendClientMessage = (client, messageType, messageData) ->
	client.json.send id: client.id, type: messageType, data: messageData

exports.sendClientBroadcast = (client, messageType, messageData) ->
	client.json.broadcast.send id: client.id, type: messageType, data: messageData
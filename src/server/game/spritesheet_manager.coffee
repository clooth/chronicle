common = require './common'

class SpriteSheet
	constructor: (@image, @options) ->
		@name       = @options.name or null
		@spriteSize = @options.spriteSize or 0
		@imageName  = @options.imageName or null

	validate: () ->

	initialize: () ->
		@canvas  = new common.Canvas @image.width, @image.height
		@context = @canvas.getContext '2d'
		@context.drawImage @image, 0, 0, @canvas.width, @canvas.height
		@validate()

class SpriteSheetFactory
	constructor: () ->
		@spritesheets = {}

	create: (@data, callback) ->
		sheetImagePath = "#{common.paths.character_sheets}/images/#{@data.imageName}"
		@data.imagePath = sheetImagePath

		common.loadImage sheetImagePath, (image) =>
			sheet = new SpriteSheet(image, @data)
			@spritesheets[sheet.name] = sheet
			callback(sheet)

	get: (name) ->
		@spritesheets[name] or null


class SpriteSheetManager
	constructor: () ->
		@factory = new SpriteSheetFactory()

	load: (sheetName, callback) ->
		sheetPath = "#{common.paths.character_sheets}/#{sheetName}.json"
		sheetJSON = require sheetPath

		@factory.create sheetJSON, (sheet) =>
			@onSheetLoaded(sheet, callback)

	onSheetLoaded: (sheet, callback) ->
		sheet.initialize()
		callback(sheet)

	get: (sheetName) ->
		@factory.get(sheetName)

module.exports = new SpriteSheetManager()
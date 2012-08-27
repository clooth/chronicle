common = require './common'
Canvas = require 'canvas'

# A Basic map tile image containing the
# information and image of the tile
class TileError extends Error
class Tile
	constructor: (@canvas, @options) ->
		# Can our character walk over this tile?
		@walkable = !!@options.walkable or true

		# Extract options
		@name   = @options.name or null
		@size   = @options.size or 0
		@coords =
			x: @options.coords[0]
			y: @options.coords[1]

		# Validate
		@validate()

	# Validate the tile data
	validate: () ->
		# Name cannot be empty
		unless @name?
			throw new TileError "Missing Tile Name"
		# The image needs to be an instance of canvas
		unless @canvas instanceof Canvas
			throw new TileError "Invalid Tile Image: #{@image}"
		# Size has to be more than 0
		unless @size > 0
			throw new TileError "Invalid Tile Size: #{@size}"

###
Tile is invalid since size is 0
	invalidTile = new Tile new Canvas(32, 32), size: 0
Tile is invalid because image is invalid
	invalidTile2 = new Tile null, size: 32
This tile is perfectly valid
	validTile   = new Tile new Canvas(32, 32), size: 32
###

# The Factory that creates tile objects
# This is used for extracting tile images from tilesets
# and creating new instances of the Tile class
class TileFactory
	constructor: (@tileData, @tileset, @tileSize) ->
		@tileClass = Tile
		# This is where we store all created tiles
		@tiles     = {}

		@initialize()

	initialize: () ->
		for tile in @tileData
			@create(tile)

	# Extract the tile image from the tileset
	extract: (options) ->
		# Tile options
		coords = options.coords
		size   = options.size

		# Prepare the tile's canvas
		canvas  = new Canvas size, size
		context = canvas.getContext '2d'

		# Extract the tile image from the tileset
		context.drawImage(@tileset, coords.x, coords.y, size, size, 0, 0, size, size)

		# Pass resulting canvas
		canvas

	# Create a new Tile instance
	create: (options) ->
		# Load the
		@tiles[options.name] = new @tileClass(@extract(options), options)

	# Get a tile by name
	get: (name) ->
		@tiles[name] or null


# This is a map tileset, it contains a TileManager from which you can
# get a list of tiles, or find a tile by name
class TilesetError extends Error
class Tileset
	constructor: (@image, @options) ->
		# Extract parameters
		@name      = @options.name or null
		@tileSize  = @options.tileSize or 0
		@imageName = @options.imageName or null

	# Validate this tileset
	validate: () ->
		# Name cannot be blank
		unless @name?
			throw new TilesetError "A Tileset cannot be unnamed"
		# Tile size has to be defined
		unless @tileSize > 0
			throw new TilesetError "Invalid Tileset Tile size: #{@tileSize}"
		# Image is required for the tileset
		unless @canvas instanceof Canvas
			throw new TilesetError "Invalid Tileset Image Type: #{@canvas}"

	initialize: () ->
		# Prepare canvas for drawing
		@canvas  = new Canvas @image.width, @image.height
		@context = @canvas.getContext '2d'

		# Apply tileset image
		@context.drawImage @image, 0, 0, @canvas.width, @canvas.height

		# Run validations
		@validate()

		# This is where we will be getting our individual tiles from
		@tiles = new TileFactory(@options.tiles, @canvas, @tileSize)


# This is the factory that creates instances of Tilesets and keeps track
# of all the created tilesets.
class TilesetFactory
	constructor: () ->
		@tilesets     = {}
		@tilesetClass = Tileset

	create: (@data, callback) ->
		# Get the absolute path to the tileset image
		tilesetImagePath = "#{common.paths.tilesets}/images/#{@data.name}.png"
		@data.imagePath = tilesetImagePath

		# Load tileset image
		common.loadImage tilesetImagePath, (image) =>
			tileset = new Tileset(image, @data)
			@tilesets[tileset.name] = tileset
			callback(tileset)

	get: (name) ->
		@tilesets[name] or null


# This is the publicly exposed manager for all Tilesets, it has a factory
# property which can be used to create new tilesets, or get information of
# the tilesets within the factory.
class TilesetManager
	constructor: () ->
		@factory = new TilesetFactory()

	# Load the information of our tileset
	load: (name) ->
		tileset_path = "#{common.paths.tilesets}/#{name}.json"
		tileset_json = require tileset_path
		# Now that we have the information of the tileset, we can
		# create a new tileset instance.
		@factory.create(tileset_json, @onTilesetLoaded)

	onTilesetLoaded: (tileset) ->
		tileset.initialize()

	get: (name) ->
		@factory.get(name)

module.exports = new TilesetManager()
buffer = {}

exports.buffer = buffer

exports.set = (id, data) ->
	if not buffer[id]
		buffer[id] = data
		return

	for attr, value of data
		buffer[id][attr] = value

exports.remove = (id) ->
	delete buffer[id]

exports.send = (client) ->
	for id, value of buffer
		client.json.send id: id, type: 'playerJoined', data: value
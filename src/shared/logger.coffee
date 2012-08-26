#
# Logger utility
#

# Colors available
colors =
	bold:    '\x1b[0;1m'
	reset:   '\x1b[0m'
	red:     '\x1b[0;31m'
	green:   '\x1b[0;32m'
	yellow:  '\x1b[0;33m'
	blue:    '\x1b[0;34m'
	magenta: '\x1b[0;35m'
	cyan:    '\x1b[0;36m'
	white:   '\x1b[0;37m'

exports.colors = colors

log = (message, color) ->
	text = "#{colors.bold}#{colors.cyan}-> #{colors.reset}"
	text+= "#{color}#{message}#{colors.reset}"
	console.log text

info    = (message)		   -> log "#{message}", colors.blue
warning = (message)        -> log "#{message}", colors.yellow
error   = (message)        -> log "#{message}", colors.red
success = (message)        -> log "#{message}", colors.green

exports.log     = log
exports.success = success
exports.warning = warning
exports.error   = error
exports.info    = info

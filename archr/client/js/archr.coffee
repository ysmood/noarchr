
class NAR.Archr
	constructor: ->
		require([
			_.u() + 'socket.io/socket.io.js'
			_.u() + 'ys-keymaster/keymaster.js'
		], =>
			@init_cmder()
		)

	init_cmder: ->
		@$cmder = $('#cmder')

		@$cmder.keyup (e) =>
			@cmd = e.target.value

		key.filter = (e) ->
			!e.target.classList.contains('keymaster-ignore')

		key 'enter', @exec_cmd

		@cmd_sock = io.connect(_.u() + 'cmd')

	exec_cmd: =>
		@cmd_sock.emit('exec', @cmd)

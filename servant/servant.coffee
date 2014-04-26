class NAR.Servant extends NB.Module
	constructor: ->
		super

		@init_cmder()

	init_cmder: ->
		io = NB.io.of('/cmd').on 'connection', (sock) =>
			sock.on 'exec', @exec

	exec: (data) =>
		console.log data
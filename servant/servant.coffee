os = require '../sys/os'

class NAR.Servant extends NB.Module
	constructor: ->
		super

		@init_cmder()

	init_cmder: ->
		@open_cmd = 'open'

		io = NB.io.of('/cmd').on 'connection', (sock) =>
			sock.on 'exec', @exec

	exec: (data) =>
		switch data
			when 'g'
				os.spawn @open_cmd, ['/Applications/Google\ Chrome.app', 'http://google.com.hk']
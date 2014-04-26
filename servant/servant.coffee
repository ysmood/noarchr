os = require '../sys/os'

class NAR.Servant extends NB.Module
	constructor: ->
		super

		@init_cmder()

	init_cmder: ->
		io = NB.io.of('/cmd').on 'connection', (sock) =>
			sock.on 'exec', @exec

	exec: (data) =>
		switch data
			when 'g'
				os.spawn 'open', ['/Applications/Google\ Chrome.app', 'http://google.com.hk']
os = require '../sys/os'
Q = require 'q'

class NAR.Cmd
	constructor: (cmd) ->
		_.defaults cmd, {
			type: 'cmd'

			# open, run, js
			exec_type: 'open'

			comment: null

			# string or array
			name: null

			group: null

			cwd: process.cwd()

			cmd_data: null

			args: null
		}

		@init_open_cmd()

		_.extend @, cmd

	init_open_cmd: ->
		switch process.platform
			# mac
			when 'darwin'
				@open_cmd = 'open'
			# widnows
			when 'win32'
				@open_cmd = 'start'
			# linux
			when 'linux'
				@open_cmd = null

	to_json: ->
		JSON.stringify @

	exec: ->
		switch @exec_type
			when 'open'
				argv = if @args then @cmd_data.concat(@args) else @cmd_data
				os.spawn @open_cmd, argv

			when 'run'
				os.spawn(
					@cmd_data.bin
					@cmd_data.args
				)

			when 'js'
				Q.fcall =>
					eval @cmd_data

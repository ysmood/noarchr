
class NAR.Archr
	constructor: ->
		require([
			_.u() + 'socket.io/socket.io.js'
			_.u() + 'ys-keymaster/keymaster.js'
		], =>
			@init_cmder()
		)

		@init_cmd_add()

	init_cmder: ->
		@$cmder = $('#cmder')

		@$cmder.keyup (e) =>
			@cmd_name = e.target.value

		key.filter = (e) ->
			!e.target.classList.contains('keymaster-ignore')

		key 'enter', @exec_cmd

		@$cmder.focus()

	exec_cmd: =>
		if @$cmder.is(':focus')
			$.get('/cmd/exec', { name: @cmd_name })
			.done (data) ->
				console.log data

	init_cmd_add: ->
		self = @
		$btn = $('#btn-add-cmd')
		editor = null
		$btn.click ->
			$tpl = $(
				_.template $('#tpl-add-cmd').html(), {}
			)
			$type = $tpl.find '.cmd-type select'
			$editor = $tpl.find '.cmd-editor'

			$msg_box = _.msg_box {
				title: 'Add Cmd'
				body: $tpl
				is_capture_enter: false
				btn_list: [
					{
						name: 'OK'
						clicked: ->
							self.add_cmd editor.getValue()
							$msg_box.modal('hide')
					}
				]
			}

			$type.change ->
				editor = self.init_editor $editor, $type.val()
			$type.change()

	init_editor: ($elem, type) ->
		schema = {
			title: 'Cmd'
			type: 'object'
			properties: {
				name: {
					type: 'string'
				}
			}
		}

		switch type
			when 'open'
				schema.properties.cmd_data = {
					type: 'array'
				}
			when 'run'
				schema.properties.cmd_data = {
					type: 'object'
					properties: {
						bin: {
							type: 'string'
						}
						args: {
							type: 'array'
						}
					}
				}
			when 'js'
				schema.properties.cmd_data = {
					type: 'string'
					format: 'javascript'
				}

		$elem.empty()
		editor = new JSONEditor $elem[0], {
			theme: 'bootstrap3'
			iconlib: 'fontawesome4'
			schema
		}

	add_cmd: (cmd) ->
		$.post('/cmd/add', cmd)
		.done (data) ->
			console.log data

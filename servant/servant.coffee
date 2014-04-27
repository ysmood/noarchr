require './cmd'

class NAR.Servant extends NB.Module
	constructor: ->
		super

		NB.app.get '/cmd/exec', @exec_cmd
		NB.app.post '/cmd/add', @add_cmd

	add_cmd: (req, res) =>
		cmd = new NAR.Cmd req.body
		NB.database.nedb.insert cmd, (err, doc) ->
			console.log ">> Add cmd: #{doc.name}".cyan
			res.send 200

	exec_cmd: (req, res) =>
		NB.database.nedb.findOne { type: 'cmd', name: req.query.name }, (err, doc) ->
			if err
				console.error err
				res.send 500
				return

			doc.args = req.query.args
			cmd = new NAR.Cmd doc
			cmd.exec()
			.then ->
				console.log ">> Exec cmd: #{cmd.name}".cyan
				res.send 200
			.catch (e) ->
				console.error ">> Exec error: #{cmd.name}".red
				res.send 500
			.done()
require './cmd'

class NAR.Servant extends NB.Module
	constructor: ->
		super

		NB.app.post '/cmd/add', @add_cmd
		NB.app.get '/cmd/get_all', @get_all
		NB.app.post '/cmd/put/:name', @add_cmd
		NB.app.get '/cmd/del/:name', @del_cmd
		NB.app.get '/cmd/exec/:name', @exec_cmd

	add_cmd: (req, res) =>
		cmd = new NAR.Cmd req.body
		if not cmd.name
			res.send 500
			return

		NB.database.nedb.insert cmd, (err, doc) ->
			console.log ">> Add cmd: #{doc.name}".cyan
			res.send { _id: doc._id }

	get_all: (req, res) =>
		NB.database.nedb.find { type: 'cmd' }, (err, docs) ->
			res.send docs

	put_cmd: (req, res) =>
		cmd = new NAR.Cmd req.body
		NB.database.nedb.update { type: 'cmd', name: req.params.name }, cmd, (err, num) ->
			console.log ">> Put cmd: #{doc.name}".cyan
			res.send 200

	del_cmd: (req, res) =>
		NB.database.nedb.remove { type: 'cmd', name: req.params.name }, (err, num) ->
			console.log ">> Del cmd: #{req.params.name}".cyan
			res.send 200

	exec_cmd: (req, res) =>
		NB.database.nedb.findOne { type: 'cmd', name: req.params.name }, (err, doc) ->
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

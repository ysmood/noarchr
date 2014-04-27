# Underscore helpers


_.mixin(

	u: ->
		###
			url prefix
		###
		NB.conf.url_prefix

	msg_box: (options) ->
		###
			options: {
				title: html or jQuery
				body: html or jQuery
				btn_list: [
					{
						name: string
						class: string
						is_default: true
						clicked: ->
					}
				]
				shown: ->
				closed: ->
			}
		###

		defaults =
			title: _.l('Title')
			body: ''
			is_capture_enter: true
			btn_list: [
				name: _.l('Close')
				class: ''
				is_default: true
				clicked: ->
					$msg_box.modal('hide')
			]
			shown: null
			closed: null

		opts = _.defaults(options, defaults)

		$msg_box = $('#NB-msg_box').clone()
		$('body').append $msg_box
		tpl_btns = $('#NB-tpl-msg_box_btns').html()

		$msg_box.find('.modal-header').append opts.title
		$msg_box.find('.modal-body').append(opts.body)
		$msg_box.find('.modal-footer').append _.template(tpl_btns, { btn_list: opts.btn_list })

		$msg_box.find('.modal-footer .btn').each((i) ->
			$this = $(this)
			$this.click(opts.btn_list[i].clicked) if opts.btn_list[i].clicked
		)

		# Default button
		if opts.is_capture_enter
			$msg_box.keypress (e) ->
				if e.keyCode == 13
					btn = _.find opts.btn_list, (el) -> el.is_default
					if btn
						btn.clicked?()
					else
						_.last(opts.btn_list).clicked?()

		$msg_box.on 'shown.bs.modal', ->
			$msg_box.find('input:first').focus()
			opts.shown?()
		$msg_box.on('hide.bs.modal', opts.closed) if opts.closed

		$msg_box.on('hidden.bs.modal', ->
			$msg_box.remove()
		)

		$msg_box.modal('show')

	notify: (options = {}) ->
		###
			See the defaults.
			It will return the jQuery of the message
			and the jQuery object has a method called `destroy`
			use it to destroy the message manully.
		###
		defaults =
			info: _.l('your information')
			auto_destroy: true
			delay: 700
			class: ''

		opts = _.defaults(options, defaults)
		$noti = $('<div class="noti">')
			.html(opts.info)
			.addClass(opts.class)
		$('#NB-notifications').append $noti

		$noti.destroy = ->
			requirejs ['/jquery.transit/jquery.transit.js'], ->
				$noti.delay(opts.delay).transit { right: $noti.outerWidth() / 2, opacity: 0 }, ->
					$noti.slideUp ->
						$noti.remove()

		requirejs ['/jquery.transit/jquery.transit.js'], ->
			$noti.transit_fade_in ->
				if opts.auto_destroy
					$noti.destroy()
		return $noti

	assist_info: (options) ->
		###
			Return true if don't need to assist again.
		###
		defaults = {
			info: ''
			done: ->
		}
		opts = _.defaults(options, defaults)

		hash = _.hash_str(opts.info)
		saved_data = localStorage.getItem('dont_show_again') or ''
		if saved_data.indexOf(hash) > -1
			opts.done()
			return

		tpl = $('#NB-tpl-assist-info').html()

		$msg_box = _.msg_box {
			title: 'Assistant'
			body: _.template tpl, { info: _.l opts.info }
			closed: ->
				if $msg_box.find('input').is ':checked'
					saved_data += hash + ','
					localStorage.setItem 'dont_show_again', saved_data
		}
		$msg_box.on 'hidden.bs.modal', opts.done

	hash_str: (str) ->
		hash = 0
		return hash if not str
		for c, i in str
			code = str.charCodeAt i
			hash = ( (hash << 5) - hash ) + code
			hash |= 0
		return hash

	pt_sum: (point_a, point_b, direction = 1) ->
		###
			Return the sum of two points.
		###

		return {
			left: (point_a.left or 0) + (point_b.left or 0) * direction
			top: (point_a.top or 0) + (point_b.top or 0) * direction
		}

	get_img_size: (url, done) ->
		###
			done = ({width, height}) ->
		###

		img = new Image
		img.src = url
		img.onload = ->
			done
				width: img.width
				height: img.height

	open_new_tab: (url) ->
		win = window.open(url, '_blank')
		win.focus()

	dragging: (options) ->
		###
			options:
				selector: string
				data: any
				mouse_down: (e) ->
				mouse_move: (e) ->
				mouse_up: (e) ->
				window: object
					Useful when using in an iframe.
		###

		if options.window
			win = options.window
		else
			win = window

		$doc = $(win.document)

		mouse_down = (e) ->
			e.data = options.data
			options.mouse_down?(e)

			$doc.mousemove(mouse_move)
			$doc.one('mouseup', mouse_up)

		mouse_move = (e) ->
			e.data = options.data
			options.mouse_move?(e)

		mouse_up = (e)->
			e.data = options.data
			options.mouse_up?(e)

			# Release event resource.
			$doc.off('mousemove', mouse_move)

		$doc.on('mousedown', options.selector, mouse_down)

	req_id: ->
		'req_id=' + Date.now()

	async_run_tasks: (tasks, all_done) ->
		count = 0

		check = ->
			if count < tasks.length
				count++
			else
				all_done?()

		check()

		for task, i in tasks
			task(check, i)

	sync_run_tasks: (tasks, all_done) ->
		###
			tasks: [
				(done, i) ->
			]
			Sync run tasks
		###

		i = 0

		check = ->
			if i < tasks.length
				run()
			else
				all_done?()

		run = ->
			tasks[i](check, i)
			i++

		check()

	class_name: (name) ->
		_.capitalize(name)

	l: (english) ->
		###
			Translate English to current language.
		###

		str = NB.langs[NB.conf.current_lang][english]
		return str or english

	play_audio: (url) ->
		window.AudioContext = window.AudioContext or window.webkitAudioContext

		if not window.AudioContext
			return

		NB.audio_ctx ?= new AudioContext()
		NB.audio_cache ?= {}

		play = ->
			src = NB.audio_ctx.createBufferSource()
			src.buffer = NB.audio_cache[url]
			src.connect(NB.audio_ctx.destination)
			src.start(0)

		if not NB.audio_cache[url]
			req = new XMLHttpRequest()
			req.open('GET', url, true)
			req.responseType = 'arraybuffer'
			req.onload = ->
				NB.audio_ctx.decodeAudioData(req.response, (buf) ->
					NB.audio_cache[url] = buf
					play()
				)
			req.send()
		else
			play()

)

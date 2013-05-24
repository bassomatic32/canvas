async = require 'async'

task 'watch:js', "Watch and Browserify the JS bundle...", (opts) ->
	options = opts
	task_watch_js()


task_watch_js = (cb) ->
	jsQueue = new LimitingQueue task_compile_js
	watcher = require('chokidar').watch ['coffee/client'],
		persistent: true

	watcher.on 'add',  -> jsQueue.push()
	watcher.on 'change', -> jsQueue.push()
	watcher.on 'unlink', -> jsQueue.push()
	cb() if cb?


task_compile_js = (cb) ->
	{exec, spawn} = require 'child_process'
	console.log 'Browserfying JS'
	exec "node_modules/.bin/browserify coffee/client/client.coffee -o js/main.js", (err,stdout,stderr) ->
		console.log stdout
		console.log stderr
		cb() if cb?


## Limiter for compiling watched files.
class LimitingQueue
	@compile = false

	constructor: (@task) ->
		@queue = async.queue (t,cb) =>
			if @compile
				@task cb
			else
				cb()
		, 1

		@queue.empty = =>
			@compile = true
		@queue.saturated = =>
			@compile = false

	push: ->
		@queue.push {}


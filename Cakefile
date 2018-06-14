async = require 'async'

task 'watch:js', "Watch and Browserify the JS bundle...", (opts) ->
	options = opts
	task_watch_js()
	task_compile_js()


task_watch_js = (cb) ->
	watcher = require('chokidar').watch ['coffee/client'],
		persistent: true

	watcher.on 'all',(event,path) ->
		console.log event,path

	watcher.on 'add',  task_compile_js
	watcher.on 'change',  task_compile_js
	watcher.on 'unlink',  task_compile_js
	cb?()


task_compile_js = (cb) ->
	{exec, spawn} = require 'child_process'
	console.log 'Browserfying JS'
	exec "node_modules/.bin/browserify coffee/client/client.coffee -o js/main.js", (err,stdout,stderr) ->
		console.log stdout
		console.log stderr
		cb?()

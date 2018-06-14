async = require 'async'


window.onload = ->
	canvas = document.getElementById 'canvas'
	ctx = canvas.getContext('2d')



	# # initialize hight map
	# heightMap = []
	# for i in [0..800]
	# 	heightMap.push undefined
	#
	# queue = async.queue (task,next) ->
	# 	{left,right} = task
	#
	# 	drawPath()
	# 	createHeight(left,right)
	# 	setTimeout next,50
	#
	# createHeight = (left,right) ->
	#
	# 	return if left >= right
	#
	# 	mid = Math.floor((right + left) / 2)
	# 	return if heightMap[mid]?
	#
	# 	midHeight = ((heightMap[right]+heightMap[left]) / 2)
	#
	# 	factor = Math.sqrt(Math.pow(right-left,2)+Math.pow(heightMap[left]-heightMap[right],2))
	#
	# 	factor /= 3
	#
	# 	heightMap[mid] = midHeight + ((Math.random() *2 ) - 1)  * factor until heightMap[mid] >= 0
	#
	# 	queue.push
	# 		left: left
	# 		right: mid
	#
	#
	# 	queue.push
	# 		left:mid
	# 		right: right
	#
	#
	# drawPath = ->
	#
	# 	ctx.fillStyle = 'rgb(255,255,255)'
	#
	# 	ctx.fillRect(0,0,1000,1000)
	#
	# 	ctx.fillStyle = 'rgb(200,70,0)'
	#
	# 	return unless heightMap[0]?
	# 	ctx.moveTo(0,heightMap[0])
	# 	ctx.beginPath()
	# 	lastKnownPosition = 0
	# 	control = false
	# 	for i in [0..800]
	# 		continue if heightMap[i] is undefined
	# 		ctx.lineTo(i,heightMap[i])
	# 		lastKnownPosition = i
	# 	ctx.stroke()

	# kick it off
	# heightMap[0] = Math.random() * 500
	# heightMap[799] = Math.random() * 500
	# heightMap[400] = 350
	# queue.push
	# 	left: 0
	# 	right: 400
	# queue.push
	# 	left: 400
	# 	right: 799




	# create tick function that sends milliseconds elapsed
	startTime = (new Date()).getTime()
	tickFunction = (func) ->
		return ->
			t = (new Date()).getTime() - startTime
			func(t)

	RADIAL_DEGREE_CONVERSION = ( 2.0 * Math.PI ) / 360 
	UNIT_RADIUS = canvas.height * (1/3)

	ctx.translate(canvas.width/2,canvas.height/2) # set 0,0 to center of canvas

	objs = []



	initObj = ->
		obj =
			r: Math.random()*UNIT_RADIUS + 10
			t: Math.random()*360
			vr: Math.random()*0.1
			vt: Math.random()
			d: Math.random()*20+5 # diameter


	initObjs = ->
		for i in [1..20]
			obj = initObj()
			objs.push obj

	drawObjs = () ->
		ctx = canvas.getContext('2d')

		for obj in objs
			ctx.beginPath()
			ctx.strokeStyle = '#000000'
			theta = obj.t * RADIAL_DEGREE_CONVERSION
			x = obj.r * Math.cos(theta)
			y = obj.r * Math.sin(theta)
			ctx.arc(x,y,obj.d,0,Math.PI*2)

			ctx.stroke()

	moveObjs = (t) ->
		for obj in objs
			obj.r += obj.vr
			obj.t += obj.vt

	objCollision = (x,y) ->
		newObjs = []
		collisionOccurred = false
		for obj in objs

			theta = obj.t * RADIAL_DEGREE_CONVERSION
			ox = obj.r * Math.cos(theta)
			oy = obj.r * Math.sin(theta)

			dx = x-ox
			dy = y-oy
			dr = (obj.d + 10)

			if Math.pow(dx,2) + Math.pow(dy,2) < Math.pow(dr,2)
				# point is within circle
				newObjs.push initObj()
				collisionOccurred = true
			else
				newObjs.push obj # keep it

		objs = newObjs
		return collisionOccurred


	Va = undefined # angular velocity
	Vr = 0 # radial velocity
	r = UNIT_RADIUS*2 # UNIT_RADIUS

	Am = 0 # angular momentum.  This must remain constant

	x = undefined
	y = undefined

	theta = 0

	pointList = []
	TAIL_LENGTH = 50
	GRADIANT_FACTOR = 256/TAIL_LENGTH
	GRAVITY = 0.15
	drawScale = 1
	drawScaleV = 0

	keyDown = ->
		console.log 'Key Down'
		Am = 100

	keyUp = ->
		console.log 'Key Up'
		Am = 0

	canvas.focus()
	window.addEventListener 'keyup',keyUp
	window.addEventListener 'keydown',keyDown

	translateX = 0
	translateY = 0

	initObjs()

	adjustScale = (r) ->
		drawScale = (UNIT_RADIUS / r) * 1.50
		drawScale = 1 if drawScale > 1





	# adjust UNIT_RADIUS based on time
	adjustUNIT_RADIUS = (t) ->
		Vr = Vr - GRAVITY
		Vr *= 0.995 # 5% drag
		# Vr = -5 if Vr < -5
		r += Vr

		if Vr < 0 and r < 10
			Vr = -Vr

	tick = (t) ->
		adjustUNIT_RADIUS(t)
		adjustScale(r,Vr)

		moveObjs()
		Va = Am / r

		theta = (theta + Va) % 360
		th = theta * RADIAL_DEGREE_CONVERSION

		# console.log "UNIT_RADIUS: #{r} Vr: #{Vr} Theta: #{theta}"

		first = not x?
		x = r * Math.cos(th)
		y = r * Math.sin(th)

		pointList.unshift {x:x,y:y}
		return if pointList.length is 1
		if pointList.length > TAIL_LENGTH
			pointList = pointList[0...-1]

		if objCollision(x,y,drawScale)
			Vr = -Vr if Vr < 0 # reverse direction if going to center
			Vr += 2 # increase speed


		# begin drawing
		ctx.save()
		ctx.clearRect(-2000,-2000,4000,4000)

		ctx.scale(drawScale,drawScale)
		ctx.translate(-(pointList[0].x)/2,-(pointList[0].y)/2)

		drawObjs()

		ctx.beginPath()
		ctx.fillStyle = '#000000'
		ctx.arc(0,0,10,0,Math.PI*2)
		ctx.fill()


		for i in [1...pointList.length]
			grey = Math.round( i*GRADIANT_FACTOR )
			ctx.strokeStyle = "rgb(#{grey},#{grey},#{grey})"

			ctx.beginPath()
			ctx.arc x,y,10,0,2*Math.PI if i is 1
			ctx.moveTo(pointList[i-1].x,pointList[i-1].y)
			ctx.lineTo(pointList[i].x,pointList[i].y)
			ctx.stroke()



		ctx.restore()




	setInterval tickFunction(tick),10

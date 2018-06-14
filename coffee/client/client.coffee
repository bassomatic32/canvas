async = require 'async'


window.onload = ->
	# get canvas and context
	canvas = document.getElementById 'canvas'
	ctx = canvas.getContext('2d')

	# create tick function that sends milliseconds elapsed
	startTime = (new Date()).getTime()
	tickFunction = (func) ->
		return ->
			t = (new Date()).getTime() - startTime
			func(t)

	RADIAL_DEGREE_CONVERSION = ( 2.0 * Math.PI ) / 360 # convert from degrees to radians
	UNIT_RADIUS = canvas.height * (1/3) # the radius of the 'basic' circle around center for the game.  (1/3 of canvas height)

	ctx.translate(canvas.width/2,canvas.height/2) # set 0,0 to center of canvas

	objs = []  # array of circle objects
	OBJ_COUNT = 20
	POINT_OBJECT_RADIUS = 10

	# return a single circle object
	initObj = ->
		obj =
			r: Math.random()*UNIT_RADIUS + 10 # the 'R' portion of the polar coordinate
			t: Math.random()*360 # the 'theta' component of polar coordinate.  These two describe the objects position
			vr: Math.random()*0.1 # the velocity of the object in the R direction
			vt: Math.random() # velocity of object in Theta direction
			d: Math.random()*20+5 # radius of object

	# initialize objects
	initObjs = ->
		for i in [1..OBJ_COUNT]
			obj = initObj()
			objs.push obj

	# draw all the circle objects
	drawObjs = () ->

		for obj in objs
			ctx.beginPath()
			ctx.strokeStyle = '#000000'
			theta = obj.t * RADIAL_DEGREE_CONVERSION # convert degrees to radians
			x = obj.r * Math.cos(theta) # convert to cartesian
			y = obj.r * Math.sin(theta)
			ctx.arc(x,y,obj.d,0,Math.PI*2) # draw the arc as a full circle

			ctx.stroke() # and commit

	# move objects according to their velocity
	moveObjs = (t) ->
		for obj in objs
			obj.r += obj.vr
			obj.t += obj.vt

	# detect if point object is colliding with any of the circle objects
	# if collision is detected, remove the circle object and add a new random one
	# return true if collision detected
	objCollision = (x,y,diameter) ->
		newObjs = [] # push all non-colliding objects into this list
		collisionOccurred = false
		for obj in objs # bad, referencing global variable

			# get cartesian center of circle object
			theta = obj.t * RADIAL_DEGREE_CONVERSION
			ox = obj.r * Math.cos(theta)
			oy = obj.r * Math.sin(theta)

			# get cartesian difference in position, and sum of radii
			dx = x-ox
			dy = y-oy
			dr = (obj.d + POINT_OBJECT_RADIUS)

			if Math.pow(dx,2) + Math.pow(dy,2) < Math.pow(dr,2) # standard circle intersection test
				# point is within circle
				newObjs.push initObj() # push a new object
				collisionOccurred = true
			else
				# push current object
				newObjs.push obj # keep it

		objs = newObjs # bad global, objs is now the updated list
		return collisionOccurred


	Va = undefined # angular velocity
	Vr = 0 # radial velocity
	r = UNIT_RADIUS*2 #  R component of point object, with inital value
	theta = 90 # theta component of point object

	Am = 0 # angular momentum. ( Am = Va * r )  This must remain constant.  Initially 0.  User interaction will modify this.
	# NOTE: By adjusting angular velocity to ensure Am is constant, point object will be slower the further away from center.


	pointList = [] # array of points for point object, so we can draw the tail

	TAIL_LENGTH = 50
	GRADIANT_FACTOR = 256/TAIL_LENGTH  # gradiant factor to adjust color for tail

	GRAVITY = 0.15 # Gravity constant
	drawScale = 1 # canvas scale.  Will be adjusted based on distance between point object and center

	# setup keyboard events
	keyDown = ->
		Am = 100 # constant Am if key is down

	keyUp = ->
		Am = 0 # angular motion if key is up

	window.addEventListener 'keyup',keyUp
	window.addEventListener 'keydown',keyDown
	# done with user interaction section


	# adjust drawScale based on input R value
	adjustScale = (r) ->
		drawScale = (UNIT_RADIUS / r) * 1.50
		drawScale = 1 if drawScale > 1 # cannot zoom in past a factor of 1


	# adjust R value based on Vr
	adjustRadius = (t) ->
		Vr = Vr - GRAVITY
		Vr *= 0.995 # 5% drag

		r += Vr

		if Vr < 0 and r < 10 # i.e. Velocity is towards center and we are less than 10 units away from center ( too close )
			Vr = -Vr # bounce by reversing velocity.  (Full Elastic Bounce)

	# adjust theta of point object based on r and angular momentum
	adjustAngle = (t) ->
		Va = Am / r # ( Am = Va * r, solve for Va)

		theta = (theta + Va) % 360 # increment theta according to angulary velocity, modula 360


	# main loop
	tick = (t) ->
		adjustRadius(t) # adjust the R value of point object
		adjustAngle(t) # adjust the angle of point object

		adjustScale(r,Vr) # adjust scale based on R value
		moveObjs() # move all the circle object

		th = theta * RADIAL_DEGREE_CONVERSION # convert to radians

		# convert position of point object to cartesian
		x = r * Math.cos(th)
		y = r * Math.sin(th)

		pointList.unshift {x:x,y:y} # add point front of array.  (Not back)
		return if pointList.length is 1 # stop here if pointList is only 1, as we get bad things happening

		# cut off back of tail if it grows beyond tail length
		if pointList.length > TAIL_LENGTH
			pointList = pointList[0...-1]

		# detect collision
		if objCollision(x,y,drawScale)
			Vr = -Vr if Vr < 0 # reverse direction if going to center
			Vr += 2 # increase speed


		# begin drawing
		ctx.clearRect(-2000,-2000,4000,4000) # clear our area first

		ctx.scale(drawScale,drawScale) # scale accordingly
		ctx.translate(-(pointList[0].x)/2,-(pointList[0].y)/2) # translate center accordingly

		drawObjs() # draw all circle objects

		# draw center
		ctx.beginPath()
		ctx.fillStyle = '#000000'
		ctx.arc(0,0,10,0,Math.PI*2)
		ctx.fill()


		# draw our tail.  Color is adjusted towards white as we get closer to tail
		for i in [1...pointList.length]
			grey = Math.round( i*GRADIANT_FACTOR ) # calculate our line color based on gradiant factor
			ctx.strokeStyle = "rgb(#{grey},#{grey},#{grey})" # set our stroke color

			ctx.beginPath()
			ctx.arc x,y,10,0,2*Math.PI if i is 1 		# draw our point object ( first point in array, since current position is always first )
			# draw tail section
			ctx.moveTo(pointList[i-1].x,pointList[i-1].y)
			ctx.lineTo(pointList[i].x,pointList[i].y)
			# and stroke
			ctx.stroke()



	# and lets kick it off
	initObjs()

	setInterval tickFunction(tick),10 # run our main loop at 10 millisecond intervals

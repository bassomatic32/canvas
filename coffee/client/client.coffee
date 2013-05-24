window.onload = ->
	canvas = document.getElementById 'canvas'
	ctx = canvas.getContext('2d')

	# initialize hight map
	heightMap = []
	for i in [0..800]
		heightMap.push -1

	heightMap[0] = Math.random() * 500
	heightMap[800-1] = Math.random() * 500


	##
	createHeight = (left,right,range) ->

		return if left >= right
		mid = Math.floor((right - left) / 2)  + left
		midHeight = ((heightMap[right]-heightMap[left]) / 2) + heightMap[left]


		return if mid is left
		range = range * 1.3*Math.random()
		factor = range


		heightMap[mid] = midHeight + (Math.random() * factor ) - (factor / 2)
		heightMap[mid] = 0 if heightMap[mid] < 0


		createHeight(left,mid,range)
		createHeight(mid,right,range)
	##

	createHeight(0,799,400)


	ctx.beginPath()
	ctx.moveTo 0,500-heightMap[0]
	for i in [0..800] by 32
		ctx.quadraticCurveTo i-16,500-heightMap[i-16],i,500-heightMap[i]


	ctx.fill()




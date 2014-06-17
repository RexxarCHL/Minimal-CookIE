$(document).ready ->
	#loadRecipes()
	return

addInfiniteScroll = (scope, delay, callback)->
	console.log "add infinite-scroll to scope:" + scope[0].id
	scrollerList = scope.scroller()
	scrollerList.clearInfinite()
	scrollerList.addInfinite()
	$.bind(scrollerList, 'infinite-scroll', ->
		console.log scope[0].id+" infinite-scroll"
		scope.find("#infinite").text "Loading more..."
		scrollerList.addInfinite()

		clearTimeout window.lastId
		window.lastId = setTimeout(->
			callback()
		, delay)
	)
	return #avoid implicit return values

recipeAjaxd = 0
loadRecipes = ->
	console.log "load recipes"
	scope = $('#main_Browse_Recipe')
	scope.find('#Results').html ""
	scope.find("#infinite").text "Reloading..."
	recipeAjaxd = 0

	getRecipes(recipeAjaxd)
	return

loadDeck = ->
	console.log "loading deck"
	$.ui.showMask 'Fetching data...'

	checkRecipeInDB()

	data = ""
	for recipeId in window.recipesInDeck
		data += "recipes=#{recipeId}&"
	console.log data
	$.ajax(
		type: 'GET'
		url: "http://54.178.135.71:8080/CookIEServer/deck_recipe?#{data}"
		contentType: 'application/json'
		data: data
		timeout: 10000
		success: (data)->
			data = JSON.parse data
			console.log "[SUCCESS]load deck"
			console.log data

			scope = $("#main_Deck")
			scope.find("#Results").html ""
			appendRecipeResult(scope, data, true)

			$.ui.hideMask()
			return
		error: (resp)->
			console.log "[ERROR]load deck"
			console.log resp

			$.ui.hideMask()
			return
	)

parseTimeToMinutes = (time)->
	time = time.split ":"
	time = parseInt(time[0])*60 + parseInt(time[1]) + parseInt(time[2])/60

convertTimeToSeconds = (time)->
	time = time.split ":"
	time = parseInt(time[0])*3600 + parseInt(time[1])*60 + parseInt(time[2])

parseSecondsToTime = (seconds)->
	hour = Math.floor seconds/3600
	seconds %= 3600
	hour = if hour<10 then "0"+hour else hour
	min = Math.floor seconds/60
	seconds %= 60
	min = if min<10 then "0"+min else min
	seconds = if seconds<10 then "0"+seconds else seconds

	"#{hour}:#{min}:#{seconds}"
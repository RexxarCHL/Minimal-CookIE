$(document).ready ->
	$("#ToBuyListCookBtn").click ->
		getScheduledRecipe window.recipesInDeck
		$.ui.loadContent 'Cooking'
		return

	$("#DoneBtn").click ->
		db.transaction (transaction)->
			sql = 'DELETE FROM `Recipes`'
			transaction.executeSql sql, [], successCallBack, errorHandler
			sql = 'DELETE FROM `MenuIngredients`'
			transaction.executeSql sql, [], ->
					$("#ToBuyListCookBtn").addClass 'hidden'
					$("#EmptyNotify").removeClass 'hidden'
					window.recipesInDeck = []
					loadDeck()
					loadRecipes()
				, errorHandler

			return
		, errorHandler, nullHandler

		window.cookingData = null
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

allCatAjaxd = 0
loadCateogries = ->
	console.log "load categories"
	scope = $("#main_Browse_Category")
	scope.find("#Results").html ""
	scope.find("#infinite").text "Loading..."
	allCatAjaxd = 0

	getAllCategory(allCatAjaxd)
	return

loadDeck = ->
	console.log "loading deck"

	checkRecipeInDB()

	if window.recipesInDeck.length is 0
		$("#main_Deck").find("#Results").html '<h2 style="padding-top:5%;padding-left:5%;">Browse recipes and add it into deck to start!</h2>'
		return
	
	$.ui.showMask 'Fetching data...'

	query = ""
	for recipeId in window.recipesInDeck
		query += "recipes=#{recipeId}&"
	console.log query
	$.ajax(
		type: 'GET'
		url: "http://54.178.135.71:8080/CookIEServer/deck_recipe?#{query}"
		dataType: 'application/json'
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
	return




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

trimStringLength = (string)->
	if string.length > 10
		string = string.substring(0, 9) + "..."
	string
###
utility.coffee
	Everything that is used repeatly or does not fit elsewhere belongs here.

	initSidebarIcons()
		Initializes the sidebar.
	sendFeedback()
		Sends feedback back to server.
	addInfiniteScroll(scope, delay, callback)
		Add infinite-scroll to 'scope' with a delay of 'delay' milliseconds and call 'callback' when fired.
	loadRecipes()
		Clear #main_Browse_Recipes and fetch data from server.
	loadCategories()
		Clear #main_Browse_Category and fetch data from server.
	loadDeck()
		Load content for the deck.
	updateNavbarDeck()
		Update the recipe count for the navbar 'Deck' icon whenever a recipe is added to the deck
	parseTimeToMinutes(time)
		Convert 'time', which is of the format "hh:mm:ss" to minutes.
	convertTimeToSeconds(time)
		Convert 'time', which is of the format "hh:mm:ss" to seconds.
	parseSecondsToTime(seconds)
		Convert 'seconds' to time, which is of the format "hh:mm:ss".
	trimStringLength(string)
		Trim the input 'string' to 14 letters.
###

# when the html is ready
$(document).ready ->
	# initiate the sidebar
	initSidebarIcons()

	# initiate the #ToBuyListCookBtn button
	$("#ToBuyListCookBtn").click ->
		# when clicked,
		# send the recipes in deck to server for scheduling
		getScheduledRecipe window.recipesInDeck
		# jump to #Cooking to view the scheduled information
		$.ui.loadContent 'Cooking'
		return

	# initiate the #DoneBtn button in #Finish
	$("#DoneBtn").click ->
		# when clicked,
		# delete everything from the database
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

		# reset the to-buy list
		$("#EmptyNotify").addClass 'hidden'
		$("#ToBuyListCookBtn").removeClass 'hidden'
		$("#list").html ""

		# reset variables used in cooking
		window.cookingData = null
		window.currentStepNum = 0
		window.currentStep = null
		window.currentTime = 0
		window.waitingStepQueue = []
		window.stepsTimeUsed = []
		window.cookingStartTime = null
		return

# initiate the sidebar
initSidebarIcons = ->
	# when close is clicked,
	$(".icon.close").click ->
		# ask if the user really want to clear all the data in the database
		ans = confirm "這會清除您調理台與購買清單中的所有資料\n繼續？"
		if ans is no then return

		# if the answer is yes, then delete everything from the database
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

		# reset the to-buy list
		$("#EmptyNotify").addClass 'hidden'
		$("#ToBuyListCookBtn").removeClass 'hidden'
		$("#list").html ""

		# reset variables used in cooking
		window.cookingData = null
		window.currentStepNum = 0
		window.currentStep = null
		window.currentTime = 0
		window.waitingStepQueue = []
		window.stepsTimeUsed = []
		window.cookingStartTime = null

		# jump back to #main_Browse_Recipe
		$.ui.loadContent "main_Browse_Recipe"
	return

# send feedback back to server
sendFeedback = ->
	# get the feedback
	name = $("#feedbackName").val()
	mail = $("#feedbackMail").val()
	type = 
		switch($("#feedbackType").val())
			when '食譜請求' then 'recipe'
			when '臭蟲回報' then 'bug'
			when '意見' then 'feedback'
	msg = $("#feedbackContent").val()

	url = "" # TODO: check actual url

	$.ajax
		type: 'POST'
		url: url
		dataType: 'application/json'
		data:
			'name': name
			'mail': mail
			'type': type
			'message': msg
		timeout: 10000
		success: (data)->
			data = JSON.parse(data)
			console.log "[SUCCESS] send feedback"
			### TODO Insert token into SQL ###

			alert "Thank you for your support!"
			return
		error: (resp)->
			console.log "[ERROR] send feedback"
			if resp.status is 0 then alert "Server Error. Try again later."
			else alert "Connection error: #{resp.status}"

			return
	return

# add infinite-scroll to 'scope' with a delay of 'delay' and call 'callback when fired'
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

# reload #main_Browse_Recipe
recipeAjaxd = 0
loadRecipes = ->
	console.log "load recipes"
	scope = $('#main_Browse_Recipe')
	scope.find('#Results').html ""
	scope.find("#infinite").text "Reloading..."
	recipeAjaxd = 0

	getRecipes(recipeAjaxd)
	updateNavbarDeck()
	return

# reload #main_Browse_Category
allCatAjaxd = 0
loadCateogries = ->
	console.log "load categories"
	scope = $("#main_Browse_Category")
	scope.find("#Results").html ""
	scope.find("#infinite").text "Loading..."
	allCatAjaxd = 0

	getAllCategory(allCatAjaxd)
	
	return

# load the deck
loadDeck = ->
	console.log "loading deck"

	checkRecipeInDB()
	updateNavbarDeck()

	# if there is not recipes in deck
	if window.recipesInDeck.length is 0
		# inform the user
		$("#main_Deck").find("#Results").html '<h2 style="color:gray;text-align:center;padding-top:5%;">逛食譜並加入調理台來煮飯!</h2>'
		return
	
	# block the ui and let the user know that we're fetching data from the server
	$.ui.showMask 'Fetching data...'
	$.ui.blockUI(0.1)

	# construct the query string
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
			# SUCCESS
			# parse and log the data
			data = JSON.parse data
			console.log "[SUCCESS]load deck"
			console.log data

			# get to ROI, clear the previous contents, and append the result to #main_Deck
			scope = $("#main_Deck")
			scope.find("#Results").html ""
			appendRecipeResult(scope, data, true)

			# unblock the ui and hide the spinning wheel
			$.ui.hideMask()
			$.ui.unblockUI()
			return # avoid implicit rv from Coffeescript

		error: (resp)->
			# ERROR
			# log the respone for DEBUG
			console.log "[ERROR]load deck"
			console.log resp

			# inform the user
			scope.find("#Resutls").html '<h2 style="color:gray;text-align:center;padding-top:5%;">Connection Error: '+resp.status+'</h2>'

			# unblock the UI and hide the spinning wheel
			$.ui.hideMask()
			$.ui.unblockUI()
			return # avoid implicit rv
	)

	return # avoid implicit rv

# update the count of how many recipes already in deck
updateNavbarDeck = ->
	console.log "update navbar deck: #{window.recipesInDeck.length}"
	$("#navbar_deck").html "調理台(#{window.recipesInDeck.length})"
	return # avoid implicit rv

# convert 'time', which is of the format "hh:mm:ss" to minutes
parseTimeToMinutes = (time)->
	time = time.split ":"
	time = parseInt(time[0])*60 + parseInt(time[1]) + parseInt(time[2])/60

# convert 'time', which is of the format "hh:mm:ss" to seconds
convertTimeToSeconds = (time)->
	time = time.split ":"
	time = parseInt(time[0])*3600 + parseInt(time[1])*60 + parseInt(time[2])

# convert 'seconds' to time, which is of the format "hh:mm:ss"
parseSecondsToTime = (seconds)->
	hour = Math.floor seconds/3600
	seconds %= 3600
	hour = if hour<10 then "0"+hour else hour
	min = Math.floor seconds/60
	seconds %= 60
	min = if min<10 then "0"+min else min
	seconds = if seconds<10 then "0"+seconds else seconds

	"#{hour}:#{min}:#{seconds}"

# trim the 'string' to a length of 14
trimStringLength = (string)->
	if string.length > 14
		string = string.substring(0, 13) + "..."
	string
	
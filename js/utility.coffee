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

deleteSelectedRecipesFromDeck = ->
	### TODO ###

recipeAjaxd = 0
loadRecipes = ->
	console.log "load recipes"
	scope = $('#main_Browse_Recipe')
	scope.find('#Results').html ""
	scope.find("#infinite").text "Reloading..."
	recipeAjaxd = 0

	getRecipes(recipeAjaxd)
	return

findChosenRecipeId = ->
	### TODO ###
	recipeSelectedId = []
	$('#main_Kitchen_Recipes').find('.chosen').forEach (elem)->
		recipeSelectedId.push elem.getAttribute 'data-recipe-id'
	console.log recipeSelectedId
	return recipeSelectedId

### Recipe -> Deck ###
addThisRecipeToDeck = (id)->
	### TODO ###
	console.log "Add recipe ##{id} to deck"
	if window.recipesInDeck.lastIndexOf(id) is -1
		window.recipesInDeck.push id # push this recipe into deck
		AddRecipeValue id # push this recipe into db

	html = $("#Recipe#{id}").html()
	scope = $("#main_Deck").find("#Results")
	scope.find("#bottomBar").remove()
	if scope.length % 2 then leftright = 'left' else leftright = 'right'
	scope.append "<div class='kitchen_recipe_item #{leftright}' data-recipe-id='#{id}'>#{html}</div>"
	
	### Add bottomBar to maintain the scroller ###
	scope.append '<div id="bottomBar" style="display:block;height:0;clear:both;"> </div>'

	return

checkRecipeInDeck = (id)->
	#console.log "index for  #{id} is #{window.recipesInDeck.lastIndexOf(id)}"
	if window.recipesInDeck.lastIndexOf(id) is -1 then false else true

checkRecipeInDB = ->
	if not window.openDatabase
        alert 'Databases are not supported in this browser.'
        return

	sql = 'SELECT `recipeId` FROM `Recipes`'

	db.transaction (transaction)->
		transaction.executeSql sql, [], (transaction, result)->
			if result? and result.rows?
				### There is recipe in deck ###
				console.log "OK"
				for x,i in result.rows
					row = result.rows.item(i)
					window.recipesExist = 1
					console.log row.recipeId
					window.recipesInDeck.push row.recipeId
				return
			console.log "NOT OK"
			window.recipesExist = 0

		, errorHandler
		return
	, errorHandler, nullHandler
	return

resetSelectedRecipe = ->
	### TODO ###

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
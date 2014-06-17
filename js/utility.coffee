$(document).ready ->
	loadPopularRecipes()
	loadPopularMenus()
	return

deleteSelectedRecipes = ->
	selectedId = findChosenRecipeId()
	if selectedId.length is 0 then return
	console.log "deleting recipes #{selectedId}"

	ans = confirm "Deleteing recipes from Kitchen. Are you sure?"
	if ans is false then return

	data = 
		'type': 'recipe'
		'recipes': selectedId
		'user_id': window.user_id
		'token': window.token
	data = JSON.stringify(data)
	console.log data
	
	$.ajax(
		type: 'DELETE'
		url: 'http://54.178.135.71:8080/CookIEServer/favorite'
		dataType: 'application/json'
		data: data
		timeout: 10000
		success: (data)->
			#data = JSON.parse(data)
			console.log "[SUCCESS] deleting recipes #"+selectedId
			console.log data
			
			reloadKitchenRecipes()
			return # avoid implicit rv
		error: (data, status)->
			console.log "[ERROR] deleting recipes #"+selectedId
			console.log data

			return # avoid implicit rv
	)

recipeAjaxd = 0
loadPopularRecipes = ->
	scope = $('#main_Popular_Recipes')
	scope.find('#Results').html ""
	scope.find("#infinite").text "Reloading..."
	recipeAjaxd = 0
	getPopularRecipes(recipeAjaxd)
	return

findChosenRecipeId = ->
	recipeSelectedId = []
	$('#main_Kitchen_Recipes').find('.chosen').forEach (elem)->
		recipeSelectedId.push elem.getAttribute 'data-recipe-id'
	console.log recipeSelectedId
	return recipeSelectedId

addThisRecipeToKitchen = ->
	recipeId = $('#RecipeContent').find('#RecipeImg').attr 'data-recipe-id'
	console.log "add #{recipeId} to kitchen"

	data = 
		user_id: window.user_id
		token: window.token
		type: 'recipe'
		recipe_id: recipeId
	data = JSON.stringify data

	$.ajax(
		type: 'POST'
		url: 'http://54.178.135.71:8080/CookIEServer/favorite'
		contentType: 'application/json'
		data: data
		timeout: 10000
		success: (data)->
			console.log "[SUCCESS] add #{recipeId} to kitchen"
			console.log data
			alert "Done!"
			reloadKitchenRecipes()
			return # avoid implicit rv
		error: (resp)->
			console.log "[ERROR] add #{recipeId} to kitchen"
			console.log resp
			if resp.status is 404
				alert "Oops! The recipe is already in Kitchen!"
			return # avoid implicit rv
	)

	return # avoid implicit rv

resetSelectedRecipe = ->
	$('#main_Kitchen_Recipes').find('.chosen').removeClass 'chosen'
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
###
ajaxRecipe.coffee
	function to get popular recipes from the server.

	getRecipes(times)
		Fetch popular recipes from the server and append the result to #main_Browse_Recipe.
		Fetch (times*20)th to (times*20+20)th results.
		The append function is in appendFunctions.coffee
###
recipeAjaxd = 0 # recipeAjaxd: a count of how many times the recipes have been ajax'ed

# when the html is ready,
$(document).ready ->
	# add infinite scroll to #main_Browse_Recipe
	addInfiniteScroll $('#main_Browse_Recipe'), 1000, ->
		# if #main_Browse_Recipe is hidden, then there is a query in search, search further
		if $('#main_Browse_Recipe').find("Results").hasClass "hidden" then search window.query, searchAjaxd
		# else get recipes normally
		else getRecipes(recipeAjaxd)
		return
	return #avoid implicit return values by Coffeescript

# fetch popular recipes
getRecipes = (times) ->
	$.ajax(
		type: "GET"
		url: 'http://54.178.135.71:8080/CookIEServer/discover_recipes'
		dataType: 'application/json'
		data: 
			'type': 'popular'
			'times': times
		timeout: 10000
		success: (data)->
			# SUCCESS
			# parse the data
			data = JSON.parse(data)
			console.log "[SUCCESS]fetch recipes"
			console.log data

			# increment the number of times popular recipes have been ajax'ed
			recipeAjaxd++

			# clear the flag for infinite scroll to prevent malfunction
			$('#main_Browse_Recipe').scroller().clearInfinite()

			# if the data received is empty
			if data.length is 0
				# inform the user
				$("#main_Browse_Recipe").find("#infinite").text "No more recipes"
				# decrement the count since this fetch is not valid
				recipeAjaxd--
				return

			# get to ROI and append the result to ROI
			scope = $("#main_Browse_Recipe")
			appendRecipeResult(scope, data)
			return #avoid implicit return values by Coffeescript

		error: (resp)->
			# ERROR
			# log the response for DEBUG
			console.log "[ERROR]fetch recipes"
			console.log resp

			# determine the error message
			if resp.status is 0
				# if the response code is 0, then the server rejected the request
				$("#main_Browse_Recipe").find("#infinite").text "Server Error. Try again later."
			else
				# else this is an unknown error
				$("#main_Browse_Recipe").find("#infinite").text "Connection Error: #{resp.status}"
			
			# clear the flag for infinite scroll to prevent malfunction
			$('#main_Browse_Recipe').scroller().clearInfinite()
			return #avoid implicit return values by Coffeescript
	)
	return #avoid implicit return values by Coffeescript
	
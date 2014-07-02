###
ajaxSearchResults2
 	search(query, times)
 		Search for 'query' in server. Fetch (times*20)th to (times*20+20)th results.
 	appendSearchResults(data)
 		Append the data received in #SearchResults.
###
searchAjaxd = 0 # searchAjaxd: the number of times this particular query has been ajax'ed
window.query = 0 # query: stores the current query
# when the html is ready,
$(document).ready ->
	# attach keyup function to the search bar
	$("#SearchBar").keyup(->
		console.log "searchbar keyup"
		# clear the last function reservation to prevent multiple fetches
		clearTimeout(window.lastId)

		# store the current working place as 'scope' to make life easier
		scope = $('#main_Browse_Recipe')

		# get the current query
		window.query =  $("#SearchBar")[0].value

		# if the query is empty
		if window.query is ""
			# reset the number of times search has been executed
			searchAjaxd = 0

			# clear the search result
			$("#SearchResults").html ""

			# hide the search result
			$("#SearchResults").addClass 'hidden'

			# show the popular receipe results
			scope.find("#Results").removeClass 'hidden'
			return

		# clear the flag for infinite scroll to prevent malfunction
		scope.scroller().clearInfinite()

		# inform the user
		scope.find("#infinite").text "Searching..."
		
		# hide the popular receipe results
		scope.find("#Results").addClass 'hidden'

		# show the search results
		scope.find("#SearchResults").removeClass 'hidden'

		# wait 1.5 seconds to conduct the search
		window.lastId = setTimeout(->
					search window.query, searchAjaxd
					return #avoid implicit return value
				, 1500)
		return #avoid implicit return value
	)
	return #avoid implicit return value

# search for 'query' in the server
search = (query, times) ->
	type = 0
	url = 'http://54.178.135.71:8080/CookIEServer/discover_recipes'

	$.ajax(
		type: "GET"
		url: url
		dataType: 'application/json'
		data: 
			'type': 'search'
			'name': query
			'times': searchAjaxd
		timeout: 10000
		success: (data)->
			# SUCCESS
			# parse the data
			data = JSON.parse(data)
			console.log "[SUCCESS]search"
			console.log data

			# get to reign of interest
			scope = $("#main_Browse_Recipe")

			# increment the number of times this query has been searched
			searchAjaxd++

			# clear the flag for infinite scroll to prevent malfunction
			$("#main_Browse_Recipe").scroller().clearInfinite()

			# should the data received is empty
			if data.length is 0
				# if this query has been ajaxed before, then end of list is reached
				if searchAjaxd > 0
					# show 'No more results'
					$("#main_Browse_Recipe").find("#infinite").html "<i>No more results.</i>"
				# if the query has not been ajaxed before, then the query is invalid
				else
					# show 'No result'
					$("#main_Browse_Recipe").find("#infinite").html "<i>No result. Try another query?</i>"
				
				# decrement the count since this fetch is invalid
				searchAjaxd--
				return

			# if the data received is not empty then append the data
			appendSearchResults(data)
			return #avoid implicit return values by Coffeescript
		error: (resp)->
			# ERROR
			# log the error status code for DEBUG
			console.log "[ERROR]search: " + resp.status

			# clear the flag for infinite scroll to prevent malfunction
			$("#main_Browse_Recipe").scroller().clearInfinite()

			# check the status code to identify the error
			if resp.status is 0
				# if status code is 0, then the server rejected this request
				$("#main_Browse_Recipe").find("#infinite").html "Server Error. Try again later."
			else
				# else, the error is unknown
				$("#main_Browse_Recipe").find("#infinite").html "Connection Error: #{resp.status}"
			return #avoid implicit return values by Coffeescript
	)
	return #avoid implicit return values by Coffeescript

# append the data received in #SearchResults
appendSearchResults = (data)->
	console.log "Append search results"

	# get to ROI
	results = $("#SearchResults")

	# remove the tags 'new' since previous data are no longer new
	results.find('.new').removeClass('new')
	
	count = 0 # count: keep tracks of how many recipes have been appended
	# for every recipes in received data
	for recipe in data
		# construct the html of the container for the recipe
		html = ''
		id = recipe.recipe_id
		name = recipe.name
		rating = recipe.rating
		url = recipe.smallURL

		# check if the recipe is already in the deck
		exist = if checkRecipeInDeck(id) then true else false 

		# check the count of this recipe
		if count%2 
			# even: append to the right side
			html += '<div class="recipe_item right new" id="Recipe'+id+'" data-recipe-id="'+id+'">'
		else
			# odd: append to the left side
			html += '<div class="recipe_item left new" id="Recipe'+id+'" data-recipe-id="'+id+'">'

		html += '<img class="recipe_image_wrapper" src="'+url+'">'
		html += '<div class="recipe_descrip chinese_font">'+name+'</div>'
		html += '<div class="recipe_cooked">人氣：'+recipe.popularity+'</div>'
			
				
		# check if the recipe is already in the deck
		exist = if checkRecipeInDeck(id) then true else false

		# append different button according to whether the recipe exist in the deck or not
		if not exist
			html += '<div class="button recipe_btn recipe_add_btn chinese_font">加到調理台</div>'
		else
			html += '<div class="button recipe_btn recipe_in_deck_btn chinese_font">已加入調理台</div>'
		html += '</div>'

		# append the result to scope
		results.append html
		
		# increment the count
		count++
		
		# append onclick function to fetch detailed recipe content on click
		thisRecipe = results.find("#Recipe"+id)
		thisRecipe.find("img").click do (id)->
			-> # closure 
				$.ui.loadContent("#RecipeContent")
				$("#RecipeContent").find("#Results").hide()
				$("#RecipeContent").find("#Loading").show()
				getRecipeContent(id)
				return

		# if the recipe does not exist in the deck
		if not exist
			# add this recipe to deck when the button is clicked
			thisRecipe.find(".recipe_btn").click do(id, thisRecipe)->
				-> # closure
					addThisRecipeToDeck(id)
					thisRecipe.find(".recipe_btn")[0].outerHTML = '<div class="button recipe_btn recipe_in_deck_btn chinese_font">已加入調理台</div>'
					return

	# append the bottom bar to the tail of the container to prevent the scroller from malfunction
	results.find("#bottomBar").remove()
	results.append '<div id="bottomBar" style="display:block;height:0;clear:both;">&nbsp;</div>'

	# inform the user that he can fetch more
	$("#main_Browse_Recipe").find("#infinite").text "Load More"

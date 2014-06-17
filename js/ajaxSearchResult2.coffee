###
ajaxSearchResults2
 	search(query, times)
 		Search for 'query' in server. Fetch (times*20)th to (times*20+20)th results.
###
searchAjaxd = 0
recipeAjaxd = 0
window.query = 0
$(document).ready ->
	$("#SearchBar").keyup(->
		console.log "searchbar keyup"
		clearTimeout(window.lastId)

		scope = $('#main_Browse_Recipe')

		window.query =  $("#SearchBar")[0].value
		if window.query is ""
			searchAjaxd = 0
			$("#SearchResults").html ""
			$("#SearchResults").addClass 'hidden'
			scope.find("#Results").removeClass 'hidden'
			return

		scope.scroller().clearInfinite()
		scope.find("#infinite").text "Searching..."
		scope.find("#Results").addClass 'hidden'
		scope.find("#SearchResults").removeClass 'hidden'
		window.lastId = setTimeout(->
					search window.query, searchAjaxd
					return #avoid implicit return value
				, 1500)
		return #avoid implicit return value
	)
	return #avoid implicit return value

search = (query, times) ->
	type = 0
	url = 'http://54.178.135.71:8080/CookIEServer/discover_recipes'

	$.ajax(
		type: "GET"
		url: url
		#dataType: 'jsonp'
		#crossDomain: true
		#jsonp: false
		dataType: 'application/json'
		data: 
			'type': 'search'
			'name': query
			'times': searchAjaxd
		timeout: 10000
		success: (data)->
			data = JSON.parse(data)
			console.log "[SUCCESS]search"
			console.log data

			scope = $("#main_Browse_Recipe")

			searchAjaxd++

			scrollerList = $("#main_Browse_Recipe").scroller()
			scrollerList.clearInfinite()

			if data.length is 0
				if searchAjaxd > 0
					$("#main_Browse_Recipe").find("#infinite").html "<i>No more results.</i>"
				else
					$("#main_Browse_Recipe").find("#infinite").html "<i>No result. Try another query?</i>"
				searchAjaxd--;
				return

			appendSearchResults(data)
			return #avoid implicit return values by Coffeescript
		error: (data, status)->
			console.log "[ERROR]search: " + status
			$("#main_Browse_Recipe").scroller().clearInfinite()
			return #avoid implicit return values by Coffeescript
	)
	return #avoid implicit return values by Coffeescript

appendSearchResults = (data)->
	console.log "Append search results"
	results = $("#SearchResults")

	results.find('.new').removeClass('new')
	count = 0
	for recipe in data
		html = ''
		id = recipe.recipe_id
		name = recipe.name
		rating = recipe.rating
		url = recipe.smallURL
		
		exist = if checkRecipeInDeck(id) then true else false 

		if count%2 is 0 #left part of the row
			html += '<div class="recipe_item left new" id="Recipe'+id+'" data-recipe-id="'+id+'">'
		else
			html += '<div class="recipe_item right new" id="Recipe'+id+'" data-recipe-id="'+id+'">'
		
		html += '<img class="recipe_image_wrapper" src="'+url+'">'
		html += '<div class="icon star recipe_descrip">'+rating+'</div>'
		html += '<div class="recipe_descrip">'+name+'</div>'
		if not exist
			html += '<div class="button recipe_btn recipe_add_btn" style="width:100%;align:center;margin-top:1px;margin-bottom:1px;border-radius:0;">Add To Deck</div>'
		else
			html += '<div class="button recipe_btn recipe_in_deck_btn" style="width:100%;align:center;margin-top:1px;margin-bottom:1px;border-radius:0;">Already in Deck</div>'
		html += '</div>'

		results.append html
		#console.log html
		count++
		
		#Fetch detailed recipe content on click
		thisRecipe = results.find("#Recipe"+id)
		thisRecipe.find("img").click do (id)->
			-> # closure 
				$.ui.loadContent("#RecipeContent")
				$("#RecipeContent").find("#Results").hide()
				$("#RecipeContent").find("#Loading").show()
				getRecipeContent(id)
				return

		if not exist
			thisRecipe.find(".recipe_btn").click do(id)->
				-> # closure
					addThisRecipeToDeck(id)
					$("#main_Browse_Recipe").find("#Recipe#{id}").find(".recipe_btn")[0].outerHTML = '<div class="button recipe_btn recipe_in_deck" style="width:100%;align:center;margin-top:1px;margin-bottom:1px;border-radius:0;">Already in Deck</div>'
					return

	results.find("#bottomBar").remove()
	results.append '<div id="bottomBar" style="display:block;height:0;clear:both;">&nbsp;</div>'
	$("#main_Browse_Recipe").find("#infinite").text "Load More"
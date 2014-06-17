recipeAjaxd = 0

$(document).ready ->
	addInfiniteScroll($('#main_Popular_Recipes'), 3000, ->getPopularRecipes(recipeAjaxd))
	return #avoid implicit return values by Coffeescript

getPopularRecipes = (times) ->
	$.ajax(
		type: "GET"
		url: 'http://54.178.135.71:8080/CookIEServer/discover_recipes'
		#dataType: 'jsonp'
		#crossDomain: true
		#jsonp: false
		dataType: 'application/json'
		data: 
			'type': 'popular'
			'times': times
		timeout: 10000
		success: (data)->
			data = JSON.parse(data)
			console.log "[SUCCESS]fetch popular recipes"
			console.log data

			recipeAjaxd++

			scrollerList = $('#main_Popular_Recipes').scroller()
			scrollerList.clearInfinite()

			if data.length is 0
				$("#main_Popular_Recipes").find("#infinite").text "No more recipes"
				recipeAjaxd--
				return

			scope = $("#main_Popular_Recipes")
			appendRecipeResult(scope, data)
			return #avoid implicit return values by Coffeescript
		error: (data, status)->
			console.log "[ERROR]fetch popular recipes: " + status
			console.log data
			$("#main_Popular_Recipes").find("#infinite").text "Load More"
			scrollerList = $('#main_Popular_Recipes').scroller()
			scrollerList.clearInfinite()
			return #avoid implicit return values by Coffeescript
	)
	return #avoid implicit return values by Coffeescript
	
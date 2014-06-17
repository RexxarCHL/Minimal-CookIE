###
ajaxSearchResults2
 	search(query, times)
 		Search for 'query' in server. Fetch (times*20)th to (times*20+20)th results.
###
searchAjaxd = 0
recipeAjaxd = 0
$(document).ready ->
	$("#SearchBar").keyup(->
		console.log "searchbar keyup"
		clearTimeout(window.lastId)

		query =  $("#SearchBar")[0].value
		if query is ""
			searchAjaxd = 0
			recipeAjaxd = 0
			getRecipes(recipeAjaxd)
			return

		$('#main_Browse_Recipe').scroller().clearInfinite()
		$("#main_Search").find("#infinite").text "Searching..."
		window.lastId = setTimeout(->
					search query, searchAjaxd
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

			scope = $("#main_Search")
			if searchAjaxd is 0
				addInfiniteScroll(scope, 1000, ->$("#SearchBar").trigger("keyup"))

			searchAjaxd++

			scrollerList = $("#main_Search").scroller()
			scrollerList.clearInfinite()

			if data.length is 0
				if searchAjaxd > 0
					$("#main_Search").find("#infinite").html "<i>No more results.</i>"
				else
					$("#main_Search").find("#infinite").html "<i>No result. Try another query?</i>"
				searchAjaxd--;
				return

			appendRecipeResult(scope, data)
			return #avoid implicit return values by Coffeescript
		error: (data, status)->
			console.log "[ERROR]search: " + status
			$("#main_Search").scroller().clearInfinite()
			return #avoid implicit return values by Coffeescript
	)
	return #avoid implicit return values by Coffeescript

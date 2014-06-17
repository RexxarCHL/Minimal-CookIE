###
ajaxSearchResults2.coffee
	initSelectBtn()
 		Initialize the Recipes/Menus tab button functionality.
 	search(query, times)
 		Search for 'query' in server. Fetch (times*20)th to (times*20+20)th results.
 	appendRecipeResult(scope, data)
 		Append 'data' to the #Results div in 'scope', in Recipe style.
 	appendMenuResult(scope, data)
 		Append 'data' to the #Results div in 'scope', in Menu style.
 	addInfiniteScroll(scope, delay, callback)
 		Add infinite scroll functionality to 'scope'. 'callback' is called after 'delay' miliseconds after infinite-scroll event is fired.
###
searchAjaxd = 0
$(document).ready ->
	initSelectBtn()
	$("#SearchBar").keyup(->
		console.log "searchbar keyup"
		scrollerList = $('#main_Search').scroller()
		clearTimeout(window.lastId)

		query =  $("#SearchBar")[0].value
		if query is ""
			searchAjaxd = 0
			$("#main_Search").find("#Results").html ""
			$("#main_Search").find("#infinite").html "<i>Search for recipes, food ingredients ...</i>"
			return

		scrollerList.clearInfinite()
		$("#main_Search").find("#infinite").text "Searching..."
		window.lastId = setTimeout(->
					search query, searchAjaxd
					return #avoid implicit return value
				, 1500)
		lastQuery = query
		return #avoid implicit return value
	)
	return #avoid implicit return value

initSelectBtn = ->
	$("#SearchSelectTab").children().each(->
		$(this).on("click", (evt)->
			if $(this).hasClass 'orange' then return

			other = $(this).siblings()[0]
			$(other).removeClass 'orange'
			$(this).addClass 'orange'
			console.log "search tab switch"
			searchAjaxd = 0
			$("#main_Search").find("#Results").html ""
			$("#main_Search").find("#infinite").html "<i>Search for recipes, food ingredients ...</i>"
			$("#SearchBar").trigger("keyup")

			evt.stopPropagation()
		)
		return
	)

search = (query, times) ->
	if $("#SearchSelectTab").find('a').hasClass('orange')
		type = 0
		url = 'http://54.178.135.71:8080/CookIEServer/discover_recipes'
	else
		type = 1
		url = 'http://54.178.135.71:8080/CookIEServer/discover_recipelists'

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

			if type then appendPopularMenuResult(scope, data)
			else appendRecipeResult(scope, data)
			return #avoid implicit return values by Coffeescript
		error: (data, status)->
			console.log "[ERROR]search: " + status
			$("#main_Search").scroller().clearInfinite()
			return #avoid implicit return values by Coffeescript
	)
	return #avoid implicit return values by Coffeescript

appendRecipeResult = (scope, data)->
	console.log "append recipe for scope: " + scope[0].id
	#if data.length%2 and data.length isnt 1 then data.length-- #prevent empty slot

	results = scope.find "#Results"
	results.find('.new').removeClass('new')
	count = 0
	for recipe in data
		html = ''
		id = recipe.recipe_id
		name = recipe.name
		rating = recipe.rating
		url = recipe.smallURL
		#url = 'img/love.jpg' # for test only
		if count%2 is 0 #left part of the row
			html += '<div class="recipe_item left new" id="Recipe'+id+'" data-recipe-id="'+id+'">'
		else
			html += '<div class="recipe_item right new" id="Recipe'+id+'" data-recipe-id="'+id+'">'
		
		html += '<img class="recipe_image_wrapper" src="'+url+'">'
		html += '<div class="recipe_descrip">'+name+'</div>'
		html += '<div class="icon star recipe_descrip">'+rating+'</div>'
		html += '</div>'

		results.append html
		#console.log html
		count++
		
		#Fetch detailed recipe content on click
		scope.find("#Recipe"+id)[0].onclick = do (id)->
			-> # closure 
				# TODO add inspect/select in kitchen
				if window.mode
					$(this).toggleClass 'chosen'
					return

				$.ui.loadContent("#RecipeContent")
				$("#RecipeContent").find("#Results").hide()
				$("#RecipeContent").find("#Loading").show()
				getRecipeContent(id)
				return

	results.find("#bottomBar").remove()
	results.append '<div id="bottomBar" style="display:block;height:0;clear:both;">&nbsp;</div>'
	scope.find("#infinite").text "Load More"
	return #avoid implicit return value

appendMenuResult = (scope, data)->
	console.log "append menu for scope: " + scope[0].id

	results = scope.find "#Results"
	results.find(".new").removeClass "new"

	for list in data
		html = ''
		id = list.list_id
		title = list.name
		rating = list.rating

		if rating is 0 then rating = 'No rating'
		else rating += " stars"
		
		html = '<div class="menu_wrapper new" id="Menu'+id+'">'
		html += '<h2 class="menu_title">'+title+'&nbsp;&nbsp;&nbsp;<i class="icon star">'+rating+'</i>&nbsp;&nbsp;<i class="icon chat">comments</i></h2>'

		idString = []
		html += '<div class="menu_img_wrapper">'
		for recipe in list.recipes
			src = recipe.smallURL
			#src = 'img/love.jpg' # for test only
			html += '<img class="menu_img" src="'+src+'">'
			idString.push recipe.recipe_id
		html += '</div>'
		
		html += '<div style="float:left;width:100%;background-color:white;border-radius:5px;"><a id="Cook" class="button red" style="float:right;width:20%;margin-right:5%;" href="#Ingredients</span>">Cook</a><a id="View" class="button green" style="float:right;width:20%;margin-right:2%;" href="#MenuContent">View</a></div><div class="aDivider">&nbsp;</div>'
		html += '</div>'
		results.append html
		scope.find("#Menu"+id).attr 'data-recipe-ids', JSON.stringify idString
		#console.log html
		#TODO add on click function to cook btn

		#!!! TODO MODIFY FROM COLLECTION TO MENUCONTENT !!!
		#Fetch detailed menu content on click
		##
		scope.find("#Menu"+id).find("#View")[0].onclick = do(id)->
			-> # closure
				$("#Collection").find("#Results").hide()
				$("#Collection").find("#Loading").show()
				getMenuContent(id)
				return
		#

	scope.find("#infinite").text "Load More"
	return #avoid implicit return values

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

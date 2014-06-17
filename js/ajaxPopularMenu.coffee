menuAjaxd = 0
$(document).ready ->
	addInfiniteScroll($('#main_Popular_Menus'), 1000, ->getPopularMenus(menuAjaxd))
	return

getPopularMenus = (times) ->
	$.ajax(
		type: "GET"
		url: 'http://54.178.135.71:8080/CookIEServer/discover_recipelists'
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
			console.log "[SUCCESS]fetch popular menu"
			console.log data

			menuAjaxd++

			$('#main_Popular_Menus').scroller().clearInfinite()

			if data is null or data.length is 0
				$("#main_Popular_Menus").find("#infinite").text "No more menu"
				menuAjaxd--
				return

			scope = $("#main_Popular_Menus")
			appendPopularMenuResult(scope, data)
			return
		error: (data, status)->
			console.log "[ERROR]fetch popular menu: " + status
			$("#main_Popular_Menus").find("#infinite").text "Error. Try Again?"
			$('#main_Popular_Menus').scroller().clearInfinite()
			return
	)
	return

appendPopularMenuResult = (scope, data)->
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
		
		html = '<div class="menu_wrapper new" id="Menu'+id+'" menu-id="'+id+'">'
		html += '<h2 class="menu_title">'+title+'&nbsp;&nbsp;&nbsp;<i class="icon star h5">'+rating+'</i>&nbsp;&nbsp;<i class="icon chat h5">comments</i></h2>'

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
		scope.find("#Menu"+id).attr "data-recipe-ids", JSON.stringify idString
		#console.log html
		#TODO add on click function to cook btn

		#Fetch detailed menu content on click
		scope.find("#Menu"+id).find("#View")[0].onclick = do(id)->
			-> # closure
				$("#MenuContent").find("#Results").hide()
				$("#MenuContent").find("#Loading").show()
				getMenuContent($("#MenuContent"), id)
				return
				
		scope.find("#Menu"+id).find("#Cook")[0].onclick = do(id)->
			-> # closure
				$("#Ingredients").find("#Results").hide()
				$("#Ingredients").find("#Loading").show()
				$.ui.loadContent("#Ingredients")
				getCookingIngredientList scope.find("#Menu#{id}").attr("data-recipe-ids")
				return # avoid implicit rv
		#

	scope.find("#infinite").text "Load More"
	return #avoid implicit return values

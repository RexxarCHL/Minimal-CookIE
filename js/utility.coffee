$(document).ready ->
	loadPopularRecipes()
	loadPopularMenus()
	$('body').find('.popup_btn').forEach (elem)->
		$(elem).click ->
			utilityDetect(this)
		return # avoid implicit rv
	resetUtilBtn()
	return

utilityDetect = (elem)->
	console.log 'Popup #'+elem.id
	switch elem.getAttribute 'data-function'
		when 'edit'
			$('#popup_btn_trash').removeClass 'selected'
			$(elem).toggleClass 'selected'
			if $(elem).hasClass('selected') then utilityEdit()
			else resetUtilBtn()
		when 'trash'
			$('#popup_btn_edit').removeClass 'selected'
			$(elem).toggleClass 'selected'
			if $(elem).hasClass('selected') then utilityTrash()
			else resetUtilBtn()
		else break
	return # avoid implicit rv

resetUtilBtn = ->
	$('#main_Kitchen_Recipes').find('.selected').removeClass('selected')
	utilBtn = $('#kitchenUtilityBtn')
	$('body').find('.popup_btn').removeClass 'selected'
	utilBtn.removeClass 'trash'
	utilBtn.removeClass 'edit'
	utilBtn.unbind 'click'
	utilBtn.bind 'click', ->
		$(".popup_btn").toggle()
	utilBtn.html 'Tap on the Cog to begin.'
	window.mode = 0

utilityEdit = ->
	console.log 'popup edit'
	window.mode = 1
	utilBtn = $('#kitchenUtilityBtn')
	utilBtn.removeClass 'trash'
	utilBtn.addClass 'edit'
	utilBtn.html 'Start Cooking.'


	utilBtn.unbind 'click'
	utilBtn.click ->
		selectedId = findChosenRecipeId()
		if selectedId.length is 0 then return
		$.ui.popup(
			title: '為Menu命名'
			message: '<input id="popupBoxInputTitle" type="text"><label>公開</label><input id="popupBoxInputPrivacy" type="checkbox" class="toggle"><label for="popupBoxInputPrivacy" data-on="私密" data-off="公開"><span></span></label><br>'
			cancelText:"Cancel"
			cancelCallback: ->
				console.log "cancelled"
				return
			doneText:"Done"
			doneCallback: (elem)->
				console.log "Done for!"
				listTitle = $(elem.container).find("#popupBoxInputTitle")[0].value
				# false:public/true:private
				isPrivate = $(elem.container).find("#popupboxInputPrivacy")[0].checked
				createNewMenu selectedId, listTitle, isPrivate
				return
			cancelOnly:false
		)


	return

utilityTrash = ->
	console.log 'popup trash'
	window.mode = 1
	utilBtn = $('#kitchenUtilityBtn')
	utilBtn.removeClass 'edit'
	utilBtn.addClass 'trash'
	utilBtn.html 'Delete selected recipe.'

	utilBtn.unbind 'click'
	utilBtn.click -> deleteSelectedRecipes()
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

kitchenRecipesAjaxd = 0 #DEBUG
reloadKitchenRecipes = ->
	scope = $("#main_Kitchen_Recipes")
	scope.find("#Results").html ""
	scope.find("#infinite").text "Reloading..."
	kitchenRecipesAjaxd = 0
	getKitchenRecipes(kitchenRecipesAjaxd)
	return

kitchenMenuAjaxd = 0
reloadKitchenMenus = ->
	scope = $("#main_Kitchen_Menus")
	scope.find('#Results').html ""
	scope.find("#infinite").text "Reloading..."
	kitchenMenuAjaxd = 0
	getKitchenMenus(kitchenMenuAjaxd)
	return

recipeAjaxd = 0
loadPopularRecipes = ->
	scope = $('#main_Popular_Recipes')
	scope.find('#Results').html ""
	scope.find("#infinite").text "Reloading..."
	recipeAjaxd = 0
	getPopularRecipes(recipeAjaxd)
	return

menuAjaxd = 0
loadPopularMenus = ->
	scope = $('#main_Popular_Menus')
	scope.find('#Results').html ""
	scope.find("#infinite").text "Reloading..."
	menuAjaxd = 0
	getPopularMenus(menuAjaxd)
	return

findChosenRecipeId = ->
	recipeSelectedId = []
	$('#main_Kitchen_Recipes').find('.chosen').forEach (elem)->
		recipeSelectedId.push elem.getAttribute 'data-recipe-id'
	console.log recipeSelectedId
	return recipeSelectedId

createNewMenu = (recipeIds, listTitle, isPrivate)->
	console.log "create new menu for ##{recipeIds} with title=#{listTitle} and privacy=#{isPrivate}"

	data = 
		list_name: listTitle
		description: ""
		privacy: isPrivate
		recipes: recipeIds
		user_id: window.user_id
		token: window.token
	data = JSON.stringify data

	console.log data
	$.ajax(
		type: 'POST'
		url: 'http://54.178.135.71:8080/CookIEServer/recipelist'
		dataType: 'application/json'
		#crossDomain: true
		#jsonp: false
		data: data
		timeout: 10000
		success: (data)->
			data = JSON.parse(data)
			console.log "[SUCCESS] new list #{listTitle} for recipes #{recipeIds}"
			console.log data
			newId = data.new_id
			alert "Menu #{listTitle} successfully created"
			resetSelectedRecipe()

			### add this newly created menu to kitchen ###
			console.log "secretly add this new list to kitchen"
			data = 
				user_id: window.user_id
				token: window.token
				type: 'list'
				list_id: newId
			data = JSON.stringify data

			$.ajax(
				type: 'POST'
				url: 'http://54.178.135.71:8080/CookIEServer/favorite'
				contentType: 'application/json'
				data: data
				timeout: 10000
				success: (data)->
					console.log "[SUCCESS] add menu ##{newId} to kitchen"
					console.log data
					reloadKitchenMenus()
					return # avoid implicit rv
				error: (resp)->
					console.log "[ERROR] add menu ##{newId} to kitchen"
					console.log resp
					return # avoid implicit rv
			)

			return # avoid implicit rv
		error: (data, status)->
			console.log "[ERROR] new list #{listTitle} for recipes #{recipeIds}"
			console.log data	
			return # avoid implicit rv
	)


	return # avoid implicit rv

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

addThisMenuToKitchen = ->
	menuId = $('#MenuContent').find('.menuContent_imgHolder').attr 'data-menu-id'
	console.log "add menu ##{menuId} to kitchen"

	data = 
		user_id: window.user_id
		token: window.token
		type: 'list'
		list_id: menuId
	data = JSON.stringify data

	$.ajax(
		type: 'POST'
		url: 'http://54.178.135.71:8080/CookIEServer/favorite'
		contentType: 'application/json'
		data: data
		timeout: 10000
		success: (data)->
			console.log "[SUCCESS] add menu ##{menuId} to kitchen"
			console.log data
			alert "Done!"
			reloadKitchenMenus()
			return # avoid implicit rv
		error: (resp)->
			console.log "[ERROR] add menu ##{menuId} to kitchen"
			console.log resp
			if resp.status is 404
				alert "Oops! The menu is already in Kitchen!"
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
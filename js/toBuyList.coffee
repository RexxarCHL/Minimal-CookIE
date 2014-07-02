###
toBuyList.coffee
	Everything about the to-buy list.

	getIngredientList(recipeIds)
		Get the ingredient list of recipes whose id are 'recipeIds' from the server, store the list, and forward the data to showIngredientList.
	storeIngredientListToDB(data)
		Store the fetched 'data' to DB `MenuIngredients`.
	showIngredientList()
		As the name implies.
	moveCheckedIngredientToBottom()
		As the name implies.
	reloadToBuyList()
		As the name implies.
###

# get 'recipeIds' from the server
getIngredientList = (recipeIds)->
	console.log "get ingredient list"

	# block the UI and let the user know that we're loading
	$.ui.blockUI(0.1)
	$.ui.showMask "Updating..."

	# construct the query string
	data = ''
	for id in recipeIds
		data += 'recipes='+id+'&'
	$.ajax(
			type: 'GET'
			url: 'http://54.178.135.71:8080/CookIEServer/list_ingredient?'+data
			timeout: 10000
			success: (data)->
				# SUCCESS
				# parse and log the data received
				data = JSON.parse(data)
				console.log '[SUCCESS] fetching #'+recipeIds
				console.log data

				storeIngredientListToDB(data)
				showIngredientList()

				return # avoid implicit rv
			error: (resp)->
				# ERROR
				# log the response for DEBUG 
				console.log '[ERROR] fetching #'+recipeIds
				console.log resp

				return # avoid implicit rv
	)
	return # avoid implicit rv

# store the 'data' to DB `MenuIngredients`
storeIngredientListToDB = (data)->
	console.log "store ingredient list to db"

	# clear everything in DB previously
	db.transaction (transaction)->
		transaction.executeSql 'DELETE FROM `MenuIngredients`', [],
			successCallBack,
			errorHandler
		, errorHandler, nullHandler
		return

	# add the ingredients to DB
	for ingredient in data
		AddValueToIngredient ingredient.ingredientId,
			ingredient.recipeId,
			ingredient.ingredientName,
			ingredient.amount,
			ingredient.unitName
	return

# show the ingredient list
showIngredientList = ->
	# check if database exists
	if not window.openDatabase
		alert 'Databases not supported by this browser'
		return

	console.log "show ingredient list"
	
	# hide the cook button and show the empty notification
	$("#EmptyNotify").removeClass 'hidden'
	$("#ToBuyListCookBtn").addClass 'hidden'

	# get everything from DB `MenuIngredients`
	db.transaction (transaction)->
		transaction.executeSql 'SELECT * FROM MenuIngredients', [],
			(transaction,result)->
				if result? and result.rows?
					### if there's no list in the DB ###
					if result.rows.length is 0 then return

					### there's list in the DB ###
					list = $("#list")
					list.html ""
					html = ''
					# append the list
					for x, i in result.rows
						row = result.rows.item(i)
						html += '<li class="listEle">'+row.name+'&nbsp;'+row.amount+'&nbsp;'+row.unitName+'</li>'
					list.append html

					# add onclick functions to every list element
					$('.listEle').click (event)->
						if $(this).css('textDecoration') is 'line-through'
							# remove the deletion line
							$(this).css 'textDecoration', 'none'
							$(this).css 'color', '#53575E'
							$(this).removeClass 'list-selected'
							$(this).removeClass 'not-moved'
						else
							# add the deletion line
							$(this).css 'textDecoration', 'line-through'
							$(this).css 'color', '#D8D8D8'
							$(this).addClass 'list-selected'
							$(this).addClass 'not-moved'
						
						# delay the move-checked-ingredients-to-bottom process in case the user regrets
						clearTimeout window.lastId
						window.lastId = setTimeout ->
							moveCheckedIngredientToBottom()
						, 2000

						return # avoid implicit rv posted by Coffeescript compliation

					# hide the empty notification and show the cook button
					$("#EmptyNotify").addClass 'hidden'
					$("#ToBuyListCookBtn").removeClass 'hidden'
					
					# hide the spinning wheel and unblock the UI
					$.ui.hideMask()
					$.ui.unblockUI()
				return # avoid implict rv
			, errorHandler
		, errorHandler, nullHandler
		return # avoid implicit rv

	return # avoid implicit rv

moveCheckedIngredientToBottom = ->
	console.log "move checked to bottom"
	$('#list').find('.not-moved').forEach (listEle)->
		html = listEle.outerHTML
		ele = $(listEle)
		ele.css3Animate
			opacity: '0.1'
			time: '200ms'
			success: ()->
				ele.removeClass 'not-moved'
				ele.remove()
				$('#list').append html
	return

reloadToBuyList = ->
	console.log "reload to buy list"
	# if the deck has not changed since last reload then don't reload
	if not window.deckChanged then return

	# the deck has changed 
	# ...but the deck is empty
	if window.recipesInDeck.length is 0
		# empty the list and show empty notification
		$("#list").html ""
		$("#EmptyNotify").removeClass 'hidden'
		$("#ToBuyListCookBtn").addClass 'hidden'
		return
	
	# the deck is not empty
	# load the ingredient lists
	getIngredientList window.recipesInDeck
	
	# reset the flag
	window.deckChanged = false

	return # avoid implicit rv
	
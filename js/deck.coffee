###
deck.coffee
	Everything about the Deck goes here.

	addThisRecipeToDeck(id)
		Add recipe whose id is 'id' to Deck.
	deleteThisRecipeToDeck(id)
		Delete recipe whose id is 'id' to Deck.
	findRecipeIdsInDeck()
		Get all the ids of the recipes currently in Deck.
	checkRecipeInDeck(id)
		Check if a recipe whose id is 'id' is in Deck.
	checkRecipeInDB()
		Check if there is any recipe in DB `Recipes`. Load the recipe ids to window.recipesInDeck if there is.
###
# when the html is ready,
$(document).ready ->
	# bind onclick behaviour to #ToBuyBtn button
	$("#ToBuyBtn").click ->
		# get all the recipe ids currently in Deck
		recipeIds = findRecipeIdsInDeck()
		# if there is no recipe in Deck then return
		if not recipeIds? or recipeIds.length is 0 then return

		# jump to To-buy list page
		$.ui.loadContent "main_ToBuy_List"

		# get current ingredient list
		getIngredientList(recipeIds)
		return # avoid implicit rv posted by Coffeescript

	# bind onclick behaviour to #CookBtn button
	$("#CookBtn").click ->
		# get all the recipe ids currently in Deck
		recipeIds = findRecipeIdsInDeck()
		# if there is not recipe in Deck then return
		if not recipeIds? or recipeIds.length is 0 then return

		# jump to scheduled information page
		$.ui.loadContent "Cooking"

		# get scheduled plan of recipes in Deck
		getScheduledRecipe(recipeIds)
		return # avoid implicit rv
	
	return # avoid implicit rv

# push 'id' to window.recipesInDeck
addThisRecipeToDeck = (id)->
	console.log "Add recipe ##{id} to deck"

	# check if maxium length is reached
	if window.recipesInDeck.length >= 6
		alert "抱歉，最多選 6 道菜做排程\n您現在選了 #{window.recipesInDeck.length} 道 "
		return

	### Push if not already in deck ###
	if window.recipesInDeck.lastIndexOf(id) is -1
		AddRecipeValue id # push this recipe into db
		checkRecipeInDB()

	# raise the flag to indicate that the deck has already changed
	window.deckChanged = true

	# update the count
	updateNavbarDeck()

	return

# delete 'id' from window.recipesInDeck
deleteThisRecipeFromDeck = (id)->
	console.log "delete #{id} from deck"

	### If not in deck, which is not possible but check anyway ###
	if (index = window.recipesInDeck.lastIndexOf(id)) is -1 then return
	window.recipesInDeck.splice index, 1
	console.log "deck: #{window.recipesInDeck}"

	# raise the flah to indicate that the deck has already changed
	window.deckChanged = true
	
	# update the counte
	updateNavbarDeck()

	### delete from DB ###
	deleteRecipe(id)
	checkRecipeInDB()

	# reset the buttons regarding this recipe
	thisRecipeBtn = $("#Recipe#{id}")
	thisRecipeBtn.find(".recipe_btn")[0].outerHTML = '<div class="button recipe_btn recipe_add_btn chinese_font">加到調理台</div>'
	thisRecipeBtn = thisRecipeBtn.find(".recipe_btn")
	thisRecipeBtn.unbind 'click'
	thisRecipeBtn.click do(id)->
		-> #closure
			addThisRecipeToDeck(id)
			$("#main_Browse_Recipe").find("#Recipe#{id}").find(".recipe_btn")[0].outerHTML = '<div class="button recipe_btn recipe_in_deck_btn chinese_font">已加入調理台</div>'
			return

	return

# get all ids of the recipes in Deck
findRecipeIdsInDeck = ->
	recipeIds = []
	$('#main_Deck').find('.recipe_item').forEach (elem)->
		recipeIds.push elem.getAttribute 'data-recipe-id'
	console.log recipeIds
	return recipeIds

# check if 'id' is in window.recipeInDeck
checkRecipeInDeck = (id)->
	#console.log "index for  #{id} is #{window.recipesInDeck.lastIndexOf(id)}"
	if window.recipesInDeck.lastIndexOf(id) is -1 then false else true

# check if there is recipe in DB `Recipes`. Load the recipe ids to window.recipesInDeck if there is.
checkRecipeInDB = ->
	# check if the database exists
	if not window.openDatabase
    	alert 'Databases are not supported in this browser.'
    	return

    # search the database
	sql = 'SELECT `recipeId` FROM `Recipes`'
	db.transaction (transaction)->
		transaction.executeSql sql, [], (transaction, result)->
			if result? and result.rows?
				### There is recipe in deck ###
				console.log "OK"

				# load the recipe ids to window.recipesInDeck
				window.recipesInDeck = []
				for x,i in result.rows
					row = result.rows.item(i)
					window.recipesExist = 1
					# console.log row.recipeId
					window.recipesInDeck.push row.recipeId
					updateNavbarDeck()
				return
			console.log "NOT OK"
			window.recipesExist = 0

		, errorHandler

		return # avoid implict rv
	, errorHandler, nullHandler

	return # avoid implicit rv

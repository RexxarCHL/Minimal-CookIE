appendRecipeResult = (scope, data, deck = 0)->
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
		
		exist = if checkRecipeInDeck(id) then true else false

		if count%2 #left part of the row
			html += '<div class="recipe_item right new" id="Recipe'+id+'" data-recipe-id="'+id+'">'
		else
			html += '<div class="recipe_item left new" id="Recipe'+id+'" data-recipe-id="'+id+'">'
		
		html += '<img class="recipe_image_wrapper" src="'+url+'">'
		html += '<div class="icon star recipe_descrip">'+rating+'</div>'
		html += '<div class="recipe_descrip">'+name+'</div>'
		if not exist
			html += '<div class="button recipe_btn recipe_add_btn" style="width:100%;align:center;margin-top:1px;margin-bottom:1px;border-radius:0;">Add To Deck</div>'
		else if deck
			html += '<div class="button recipe_btn recipe_remove_btn" style="width:100%;align:center;margin-top:1px;margin-bottom:1px;border-radius:0;">Remove from Deck</div>'
		else
			html += '<div class="button recipe_btn recipe_in_deck_btn" style="width:100%;align:center;margin-top:1px;margin-bottom:1px;border-radius:0;">Already in Deck</div>'
		html += '</div>'

		results.append html
		#console.log html
		count++
		
		#Fetch detailed recipe content on click
		thisRecipe = scope.find("#Recipe"+id)
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
		else if deck
			thisRecipe.find(".recipe_btn").click do(id)->
				-> # closure
					deleteThisRecipeFromDeck(id)
					return

	results.find("#bottomBar").remove()
	results.append '<div id="bottomBar" style="display:block;height:0;clear:both;">&nbsp;</div>'
	scope.find("#infinite").text "Load More"
	return #avoid implicit return value

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
		
		disable = if checkRecipeInDeck(id) then "disabled" else ""

		if count%2 is 0 #left part of the row
			html += '<div class="recipe_item left new" id="Recipe'+id+'" data-recipe-id="'+id+'">'
		else
			html += '<div class="recipe_item right new" id="Recipe'+id+'" data-recipe-id="'+id+'">'
		
		html += '<img class="recipe_image_wrapper" src="'+url+'">'
		html += '<div class="icon star recipe_descrip">'+rating+'</div>'
		html += '<div class="recipe_descrip">'+name+'</div>'
		html += '<div class="button recipe_add_btn" style="width:100%;align:center;margin-top:1px;margin-bottom:1px;">Add To Deck</div>'
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

		thisRecipe.find(".recipe_add_btn").click do(id)->
			-> # closure
				addThisRecipeToDeck(id)
				return

	results.find("#bottomBar").remove()
	results.append '<div id="bottomBar" style="display:block;height:0;clear:both;">&nbsp;</div>'
	scope.find("#infinite").text "Load More"
	return #avoid implicit return value

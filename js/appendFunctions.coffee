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

		if deck
			html += '<div class="recipe_item long" id="Recipe'+id+'" data-recipe-id="'+id+'">'
		else
			if count%2 #left part of the row
				html += '<div class="recipe_item right new" id="Recipe'+id+'" data-recipe-id="'+id+'">'
			else
				html += '<div class="recipe_item left new" id="Recipe'+id+'" data-recipe-id="'+id+'">'
			html += '<div style="height:30%;background-color:white;border-radius:2px;">'
		
		if deck
			html += '<img class="recipe_image_wrapper long" src="'+url+'">'
			html += '<div class="recipe_descrip long chinese_font">'+name+'</div>'
			html += '<div class="recipe_time chinese_font">'+'</div>'
		else
			html += '<img class="recipe_image_wrapper" src="'+url+'">'
			html += '<div class="recipe_descrip chinese_font">'+name+'</div>'
		#html += '<div class="icon star recipe_descrip">'+rating+'</div>'
		
		if not deck
			html += '<div class="recipe_cooked"><i class="fa fa-spoon"></i></div>'+'</div>'
		if not exist
			html += '<div class="button recipe_btn recipe_add_btn chinese_font" style="width:80%;text-align:center;text-shadow:-1px -1px gray;padding:8px 0px;margin-top:5%;margin-bottom:3px;margin-left:10%;border:none;">加到 Deck</div>'
		else if deck
			html += '<div class="button recipe_btn recipe_remove_btn chinese_font" style="float:right;width:60%;text-align:center;margin-top:1px;margin-bottom:1px;margin-right:1%;border:none;border-radius:0;">移除</div>'
		else
			html += '<div class="button recipe_btn recipe_in_deck_btn chinese_font" style="color:gray;width:80%;text-align:center;padding:8px 0px;margin-top:5%;margin-bottom:3px;margin-left:10%;border:none;">已加入 Deck</div>'
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
			thisRecipe.find(".recipe_btn").click do(id, thisRecipe)->
				-> # closure
					addThisRecipeToDeck(id)
					thisRecipe.find(".recipe_btn")[0].outerHTML = '<div class="button recipe_btn recipe_in_deck_btn chinese_font" style="color:gray;width:80%;text-align:center;padding:8px 0px;margin-top:1px;margin-bottom:3px;margin-left:10%;border:none;">已加入 Deck</div>'
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

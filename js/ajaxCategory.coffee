###
ajaxCategory.coffee
	category related remote fetching functions

	getAllCategory(times)
		Get all categories and forward the data received to appendAllCategoryResult.
		Fetch (times*20)th to (times*20+20)th results.
	appendAllCateogryResult(data)
		Append the data received to #main_Browse_Category.
	getSingleCategory(times, tagId)
		Get the category whose id is 'tagId' and forward to append functions to append the data to #CategoryContent.
		Fetch (times*20)th to (times*20+20)th results.
		The append function is in appendFunctions.coffee.
###

#singleCatId = 26 #DEBUG
allCatAjaxd = 0 # allCatAjaxd: a count of how many times all categories have been ajax'ed
singleCatAjaxd = 0 # singleCatAjaxd: a count of how many times a single category has been ajax'ed

# when the html is ready
$(document).ready ->
	# add infinite scrolls to category related pages
	addInfiniteScroll($("#main_Browse_Category"), 1000, -> getAllCategory(allCatAjaxd))
	addInfiniteScroll($("#CategoryContent"), 1000, ->
		getSingleCategory(singleCatAjaxd, singleCatId)
		return
	)

	return #prevent implicit rv

# get all categories and append them to #main_Browse_Category
getAllCategory = (times) ->
	$.ajax(
		type: "GET"
		url: "http://54.178.135.71:8080/CookIEServer/discover_category"
		#dataType: 'jsonp'
		#crossDomain: true
		#jsonp: false
		dataType: 'application/json'
		data:
			'times': times
		
		timeout: 10000
		success: (data)->
			# SUCCESS
			# parse the received data
			data = JSON.parse(data)
			console.log "[SUCCESS]fetch categories"
			console.log data

			# increment the number of times all categories has been ajax'ed
			allCatAjaxd++

			# clear the infinite scroll flag to prevent malfunction 
			$("#main_Browse_Category").scroller().clearInfinite()

			# if the data returned is empty
			if data.length is 0
				# let the user know
				$("#main_Browse_Category").find("#infinite").text "No more categories"
				
				#decrement the count since this fetch is not valid
				allCatAjaxd--
				return

			# the data is not empty, show apporiate text and append the result
			$("#main_Browse_Category").find("#infinite").text "Load more"
			appendAllCategoryResult(data)
			return #avoid implicit rv
		error: (resp)->
			# ERROR
			# log the error status
			console.log "[ERROR]fetch kitchen menu: " + resp.status
			
			# clear the infinite scroll flag to prevent malfunction
			$("#main_Browse_Category").scroller().clearInfinite()

			# show apporiate text according to status code
			if resp.status is 0 
				# status is 0: server rejects
				$("#main_Browse_Category").find("#infinite").text "Server Error. Try again later."
			else
				# else: unknown error
				$("#main_Browse_Category").find("#infinite").text "Connection Error: #{resp.status}"
			return #avoid implicit rv

	)

	return #avoid implicit rv

# append the data received to #main_Browse_Category
appendAllCategoryResult = (data)->
	console.log "append all category result"

	# get to the place where the results belong
	results = $("#main_Browse_Category").find("#Results")
	
	# remove the class 'new' since the previous categories are no longer new
	results.find(".new").removeClass("new")

	# for every tag group
	for tagGroup in data
		# if the length is zero then skip this group, to prevent empty container
		if tagGroup.tagWithRecipe.length is 0 then continue

		# construct the html of the recipes in this group
		html = '<div class="category_box" id="TagFilter'+tagGroup.tagfilter.filterId+'"><h2 style="margin-left:5px;">'+tagGroup.tagfilter.filterName+'</h2>'
		for tag in tagGroup.tagWithRecipe
			id = tag.tag.tagId
			html += '<div id="Tag'+id+'" class="cat_wrapper new" data-tag-id="'+id+'" data-times="0"><img class="cat_icon" src="'+tag.mostPopularRecipe.smallURL+'"><div class="cat_text">'+tag.tag.tagName+'</div></div>'
		html += '</div><div class="divider">&nbsp;</div>'

		# append the container
		results.append html

	# add on click functions to newly appended categories
	results.find(".new").forEach (elem)->
		$(elem).click ->
			$.ui.loadContent "#CategoryContent"
			times = parseInt this.getAttribute 'data-times'
			id = this.getAttribute 'data-tag-id'
			singleCatId = id
			singleCatAjaxd = times
			getSingleCategory singleCatAjaxd, singleCatId
			# this.setAttribute 'data-times', times+1
	
	return #avoid implicit rv

# get single category whose id is 'tagId' and append the data received to #CategoryContent
getSingleCategory = (times, tagId)->
	$.ajax(
		type: "GET"
		url: "http://54.178.135.71:8080/CookIEServer/get_tag"	
		dataType: 'application/json'
		#crossDomain: true
		data:
			'times': times
			'tag_id': tagId
		#jsonp: false
		#timeout: 10000
		success: (data)->
			# SUCCESS
			# parse the data received
			data = JSON.parse(data)
			console.log "[SUCCESS]fetch cat #{tagId} for #{times} times"
			console.log data

			# increment the number of times this category has been ajax'ed
			singleCatAjaxd++

			# clear the flag for infinite scroll to prevent malfunction
			$('#CategoryContent').scroller().clearInfinite()

			# if the data received is empty
			if data.recipes.length is 0
				# inform the user
				$("#CategoryContent").find("#infinite").html "No more recipes."
				
				# decrement the count since this fetch is not valid
				singleCatAjaxd--
				return

			# the data received is not empty
			# change the title
			$.ui.setTitle data.tag.tagName

			# empty the contents in #CategoryContent and append the new result
			scope = $('#CategoryContent')
			scope.find("#Results").html ""
			appendRecipeResult(scope, data.recipes)
			return #avoid implicit rv
		error: (data, status)->
			#ERROR
			console.log "[ERROR]fetch cat #"+tagId
			
			# clear the flag for infinite scroll to prevent malfunction
			$('#CategoryContent').scroller().clearInfinite()

			# imform the user
			$("#CategoryContent").find("#infinite").html "Error. Try Again?"
			return #avoid implicit rv
	)
	
	return #avoid implicit rv

### Class Definitions ###
class Step
	constructor: (obj)->
		@finishTime = @startTime + @duration
		@timeElapsed = 0
		@percentage = ""
		return

	calculateRemainTime: ->
		@remainTime = @duration - @timeElapsed

	calculatePercentage: ->
		remainTime = this.calculateRemainTime()
		@percentage = Math.floor(remainTime / @duration * 100)
		@percentage + "%"

### Function definitions ###
# on-panel-load function for #Step aka cooking step
cookingStarted = ->
	### Check if cooking data exist. It should exist when this is called but check anyways. ###
	if not window.cookingData? then return

	currentStepNum = window.currentStepNum
	window.currentTime = 0
	window.waitingStepQueue = []
	window.cookingStartTime = new Date()

	console.log "cooking started"

	# reset the interface
	$(".step_next_btn").html "Next"
	$(".waiting_step_outer_wrapper").addClass 'invisible'
	checkFinishPercentageAndChangeTitle()

	# load this/next step data
	$("#Step").attr "data-title", "Step #{currentStepNum+1} (#{finishPercentage}%)"
	loadStep(currentStepNum)

	setTimeout ->
		timer()
	, 1000

	return # avoid implicit rv

cookingEnded = ->
	stopTimer()

### Timer: for clocking the cook process ###
timer = ->
	# clock tick
	window.currentTime = window.currentTime + 1
	window.waitingStepQueue.forEach (step)->
		step.timeElapsed += 1
		step.calculateRemainTime()
	
	# update progress bar
	checkProgress()
	showTwoUrgentSteps()

	#start another timer
	startTimer()

	return # avoid implicit rv

startTimer = ->
	# clear the any previous timer
	clearTimeout window.lastId

	# reserve next clock tick
	window.lastId = setTimeout ->
			timer()
		, 1000
	return

stopTimer = ->
	# clear previous timer
	clearTimeout window.lastId

### Steps ###
loadStep = (stepNum)->
	console.log "load step##{stepNum}"
	thisStep = window.cookingData.steps[stepNum]
	window.currentStep = addStepInfo(thisStep)
	window.currentStepNum = stepNum

	# change the title
	checkFinishPercentageAndChangeTitle()


	scope = $("#Step")
	# load this step
	scope.find(".this_step_recipe_name").html thisStep.recipeName
	scope.find(".this_step_digest").html thisStep.digest

	# load next step info
	nextStep = window.cookingData.steps[stepNum+1]
	if nextStep?
		scope.find(".next_step_name").html nextStep.stepName
		scope.find(".next_step_time").html thisStep.time
	else
		scope.find(".next_step_name").html "Final Step Reached"
		scope.find(".next_step_time").html "00:00"
		scope.find(".step_next_btn").html "Finish "

	scope.find(".step_next_btn").unbind 'click'
	scope.find(".step_next_btn").click ->
		checkNextStep()
		return # avoid implicit rv

	return # avoid implicit rv

checkNextStep = ->
	currentTime = window.currentTime
	thisStep = window.currentStep
	thisStepFinishTime = thisStep.finishTime
	
	if not (nextStep = window.cookingData.steps[thisStep.stepNum+1])?
		### There is no next step ###
		console.log "finished"
		$.ui.loadContent "Finish"
		return

	### Check if there is a step blocking in the waiting queue ###
	if checkWaitingStepBlocking(thisStep, nextStep) then return

	### No blocking step -> load next step ###
	checkProgress()
	loadStep(thisStep.stepNum+1)

	return # avoid implicit rv

# Checks if there is a step blocking in the waiting queue
checkWaitingStepBlocking = (thisStep, nextStep)->
	clonedQueue = clone window.waitingStepQueue
	if thisStep.finishTime < nextStep.startTime
		### This step does not directly lead to next step -> there is a blocking step in waiting queue ###
		window.waitingStepQueue.forEach (waitingStep)->
			if waitingStep.finishTime is nextStep.startTime
				### The blocking step is found ###
				waitingStepIndex = clonedQueue.lastIndexOf waitingStep
				showBlockingStep waitingStepIndex
				true

	### Check the waiting steps for next step's previous steps ###
	window.waitingStepQueue.forEach (waitingStep)->
		if waitingStep.recipeId is nextStep.recipeId
			### There is a step with the same recipeId as next step in the waiting queue. ###
			# retrieve the index of the blocking step in the waiting queue
			waitingStepIndex = clonedQueue.lastIndexOf(waitingStep)
			showBlockingStep waitingStepIndex
			true

	false
	

checkFinishPercentageAndChangeTitle = ->
	stepNum = window.currentStepNum
	finishPercentage = Math.ceil (stepNum+1) / window.cookingData.steps.length * 100
	$.ui.setTitle "Step #{stepNum+1} (#{finishPercentage}%)"

	return

addStepInfo = (step)->
	step.duration = convertTimeToSeconds step.time
	step.finishTime = step.startTime + step.duration
	step.timeElapsed = 0
	step.percentage = ""
	step.remainTime = calculateRemainTime(step)

	step

calculateRemainTime = (step)->
	step.remainTime = step.duration - step.timeElapsed

finishedShowStatus = -> 
	timeElapsed = (new Date()) - window.cookingStartTime # in milliseconds
	timeElapsed = parseSecondsToTime timeElapsed/1000
	
	scope = $("#Finish")
	scope.find("#TotalTimeSpent").html timeElapsed
	scope.find("#OriginalTime").html window.cookingData.originTime

	return
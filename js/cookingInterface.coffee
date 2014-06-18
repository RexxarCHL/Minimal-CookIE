### Class Definitions ###
class Step
	constructor: (@stepNum, @startTime, @duration, @recipeName, @digest, @people)->
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
	window.currentStep = Step(stepNum, parseInt(thisStep.startTime), convertTimeToSeconds(thisStep.time), thisStep.recipeName, thisStep.stepName, thisStep.people)
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
	
	if (nextStep = window.cookingData.steps[thisStep.stepNum+1])?
		if (timeDiff = nextStep.startTime - thisStepFinishTime) > 0
			# next step start time > this step finish time:
			#  there is a step in the waiting queue and we must wait for it to finish
			#ans = confirm "wait!!!"
			ans = no # debug
			if ans is no
				window.waitingStepQueue.forEach (step)->
					step.timeElapsed += timeDiff
					step.calculateRemainTime()
				window.currentTime = nextStep.startTime
				loadStep thisStep.stepNum+1
			return
	else
		console.log "finished"
		$.ui.loadContent "Finish"
		return

	if thisStepFinishTime - currentTime <= 30
		console.log "<=30, time=#{thisStepFinishTime}"
		window.currentTime = thisStepFinishTime
	else if thisStep.people is true
		console.log ">30 and people=true, currentTime=#{currentTime}, time=#{thisStepFinishTime}"
		#ans = confirm "This step may take you longer. Skip anyways?"
		ans = yes # debug
		if ans is yes
			window.currentTime = thisStepFinishTime
		else
			return
	else
		console.log ">30, endtime=#{thisStepFinishTime}"
		pushStepToWaitingQueue thisStep, currentTime
		window.currentTime = currentTime + 30

	checkProgress()
	loadStep(thisStep.stepNum+1)
	return # avoid implicit rv

checkFinishPercentageAndChangeTitle = ->
	stepNum = window.currentStepNum
	finishPercentage = Math.ceil (stepNum+1) / window.cookingData.steps.length * 100
	$.ui.setTitle "Step #{stepNum+1} (#{finishPercentage}%)"

	return

finishedShowStatus = -> 
	timeElapsed = parseSecondsToTime window.currentTime
	
	scope = $("#Finish")
	scope.find("#TotalTimeSpent").html timeElapsed
	scope.find("#OriginalTime").html window.cookingData.originTime

	return
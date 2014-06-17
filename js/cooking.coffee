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
	if not window.cookingData? then return
	cookingData = window.cookingData
	currentStepNum = window.currentStepNum
	finishPercentage = Math.ceil (currentStepNum+1) / window.cookingData.steps.length * 100
	window.currentTime = 0
	window.waitingStepQueue = []

	console.log "cooking started"

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
# load step: load step #[stepNum]
loadStep = (stepNum)->
	stepsLen = window.cookingData.steps.length
	if stepNum >= stepsLen
		# end reached
		console.log "finished"
		$.ui.loadContent "Finish"
		return

	console.log "load step##{stepNum}"
	thisStep = window.cookingData.steps[stepNum]
	window.currentStep = new Step(stepNum, parseInt(thisStep.startTime), convertTimeToSeconds(thisStep.time), thisStep.recipeName, thisStep.stepName, thisStep.people)
	window.currentStepNum = stepNum

	finishPercentage = Math.ceil (stepNum+1) / stepsLen * 100
	scope = $("#Step")

	$.ui.setTitle "Step #{stepNum+1} (#{finishPercentage}%)"

	# load this step
	scope.find(".this_step_recipe_name").html thisStep.recipeName
	if thisStep.imageURL?
		scope.find(".this_step_img").attr "src", thisStep.imageURL
		scope.find(".this_step_img_wrapper").show()
	else
		scope.find(".this_step_img_wrapper").hide()
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
			ans = confirm "wait!!!"
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
		ans = confirm "This step may take you longer. Skip anyways?"
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

checkProgress = ->
	### Check waiting queue status ###
	queueClone = clone window.waitingStepQueue
	queue = window.waitingStepQueue
	queueLen = queueClone.length
	queueClone.forEach (waitingStep)->
		if waitingStep.remainTime <= 0
			### Finished ###
			# pop the step out of the queue
			step = queue.pop()
			# alert the user
			alert "Step finished: #{step.digest}"

	# show current time elapse on next step progress bar
	thisStep = window.currentStep
	currentTime = window.currentTime
	remainTime = thisStep.finishTime-currentTime
	if remainTime < 0
		stopTimer()

		ans = confirm "Timeout! Extend time?"
		if ans is yes
			window.currentTime = currentTime - thisStep.duration
		else
			loadStep window.currentStepNum+1
		
		startTimer()
	
	nextStep = $("#NextStep")
	nextStep.find("#ProgressBar").css3Animate
			width: "#{100 - Math.ceil((remainTime/thisStep.duration)*100)}%"
			time: '100ms'
	nextStep.find("#ProgressRemainTime").html parseSecondsToTime remainTime

	return # avoid implicit rv

pushStepToWaitingQueue = (step, currentTime)->
	console.log "push #{step.stepNum}: #{step.digest} into queue"
	window.waitingStepQueue.push step
	window.waitingStepQueue.forEach (waitingStep)->
		waitingStep.calculateRemainTime()
	window.waitingStepQueue.sort (a,b)->
		b.remainTime - a.remainTime
	console.log window.waitingStepQueue
	showTwoUrgentSteps()
	#checkProgress
	return # avoid implicit rv

showTwoUrgentSteps = ->
	console.log "show two urgent steps"
	waitingQueue = window.waitingStepQueue
	queueLen = waitingQueue.length
	nextStep = waitingQueue[queueLen-1]
	nextNextStep = waitingQueue[queueLen-2]
	updateProgressBar $("#NextNextWaitingStep"), nextNextStep
	updateProgressBar $("#NextWaitingStep"), nextStep

	###
	if nextStep? and nextNextStep?
		console.log "enough steps. steps:#{nextStep.stepNum}, #{nextNextStep.stepNum}"
	else if nextStep?
		console.log "not enough steps. step:#{nextStep.stepNum}"
	else
		console.log "no step waiting"
	###

	return # avoid implicit rv

updateProgressBar = (scope, step)->
	progressBar = scope.find "#ProgressBar"
	progressName = scope.find "#ProgressName"
	progressRemainTime = scope.find "#ProgressRemainTime"
	if not step?
		### step = null: empty progress bar ###
		progressBar.css3Animate 
			width: '0%'
			time: '500ms'
		progressName.html "No step waiting"
		progressRemainTime.html ""
	else
		progressBar.css3Animate
			width: "#{step.calculatePercentage()}%"
			time: '500ms'
		progressName.html step.digest
		progressRemainTime.html parseSecondsToTime step.remainTime

	return
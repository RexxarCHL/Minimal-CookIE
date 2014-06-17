login = ->
	### Initiate a pop-up prompt ###
	$.ui.popup
		title: 'Log in'
		message: '<form><label>Username</label><input id="login-username" type="text" placeholder="username"><label>Password</label><input id="login-password" type="password" placeholder="password">'
		cancelText: 'Cancel'
		cancelCallback: ->
			console.log "login cancelled"
		doneText: 'Login'
		doneCallback: ->
			console.log "login"
			username = $('#login-username').val()
			password = $('#login-password').val()
			password = calcMD5 password
			$.ui.showMask "Logging in..."

			### Send the data to server to log in ###
			data = 
				user_name: username
				password: password
			data = JSON.stringify data
			$.ajax(
				type: 'POST'
				url: 'http://54.178.135.71:8080/CookIEServer/temp_login'
				contentType: 'application/json'
				data: data
				timeout: 10000
				success: (data)->
					### Login success ###
					data = JSON.parse data
					console.log "[SUCCESS] logging in"
					console.log data

					### Insert value to DB ###
					AddValueToDB data.token, data.userId
					### Store it in global variable ###
					window.token = data.token
					window.user_id = data.userId

					### Update user panel after logged in ###
					updateUserPanel()

					console.log "#{data.token}, #{data.userId}"

					$.ui.hideMask()
					alert "Login Success."
					return
				error: (resp)->
					### Login failed ###
					console.log "[ERROR] logging in"
					console.log resp

					$.ui.hideMask()

					if resp.status is 404
						alert "Login failed: #{JSON.parse(resp.response).error}"
					return
			)
			return

### Check if login whenever switched to Kitchen (called in loadedPanel) ###
checkIfLogin = ->
	if not window.openDatabase
		alert 'Database are not supported in this browser.'
		return

	if window.token? and window.user_id?
		### User already logged in ###
		console.log "Already logged in."
		return

	### No login data. Try retrieve it from DB. ###
	db.transaction (transaction)->
		### UserId is actually the indexing ID. ###
		sql = 'SELECT * FROM `CookieUsers` WHERE `UserId` = (SELECT max(`UserId`) FROM `CookieUsers`)'
		transaction.executeSql sql, [], (transaction, result)->
			### success handler ###
			if result?
				user = result.rows.item(0)
				console.log user
				console.log "User found. user_id: #{user.ID}, token: #{user.Token}"

				### Data exists in DB. Logged in. ###
				console.log "Logged in after checking DB"
				window.token = user.Token
				window.user_id = user.ID

				### Update user panel after logged in ###
				updateUserPanel()
			return
		, errorHandler, (transaction,result)-> 
			### null handler ###
			### No user data in DB. Redirect to sign up page. ###
			console.log "Not logged in"
			alert "Please log in or sign up to use the Kitchen."
			$.ui.loadContent "#User"

			return
		return

	return

updateUserPanel = ->
	### TODO retrieve more data like Username and Cooking Time from Server? ###
	console.log "Update user panel"
	return

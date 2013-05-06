express = require "express"
app = express()
server = app.listen 8888

app.configure ->
	app.use express.bodyParser()
	app.use express.static "./public"



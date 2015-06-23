express = require 'express'
emails = require './src/emails'
mailer = require './src/mailer'
bodyParser = require 'body-parser'

app = express()
app.set 'views', './views'
app.set 'view engine', 'jade'
app.use express.static "#{__dirname}/public"
app.use bodyParser.json()

app.get '/', (req, res) ->
  res.send 'Emails service is running'

server = app.listen 3000, ->
  address = server.address()
  console.log "Server listening #{address.address}/#{address.port}"

for service in [emails, mailer]
  service.init app


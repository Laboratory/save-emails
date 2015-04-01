express = require 'express'
emails = require('./src/emails')

app = express()

app.get '/', (req, res) ->
  res.send 'Emails service is running'

server = app.listen 3000, ->
  address = server.address()
  console.log "Server listening #{address.address}/#{address.port}"

emails.init app


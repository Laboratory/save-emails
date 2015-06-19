nodemailer = require 'nodemailer'
fs = require 'fs'

Mailer = class
  constructor: (@db) ->
    @collection = @db.collection 'emailSendHistory'
    mailSettings = JSON.parse fs.readFileSync "#{process.cwd()}/private/mail.config"
    @transporter = nodemailer.createTransport mailSettings
    @mailOptions = JSON.parse fs.readFileSync "#{process.cwd()}/private/mailOptions.config"

  send: (to) ->
    options = @mailOptions
    options.to = to
    @transporter.sendMail options, (err, info) ->
      return console.log err if err
      console.log "Message sent to #{to}: " + info.response

  # post req.body:
  #   email
  #   device
  processing: (req, res) ->
    data = req.body
    res.send 400, 'Params Error' unless data.email or data.device
    emailRegExp = /[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?/
    check = emailRegExp.test data.email
    res.send 400, 'Email is not valid' unless check
    @log data.email, data.device
    @send data.email
    res.send 200, 'Send'

  log: (email, device) ->
    @collection.insert
      email: email
      device: device
      create_ts: new Date
    , (err) ->
        console.error err if err

initMailer = (app) ->
  require('./mongo') (db) ->
    mailer = new Mailer db, app
    app.post '/email/send', mailer.processing.bind mailer

module.exports =
  init: initMailer

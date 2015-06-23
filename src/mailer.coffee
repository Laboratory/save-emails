nodemailer = require 'nodemailer'
fs = require 'fs'
_ = require 'underscore'

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
  #   Accounts: [
  #     {
  #        email: String,
  #        selected: Boolean | Optional
  #     }
  #   ],
  #   Device: String
  processing: (req, res) ->
    data = req.body
    return res.status(400).send 'Params Error' unless data.Accounts or data.Device
    emailRegExp = /[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?/
    #check all emails
    check = _.every data.Accounts, (data) ->
      emailRegExp.test data.email
    return res.status(400).send 'Email(s) is not valid' unless check
    #save data to store
    @log data
    #find selected email for sending
    findEmail = _.find data.Accounts, (account) ->
      account.selected is true
    #send email if then was selected
    @send findEmail.email if findEmail
    res.status(200).send if findEmail then 'Send' else 'Not send, email didn\'t get selected'

  log: (data) ->
    @collection.insert _.extend data,
      create_ts: new Date
    , (err) ->
      console.error err if err

initMailer = (app) ->
  require('./mongo') (db) ->
    mailer = new Mailer db, app
    app.post '/email/send', mailer.processing.bind mailer

module.exports =
  init: initMailer

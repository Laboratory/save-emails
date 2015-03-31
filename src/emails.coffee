# Class emails
# Transport object from service to db
Emails = class
  constructor: (@db, app) ->
    @mailCollection = @db.collection 'emails'
    app.get '/post/email', @createMail

  createMail: (req, res) =>
    mail = req.query.email
    @save mail, (err, _res) ->
      console.log mail unless err
      return res.status(404).send err if err
      res.send 'saved'

  save: (email, cb) ->
    return cb 'email is null' unless email
    return cb 'email is not valid' unless @checkMail email
    @mailCollection.insert
      mail: email
      create_ts: new Date()
    , cb

  checkMail: (email) ->
    req = /[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?/
    req.test email

emailsInit = (app) ->
  require('./mongo') (db) ->
    new Emails(db, app)

module.exports =
  init: emailsInit

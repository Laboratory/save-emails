moment = require 'moment'
# Class emails
# Transport object from service to db
Emails = class
  constructor: (@db, app) ->
    @emailslCollection = @db.collection 'emails'
    @settingsCollection = @db.collection 'settings'
    @lastViewDate = null

    app.get '/post/email', @createMail
    app.get '/emails/', @getAll
    app.get '/allemails/', @pageAllEmails
    app.get '/newemails/', @pageNewemails
    @getLastPageViewDate()

  pageNewemails: (req, res) =>
    query = {}
    lwd = moment(@lastViewDate).format 'YYYY-MM-DD HH:mm:ss' if @lastViewDate
    (query.create_ts =
      $gte: @lastViewDate) if @lastViewDate

    @emailslCollection.find(query,
      _id: 0
      sort:
        $natural: -1
    ).toArray (err, docs) =>
      res.render 'newemails',
        error: err
        items: docs.map (item) ->
          item.create_ts = moment(item.create_ts).format 'YYYY-MM-DD HH:mm'
          item
        lastViewDate: lwd || '-'
    @updateLastPageViewDate()
    @lastViewDate = new Date()

  pageAllEmails: (req, res) =>
    @emailslCollection.find(
      {}
    ,
      _id: 0
      sort:
        $natural: -1
    ).toArray (err, docs) =>
      res.render 'allemails',
        error: err
        items: docs.map (item) ->
          item.create_ts = moment(item.create_ts).format 'YYYY-MM-DD HH:mm'
          item

  getLastPageViewDate: ->
    @settingsCollection.findOne
      name: 'lastViewDate'
    , (err, doc) =>
      @lastViewDate = doc.lastViewDate if doc?.lastViewDate

  updateLastPageViewDate: ->
    @settingsCollection.findAndModify
      name: 'lastViewDate'
    ,
      null
    ,
      name: 'lastViewDate'
      lastViewDate: new Date()
    ,
      upsert: true
    , =>
      console.log 'update last view date to', new Date()

  getAll: (req, res) =>
    @emailslCollection.find({}, {_id: 0}).toArray (err, docs) =>
      return res.status(404).send err if err
      res.send docs

  createMail: (req, res) =>
    mail = req.query.email
    console.log mail
    @save mail, (err, _res) =>
      console.log mail unless err
      res.jsonp
        status: if err then 'error' else 'ok'

  save: (email, cb) ->
    return cb 'email is null' unless email
    return cb 'email is not valid' unless @checkMail email
    @emailslCollection.insert
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


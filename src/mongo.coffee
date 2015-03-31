MongoClient = require('mongodb').MongoClient
mongoUrl = 'mongodb://localhost:27017/emails'

module.exports = (cb) ->
  MongoClient.connect mongoUrl, (err, db) ->
    console.log "Connected correctly to server" unless err
    cb db


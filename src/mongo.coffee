MongoClient = require('mongodb').MongoClient
port = process.env.MONGO_PORT || 27017
mongoUrl = process.env.MONGO_URL or "mongodb://localhost:#{port}/emails"
console.log mongoUrl

module.exports = (cb) ->
  MongoClient.connect mongoUrl, (err, db) ->
    console.log "Connected correctly to server" unless err
    cb db

colors = require 'colors'
async = require 'async'
request = require 'request'
jsdom = require 'jsdom'
jquery = require 'jquery'
# sites = require './sites'

job = require './jobs/jay'

fetchImage = (q, options) ->
  console.log 'fetch images'

siteLogin = (form, r, cb) ->
  url = form.action
  if form.action.indexOf('/') is 0
    url = r.uri.protocol + '//' + r.uri.host + form.action

  request
    url: url
    method: 'POST'
    body: form.data
    , (err, res, body) ->
      if err
        throw "Login Failed: " + err
      else
        console.log body
        cb()

q = async.queue(
  (task, callback) ->
    console.log "run task #{task.url}".rainbow
    console.log q
    callback()
  2)

q.drain = ->
  console.log "Queue is empty".yellow

r = request job.url, (err, res, body) ->
  if err
    console.log err
  else
    # init jquery manipulation
    Site = new job.site
    Site.setBody(body)
    console.log Site.getTitle().cyan

    # attempt to log in
    if Site.enterPassword job.password
      r2 = {}
      async.series([
        (callback) ->
          formData = Site.getLoginForm()
          # request
          console.log formData
          Site.login(r, callback)
        , (callback) ->
          # console.log r2.req
          Site.getImagePaths(job.url)
          callback()
      ]);
    else
      Site.getImagePaths(job.url)

    # if job.site.hasLogin($)
      # enter password, submit form

    # console.log body, res
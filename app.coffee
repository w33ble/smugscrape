colors = require 'colors'
async = require 'async'
request = require 'request'
jsdom = require 'jsdom'
jquery = require 'jquery'
# sites = require './sites'

job = require './jobs/FILENAME'

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
          Site.login(r, callback)
        , (callback) ->
          Site.getImages(job.imgs)
          callback()
      ]);
    else
      Site.getImages(job.imgs)

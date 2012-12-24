colors = require 'colors'
async = require 'async'
request = require 'request'
jsdom = require 'jsdom'
jquery = require 'jquery'
fs = require 'fs'

jqify = (body) ->
  window = jsdom.jsdom(body).createWindow()
  jquery.create(window)

dlQueue = async.queue(
  (task, callback) ->
    console.log "Downloading image: ".rainbow + "#{task.url}".yellow + ' -> '.red + "#{task.filename}".cyan
    r = request(task.url)
    p = r.pipe(fs.createWriteStream("./files/#{task.filename}"))
    # console.log p
    p.on 'close', ->
      # console.log 'pipe complete'.magenta
      callback()
  4)

dlQueue.drain = ->
  console.log "Queue is empty".yellow

module.exports = class

  pwInput: 'input[name=albumPass]'
  $: {}
  body: ''

  setBody: (body) ->
    @body = body
    @$ = jqify(@body)

  currentPhoto: ->
    @$('#photoNavTop span.title')

  getTitle: ->
    @$('title').html()

  hasLogin: ->
    @$(@pwInput).length > 0

  enterPassword: (pw) ->
    pwinput = @$(@pwInput)
    if pwinput.length > 0
      pwinput.val(pw)
    else
      return false

  getLoginForm: ->
    pwform = @$('form')

    data: pwform.serialize()
    action: pwform.attr('action')

  login: (r, cb) ->
    form = @getLoginForm()
    url = form.action
    if form.action.indexOf('/') is 0
      url = r.uri.protocol + '//' + r.uri.host + form.action

    # turn the querystring into an object
    formData = {}
    for i in form.data.split('&')
      info = i.split('=')
      formData[info[0]] = decodeURIComponent(info[1])

    r2 = request
      url: url
      method: 'POST'
      form: formData
      followAllRedirects: true
      , (err, res, body) =>
        if err || res.statusCode is not 200
          throw "Login Failed: " + err
        else
          console.log "Login successful!".green
          # @setBody body
          cb()

  getImages: (imgs) ->
    idx = 0;
    baseIndex = '000000'
    for i in imgs
      idx++
      img = i.replace(/Ti/g, 'X2')
      filename = img.substring(img.lastIndexOf('/')+1)
      index = baseIndex.substr(0,baseIndex.length-(idx+'').length) + idx;

      dlQueue.push
        url: img
        filename: index + '_' + filename

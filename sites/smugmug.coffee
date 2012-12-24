request = require 'request'
jsdom = require 'jsdom'
jquery = require 'jquery'

jqify = (body) ->
  window = jsdom.jsdom(body).createWindow()
  jquery.create(window)

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
        # console.log r2
        if err || res.statusCode is not 200
          console.log res
          throw "Login Failed: " + err
        else
          @setBody body
          cb()

  getImagePaths: (url) ->
    images = []
    nodes = @$('#thumbnails  div.photo').find('img')
    for i in nodes
      console.log 'image found'.cyan
      console.log @$(i).css('background-image')
    console.log nodes.length + ' images found'
    console.log 'did you see stuff?'.bold.magenta

  getPages: ->
    return false
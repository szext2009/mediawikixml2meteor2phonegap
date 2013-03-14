
Template.page.siteName = ->
  Session.get 'jsonChanged'  # force reactivity
  json?.siteinfo.sitename


json = null

getPage = (title) ->
  title = title.replace /_/g, ' '
  page = _.find json.page, (p) ->
    p.title == title


Template.page.content = ->
  if json?
    title = Session.get 'currentTitle'
    value = getPage(title)?.revision.text
  if value?
    redirect = value.match /\#redirect \[\[(.+?)\]\]/i
    if redirect
      Session.set 'currentTitle', redirect[1]
    else
      unsafe articleParse value
  else
    'no page found, or still processing...'

unsafe = (text) ->
  if text?
    new Handlebars.SafeString text

Template.page.title = ->
  Session.get('currentTitle')?.replace(/[%20|_]/g, ' ')


Template.page.events
  'click a': (e) ->
    href = if e.srcElement? then e.srcElement.href else e.currentTarget.href
    title = href.split('#')[1]
    Session.set 'currentTitle', ucfirst title


Meteor.startup ->
  page = location.hash.slice(1)
  if page == ''
    page = 'Main Page'
  Session.set 'currentTitle', page

  Meteor.http.get '/dump.xml', {}, (error, data) ->
    console.log error
    console.log 'xml size: ', data.content.length
    xml = data.content
    json = $.xml2json xml
    Session.set 'jsonChanged', Meteor.uuid()


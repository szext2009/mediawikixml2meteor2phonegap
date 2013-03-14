
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
    revision = getPage(title)?.revision.text
    if revision?
      value = unsafe articleParse revision
  if value? then value else 'no page found'

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

  Meteor.http.get '/test.xml', {}, (error, data) ->
    # content = '<' + data.content.split('<')[1]
    xml = data.content
    json = $.xml2json xml
    Session.set 'jsonChanged', Meteor.uuid()

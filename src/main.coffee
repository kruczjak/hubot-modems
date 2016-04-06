url = require('url')
querystring = require('querystring')

module.exports = (robot) ->
  robot.router.post '/hubot/sms', (req, res) ->
    query = querystring.parse(url.parse(req.url).query)
    console.log(query)

    room = if query.room then query.room else 'sms'
    
    if robot.adapterName is 'slack'
      green = '#48CE78'
      blue = '#286EA6'
      red = '#E5283E'

      msg =
        message:
          reply_to: room
          room: room

url = require('url')
querystring = require('querystring')

module.exports = (robot) ->
  robot.router.post '/hubot/sms', (req, res) ->
    res.writeHead 204, { 'Content-Length': 0 }
    res.end()

    room = if query.room then query.room else 'sms'

    data = req.body

    console.log(data)

    sender = data.sender
    sms_text = data.sms_text
    sms_number = data.sms_number

    msg = ''

    green = '#48CE78'

    msg =
      message:
        reply_to: room
        room: room

    content =
      text: sender
      fallback: sms_text
      color: green
      mrkdwn_in: ["text", "title", "fallback", "fields"]
      fields: [
        {
          title: 'Part number'
          value: sms_number
        }
      ]

    msg.content = content
    robot.emit 'slack-attachment', msg
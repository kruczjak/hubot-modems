url = require('url')
querystring = require('querystring')

module.exports = (robot) ->
  robot.router.post '/hubot/sms', (req, res) ->
    res.writeHead 204, { 'Content-Length': 0 }
    res.end()

    room = 'sms'

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
      text: sms_text
      fallback: sms_text
      color: green
      mrkdwn_in: ["text", "title", "fallback", "fields"]
      fields: [
        {
          title: 'Part number'
          value: sms_number
        },
        {
          title: 'Sender',
          value: sender
        }
      ]

    msg.content = content
    robot.emit 'slack-attachment', msg

  robot.respond /modems/i, (msg) ->
    output = execSync('ps -axfo command | grep \'^gammu-smsd -c\'');
    msg.send "Hi :) These modems processes are working now:\n #{output}"
# Description:
#   Modems interaction.
#
# Commands:
#   hubot modems - Displays information about modems.

url = require('url')
querystring = require('querystring')
moment = require('moment')
http = require('http');

DEFAULT_PATH = '/mt_messages/all'
HTTP_HOST = 'http://127.0.0.1:9901'

COLORS = {
  '4740769126': '#00A000',
  '4745963147': '#00b3ee',
  '4748229076': '#0000fe',
  '46738197918': '#7a43b6'
}

ROOM = 'sms'

module.exports = (robot) ->
  request = (path, cb) ->
    robot.http(HTTP_HOST + path)
    .header('PASSWORD', process.env.HUBOT_MODEMS_PASSWORD)
    .get() (err, res, body) ->
      if err
        cb(err)
      else
        json = JSON.parse(body)
        if json.error
          cb(new Error(body))
        else
          cb(null, json)


  robot.router.post '/hubot/sms', (req, res) ->
    res.writeHead 204, { 'Content-Length': 0 }
    res.end()


    lastSyncTime = robot.brain.get('modemsLastSync')
    robot.brain.set('modemsLastSync', moment().format())

    if lastSyncTime != null
      time = "?start_time=#{lastSyncTime}"
    else
      time = "?start_time=#{moment().startOf('day').format()}"

    console.log(lastSyncTime)

    request DEFAULT_PATH + time, (err, json) ->
      if err
        console.log(err)
      else
        console.log(json)
        for i in json
          reply(i)

    reply = (object) ->
      parts = object.number_of_parts ? ", part: #{object.number_of_parts} (#{object.number_of_parts_udh})" : ''

      msg =
        message:
          reply_to: ROOM
          room: ROOM

      content =
        text: object.TextDecoded
        fallback: object.TextDecoded
        color: COLORS[object.RecipientID]
        mrkdwn_in: ["text", "title", "fallback", "fields"]
        fields: [
          {
            title: 'Details'
            value: "To: *#{object.RecipientID}*#{parts}, from: *#{object.SenderNumber}*, at: *#{object.ReceivingDateTime}*"
          }
        ]

      msg.content = content
      robot.emit 'slack-attachment', msg

  robot.respond /modems/i, (msg) ->
    output = require('child_process').execSync('ps -axfo command | grep \'^gammu-smsd -c\'');
    msg.send "Hi :) These modems processes are working now:\n #{output}"

  robot.respond /beep/i, (msg) ->
    require('child_process').exec('/home/hubot/beep.sh')
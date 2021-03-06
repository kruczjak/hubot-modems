# Description:
#   Modems interaction.
#
# Commands:
#   hubot modems - Displays information about modems.
#   hubot update_domain - Updates domains IP address in no-ip

url = require('url')
querystring = require('querystring')
moment = require('moment')
http = require('http');
noip_updater = require('noip-updater');

DEFAULT_PATH = '/mt_messages/all'
HTTP_HOST = 'http://127.0.0.1:9902'

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
      parts = if !!object.number_of_parts then ", part: #{object.number_of_parts} (#{object.number_of_parts_udh})" else ''

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

      msg = attachments: [content]
      robot.send room: ROOM, msg

  robot.respond /modems/i, (msg) ->
    output = require('child_process').execSync('ps -axfo command | grep \'^gammu-smsd -c\'');
    msg.send "Hi :) These modems processes are working now:\n #{output}"

  robot.respond /beep/i, (msg) ->
    require('child_process').exec('/home/hubot/beep.sh')

  robot.hear /^(\d+)\/(\d+)$/i, (msg) ->
    return if msg.envelope.room != 'rylisy'

    deal = ':torstein-deal: '
    no_deal = ':torstein: '

    first = parseInt(msg.match[1])
    second = parseInt(msg.match[2])

    no_deal_number = second - first

    msg.send "#{Array(first + 1).join(deal)}#{Array(no_deal_number + 1).join(no_deal)}"

  robot.respond /update_domain/i, (msg) ->
    noip_updater.getPublicIP (ip) ->
      noip_updater.updateNoIP process.env.HUBOT_MODEMS_NOIP_USERNAME, process.env.HUBOT_MODEMS_NOIP_PASSWORD, process.env.HUBOT_MODEMS_NOIP_DOMAIN, ip, false, (body, response, error) ->
        console.log(body);

      msg.send "Hi! This is your current public ip: #{ip}"

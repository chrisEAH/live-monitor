var mqtt = require('mqtt');
var express = require('express');
var app = express();


var config = {
	"mqttBroker":"mqtt://127.0.0.1:1883",
	"topic":"#",
	"port":"6600"
}

if(process.env.mqttBroker!=undefined)config.mqttBroker=process.env.mqttBroker;
if(process.env.topic!=undefined)config.topic=process.env.topic;
if(process.env.port!=undefined)config.port=process.env.port;

var server = app.listen(config.port);
var io = require('socket.io')(server, { origins: '*:*'}); 
app.use(express.static('public'));


io.on("connect", function(socket){
    console.log("connected: "+socket);
    createMqttConnection();
})

function createMqttConnection()
{
    var clientMqtt = mqtt.connect(config.mqttBroker);
    clientMqtt.on('connect', function () {
        {
            clientMqtt.subscribe(config.topic, function (err) {
                if (!err) {
                  console.log("Topic abonniert: "+config.topic);
                }});
        }
    });

    clientMqtt.on('message', function(topic,message){
        //console.log(message.toString());
        var temp=JSON.parse(message.toString());
        io.sockets.emit('temp',{temp:temp.Wert[0], time:temp.Zeitstempel}); 
    })

}
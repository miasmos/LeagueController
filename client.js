var net = require('net');

function leagueController(opts) {
  this.opts = {
    url: '',
    port: '1000',
    host: '127.0.0.1'
  };
  var self = this;
  this.client = net.connect({port: this.opts.port, host: this.opts.host}, function(err) {
    self.client.setEncoding('utf16le');
    if (err) {
      console.log('connect failed: '+err);
    } else {
      console.log('connected to '+self.opts.host+':'+self.opts.port);
    }

    self.client.on('data', function(data) {
      console.log('received: '+data);
    });

    self.client.on('end', function() {
      console.log('connection closed');
    });
  });
}

leagueController.prototype._send = function(command) {
  this.client.write(command, 'utf16le');
  console.log('sent: '+command);
}

leagueController.prototype._end = function() {
  this.client.end();
}

LeagueController.prototype.FocusSummoner1Blue = function() {
  win._send('FOCUSSUMMONER1BLUE');
}
LeagueController.prototype.FocusSummoner2Blue = function() {
  win._send('FOCUSSUMMONER2BLUE');
}
LeagueController.prototype.FocusSummoner3Blue = function() {
  win._send('FOCUSSUMMONER3BLUE');
}
LeagueController.prototype.FocusSummoner4Blue = function() {
  win._send('FOCUSSUMMONER4BLUE');
}
LeagueController.prototype.FocusSummoner5Blue = function() {
  win._send('FOCUSSUMMONER5BLUE');
}
LeagueController.prototype.FocusSummoner1Purple = function() {
  win._send('FOCUSSUMMONER1PURPLE');
}
LeagueController.prototype.FocusSummoner2Purple = function() {
  win._send('FOCUSSUMMONER2PURPLE');
}
LeagueController.prototype.FocusSummoner3Purple = function() {
  win._send('FOCUSSUMMONER3PURPLE');
}
LeagueController.prototype.FocusSummoner4Purple = function() {
  win._send('FOCUSSUMMONER4PURPLE');
}
LeagueController.prototype.FocusSummoner5Purple = function() {
  win._send('FOCUSSUMMONER5PURPLE');
}
LeagueController.prototype.FogOfWarBlue = function() {
  win._send('FOGOFWARBLUE');
}
LeagueController.prototype.FogOfWarPurple = function() {
  win._send('FOGOFWARPURPLE');
}
LeagueController.prototype.FogOfWarAll = function() {
  win._send('FOGOFWARALL');
}
LeagueController.prototype.ToggleTeamfightUI = function() {
  win._send('TOGGLETEAMFIGHTUI');
}
LeagueController.prototype.ToggleScoreboard = function() {
  win._send('TOGGLESCOREBOARD');
}
LeagueController.prototype.ToggleUI = function() {
  win._send('TOGGLEUI');
}
LeagueController.prototype._ReleaseKey = function() {
  win._send('RELEASEKEY');
}

process.on('exit', function(){win._end();});
process.on('SIGINT', function(){win._end();});
process.on('uncaughtException', function(){win._end();});

module.exports = leagueController
var net = require('net');

function LeagueController(opts) {
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
      //console.log('connected to '+self.opts.host+':'+self.opts.port);
    }

    self.client.on('data', function(data) {
      console.log('received: '+data);
    });

    self.client.on('end', function() {
      //console.log('connection closed');
    });
  });
}

LeagueController.prototype._send = function(command) {
  this.client.write(command, 'utf16le');
  console.log('sent: '+command);
}

LeagueController.prototype._end = function() {
  this.client.end();
}

LeagueController.prototype.FocusSummoner1Blue = function() {
  this._send('FOCUSSUMMONER1BLUE');
}
LeagueController.prototype.FocusSummoner2Blue = function() {
  this._send('FOCUSSUMMONER2BLUE');
}
LeagueController.prototype.FocusSummoner3Blue = function() {
  this._send('FOCUSSUMMONER3BLUE');
}
LeagueController.prototype.FocusSummoner4Blue = function() {
  this._send('FOCUSSUMMONER4BLUE');
}
LeagueController.prototype.FocusSummoner5Blue = function() {
  this._send('FOCUSSUMMONER5BLUE');
}
LeagueController.prototype.FocusSummoner1Purple = function() {
  this._send('FOCUSSUMMONER1PURPLE');
}
LeagueController.prototype.FocusSummoner2Purple = function() {
  this._send('FOCUSSUMMONER2PURPLE');
}
LeagueController.prototype.FocusSummoner3Purple = function() {
  this._send('FOCUSSUMMONER3PURPLE');
}
LeagueController.prototype.FocusSummoner4Purple = function() {
  this._send('FOCUSSUMMONER4PURPLE');
}
LeagueController.prototype.FocusSummoner5Purple = function() {
  this._send('FOCUSSUMMONER5PURPLE');
}
LeagueController.prototype.FogOfWarBlue = function() {
  this._send('FOGOFWARBLUE');
}
LeagueController.prototype.FogOfWarPurple = function() {
  this._send('FOGOFWARPURPLE');
}
LeagueController.prototype.FogOfWarAll = function() {
  this._send('FOGOFWARALL');
}
LeagueController.prototype.ToggleTeamfightUI = function() {
  this._send('TOGGLETEAMFIGHTUI');
}
LeagueController.prototype.ToggleScoreboard = function() {
  this._send('TOGGLESCOREBOARD');
}
LeagueController.prototype.ToggleUI = function() {
  this._send('TOGGLEUI');
}
LeagueController.prototype.DirectedCamera = function() {
  this._send('DIRECTEDCAMERA');
}
LeagueController.prototype.ManualCamera = function() {
  this._send('MANUALCAMERA');
}
module.exports = LeagueController
var leagueController = require('./client.js');
var lc = new leagueController();

setTimeout(function() {
  lc.FocusSummoner1Blue();
  lc.FogOfWarBlue();
},5000);

process.on('exit', function(){lc._end();});
process.on('SIGINT', function(){lc._end();});
process.on('uncaughtException', function(){lc._end();});
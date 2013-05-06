#this is the hitchhikers guide 
queue = require "queue-async"
gm = require "googlemaps"
fs = require "fs"
swedn = require "swedn"

places = swedn.toJS swedn.readFileSync "./places.swedn" 

directions = {}

q = queue 1
count = 0
for fromLocId, fromLoc of places
	if not directions[fromLocId]
		directions[fromLocId] = {}
	for toLocId, toLoc of places when toLocId isnt fromLocId
		do (fromLocId, fromLoc, toLocId, toLoc) -> 
			q.defer (next) ->
				console.log "Request #{++count} #{fromLoc.address} to #{toLoc.address}"
				gm.directions fromLoc.address, toLoc.address, ((err, result) -> 
					directions[fromLocId][toLocId] = result
					console.log JSON.stringify result, undefined, 2
					console.log "Directions fetched. Sleeping."
					setTimeout next, 5000
				), "false", "transit|walking"

q.awaitAll -> 
	console.log "DONE"
	console.log JSON.stringify directions
	fs.writeFileSync "directions.json", JSON.stringify directions

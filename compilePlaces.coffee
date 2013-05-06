swedn = require "swedn"
fs = require "fs"

fs.writeFileSync "./public/places.json", JSON.stringify swedn.toJS swedn.readFileSync "./places.swedn"

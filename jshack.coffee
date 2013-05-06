s = require "./stuff5.json"

steps = (divs) -> 
	keep = []
	for div in divs
		for row in div.div.table.tr

			if row.td.class in ["dir-ts-empty-top", "dir-ts-empty-bottom"]
				continue

			console.log row
			seg = []
		
			for cell in row.td.div ? []
				if cell.class is "dir-ts-direction"
					console.log "GOT ONE", cell.span
					seg.push cell 
					
			for cell in row.td.span ? []
				if cell.class is "dir-ts-addinfo dir-ts-addinfopad"
					seg.push cell 
					
				if cell.class is "dir-ts-addinfo"
					seg.push cell 
					
			if seg.length
				keep.push seg 

		
	keep
	
results = []
for row in s 
	results.push(
		direction = 
			id: row.id
			steps: steps row.div[0].div)
	
console.log JSON.stringify results, null, 2
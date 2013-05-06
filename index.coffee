
HHG = {}
window.HHG = HHG

class View
	constructor: (options) -> 
		@$el = options.el
	
class LocationControl extends View
	constructor: -> 
		super
		@$categories = $("<select />").appendTo @$el
		@$locations = $("<select />").appendTo @$el
	
	renderItem: (item) -> 
		item.name 
	
	sortItem: (item) -> 
		item.name

	render: (curLoc) -> 
		console.log curLoc
		@$categories.empty()
		@$locations.empty()
		
		for category in _.keys HHG.categories
			@$categories.append $("<option />").text category


		@$categories.on "change", =>
			@$locations.empty()
			oppositeLocationId = if curLoc then false else @opposite.$locations.val()
			for location in _.sortBy (l for l in HHG.categories[@$categories.val()] when l.id isnt oppositeLocationId), @sortItem
				@$locations.append $("<option />")
					.text(@renderItem location)
					.prop(value: location.id)
					
			if curLoc then @$locations.val curLoc.id
			@$locations.trigger "change"
		
		if curLoc then @$categories.val curLoc.category[0]
		@$categories.trigger "change"
		
		this
		
class RoutesControl extends View
	constructor: ->
		super
		@$el.on "click", ".checkStep", => @nextStep()
			
	render: -> 
		@$el.empty()
		fromPlace = HHG.fromControl.$locations.val()
		toPlace = HHG.toControl.$locations.val()
		return if not fromPlace or not toPlace 
		
		@$el.append $("<h4 />").text "A: " + HHG.places[fromPlace].name + ": " + HHG.places[fromPlace].address
		@$el.append $("<h4 />").text "B: " + HHG.places[toPlace].name + ": " + HHG.places[toPlace].address
		console.log {fromPlace, toPlace}
		@drawRoutes HHG.directions[fromPlace][toPlace].routes
		
	drawRoutes: (routes) ->
		@activeStep = undefined
		@steps = []
		for route in routes 
			for step in route.legs[0].steps
				@$el.append stepEl = $("<div />")
					.addClass("step")
					.html($("<button />").html("✓").addClass("checkStep"))
					.append(step.html_instructions + " - #{step.distance.text} - #{step.duration.text}")

				@steps.push stepEl
		
		@$el.append @$arrivedButton = $("<button />").hide().text("Arrived at #{HHG.places[HHG.toControl.$locations.val()].name}").click =>
			@$arrivedButton.replaceWith $("<h4 />").text @$arrivedButton.text() + " - " + (new Date).toLocaleTimeString()
			@$el.append $makeNotes = $("<button />").text("make notes").click => 
				$makeNotes.replaceWith $("<div />").html $("<textarea />")
			
			@$el.append $giveRating = $("<button />").text("give rating").click =>
				$giveRating.replaceWith $("<div />").html $("<select />")
					.append($("<option />").text(0))
					.append($("<option />").text(1))
					.append($("<option />").text(2))
					.append($("<option />").text(3))
					.append($("<option />").text(4))
					.append($("<option />").text(5))
					
			
			@$el.append $("<button />").text("go somewhere from here").click => 
				HHG.A = HHG.toControl.$locations.val()
				HHG.B = false
				HHG.render()
				
			@$el.append $("<button />").text("go back to #{HHG.places[HHG.fromControl.$locations.val()].name}").click =>
				HHG.A = HHG.toControl.$locations.val()
				HHG.B = HHG.fromControl.$locations.val()
				HHG.render()
		
		@setStep 0 
		
		this
		
	setStep: (num) -> 
		if @activeStep? then @steps[@activeStep].addClass "pastStep"
		@$el.find(".activeStep").removeClass "activeStep"
		
		if num is @steps.length
			@$arrivedButton.show()
		else
			@activeStep = num
			@steps[@activeStep].addClass "activeStep"
		this
		
	nextStep: -> 
		@setStep @activeStep + 1
		
$ ->
	$.getJSON "places.json", (result) -> 
		HHG.places = result
		HHG.categories = {}
		HHG.subcategories = {}
		for locationId, details of HHG.places
			details.id = locationId

			for category, i in details.category
				if i is 0 
					if not HHG.categories[category]
						HHG.categories[category] = []
					HHG.categories[category].push details
				else
					if not HHG.subcategories[category]
						HHG.subcategories[category] = []
					HHG.subcategories[category].push details
	
		$.getJSON "directions.json", (result) -> 
			HHG.directions = result
			HHG.routesControl = new RoutesControl el: $(".routes")
			HHG.fromControl = new LocationControl el: $(".fromLocation .locationControl")
			HHG.toControl = new LocationControl el: $(".toLocation .locationControl")	
			HHG.fromControl.opposite = HHG.toControl
			HHG.toControl.opposite = HHG.fromControl

			HHG.toControl.renderItem = (item) -> 
				if leg = HHG.directions[HHG.fromControl.$locations.val()]?[item.id]?.routes[0].legs[0]
					item.name + " - #{leg.distance.text} - #{leg.duration.text}"
			
			HHG.toControl.sortItem = (item) -> 
				HHG.directions[HHG.fromControl.$locations.val()]?[item.id]?.routes[0].legs[0].distance.value

			HHG.fromControl.$locations.on change: -> 
				#HHG.toControl.$categories.trigger "change"
				
			HHG.toControl.$locations.on change: -> 
				HHG.routesControl.render()
				
			HHG.fromControl.render()
			HHG.toControl.render()
			
			HHG.render = ->
				HHG.fromControl.render if HHG.A then HHG.places[HHG.A] else false
				HHG.toControl.render if HHG.B then HHG.places[HHG.B] else false
				
			
				
				

					

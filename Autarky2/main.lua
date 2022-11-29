
inspect = require 'lib.inspect'
-- https://github.com/kikito/inspect.lua

res = require 'lib.resolution_solution'
-- https://github.com/Vovkiv/resolution_solution

marketplace = require 'lib.marketplace'

cf = require 'lib.commonfunctions'
fun = require 'functions'
require 'draw'
require 'constants'
require 'people'
require 'structures'

function love.keyreleased( key, scancode )
	if key == "escape" then
		cf.RemoveScreen(SCREEN_STACK)
	end
	if key == "g" then
		SHOW_GRAPH = not SHOW_GRAPH
	end

	if key == "f" then
		for k,person in pairs(PERSONS) do
			if person.isSelected and person.occupation == nil then
				person.isSelected = false
				VILLAGERS_SELECTED = VILLAGERS_SELECTED - 1		-- not sure if this will be used

				person.occupation = enum.jobFarmer
				local row, col = structures.create(enum.structureFarm, person.guid)
				person.workrow = row
				person.workcol = col
                person.occupationstockgain = love.math.random(40,60) / 10	-- (4.0 -> 6.0)
				person.occupationstockinput = nil
				person.occupationstockoutput = enum.stockFood
			end
		end
	end
	if key == "w" then
		-- woodsman
		for k, person in pairs(PERSONS) do
			if person.isSelected and person.occupation == nil then
				person.isSelected = false
				VILLAGERS_SELECTED = VILLAGERS_SELECTED - 1

				person.occupation = enum.jobWoodsman
				local row, col = structures.create(enum.structureLogs, person.guid)
				person.workrow = row
				person.workcol = col
                person.occupationstockgain = love.math.random(5,12) / 10	-- (0.5 -> 1.2)
				person.occupationstockinput = nil
				person.occupationstockoutput = enum.stockLogs
			end
		end
	end
	if key == "h" then
		--healer
		for k, person in pairs(PERSONS) do
			if person.isSelected and person.occupation == nil then
				person.isSelected = false
				VILLAGERS_SELECTED = VILLAGERS_SELECTED - 1

				person.occupation = enum.jobHealer
				local row, col = structures.create(enum.structureHealer, person.guid)
				person.workrow = row
				person.workcol = col
                person.occupationstockgain = love.math.random(20,40) / 10	-- (1.0 -> 2.0)
				person.occupationstockinput = nil
				person.occupationstockoutput = enum.stockHerbs
			end
		end
	end
	if key == "b" then
		-- house builder
		for k, person in pairs(PERSONS) do
			if person.isSelected and person.occupation == nil then
				person.isSelected = false
				VILLAGERS_SELECTED = VILLAGERS_SELECTED - 1

				person.occupation = enum.jobBuilder
				local row, col = structures.create(enum.structureBuilder, person.guid)
				person.workrow = row
				person.workcol = col
				person.occupationstockinput = enum.stockLogs
				person.occupationstockoutput = enum.stockHouse
				person.occupationconversionrate = 5					-- this many inputs needed to make one output
			end
		end
	end
end

function love.mousepressed( x, y, button, istouch, presses )
	local gamex, gamey = res.toGame(x, y)
	if button == 1 then
		-- select the villager if clicked, else select the tile (further down)
		for k, person in pairs(PERSONS) do
			local x2, y2 = fun.getDrawXY(person)
			local dist = math.abs(cf.GetDistance(gamex, gamey, x2, y2))

			if dist <= PERSONS_RADIUS then
				if person.isSelected then
					person.isSelected = false
					VILLAGERS_SELECTED = VILLAGERS_SELECTED - 1
				else
					person.isSelected = true
					VILLAGERS_SELECTED = VILLAGERS_SELECTED + 1
				end
			end
		end
	end
-- print("******")

end

function love.load()

	love.window.setMode(800, 600, {resizable = true, display = 1})
	res.setGame(1920, 1080)

	SCREEN_WIDTH = 1920
	SCREEN_HEIGHT = 1080

	constants.load()

    love.window.setTitle("Autarky2 " .. GAME_VERSION)
	love.keyboard.setKeyRepeat(true)

    cf.AddScreen("World", SCREEN_STACK)

    fun.initialiseMap()     -- initialises 2d map with nils
	people.initialise()		-- adds ppl to the world
	fun.loadImages()

	-- make this last to capture the initial state of the world
	fun.RecordHistoryStock()
end

function love.draw()
    res.start()

    draw.world()
	people.draw()
	if SHOW_GRAPH then
		draw.graphs()
	end

    res.stop()
end

function love.update(dt)

	local movement = people.moveToDestination(dt)

	TICKER = TICKER + dt
	if TICKER >= 1 then
		TICKER = TICKER - 1
		if not movement then
			WORLD_HOURS = WORLD_HOURS + 1
			if WORLD_HOURS == 8 then
				people.assignDestination(WORLD_HOURS)
			end

			if WORLD_HOURS == 20 then
				people.assignDestination(WORLD_HOURS)
			end

			if WORLD_HOURS >= 24 then
				-- do once per day
				people.heal()
				structures.age()
				people.buildHouse()
				people.payTaxes()
				people.claimSocialSecurity()
				fun.RecordHistoryStock()		-- record key stats for graphs etc. Do before the day ticker increments
				fun.RecordHistoryTreasury()


				WORLD_HOURS = WORLD_HOURS - 24
				WORLD_DAYS = WORLD_DAYS + 1

				MARKET_RESOLVED = false 			-- reset this every midnight

				-- print("Person 1 belief history (food and herbs)")
				-- print(inspect(PERSONS[1].beliefRangeHistory[enum.stockFood]))
				-- print(inspect(PERSONS[1].beliefRangeHistory[enum.stockHerbs]))
			end
		end

		-- pay time
		if WORLD_HOURS == 17 then
			people.pay()
		end

		-- dinner time
		if WORLD_HOURS == 18 then
			print("Nom")
			people.eat()
		end

		if WORLD_HOURS == 19 then
			-- market time
			if not MARKET_RESOLVED then
				people.doMarketplace()
				MARKET_RESOLVED = true
			end
		end
	end
	res.update()
end

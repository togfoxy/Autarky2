
inspect = require 'lib.inspect'
-- https://github.com/kikito/inspect.lua

res = require 'lib.resolution_solution'
-- https://github.com/Vovkiv/resolution_solution

Camera = require 'lib.cam11.cam11'
-- https://notabug.org/pgimeno/cam11

gspot = require 'lib.gspot.Gspot'
-- https://notabug.org/pgimeno/Gspot

bitser = require 'lib.bitser'
-- https://github.com/gvx/bitser

nativefs = require 'lib.nativefs'
-- https://github.com/megagrump/nativefs

lovelyToasts = require 'lib.lovelyToasts'
-- https://github.com/Loucee/Lovely-Toasts


marketplace = require 'lib.marketplace'

cf = require 'lib.commonfunctions'
fun = require 'functions'
require 'draw'
require 'constants'
require 'people'
require 'structures'
require 'gui'

function love.keyreleased( key, scancode )
	if key == "escape" then
		cf.RemoveScreen(SCREEN_STACK)
	end
	if key == "space" then
		-- pause
		PAUSED = not PAUSED
	end


	if key == "g" then
		if cf.CurrentScreenName(SCREEN_STACK) == "World" then
			cf.AddScreen("Graphs", SCREEN_STACK)
		end
	end

	if key == "o" then
		if cf.CurrentScreenName(SCREEN_STACK) == "World" then
			cf.AddScreen("Options", SCREEN_STACK)
		end
	end

	if key == "kp+" then
		-- add a new villager
		people.createPerson()
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

	if key == "kp5" then
		ZOOMFACTOR = 1
		TRANSLATEX = SCREEN_WIDTH / 2
		TRANSLATEY = SCREEN_HEIGHT / 2
	end
end

function love.keypressed( key, scancode, isrepeat )

	local translatefactor = 5 * (ZOOMFACTOR * 2)		-- screen moves faster when zoomed in

	local leftpressed = love.keyboard.isDown("left")
	local rightpressed = love.keyboard.isDown("right")
	local uppressed = love.keyboard.isDown("up")
	local downpressed = love.keyboard.isDown("down")
	local shiftpressed = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")	-- either shift key will work

	-- adjust translatex/y based on keypress combinations
	if shiftpressed then translatefactor = translatefactor * 2 end	-- ensure this line is above the lines below
	if leftpressed then TRANSLATEX = TRANSLATEX - translatefactor end
	if rightpressed then TRANSLATEX = TRANSLATEX + translatefactor end
	if uppressed then TRANSLATEY = TRANSLATEY - translatefactor end
	if downpressed then TRANSLATEY = TRANSLATEY + translatefactor end
end

function love.mousemoved( x, y, dx, dy, istouch )
	if love.mouse.isDown(3) then
		TRANSLATEX = TRANSLATEX - dx
		TRANSLATEY = TRANSLATEY - dy
	end
end

function love.mousepressed( x, y, button, istouch, presses )
	local wx, wy = cam:toWorld(x, y)	-- converts screen x/y to world x/y

	gspot:mousepress(wx, wy, button)

	if button == 1 then
		-- select the villager if clicked, else select the tile (further down)
		for k, person in pairs(PERSONS) do
			local x2, y2 = fun.getDrawXY(person)
			local dist = math.abs(cf.GetDistance(wx, wy, x2, y2))

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
end

function love.mousereleased( x, y, button, istouch, presses )
	local wx, wy = cam:toWorld(x, y)	-- converts screen x/y to world x/y
	lovelyToasts.mousereleased(wx, wy, button)
end

function love.wheelmoved(x, y)
	if y > 0 then
		-- wheel moved up. Zoom in
		ZOOMFACTOR = ZOOMFACTOR + 0.05
	end
	if y < 0 then
		ZOOMFACTOR = ZOOMFACTOR - 0.05
	end
	if ZOOMFACTOR < 0.8 then ZOOMFACTOR = 0.8 end
	if ZOOMFACTOR > 3 then ZOOMFACTOR = 3 end
end

function love.load()

	love.window.setMode(800, 600, {resizable = true, display = 1, fullscreen = true})
	res.setGame(1920, 1080)

	SCREEN_WIDTH = 1920
	SCREEN_HEIGHT = 1080

	constants.load()

    love.window.setTitle("Autarky2 " .. GAME_VERSION)
	love.keyboard.setKeyRepeat(true)
	love.keyboard.setKeyRepeat(true)

    cf.AddScreen("World", SCREEN_STACK)

    fun.initialiseMap()     -- initialises 2d map with nils
	people.initialise()		-- adds ppl to the world
	fun.loadImages()

	-- make this last to capture the initial state of the world
	fun.RecordHistoryStock()

	cam = Camera.new(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2, 1)

	gui.load()

	lovelyToasts.options.tapToDismiss = true
end

function love.draw()
    res.start()

	local currentscreen = cf.CurrentScreenName(SCREEN_STACK)

	if currentscreen == "World" or currentscreen == "Graphs" then
		cam:attach()

		draw.world()	-- draw the world before the people
		people.draw()
		draw.daynight()

		tax_rate_up_button:hide()
		tax_rate_down_button:hide()
		close_options_button:hide()


		if currentscreen == "Graphs" then
			draw.graphs()
			close_graph_button:show()
		else
			close_graph_button:hide()
		end
		cam:detach()
	elseif currentscreen == "Options" then
		tax_rate_up_button:show()
		tax_rate_down_button:show()
		close_options_button:show()

		love.graphics.setColor(1,1,1,1)
		love.graphics.print(SALES_TAX, 300, 415)

	end
	lovelyToasts.draw()
	gspot:draw()
    res.stop()
end

function love.update(dt)

	local currentscreen = cf.CurrentScreenName(SCREEN_STACK)

	if currentscreen == "World" then

		if not PAUSED then

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
		end

		cam:setPos(TRANSLATEX,	TRANSLATEY)
		cam:setZoom(ZOOMFACTOR)
	end

	lovelyToasts.update(dt)
	gspot:update(dt)
	res.update()
end

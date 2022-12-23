
inspect = require 'lib.inspect'
-- https://github.com/kikito/inspect.lua

res = require 'lib.resolution_solution'
-- https://github.com/Vovkiv/resolution_solution

Camera = require 'lib.cam11.cam11'
-- https://notabug.org/pgimeno/cam11

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
require 'file'
buttons = require 'buttons'

function love.keyreleased( key, scancode )
	if key == "escape" then
		if cf.CurrentScreenName(SCREEN_STACK) == enum.sceneExitGame then
			cf.AddScreen(enum.sceneWorld, SCREEN_STACK)
		else
			cf.RemoveScreen(SCREEN_STACK)
		end
	end
	if key == "return" then
		if cf.CurrentScreenName(SCREEN_STACK) == enum.sceneExitGame then
			cf.RemoveScreen(SCREEN_STACK)
		end
	end
	if key == "space" then
		-- pause
		PAUSED = not PAUSED
	end
	if key == "s" then
		file.saveGame()
	end
	if key == "l" then
		file.loadGame()
	end

	if key == "g" then
		if cf.CurrentScreenName(SCREEN_STACK) == enum.sceneWorld then
			cf.AddScreen(enum.sceneGraphs, SCREEN_STACK)
		elseif cf.CurrentScreenName(SCREEN_STACK) == enum.sceneGraphs then
			cf.RemoveScreen(SCREEN_STACK)
		end
	end

	if key == "o" then
		if cf.CurrentScreenName(SCREEN_STACK) == enum.sceneWorld then
			cf.AddScreen(enum.sceneOptions, SCREEN_STACK)
		elseif cf.CurrentScreenName(SCREEN_STACK) == enum.sceneOptions then
			cf.RemoveScreen(SCREEN_STACK)
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
                person.occupationstockgain = love.math.random(20,40) / 10	-- (2.0 -> 4.0)
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
				-- person.stock[enum.stockWealth] = 100
			end
		end
	end

	if key == "kp5" then
		ZOOMFACTOR = 0.95
		TRANSLATEX = SCREEN_WIDTH / 2
		TRANSLATEY = SCREEN_HEIGHT / 2

		people.unselectAll()
	end

	if key == "-" then
		ZOOMFACTOR = ZOOMFACTOR - 0.05
	end
	if key == "=" then
		ZOOMFACTOR = ZOOMFACTOR + 0.05
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
	local wx, wy = cam:toWorld(x, y)	-- converts screen x/y to world x/y

	if love.mouse.isDown(1) then
		if cf.CurrentScreenName(SCREEN_STACK) == enum.sceneWorld then
			if MOUSE_DOWN_X == nil then
				-- start the drag operation
				MOUSE_DOWN_X = wx
				MOUSE_DOWN_Y = wy
			end
		end
	end

	if love.mouse.isDown(3) then
		TRANSLATEX = TRANSLATEX - dx
		TRANSLATEY = TRANSLATEY - dy
	end
end

function love.mousepressed( x, y, button, istouch, presses )

	local wx, wy = cam:toWorld(x, y)	-- converts screen x/y to world x/y

	if button == 1 then
		-- select the villager if clicked
		local personclicked = false			-- to capture if a villager was clicked
		for k, person in pairs(PERSONS) do
			local x2, y2 = fun.getDrawXY(person)
			local dist = math.abs(cf.GetDistance(wx, wy, x2, y2))

			if dist <= PERSONS_RADIUS then
				personclicked = true
				if person.isSelected then
					person.isSelected = false
					VILLAGERS_SELECTED = VILLAGERS_SELECTED - 1
				else
					person.isSelected = true
					VILLAGERS_SELECTED = VILLAGERS_SELECTED + 1

				end
			end
		end

		if not personclicked then
			people.unselectAll()
			VILLAGERS_SELECTED = 0
		end

	end
end

function love.mousereleased( x, y, button, istouch, presses )
	local wx, wy = cam:toWorld(x, y)	-- converts screen x/y to world x/y
	lovelyToasts.mousereleased(wx, wy, button)

	local currentscreen = cf.CurrentScreenName(SCREEN_STACK)
	if currentscreen == enum.sceneWorld then

		if MOUSE_DOWN_X ~= nil and button == 1 then
			-- a mouse box has been drawn and released
			-- A box can be drawn in any of the four quadrants - determine the top left corner:
			local xlow = math.min(wx, MOUSE_DOWN_X)
			local xhigh = math.max(wx, MOUSE_DOWN_X)
			local ylow = math.min(wy, MOUSE_DOWN_Y)
			local yhigh = math.max(wy, MOUSE_DOWN_Y)

			-- cycle through persons and select all inside bounding box
			for _, person in pairs(PERSONS) do
				local personx, persony = fun.getDrawXY(person)
				if personx >= xlow and personx <= xhigh and
					persony >= ylow and persony <= yhigh then

					if person.isSelected then
						-- nothing to do
					else
						person.isSelected = true
						VILLAGERS_SELECTED = VILLAGERS_SELECTED + 1
					end
				end
			end
		end

		-- used for mouse box dragging thingy
		MOUSE_DOWN_X = nil
		MOUSE_DOWN_Y = nil
	elseif currentscreen == enum.sceneOptions then
		-- do button stuff
		local rx, ry = res.toGame(x,y)		-- does this need to be applied consistently across all mouse clicks?
		for k, button in pairs(GUI_BUTTONS) do
			if button.scene == enum.sceneOptions and button.visible then
				local mybuttonID = buttons.buttonClicked(rx, ry, button)		-- bounding box stuff
				if mybuttonID == enum.buttonOptionsExit then
					cf.RemoveScreen(SCREEN_STACK)
				end
				if mybuttonID == enum.buttonOptionsUpSpinner then
					SALES_TAX = SALES_TAX + 0.01
				end
				if mybuttonID == enum.buttonOptionsDownSpinner then
					SALES_TAX = SALES_TAX - 0.01
					if SALES_TAX < 0.01 then SALES_TAX = 0 end
				end
				if mybuttonID == enum.buttonOptionsSocialSecurity then
					SOCIAL_SECURITY_ACTIVE = not SOCIAL_SECURITY_ACTIVE
					buttons.changeButtonLabel(enum.buttonOptionsSocialSecurity, SOCIAL_SECURITY_ACTIVE)
				end
			end
		end
	end
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
	print("Zoom factor = " .. ZOOMFACTOR)
end

function love.load()

	local width, height = love.window.getDesktopDimensions(1)
	love.window.setMode(width, height, {resizable = true, display = 1})
	-- love.window.setMode(800, 600, {resizable = true, display = 2})

	res.setGame(1920, 1080)

	SCREEN_WIDTH = 1920
	SCREEN_HEIGHT = 1080

	constants.load()

    love.window.setTitle("Autarky2 " .. GAME_VERSION)
	love.keyboard.setKeyRepeat(true)
	love.keyboard.setKeyRepeat(true)

	fun.loadFonts()

	cf.AddScreen(enum.sceneExitGame, SCREEN_STACK)
    cf.AddScreen(enum.sceneWorld, SCREEN_STACK)

    fun.initialiseMap()     -- initialises 2d map with nils
	people.initialise()		-- adds ppl to the world
	fun.loadImages()

	-- make this last to capture the initial state of the world
	fun.RecordHistoryStock()

	cam = Camera.new(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2, 1)
	cam:setZoom(ZOOMFACTOR)
	cam:setPos(TRANSLATEX,	TRANSLATEY)

	fun.loadAudio()
	buttons.loadButtons()			-- the buttons that are displayed on different gui's

	lovelyToasts.options.tapToDismiss = true
end

function love.draw()
    res.start()

	local currentscreen = cf.CurrentScreenName(SCREEN_STACK)

	if currentscreen == enum.sceneWorld or currentscreen == enum.sceneGraphs then
		cam:attach()

		draw.world()	-- draw the world before the people
		people.draw()
		draw.imageQueue()

		draw.daynight()	-- draw day/night last

		if currentscreen == enum.sceneWorld then
			-- do the mouse dragging thingy
			if MOUSE_DOWN_X ~= nil then
				-- draw box
				local x, y = love.mouse.getPosition()
				local wx, wy = cam:toWorld(x, y)	-- converts screen x/y to world x/y

				local xlow = math.min(wx, MOUSE_DOWN_X)
				local xhigh = math.max(wx, MOUSE_DOWN_X)
				local ylow = math.min(wy, MOUSE_DOWN_Y)
				local yhigh = math.max(wy, MOUSE_DOWN_Y)

				local boxwidth = math.abs(xhigh - xlow)
				local boxheight = math.abs(yhigh - ylow)

				love.graphics.setColor(1,1,1,1)
				love.graphics.rectangle("line", xlow, ylow, boxwidth, boxheight)
			end
		end

		if currentscreen == enum.sceneGraphs then
			draw.graphs()
		else

		end

		cam:detach()

		-- this happens after the camera is detached
		if currentscreen == enum.sceneWorld then
			draw.topBar()
		end

	elseif currentscreen == enum.sceneOptions then
		draw.optionScreen()
	elseif currentscreen == enum.sceneExitGame then
		draw.exitScreen()
	else
		error("Current screen is unrecognised: " .. currentscreen)
	end

	lovelyToasts.draw()
    res.stop()
end

function love.update(dt)

	local currentscreen = cf.CurrentScreenName(SCREEN_STACK)

	if currentscreen == enum.sceneWorld then

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
						people.getLoan()
						people.buildHouse()
						people.payTaxes()
						if SOCIAL_SECURITY_ACTIVE then		-- this is a toggle on the options screen
							people.claimSocialSecurity()
						end
						fun.RecordHistoryStock()		-- record key stats for graphs etc. Do before the day ticker increments
						fun.RecordHistoryTreasury()

						WORLD_HOURS = WORLD_HOURS - 24
						WORLD_DAYS = WORLD_DAYS + 1

						MARKET_RESOLVED = false 			-- reset this every midnight
					end
				end

				-- pay time
				if WORLD_HOURS == 17 then
					people.pay()
					people.repayLoan()	-- need to ensure a loan is not paid back in the same cycle
				end

				-- dinner time
				if WORLD_HOURS == 18 then
					print("Nom")
					people.eat()
				end

				if WORLD_HOURS == 19 then
					-- market time
					if not MARKET_RESOLVED then
						-- people.doMarketplace()
						people.gotoMarket()
						MARKET_RESOLVED = true
					end
				end
			end

			for i = #IMAGE_QUEUE, 1, -1 do
				IMAGE_QUEUE[i].time = IMAGE_QUEUE[i].time - dt
				if IMAGE_QUEUE[i].time <= 0 then
					table.remove(IMAGE_QUEUE, i)
				end
			end
		end

	end

	if currentscreen == enum.sceneWorld or currentscreen == enum.sceneGraphs then
		cam:setZoom(ZOOMFACTOR)
		cam:setPos(TRANSLATEX,	TRANSLATEY)
	end

	fun.PlayAmbientMusic()

	lovelyToasts.update(dt)
	res.update()
end

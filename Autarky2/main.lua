
inspect = require 'lib.inspect'
-- https://github.com/kikito/inspect.lua

res = require 'lib.resolution_solution'
-- https://github.com/Vovkiv/resolution_solution

cf = require 'lib.commonfunctions'
fun = require 'functions'
require 'draw'
require 'constants'
require 'people'

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
				person.occupation = enum.jobFarmer
				person.isSelected = false
				VILLAGERS_SELECTED = VILLAGERS_SELECTED - 1		-- not sure if this will be used
			end
		end
	end
end

function love.mousepressed( x, y, button, istouch, presses )

	if button == 1 then
		-- select the villager if clicked, else select the tile (further down)
		for k, person in pairs(PERSONS) do
			local x2, y2 = fun.getDrawXY(person)

			local dist = math.abs(cf.GetDistance(x, y, x2, y2))

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

function love.load()

	love.window.setMode(800,600,{fullscreen=true, display=1, resizable=true, borderless=false})
	SCREEN_WIDTH = love.graphics.getWidth()
	SCREEN_HEIGHT = love.graphics.getHeight()
	love.window.setMode(SCREEN_WIDTH,SCREEN_HEIGHT,{fullscreen=false, display=1, resizable=true, borderless=false})

	res.setGame(SCREEN_WIDTH, SCREEN_HEIGHT)

    constants.load()

    love.window.setTitle("Autarky2 " .. GAME_VERSION)
	love.keyboard.setKeyRepeat(true)

    cf.AddScreen("World", SCREEN_STACK)

    fun.initialiseMap()     -- initialises 2d map with nils
	people.initialise()		-- adds ppl to the world
	fun.loadImages()


	-- make this last to capture the initial state of the world
	fun.RecordHistory(WORLD_DAYS)
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
			if WORLD_HOURS == 18 then
				people.assignDestination(WORLD_HOURS)
			end

			if WORLD_HOURS >= 24 then
				fun.RecordHistory(WORLD_DAYS)		-- record key stats for graphs etc. Do before the day ticker increments
				WORLD_HOURS = WORLD_HOURS - 24
				WORLD_DAYS = WORLD_DAYS + 1

				-- do once per day

			end
		end

		-- dinner time
		if WORLD_HOURS == 19 then
			print("Nom")		--!
			people.eat()
		end
	end
end

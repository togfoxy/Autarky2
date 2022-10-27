
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
	fun.initialisePeople()	-- adds ppl to the world
end

function love.draw()
    res.start()

    draw.world()
	draw.people()

    res.stop()
end

function love.update(dt)

	TICKER = TICKER + dt
	if TICKER >= 1 then
		TICKER = TICKER - 1
		WORLD_HOURS = WORLD_HOURS + 1
		if WORLD_HOURS >= 24 then
			WORLD_HOURS = WORLD_HOURS - 24
			WORLD_DAYS = WORLD_DAYS + 1
		end
	end

	if WORLD_HOURS = 8 then
		-- assign people to their occupations
		people.assignDestination()


	end
end

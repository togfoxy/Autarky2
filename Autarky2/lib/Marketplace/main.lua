

require 'marketplace'

require 'constants'
inspect = require 'lib.inspect'
-- https://github.com/kikito/inspect.lua

cf = require 'lib.commonfunctions'
fun = require 'functions'
require 'draw'

function love.keyreleased( key, scancode )
	if key == "return" then
        processturn = true
    end

end

function love.load()

    constants.load()        -- loads globals and constants
	fun.initialisePersons()		-- set up a bunch of random person objects
end

function love.draw()
    draw.allInventory(100)      -- number is the y value down the screen
end

function love.update()

    if processturn then
        processturn = false

        for i = 1, #persons do
			-- deduct one sugar from each person
            persons[i].inventory["sugar"] = persons[i].inventory["sugar"] - 1
            if persons[i].inventory["sugar"] < 0 then persons[i].inventory["sugar"] = 0 end
            table.insert(persons[i].inventoryHistory["sugar"], persons[i].inventory["sugar"])

			-- add sugar if person is a producer
			if persons[i].isProducer then
				persons[i].inventory["sugar"] = persons[i].inventory["sugar"] + love.math.random(0,2)
			end

			-- make bids as appropriate
			if persons[i].inventory["sugar"] < 5 then
				-- make a bid	--! might need to wrap this up in a function

				-- determine bid quantity
				local maxqtytobuy = 10 - persons[i].inventory["sugar"]
				local bidqty = marketplace.determineQty("sugar", maxqtytobuy, persons[i].commodityKnowledge["sugar"]) -- commodity, maxQty, commodityKnowledge
				bidqty = cf.round(bidqty)

				-- determine bid price which is a rndnum in belief range
				local bidprice = marketplace.determineCommodityPrice(persons[i].beliefRange["sugar"])

				-- register the bid
				marketplace.createBid("sugar", bidqty, bidprice, persons[i].guid)
				-- print("Person made a bid for sugar. Preferred qty = " .. bidqty .. " at price $" .. bidprice)
			end

			-- make an ask if appropriate
			if persons[i].inventory["sugar"] > 6 then
				-- determine ask quantity
				local maxqtytosell = persons[i].inventory["sugar"] - 5
				local askqty = marketplace.determineQty("sugar", maxqtytosell, persons[i].commodityKnowledge["sugar"]) -- commodity, maxQty, commodityKnowledge
				askqty = cf.round(askqty)

				-- determine ask price
				local askprice = marketplace.determineCommodityPrice(persons[i].beliefRange["sugar"])

				-- register the ask
				marketplace.createAsk("sugar", askqty, askprice, persons[i].guid)
			end

        end

		-- resolve bids/asks after all persons have had a chance to update orders
		marketplace.resolveOrders()

		-- adjust beliefs

    end
end

gui = {}

function gui.load()

    -- button
    close_graph_button = gspot:button('Close', {x = 225, y = 400, w = 128, h = gspot.style.unit})
    close_graph_button.click = function(this, x, y, button)
		cf.RemoveScreen(SCREEN_STACK)
        end

    close_options_button = gspot:button('Close', {x = 400, y = 600, w = 128, h = gspot.style.unit})
    close_options_button.click = function(this, x, y, button)
        cf.RemoveScreen(SCREEN_STACK)
        end

	tax_rate_up_button = gspot:button('^', {x = 225, y = 400, w = 50, h = gspot.style.unit})
	tax_rate_up_button.click = function(this, x, y, button)
		SALES_TAX = SALES_TAX + 0.05
		end
	tax_rate_down_button = gspot:button('v', {x = 225, y = 425, w = 50, h = gspot.style.unit})
	tax_rate_down_button.click = function(this, x, y, button)
		SALES_TAX = SALES_TAX - 0.05
		if SALES_TAX < 0 then SALES_TAX = 0 end
		end


    local y = SCREEN_HEIGHT / 2
    local w = 100
    local x = (SCREEN_WIDTH / 2) - (w / 2)

	exit_game_button = gspot:button('Exit game', {x = x, y = y, w = w, h = gspot.style.unit * 2})
	exit_game_button.click = function(this, x, y, button)
		cf.RemoveScreen(SCREEN_STACK)
		--! can invoke the 'quit' option here for safety
		end

end



return gui

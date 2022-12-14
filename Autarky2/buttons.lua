buttons = {}



function buttons.setButtonVisible(enumvalue)
	-- receives an enum (number) and sets the visibility of that button to true
	for k, button in pairs(GUI_BUTTONS) do
		if button.identifier == enumvalue then
			button.visible = true
			break
		end
	end
end

function buttons.setButtonInvisible(enumvalue)
	-- receives an enum (number) and sets the visibility of that button to false
	for k, button in pairs(GUI_BUTTONS) do
		if button.identifier == enumvalue then
			button.visible = false
			break
		end
	end
end

function buttons.buttonClicked(mx, my, button)
	-- the button table is a global table
	-- check if mouse click is inside any button
	-- mx, my = mouse click X/Y
	-- button is from the global table
	-- returns the identifier of the button (enum) or nil
	if mx >= button.x and mx <= button.x + button.width and
		my >= button.y and my <= button.y + button.height then
			return button.identifier
	else
		return nil
	end
end

function buttons.loadButtons()
    -- load the global GUI_BUTTONS table with buttons
local mybutton = {}

    -- alarms off
    local mybutton = {}
    mybutton.x = 200
    mybutton.y = 200
    mybutton.width = 65
    mybutton.height = 20
    mybutton.drawOutline = true
    mybutton.label = ""		-- alarm off
    mybutton.image = nil
    -- -- mybutton.labelcolour = {1,1,1,1}
    mybutton.labeloffcolour = {1,1,1,1}
    mybutton.labeloncolour = {1,1,1,1}
    mybutton.labelxoffset = 0
    mybutton.bgcolour = {1,0,0,1}
    mybutton.state = "on"
    mybutton.visible = true
    mybutton.scene = enum.sceneOptions
    mybutton.identifier = enum.buttonOptionsExit
    table.insert(GUI_BUTTONS, mybutton)

end





return buttons

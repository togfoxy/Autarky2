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

function buttons.changeButtonLabel(enumvalue, newlabel)
	for k, button in pairs(GUI_BUTTONS) do
		if button.identifier == enumvalue then
			button.label = tostring(newlabel)
			break
		end
	end
end

function buttons.loadButtons()
    -- load the global GUI_BUTTONS table with buttons
local mybutton = {}

    -- exit button on options screen
    local mybutton = {}
    mybutton.width = 65
    mybutton.x = (SCREEN_WIDTH / 2) - (mybutton.width / 2)
    mybutton.y = (SCREEN_HEIGHT  / 2) + 25
    mybutton.width = 65
    mybutton.height = 20
    mybutton.bgcolour = {0,0,0,1}
    mybutton.drawOutline = true
    mybutton.outlineColour = {1,1,1,1}
    mybutton.label = "Close"		-- alarm off
    mybutton.image = nil
    -- -- mybutton.labelcolour = {1,1,1,1}
    mybutton.labeloffcolour = {1,1,1,1}
    mybutton.labeloncolour = {1,1,1,1}
    mybutton.labelcolour = {1,1,1,1}
    mybutton.labelxoffset = 0

    mybutton.state = "on"
    mybutton.visible = true
    mybutton.scene = enum.sceneOptions
    mybutton.identifier = enum.buttonOptionsExit
    table.insert(GUI_BUTTONS, mybutton)

	-- up spinner on options screen
	local mybutton = {}
	mybutton.width = 65
	mybutton.x = (100)
	mybutton.y = (100)
	mybutton.width = 20
	mybutton.height = 20
	mybutton.bgcolour = {0,0,0,1}
	mybutton.drawOutline = false
	mybutton.outlineColour = {1,1,1,1}
	mybutton.label = ""		-- alarm off
	mybutton.image = GUI[enum.guiSpinnerUp]
	mybutton.imageoffsetx = 10
	mybutton.imageoffsety = 10

	-- -- mybutton.labelcolour = {1,1,1,1}
	mybutton.labeloffcolour = {1,1,1,1}
	mybutton.labeloncolour = {1,1,1,1}
	mybutton.labelcolour = {1,1,1,1}
	mybutton.labelxoffset = 0
	mybutton.state = "on"
	mybutton.visible = true
	mybutton.scene = enum.sceneOptions
	mybutton.identifier = enum.buttonOptionsUpSpinner
	table.insert(GUI_BUTTONS, mybutton)

	-- down spinner on options screen
	local mybutton = {}
	mybutton.width = 65
	mybutton.x = (100)
	mybutton.y = (130)
	mybutton.width = 20
	mybutton.height = 20
	mybutton.bgcolour = {0,0,0,1}
	mybutton.drawOutline = false
	mybutton.outlineColour = {1,1,1,1}
	mybutton.label = ""		-- alarm off
	mybutton.image = GUI[enum.guiSpinnerDown]
	mybutton.imageoffsetx = 10
	mybutton.imageoffsety = 10
	-- -- mybutton.labelcolour = {1,1,1,1}
	mybutton.labeloffcolour = {1,1,1,1}
	mybutton.labeloncolour = {1,1,1,1}
	mybutton.labelcolour = {1,1,1,1}
	mybutton.labelxoffset = 0

	mybutton.state = "on"
	mybutton.visible = true
	mybutton.scene = enum.sceneOptions
	mybutton.identifier = enum.buttonOptionsDownSpinner
	table.insert(GUI_BUTTONS, mybutton)

	-- checkbox for social security
	local mybutton = {}
	mybutton.width = 80
	mybutton.x = (90)
	mybutton.y = (225)
	mybutton.width = 40
	mybutton.height = 25
	mybutton.bgcolour = {0,0,0,1}
	mybutton.drawOutline = true
	mybutton.outlineColour = {1,1,1,1}
	mybutton.label = tostring(SOCIAL_SECURITY_ACTIVE)
	-- -- mybutton.labelcolour = {1,1,1,1}
	mybutton.labeloffcolour = {1,1,1,1}
	mybutton.labeloncolour = {1,1,1,1}
	mybutton.labelcolour = {1,1,1,1}
	mybutton.labelxoffset = 7

	mybutton.state = "on"
	mybutton.visible = true
	mybutton.scene = enum.sceneOptions
	mybutton.identifier = enum.buttonOptionsSocialSecurity
	table.insert(GUI_BUTTONS, mybutton)

end





return buttons

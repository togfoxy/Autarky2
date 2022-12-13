file = {}

local savedir = love.filesystem.getSourceBaseDirectory()
if love.filesystem.isFused() then
    savedir = savedir .. "\\savedata\\"
else
    savedir = savedir .. "/Autarky2/savedata/"
end

local function saveStructures()
    local savefile = savedir .. "structures.dat"

    local serialisedString = bitser.dumps(STRUCTURES)
    local success, message = nativefs.write(savefile, serialisedString)

    return success
end

local function savePersons()
    local savefile = savedir .. "persons.dat"

    local serialisedString = bitser.dumps(PERSONS)
    local success, message = nativefs.write(savefile, serialisedString)

    return success
end

local function saveGlobals()
    local savefile = savedir .. "globals.dat"

    local t = {}    -- random table
    t.WORLD_DAYS = WORLD_DAYS
    t.WORLD_HOURS = WORLD_HOURS
    t.SALES_TAX = SALES_TAX
    t.TREASURY = TREASURY
    t.TREASURY_OWED = TREASURY_OWED
    t.WELLROW = WELLROW
    t.WELLCOL = WELLCOL
    t.MARKETROW = MARKETROW
    t.MARKETCOL = MARKETCOL
    t.PERSONS_LEFT = PERSONS_LEFT

    local serialisedString = bitser.dumps(t)
    local success, message = nativefs.write(savefile, serialisedString)

    return success
end

local function saveHistoryStock()
    local savefile = savedir .. "historystock.dat"

    local serialisedString = bitser.dumps(HISTORY_STOCK)
    local success, message = nativefs.write(savefile, serialisedString)

    return success
end

local function saveHistoryPrice()
    local savefile = savedir .. "historyprice.dat"

    local serialisedString = bitser.dumps(HISTORY_PRICE)
    local success, message = nativefs.write(savefile, serialisedString)

    return success
end

local function saveHistoryTreasury()
    local savefile = savedir .. "historytreasury.dat"

    local serialisedString = bitser.dumps(HISTORY_TREASURY)
    local success, message = nativefs.write(savefile, serialisedString)

    return success
end

function file.saveGame()
    local success1 = saveGlobals()
    local success2 = savePersons()
    local success3 = saveStructures()
    local success4 = saveHistoryStock()
    local success5 = saveHistoryPrice()
    local success6 = saveHistoryTreasury()

    --! will need to save the perlin noise at some stage

    if success1 and success2 and success3 and success4 and success5 and success6 then
        lovelyToasts.show("Game saved",10)
    else
        lovelyToasts.show("Error saving",10)
    end
end

local function loadGlobals()
    local savefile = savedir .. "globals.dat"

	if nativefs.getInfo(savefile) then

        -- erase these values here and then reload new values below
        MAP[WELLROW][WELLCOL].structure = nils
        MAP[MARKETROW][MARKETCOL].structure = nil

		contents, size = nativefs.read(savefile)
	    t = bitser.loads(contents)

        WORLD_DAYS = t.WORLD_DAYS
        WORLD_HOURS = t.WORLD_HOURS
        SALES_TAX = t.SALES_TAX
        TREASURY = t.TREASURY
        TREASURY_OWED = t.TREASURY_OWED
        WELLROW = t.WELLROW
        WELLCOL = t.WELLCOL
        MARKETROW = t.MARKETROW
        MARKETCOL = t.MARKETCOL
        PERSONS_LEFT = t.PERSONS_LEFT

        MAP[WELLROW][WELLCOL].structure = enum.well
        MAP[MARKETROW][MARKETCOL].structure = enum.market

        return true
    else
        error()
    end
end

local function loadPersons()
    local savefile = savedir .. "persons.dat"

	if nativefs.getInfo(savefile) then
		contents, size = nativefs.read(savefile)
	    PERSONS = bitser.loads(contents)
        return true
    else
        error()
    end
end

local function loadStructures()
    local savefile = savedir .. "structures.dat"

	if nativefs.getInfo(savefile) then
		contents, size = nativefs.read(savefile)
	    STRUCTURES = bitser.loads(contents)
        return true
    else
        error()
    end
end

local function loadHistoryStock()
    local savefile = savedir .. "historystock.dat"

	if nativefs.getInfo(savefile) then
		contents, size = nativefs.read(savefile)
	    HISTORY_STOCK = bitser.loads(contents)
        return true
    else
        error()
    end
end

local function loadHistoryPrice()
    local savefile = savedir .. "historyprice.dat"

	if nativefs.getInfo(savefile) then
		contents, size = nativefs.read(savefile)
	    HISTORY_PRICE = bitser.loads(contents)
        return true
    else
        error()
    end
end

local function loadHistoryTreasury()
    local savefile = savedir .. "historytreasury.dat"

	if nativefs.getInfo(savefile) then
		contents, size = nativefs.read(savefile)
	    HISTORY_TREASURY = bitser.loads(contents)
        return true
    else
        error()
    end
end

function file.loadGame()
    local success1 = loadGlobals()
    local success2 = loadPersons()
    local success3 = loadStructures()
    local success4 = loadHistoryStock()
    local success5 = loadHistoryPrice()
    local success6 = loadHistoryTreasury()

    if success1 and success2 and success3 and success4 and success5 and success6 then
        lovelyToasts.show("Game loaded",10)
    else
        lovelyToasts.show("Error loading",10)
        print(success1, success2, success3, success4, success5, success6)
    end

end

return file

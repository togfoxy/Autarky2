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
    t.WELLROW = WELLROW
    t.WELLCOL = WELLCOL
    t.MARKETROW = MARKETROW
    t.MARKETCOL = MARKETCOL

    local serialisedString = bitser.dumps(t)
    local success, message = nativefs.write(savefile, serialisedString)

    return success
end

local function saveHistoryStock()
    local savefile = savedir .. "HistoryStock.dat"

    local serialisedString = bitser.dumps(HISTORY_STOCK)
    local success, message = nativefs.write(savefile, serialisedString)

    return success
end

local function saveHistoryPrice()
    local savefile = savedir .. "HistoryPrice.dat"

    local serialisedString = bitser.dumps(HISTORY_PRICE)
    local success, message = nativefs.write(savefile, serialisedString)

    return success
end

local function saveHistoryTreasury()
    local savefile = savedir .. "HistoryTreasury.dat"

    local serialisedString = bitser.dumps(HISTORY_TREASURY)
    local success, message = nativefs.write(savefile, serialisedString)

    return success
end

function file.saveGame()

    -- save the globals
    local success1 = saveGlobals()
    local success2 = savePersons()
    local success3 = saveStructures()
    local success4 = saveHistoryStock()
    local success5 = saveHistoryPrice()
    local success6 = saveHistoryTreasury()

    if success1 and success2 and success3 and success4 and success5 and success6 then
        lovelyToasts.show("Game saved",10)
    else
        lovelyToasts.show("Error saving",10)
    end
end

return file

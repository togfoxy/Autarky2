functions = {}

function functions.loadImages()
	-- structure tiles
    IMAGES[enum.well] = love.graphics.newImage("assets/images/well_50x45.png")
    IMAGES[enum.market] = love.graphics.newImage("assets/images/market_50x50.png")
    IMAGES[enum.structureFarm] = love.graphics.newImage("assets/images/appletree_50x50.png")
    IMAGES[enum.structureLogs] = love.graphics.newImage("assets/images/woodsman.png")
    IMAGES[enum.structureHealer] = love.graphics.newImage("assets/images/healerhouse.png")
    IMAGES[enum.structureBuilder] = love.graphics.newImage("assets/images/builderhouse.png")
    IMAGES[enum.structureHouse] = love.graphics.newImage("assets/images/house3.png")

    -- emoticons
    EMOTICONS[enum.emoticonCash] = love.graphics.newImage("assets/images/emote_cash.png")
    EMOTICONS[enum.emoticonSad] = love.graphics.newImage("assets/images/emote_faceSad.png")

    -- quads
    SPRITES[enum.spriteBlueWoman] = love.graphics.newImage("assets/images/Civilian Female Walk Blue.png")
    QUADS[enum.spriteBlueWoman] = cf.fromImageToQuads(SPRITES[enum.spriteBlueWoman], 15, 32)

    SPRITES[enum.spriteRedWoman] = love.graphics.newImage("assets/images/Civilian Female Walk Red.png")
    QUADS[enum.spriteRedWoman] = cf.fromImageToQuads(SPRITES[enum.spriteRedWoman], 15, 32)

    -- icons
    IMAGES[enum.iconFarmer] = love.graphics.newImage("assets/images/appleicon64x64.png")
    IMAGES[enum.iconWoodsman] = love.graphics.newImage("assets/images/axeicon64x64.png")
    IMAGES[enum.iconHealer] = love.graphics.newImage("assets/images/healericon64x64.png")
    IMAGES[enum.iconBuilder] = love.graphics.newImage("assets/images/hammericon64x64.png")

    -- GUI
    GUI[enum.guiSpinnerUp] = love.graphics.newImage("assets/images/buttonspinnerup.png")
    GUI[enum.guiSpinnerDown] = love.graphics.newImage("assets/images/buttonspinnerdown.png")
    GUI[enum.guiButton] = love.graphics.newImage("assets/images/button.png")

    -- MISC
    IMAGES[enum.miscPaperBG] = love.graphics.newImage("assets/images/paperbg.png")


end

function functions.loadAudio()

    AUDIO[enum.musicCityofMagic] = love.audio.newSource("assets/audio/City of magic.wav", "stream")
	AUDIO[enum.musicOvertheHills] = love.audio.newSource("assets/audio/Over the hills.wav", "stream")
	AUDIO[enum.musicSpring] = love.audio.newSource("assets/audio/Spring.wav", "stream")
    AUDIO[enum.musicMedievalFiesta] = love.audio.newSource("assets/audio/Medieval fiesta.wav", "stream")
    AUDIO[enum.musicFuji] = love.audio.newSource("assets/audio/Fuji.mp3", "stream")
    AUDIO[enum.musicHiddenPond] = love.audio.newSource("assets/audio/Hidden-Pond.mp3", "stream")
    AUDIO[enum.musicDistantMountains] = love.audio.newSource("assets/audio/Distant-Mountains.mp3", "stream")
    AUDIO[enum.musicBirdsinForest] = love.audio.newSource("assets/audio/430917__ihitokage__birds-in-forest-5.mp3", "stream")
    AUDIO[enum.musicBirds] = love.audio.newSource("assets/audio/532148__patchytherat__birds-1.wav", "stream")

    -- AUDIO[enum.audioWork]:setVolume(0.2)
    AUDIO[enum.musicMedievalFiesta]:setVolume(0.2)
    AUDIO[enum.musicOvertheHills]:setVolume(0.2)
    -- AUDIO[enum.audioNewVillager]:setVolume(0.2)
    AUDIO[enum.musicCityofMagic]:setVolume(0.2)
    AUDIO[enum.musicSpring]:setVolume(0.1)
    -- AUDIO[enum.audioEat]:setVolume(0.2)
    AUDIO[enum.musicBirdsinForest]:setVolume(1)
    -- AUDIO[enum.audioSawWood]:setVolume(0.2)
    -- AUDIO[enum.audioBandage]:setVolume(0.2)
    -- AUDIO[enum.audioWarning]:setVolume(0.2)

end

function functions.loadFonts()
    FONT[enum.fontDefault] = love.graphics.newFont("assets/fonts/Vera.ttf", 12)
    FONT[enum.fontMedium] = love.graphics.newFont("assets/fonts/Vera.ttf", 14)
    FONT[enum.fontLarge] = love.graphics.newFont("assets/fonts/Vera.ttf", 18)
    -- FONT[enum.fontHeavyMetalLarge] = love.graphics.newFont("assets/fonts/Heavy Metal Box.ttf")
    -- FONT[enum.fontTech18] = love.graphics.newFont("assets/fonts/CorporateGothicNbpRegular-YJJ2.ttf", 24)

    love.graphics.setFont(FONT[enum.fontDefault])
end

function functions.initialiseMap()

    -- set up some perlin noise for later
    local terrainheightperlinseed
    local terraintypeperlinseed = love.math.random(0,20) / 20
    repeat
        terrainheightperlinseed = love.math.random(0,20) / 20
    until terrainheightperlinseed ~= terraintypeperlinseed

    -- establish the map
    for row = 1, NUMBER_OF_ROWS do
		MAP[row] = {}
	end
	for col = 1, NUMBER_OF_COLS do
		for row = 1,NUMBER_OF_ROWS do
			MAP[row][col] = {}
            MAP[row][col].row = row
            MAP[row][col].col = col
            -- MAP[row][col].centrex = col     -- convenient to store here for drawing purposes
            -- MAP[row][col].centrey = col

            MAP[row][col].structure = nil

            -- create terrain with perlin noise
            -- the noise function only works with numbers between 0 and 1
            local rowvalue = row / NUMBER_OF_ROWS       -- an arbitrary fraction
            local colvalue = col / NUMBER_OF_COLS

            MAP[row][col].height = cf.round(love.math.noise(rowvalue, colvalue, terrainheightperlinseed) * UPPER_TERRAIN_HEIGHT)
            MAP[row][col].tileType = cf.round(love.math.noise(rowvalue, colvalue, terraintypeperlinseed) * 4)
		end
	end

    -- add a well to the map (but not on the edge of the map)
    local minrow = 3
    local mincol = 3
    local maxrow = NUMBER_OF_ROWS - 3
    local maxcol = NUMBER_OF_COLS - 3
    local wellrow = love.math.random(minrow, maxrow)
    local wellcol = love.math.random(mincol, maxcol)
    MAP[wellrow][wellcol].structure = enum.well
    -- store globals for easy recall
    WELLROW = wellrow
    WELLCOL = wellcol

    -- add a marketplace but not too close to the well
    local marketrow
    local marketcol
    repeat
        marketrow = love.math.random(minrow, maxrow)
        marketcol = love.math.random(minrow, maxrow)
    until math.abs(wellrow - marketrow) > 1 or math.abs(wellcol - marketcol) > 1

    MAP[marketrow][marketcol].structure = enum.market
    MARKETROW = marketrow
    MARKETCOL = marketcol

    for i = 1, NUMBER_OF_STOCK_TYPES do
        HISTORY_STOCK[i] = {}   -- the average stock held by each person each day
        HISTORY_PRICE[i] = {}   -- the average price of each stock recorded at the market

        -- this should be set in constants.lua but will default to '5' if not
        if STOCK_QTY_SELLPOINT[i] == nil then STOCK_QTY_SELLPOINT[i] = 5 end
    end
end

function functions.getTileXY(row, col)
    -- returns the top left corner
    local drawx = LEFT_MARGIN + (col -1) * TILE_SIZE
    local drawy = TOP_MARGIN + (row - 1) * TILE_SIZE
    return drawx, drawy
end

function functions.getDrawXY(person)
    -- returns the screen x/y
    -- used to detect mouse interactions
    local row = person.row
    local col = person.col
    local x = person.x
    local y = person.y

    local drawx, drawy = fun.getTileXY(row, col)
    return drawx + x, drawy + y
end

function functions.RecordHistoryStock()
    -- captures average stock inventory for all inventories
    --## initialise any new HISTORY tables in fun.initialiseMap()
    --## ensure you add a new enum in constants.lua
    local personcount = #PERSONS
    local foodsum = 0
    local healthsum = 0
    local wealthsum = 0

    -- calculate average stock qty across the whole population
    -- used to report graphs to the player
    for i = 1, NUMBER_OF_STOCK_TYPES do
        local sum = 0
        for _, person in pairs(PERSONS) do
            sum = sum + person.stock[i]
        end
        local avg = sum / #PERSONS
        table.insert(HISTORY_STOCK[i], avg)
    end
end

function functions.RecordHistoryTreasury()
    table.insert(HISTORY_TREASURY, TREASURY)
end

function functions.getEmptyTile()
    local count = 0
    local row, col
    repeat
        count = count + 1
        local tilevalid = true
        row = love.math.random(1, NUMBER_OF_ROWS)
        col = love.math.random(1, NUMBER_OF_COLS)

        if MAP[row][col].structure ~= nil then
            tilevalid = false
        end

        if math.abs(WELLROW - row) < 2 and math.abs(WELLCOL - col) < 2 then
            tilevalid = false
        end
        if math.abs(MARKETROW - row) < 2 and math.abs(MARKETCOL - col) < 2 then
            tilevalid = false
        end
    until tilevalid or count > 999

    if count > 999 then
        error("Cound not find a blank tile")
    end
    return row, col
end

function functions.getAvgPrice(stockPriceHistory)
    -- returns the average price for a commodity according to a single person (not global nor accurate/actual)
    -- stockPriceHistory = table of stock prices
    local total = 0
    for i = 1, #stockPriceHistory do
        total = total + stockPriceHistory[i]
    end
    return total / #stockPriceHistory
end

function functions.getHistoricAvgPrice(commodity)
    -- get the actual historic average transaction price for provided commodity
    -- returns a number with two decimal places

    local sum = 0
    for i = 1, #HISTORY_PRICE[commodity] do
        sum = sum + HISTORY_PRICE[commodity][i]
    end
    local avgprice = (sum / #HISTORY_PRICE[commodity])
    return cf.round(avgprice, 2)
end

function functions.getRandomMarketXY(person)
    -- get a row/col and and x/y when moving to the market
    -- only use when it's known the person needs to go to market

    person.destrow = MARKETROW
    person.destcol = MARKETCOL
    local min = 0 + (PERSONS_RADIUS * 2)
    local max = TILE_SIZE - (PERSONS_RADIUS * 2)
    person.destx = love.math.random(min, max)
    person.desty = love.math.random(min, max)
end

function functions.playAudio(audionumber, isMusic, isSound)
    if isMusic and MUSIC_TOGGLE then
        AUDIO[audionumber]:play()
    end
    if isSound and SOUND_TOGGLE then
        AUDIO[audionumber]:play()
    end
    -- print("playing music/sound #" .. audionumber)
end

function functions.PlayAmbientMusic()
	local intCount = love.audio.getActiveSourceCount()
	if intCount == 0 then
		if love.math.random(1,2000) == 1 then		-- allow for some silence between ambient music
			if love.math.random(1,2) == 1 then
                -- music
                local random = love.math.random(11, 17)
                fun.playAudio(random, true, false)
			else

                local random = love.math.random(21, 22)
                fun.playAudio(random, true, false)
			end
		end
	end
end

function functions.getCommodityLabel(commodityID)
    -- receives an enum and returns a string
    -- has no pre or post spacing

    if commodityID == enum.stockFood then
        return "apples"     --! singular/plural
    elseif commodityID == enum.stockLogs then
        return "logs"
    elseif commodityID == enum.stockHerbs then
        return "herbs"
    elseif commodityID == enum.stockHouse then
        return "house"
    end
end

return functions

constants = {}

function constants.load()
    -- includes globals

    GAME_VERSION = "0.01"

    TILE_SIZE = 50
    UPPER_TERRAIN_HEIGHT = 6
    NUMBER_OF_ROWS = (cf.round(SCREEN_HEIGHT / TILE_SIZE)) - 3
    NUMBER_OF_COLS = (cf.round(SCREEN_WIDTH / TILE_SIZE)) - 2

    LEFT_MARGIN = cf.round(TILE_SIZE / 1)
    TOP_MARGIN = cf.round(TILE_SIZE / 1)

    TRANSLATEX = cf.round(SCREEN_WIDTH / 2)		-- starts the camera in the middle of the ocean
    TRANSLATEY = cf.round(SCREEN_HEIGHT / 2)	-- need to round because this is working with pixels
    ZOOMFACTOR = 1
    
    GAME_LOG_DRAWX = SCREEN_WIDTH - 275
    MAP = {}
    SHOW_GRAPH = false
    MARKET_RESOLVED = false

    SCREEN_STACK = {}
    IMAGES = {}
    SPRITES = {}
    QUADS = {}

    HISTORY_STOCK = {}
    HISTORY_PRICE = {}
    HISTORY_TREASURY = {}

    WORLD_HOURS = 0
    WORLD_DAYS = 0
    TICKER = 0          -- dt or seconds (in fractions)
    SALES_TAX = 0.05
    TREASURY = 0        -- govt coffers

    PERSONS = {}
    PERSONS_RADIUS = 7      -- for drawing and mouse click purposes
    MOVEMENT_RATE = 300       -- number of pixels person moves pers second (not per dt)
    VILLAGERS_SELECTED = 0

    STRUCTURES = {}           -- any sort of tile improvement
    WELLROW = 0                 -- stored here for convenience and easy recall
    WELLCOL = 0
    MARKETROW = 0
    MARKETCOL = 0


    -- ********************
    -- enums
    -- ********************

    enum = {}
    enum.well = 1       -- this is for image and structure type
    enum.market = 2

    -- stock types

    enum.stockHealth = 1
    enum.stockWealth = 2
    enum.stockTaxOwed = 3

    enum.structureFarm = 11
    enum.jobFarmer = 11     -- job and icon need to have the same number
    enum.iconFarmer = 111  -- offset the icon by 100
    enum.stockFood = 11

    enum.structureLogs = 12
    enum.stockLogs = 12
    enum.jobWoodsman = 12
    enum.iconWoodsman = 112

    enum.jobHealer = 13
    enum.stockHerbs = 13
    enum.structureHealer = 13
    enum.iconHealer = 113

    enum.jobBuilder = 14
    enum.stockHouse = 14
    enum.structureBuilder = 14
    enum.iconBuilder = 114

    --# update NUMBER_OF_STOCK_TYPES constant when adding new stock types
    --# update functions.loadImages() x 2
    --# update main.keyreleased()
    --# provide a sell point down below or it will default to 5
    NUMBER_OF_STOCK_TYPES = 14      -- maximum value of enum.stock

    enum.structureHouse = 201   -- if no job/stock then start at 200

    -- agents will sell when their output stock reaches this value
    STOCK_QTY_SELLPOINT = {}
    STOCK_QTY_SELLPOINT[enum.stockFood] = 7
    STOCK_QTY_SELLPOINT[enum.stockLogs] = 1
    STOCK_QTY_SELLPOINT[enum.stockHerbs] = 2
    STOCK_QTY_SELLPOINT[enum.stockHouse] = 1


    -- sprites and quads
    enum.spriteBlueWoman = 1
    enum.spriteRedWoman = 2




end


return constants

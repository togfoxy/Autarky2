constants = {}

function constants.load()
    -- includes globals

    GAME_VERSION = "0.18"

    TILE_SIZE = 50
    UPPER_TERRAIN_HEIGHT = 6
    NUMBER_OF_ROWS = (cf.round(SCREEN_HEIGHT / TILE_SIZE)) - 3
    NUMBER_OF_COLS = (cf.round(SCREEN_WIDTH / TILE_SIZE)) - 2

    LEFT_MARGIN = cf.round(TILE_SIZE / 1)
    TOP_MARGIN = cf.round(TILE_SIZE / 1)
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

    WORLD_HOURS = 0
    WORLD_DAYS = 0
    TICKER = 0          -- dt or seconds (in fractions)

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



    enum.structureFarm = 3
    enum.jobFarmer = 3      -- job and icon need to have the same number
    enum.iconFarmer = 103   -- offset the icon by 100
    enum.stockFood = 3

    enum.structureLogs = 4
    enum.stockLogs = 4
    enum.jobWoodsman = 4
    enum.iconWoodsman = 104

    enum.jobHealer = 5
    enum.stockHerbs = 5
    enum.structureHealer = 5
    enum.iconHealer = 105

    enum.jobBuilder = 6
    enum.stockHouse = 6
    enum.structureBuilder = 6
    enum.iconBuilder = 106

    --# update NUMBER_OF_STOCK_TYPES constant when adding new stock types
    --# update functions.loadImages() x 2
    --# update main.keyreleased()
    NUMBER_OF_STOCK_TYPES = 6


    -- sprites and quads
    enum.spriteBlueWoman = 1
    enum.spriteRedWoman = 2




end


return constants

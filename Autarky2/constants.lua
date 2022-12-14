constants = {}

function constants.load()
    -- includes globals

    GAME_VERSION = "0.08"

    TILE_SIZE = 50
    UPPER_TERRAIN_HEIGHT = 6
    local width, height = love.window.getDesktopDimensions(1)
    NUMBER_OF_ROWS = (cf.round(height / TILE_SIZE)) - 1
    NUMBER_OF_COLS = (cf.round(width / TILE_SIZE)) - 1

    LEFT_MARGIN = cf.round(TILE_SIZE / 1)
    TOP_MARGIN = cf.round(TILE_SIZE / 1)

    TRANSLATEX = cf.round(width / 2)		-- starts the camera in the middle of the ocean
    TRANSLATEY = cf.round(height / 2)	-- need to round because this is working with pixels
    ZOOMFACTOR = 0.95

    GAME_LOG_DRAWX = SCREEN_WIDTH - 275
    MAP = {}

    SHOW_OPTIONS = false
    MARKET_RESOLVED = false
    MUSIC_TOGGLE = true             -- turn music on or off
    SOCIAL_SECURITY_ACTIVE = false        -- wounded villagers can get free treatment

	MOUSE_DOWN_X = nil
	MOUSE_DOWN_Y = nil

	MOUSE_DOWN_X = nil
	MOUSE_DOWN_Y = nil

    SCREEN_STACK = {}
    IMAGES = {}
    SPRITES = {}
    QUADS = {}
    EMOTICONS = {}      -- holds emoticon images
    IMAGE_QUEUE = {}
    AUDIO = {}
    FONT = {}
    GUI = {}            -- buttons and spinners etc
    GUI_BUTTONS = {}    -- this is the complete set of buttons


    HISTORY_STOCK = {}
    HISTORY_PRICE = {}
    HISTORY_TREASURY = {}
    LAST_MARKET_ASK = {}        -- hack. store the last price that was asked for each commodity and let newbies use this value

    WORLD_HOURS = 9
    WORLD_DAYS = 0
    TICKER = 0          -- dt or seconds (in fractions)
    PAUSED = false
    SALES_TAX = 0.05
    TREASURY = 0        -- govt coffers
    TREASURY_OWED = 0       -- how much is owed to the treasury

    PERSONS = {}
    PERSONS_RADIUS = 7      -- for drawing and mouse click purposes
    MOVEMENT_RATE = 300       -- number of pixels person moves pers second (not per dt)
    VILLAGERS_SELECTED = 0
    PERSONS_LEFT = 0            -- number of persons left the village (died)

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

    enum.stockWealthOwed = 15

    --# update NUMBER_OF_STOCK_TYPES constant when adding new stock types
    --# update functions.loadImages() x 2
    --# update main.keyreleased()
    --# provide a sell point down below or it will default to 5
    NUMBER_OF_STOCK_TYPES = 15      -- maximum value of enum.stock

    enum.structureHouse = 201   -- if structure is not job/stock then start at 200

    -- agents will sell when their output stock reaches this value
    STOCK_QTY_SELLPOINT = {}
    STOCK_QTY_SELLPOINT[enum.stockFood] = 7
    STOCK_QTY_SELLPOINT[enum.stockLogs] = 1
    STOCK_QTY_SELLPOINT[enum.stockHerbs] = 2
    STOCK_QTY_SELLPOINT[enum.stockHouse] = 1

    -- sprites and quads
    enum.spriteBlueWoman = 1
    enum.spriteRedWoman = 2

    -- emoticons
    enum.emoticonCash = 1
    enum.emoticonSad = 2

    -- audio
    enum.audioYawn = 1
    enum.audioWork = 2
    enum.audioEat = 3
    enum.audioNewVillager = 4
    enum.audioRustle = 5
    enum.audioSawWood = 6
    enum.audioBandage = 7
    enum.audioWarning = 8
    enum.audioDanger = 9

    enum.musicCityofMagic = 11
    enum.musicOvertheHills = 12
    enum.musicSpring = 13
    enum.musicMedievalFiesta = 14
    enum.musicFuji = 15
    enum.musicHiddenPond = 16
    enum.musicDistantMountains = 17

    enum.musicBirds = 21
    enum.musicBirdsinForest = 22

    enum.fontDefault = 1
    enum.fontLarge = 2
    enum.fontMedium = 3

    enum.guiSpinnerUp = 1
    enum.guiSpinnerDown = 2
    enum.guiPaperBG = 3
    enum.guiButton = 4

    enum.sceneOptions = 1       --! this is inconsistently applied
    enum.sceneWorld = 2
    enum.sceneGraphs = 3
    enum.sceneExitGame = 4

    enum.buttonOptionsExit = 1
    enum.buttonOptionsUpSpinner = 2
    enum.buttonOptionsDownSpinner = 3
    enum.buttonOptionsSocialSecurity = 4

    enum.miscPaperBG = 201                      -- start at 200. Icons start at 100

end


return constants

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

    SCREEN_STACK = {}
    IMAGES = {}

    NUMBER_OF_STOCK_TYPES = 1
    HISTORY = {}

    WORLD_HOURS = 5
    WORLD_DAYS = 0
    TICKER = 0          -- dt or seconds (in fractions)

    PERSONS = {}
    PERSONS_RADIUS = 5      -- for drawing purposes
    MOVEMENT_RATE = 300       -- number of pixels person moves pers second (not per dt)
    VILLAGERS_SELECTED = 0

    STRUCTURES = {}           -- any sort of tile improvement
    WELLROW = 0                 -- stored here for convenience and easy recall
    WELLCOL = 0


    -- enums
    enum = {}
    enum.well = 1       -- this is for image and structure type

    enum.historyFood = 1
    enum.historyHealth = 2

end


return constants

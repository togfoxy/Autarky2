structures = {}

function structures.create(structuretype, personguid)
    -- finds an empty cell and creates the provided structure
    -- input: structure type = enum.structureLogs
    -- input: personguid = person.guid
    -- output: the row/col the structure was placed
    local row, col = fun.getEmptyTile()
    MAP[row][col].structure = structuretype
    MAP[row][col].structureHealth = 30
    MAP[row][col].owner = personguid

    return row, col
end

function structures.age()
    for col = 1, NUMBER_OF_COLS do
        for row = 1,NUMBER_OF_ROWS do
            if MAP[row][col].structure == enum.structureHouse then
                MAP[row][col].structureHealth = MAP[row][col].structureHealth - 1
                if MAP[row][col].structureHealth <= 0 then
                    structures.kill(row, col)
                end
            end
        end
    end
end

function structures.kill(row, col)

    if MAP[row][col].structure == enum.structureHouse then
        -- need to tell the owner they don't have a house
        local person = people.get(MAP[row][col].owner)
        -- erase ownership
        person.houserow = nil
        person.housecol = nil
    end

    MAP[row][col].structure = nil
    MAP[row][col].owner = nil
end




return structures

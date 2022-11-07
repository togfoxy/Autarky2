functions = {}

function functions.initialisePersons()

    local numofpersons = 20

    for i = 1, numofpersons do
        local newperson = {}
        newperson.guid = cf.getUUID()
        if love.math.random(1, 2) == 2 then
            newperson.isProducer = true
        else
            newperson.isProducer = false
        end

        newperson.commodityKnowledge = {}
        newperson.commodityKnowledge["sugar"] = {}

        newperson.beliefRange = {}
        newperson.beliefRange["sugar"] = {1,10}

        newperson.inventory = {}
        newperson.inventory["sugar"] = love.math.random(0, 10)

        newperson.inventoryHistory = {}
        newperson.inventoryHistory["sugar"] = {newperson.inventory["sugar"]}

        table.insert(persons, newperson)
    end
end

return functions

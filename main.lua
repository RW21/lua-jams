function love.load()
    Timer = 1
    CycleCount = 1
    Paused = false

    love.graphics.setBackgroundColor(1, 1, 1)
    CellSize = 7

    GridHistory = {}
    Grid = {}

    GridY = 80
    GridX = 120
    for y = 1, GridY do
        Grid[y] = {}
        for x = 1, GridX do
            Grid[y][x] = false
        end
    end
end

function love.draw()
    local cellDrawSize = CellSize - 1

    for x = 1, GridX do
        for y = 1, GridY do
            if x == SelectedX and y == SelectedY then
                love.graphics.setColor(0, 0, 0)
            elseif Grid[y][x] then
                love.graphics.setColor(1, 0, 1)
            else
                love.graphics.setColor(.86, .86, .86)
            end

            love.graphics.rectangle("fill", (x-1) * CellSize, (y-1) * CellSize, cellDrawSize, cellDrawSize)
        end
    end

    if Paused then
        love.graphics.setColor(0, 0, 0)
        love.graphics.print("Paused", 10, 30)
    end

    -- Debug
    love.graphics.setColor(0, 0, 0)
    love.graphics.print("X: " .. SelectedX .. " Y: " .. SelectedY, 10, 10)
    local neighborCount = getNeighborCount(SelectedX, SelectedY)
    love.graphics.print("Neighbors: " .. neighborCount, 10, 20)
    love.graphics.print("Cycle: " .. CycleCount, 10, 40)

end

function love.update(dt)
    SelectedX = math.floor(love.mouse.getX() / CellSize) + 1
    SelectedY = math.floor(love.mouse.getY() / CellSize) + 1

    if love.mouse.isDown(1) then
        Grid[SelectedY][SelectedX] = true
    end
    if love.mouse.isDown(2) then
        local neighborCount = getNeighborCount(SelectedX, SelectedY)
        print(neighborCount)
    end

    Timer = Timer + dt
    if (math.fmod(math.floor(Timer), 1 + 1) == 0) and not Paused then
        print("tick")
        Timer = 1
        CycleCount = CycleCount + 1

        cycle()
    end

end

function getNeighborCount(x, y)
    local neighborCount = 0

    for dy = -1, 1 do
        for dx = -1, 1 do
            if (dx == 0 and dy == 0) then
                goto continue
            end

            if y + dy < 1 or y + dy > GridY then
                goto continue
            end

            if x + dx < 1 or x + dx > GridX then
                goto continue
            end

            if Grid[y + dy][x + dx] then
                neighborCount = neighborCount + 1
            end
        ::continue::
        end
    end

    return neighborCount
    end


function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end



function cycle()
    GridHistory[CycleCount] = deepcopy(Grid)

    for x = 1, GridX do
        for y = 1, GridY do
            local neighborCount = getNeighborCount(x, y)

            -- Alive cells with exactly two or three alive neighbors live on.
            -- Dead cells with exactly three alive neighbors become alive.
            local toKill = {}
            local toRevive = {}

            if Grid[y][x] and (neighborCount == 3 or neighborCount == 2) then
                toRevive[#toRevive + 1] = {x, y}
            elseif not Grid[y][x] and neighborCount == 3 then
                toRevive[#toRevive + 1] = {x, y}
            else
                toKill[#toKill + 1] = {x, y}
            end

            for i = 1, #toKill do
                Grid[toKill[i][2]][toKill[i][1]] = false
            end
            for i = 1, #toRevive do
                Grid[toRevive[i][2]][toRevive[i][1]] = true
            end

        end
    end

end

function love.keypressed(key)
    if key == "space" then
        Paused = not Paused
    elseif key == "right" then
        CycleCount = CycleCount + 1
        cycle()
    elseif key == "left" then
        print("AAASC")
        Grid = GridHistory[CycleCount]
    end

end
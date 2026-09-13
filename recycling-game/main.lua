local windowWidth = 900
local windowHeight = 650

local bin = {}
local trashItems = {}

local score = 0
local spawnTimer = 0
local gameWon = false

local gameState = "menu"
local gameMode = nil

local gameFont
local titleFont
local bigFont

local allWasteTypes = {
    {
        id = "mixed",
        name = "Mixed",
        binName = "BLACK BIN",
        key = "1",
        color = {0.15, 0.15, 0.15},
        symbol = "MIXED"
    },
    {
        id = "organic",
        name = "Organic",
        binName = "BROWN BIN",
        key = "2",
        color = {0.45, 0.25, 0.10},
        symbol = "FOOD"
    },
    {
        id = "glass",
        name = "Glass",
        binName = "GREEN BIN",
        key = "3",
        color = {0.05, 0.50, 0.20},
        symbol = "GLASS"
    },
    {
        id = "paper",
        name = "Paper",
        binName = "BLUE BIN",
        key = "4",
        color = {0.10, 0.35, 0.80},
        symbol = "PAPER"
    },
    {
        id = "plastic",
        name = "Plastic",
        binName = "VALORLUX BAG",
        key = "5",
        color = {0.10, 0.70, 0.90},
        symbol = "PLASTIC"
    }
}

local activeWasteTypes = {}

local function rectanglesOverlap(a, b)
    return a.x < b.x + b.width
        and a.x + a.width > b.x
        and a.y < b.y + b.height
        and a.y + a.height > b.y
end

local function getDifficulty()
    if score >= 40 then
        return 0.9, 160, 360
    elseif score >= 30 then
        return 1.1, 140, 330
    elseif score >= 20 then
        return 1.3, 120, 300
    elseif score >= 10 then
        return 1.6, 100, 270
    else
        return 2.0, 80, 240
    end
end

local function setGameMode(mode)
    gameMode = mode
    activeWasteTypes = {}

    if mode == "easy" then
        local mixed = allWasteTypes[1]--mixed
        local plastic = allWasteTypes[5]--plastic
        local glass = allWasteTypes[3]--glass

        table.insert(activeWasteTypes, {
            id = mixed.id,
            name = mixed.name,
            binName = mixed.binName,
            key = "1",
            color = mixed.color,
            symbol = mixed.symbol
        })

        table.insert(activeWasteTypes, {
            id = plastic.id,
            name = plastic.name,
            binName = plastic.binName,
            key = "2",
            color = plastic.color,
            symbol = plastic.symbol
        })

        table.insert(activeWasteTypes, {
            id = glass.id,
            name = glass.name,
            binName = glass.binName,
            key = "3",
            color = glass.color,
            symbol = glass.symbol
        })

    elseif mode == "normal" then
        for i = 1, #allWasteTypes do
            table.insert(activeWasteTypes, allWasteTypes[i])
        end
    end
end

local function createTrash()
    local wasteType =
        activeWasteTypes[
            love.math.random(1, #activeWasteTypes)
        ]

    local spawnInterval, minSpeed, maxSpeed =
        getDifficulty()

    local item = {
        type = wasteType,
        width = 75,
        height = 45,
        x = love.math.random(20, windowWidth - 95),
        y = -60,
        speed = love.math.random(minSpeed, maxSpeed),
        rotation = 0,
        rotationSpeed =
            love.math.random(-100, 100) / 100
    }

    table.insert(trashItems, item)
end

local function resetGame()
    score = 0
    trashItems = {}
    spawnTimer = 0
    gameWon = false

    bin.selectedType = 1

    bin.x =
        windowWidth / 2
        - bin.width / 2
end

local function startGame(mode)
    setGameMode(mode)
    resetGame()
    gameState = "playing"
end

local function returnToMenu()
    gameState = "menu"
    gameMode = nil

    trashItems = {}
    score = 0
    spawnTimer = 0
    gameWon = false
end

function love.load()
    love.window.setMode(
        windowWidth,
        windowHeight
    )

    love.window.setTitle("Recycle")

    love.graphics.setBackgroundColor(
        0.08,
        0.10,
        0.14
    )

    gameFont = love.graphics.newFont(18)
    titleFont = love.graphics.newFont(30)
    bigFont = love.graphics.newFont(46)

    love.math.setRandomSeed(os.time())

    bin.width = 145
    bin.height = 105

    bin.x = windowWidth / 2 - bin.width / 2

    bin.y = windowHeight - bin.height - 20
 
    bin.speed = 430
    bin.selectedType = 1
end

function love.update(dt)
    if gameState ~= "playing" then
        return
    end

    if gameWon then
        return
    end

    --move the bin
    if love.keyboard.isDown("left")
        or love.keyboard.isDown("a") then

        bin.x =
            bin.x - bin.speed * dt
    end

 
    if love.keyboard.isDown("right")
        or love.keyboard.isDown("d") then

        bin.x =
            bin.x + bin.speed * dt
    end

    --keep bin inside screen
    bin.x = math.max(
        0,
        math.min(
            windowWidth - bin.width,
            bin.x
        )
    )

    --current difficulty
    local currentSpawnInterval =
        getDifficulty()

    spawnTimer =
        spawnTimer + dt

    if spawnTimer >= currentSpawnInterval then
        spawnTimer =
            spawnTimer - currentSpawnInterval

        createTrash()
    end

    --update trash
    for i = #trashItems, 1, -1 do
        local item = trashItems[i]

        item.y = item.y + item.speed * dt

        item.rotation = item.rotation + item.rotationSpeed * dt

        --trash touches bin
        if rectanglesOverlap(item, bin) then

            local selectedWaste =
                activeWasteTypes[
                    bin.selectedType
                ]

            if item.type.id == selectedWaste.id then
                score = score + 1

            else
                score = score - 1
            end

            table.remove(
                trashItems,
                i
            )

            --win at 50
            if score >= 50 then
                score = 50
                gameWon = true
                trashItems = {}
                break
            end

        elseif item.y > windowHeight then
            table.remove(
                trashItems,
                i
            )
        end
    end
end

function love.keypressed(key)

    --menu controls
    if gameState == "menu" then

        if key == "1" then
            startGame("easy")

        elseif key == "2" then
            startGame("normal")

        elseif key == "escape" then
            love.event.quit()
        end

        return
    end

    --easy controls
    if gameMode == "easy" then

        if key == "1" then
            bin.selectedType = 1

        elseif key == "2" then
            bin.selectedType = 2

        elseif key == "3" then
            bin.selectedType = 3
        end

    --normal controls
    elseif gameMode == "normal" then

        if key == "1" then
            bin.selectedType = 1

        elseif key == "2" then
            bin.selectedType = 2

        elseif key == "3" then
            bin.selectedType = 3

        elseif key == "4" then
            bin.selectedType = 4

        elseif key == "5" then
            bin.selectedType = 5
        end
    end

    if key == "r" then
        resetGame()

    elseif key == "m" then
        returnToMenu()

    elseif key == "escape" then
        love.event.quit()
    end
end

local function drawTrash(item)

    love.graphics.push()

    love.graphics.translate(
        item.x + item.width / 2,
        item.y + item.height / 2
    )

    love.graphics.rotate(
        item.rotation
    )

    love.graphics.setColor(
        item.type.color
    )

    love.graphics.rectangle(
        "fill",
        -item.width / 2,
        -item.height / 2,
        item.width,
        item.height,
        8,
        8
    )

    love.graphics.setColor(
        1,
        1,
        1
    )

    love.graphics.setLineWidth(3)

    love.graphics.rectangle(
        "line",
        -item.width / 2,
        -item.height / 2,
        item.width,
        item.height,
        8,
        8
    )

    love.graphics.setFont(
        gameFont
    )

    local textWidth =
        gameFont:getWidth(
            item.type.symbol
        )

    love.graphics.print(
        item.type.symbol,
        -textWidth / 2,
        -gameFont:getHeight() / 2
    )

    love.graphics.pop()
end

local function drawBin()

    local selectedWaste =
        activeWasteTypes[
            bin.selectedType
        ]

    love.graphics.setColor(
        selectedWaste.color
    )

    --bin body
    love.graphics.rectangle(
        "fill",
        bin.x,
        bin.y + 15,
        bin.width,
        bin.height - 15,
        10,
        10
    )

    --bin lid
    love.graphics.rectangle(
        "fill",
        bin.x - 8,
        bin.y,
        bin.width + 16,
        22,
        8,
        8
    )

    love.graphics.setColor(
        1,
        1,
        1
    )

    love.graphics.setLineWidth(4)

    love.graphics.rectangle(
        "line",
        bin.x,
        bin.y + 15,
        bin.width,
        bin.height - 15,
        10,
        10
    )

    love.graphics.rectangle(
        "line",
        bin.x - 8,
        bin.y,
        bin.width + 16,
        22,
        8,
        8
    )

    --bin label
    local label = selectedWaste.binName

    local labelWidth = gameFont:getWidth(label)

    love.graphics.print(
        label,
        bin.x
            + bin.width / 2
            - labelWidth / 2,
        bin.y + 50
    )
end

local function drawMenu()

    love.graphics.setColor(
        1,
        1,
        1
    )

    love.graphics.setFont(
        bigFont
    )

    local title =
        "RECYCLE"

    love.graphics.print(
        title,
        windowWidth / 2
            - bigFont:getWidth(title) / 2,
        90
    )

    love.graphics.setFont(
        titleFont
    )

    local chooseText =
        "Choose a mode"

    love.graphics.print(
        chooseText,
        windowWidth / 2
            - titleFont:getWidth(chooseText) / 2,
        180
    )

    --easy mode button
    love.graphics.setColor(
        0.05,
        0.50,
        0.20
    )

    love.graphics.rectangle(
        "fill",
        250,
        260,
        400,
        105,
        12,
        12
    )

    love.graphics.setColor(
        1,
        1,
        1
    )

    love.graphics.setFont(
        titleFont
    )

    local easyText =
        "1 - EASY MODE"

    love.graphics.print(
        easyText,
        windowWidth / 2
            - titleFont:getWidth(easyText) / 2,
        275
    )

    love.graphics.setFont(
        gameFont
    )

    local easyInfo =
        "Mixed / Plastic / Glass"

    love.graphics.print(
        easyInfo,
        windowWidth / 2
            - gameFont:getWidth(easyInfo) / 2,
        320
    )

    --normal mode button
    love.graphics.setColor(
        0.10,
        0.35,
        0.80
    )

    love.graphics.rectangle(
        "fill",
        250,
        395,
        400,
        105,
        12,
        12
    )

    love.graphics.setColor(
        1,
        1,
        1
    )

    love.graphics.setFont(
        titleFont
    )

    local normalText =
        "2 - NORMAL MODE"

    love.graphics.print(
        normalText,
        windowWidth / 2
            - titleFont:getWidth(normalText) / 2,
        410
    )

    love.graphics.setFont(
        gameFont
    )

    local normalInfo =
        "All 5 trash types"

    love.graphics.print(
        normalInfo,
        windowWidth / 2
            - gameFont:getWidth(normalInfo) / 2,
        455
    )

    love.graphics.setColor(
        0.75,
        0.75,
        0.75
    )

    local quitText =
        "ESC - Quit"

    love.graphics.print(
        quitText,
        windowWidth / 2
            - gameFont:getWidth(quitText) / 2,
        560
    )
end

local function drawInstructions()

    love.graphics.setFont(
        gameFont
    )

    for i, waste in ipairs(
        activeWasteTypes
    ) do

        local y =
            92 + (i - 1) * 25

        --color square
        love.graphics.setColor(
            waste.color
        )

        love.graphics.rectangle(
            "fill",
            25,
            y + 2,
            16,
            16
        )

        --text
        love.graphics.setColor(
            1,
            1,
            1
        )

        love.graphics.print(
            waste.key
                .. " - "
                .. waste.name,
            50,
            y
        )
    end

    local extraY =
        92
        + #activeWasteTypes * 25
        + 5

    love.graphics.setColor(
        1,
        1,
        1
    )

    love.graphics.print(
        "R - Restart",
        25,
        extraY
    )

    love.graphics.print(
        "M - Menu",
        25,
        extraY + 25
    )
end

function love.draw()

    --menu
    if gameState == "menu" then
        drawMenu()
        return
    end

    -- Title
    love.graphics.setFont(
        titleFont
    )

    love.graphics.setColor(
        1,
        1,
        1
    )

    love.graphics.print(
        "RECYCLE",
        25,
        18
    )

    --mode
    love.graphics.setFont(
        gameFont
    )

    local modeText

    if gameMode == "easy" then
        modeText = "EASY MODE"
    else
        modeText = "NORMAL MODE"
    end

    love.graphics.print(
        modeText,
        25,
        55
    )

    --score
    love.graphics.setFont(
        titleFont
    )

    local scoreText =
        "Score: " .. score

    love.graphics.print(
        scoreText,
        windowWidth
            - titleFont:getWidth(scoreText)
            - 25,
        18
    )

    --instructions
    drawInstructions()

    --falling trash
    for _, item in ipairs(
        trashItems
    ) do
        drawTrash(item)
    end

    --bin
    drawBin()

    --win screen
    if gameWon then

        love.graphics.setColor(
            0,
            0,
            0,
            0.75
        )

        love.graphics.rectangle(
            "fill",
            0,
            0,
            windowWidth,
            windowHeight
        )

        love.graphics.setColor(
            1,
            1,
            1
        )

        love.graphics.setFont(
            bigFont
        )

        local winText =
            "YOU WIN!"

        love.graphics.print(
            winText,
            windowWidth / 2
                - bigFont:getWidth(winText) / 2,
            windowHeight / 2 - 70
        )

        love.graphics.setFont(
            gameFont
        )

        local restartText =
            "Press R to restart"

        love.graphics.print(
            restartText,
            windowWidth / 2
                - gameFont:getWidth(restartText) / 2,
            windowHeight / 2 + 10
        )

        local menuText =
            "Press M for menu"

        love.graphics.print(
            menuText,
            windowWidth / 2
                - gameFont:getWidth(menuText) / 2,
            windowHeight / 2 + 40
        )
    end
end
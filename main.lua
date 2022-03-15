local DropdownBox = require("dropdownBox")

local bg = display.newImageRect("test1.jpg", display.actualContentWidth, display.actualContentHeight)
bg.x, bg.y = display.contentCenterX, display.contentCenterY
bg.fill.effect = "filter.blur"

local txtPhase = display.newText("Phase: ", 50, 0, "LeagueSpartan-Bold.otf", 20)
txtPhase.anchorX = 0

local txtOption = display.newText("Option: ", 50, 50, "LeagueSpartan-Bold.otf", 20)
txtOption.anchorX = 0



local function dropdownBoxListener(event)
    txtPhase.text = "Phase: " .. event.phase -- get phase

    txtOption.text = "Option: " .. (event.value or "") -- get value of option

    if event.phase == "selection" then
        print("Value : " .. event.target:getValue()) -- listener when selected
    end
end

local dropdownBox = DropdownBox.new({
    x = display.contentCenterX,
    y = display.contentCenterY - 100,
    label = "Label Test:",
    defaultAnswer = false, -- set true to get first option
    font = "LeagueSpartan-Bold.otf",
    -- contentColor = {0.5, 0.5, 0.5},
    textSize = 15,
    listener = dropdownBoxListener
})


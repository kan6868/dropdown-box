local M = {}

local widget = require( "widget" )

local hideValue = 0.0001
local testData = {
    "Options 1",
    "Options 2",
    "Options 3",
    "Options 4",
    "Options 5",
    "Options 6",
    "Options 7",
}
function M.new(options)
    local options = options or {}

    local x                 = options.x or display.contentCenterX
    local y                 = options.y or display.contentCenterY
    local label             = options.label or "Label:"
    local data              = options.data or testData
    local moveLeftSelector  = options.moveLeftSelector or 0
    local defaultAnswer     = options.defaultAnswer
    local font              = options.font
    local textSize          = options.textSize or 12
    local contentColor      = options.contentColor or {1, 1, 1}
    local labelColor        = options.labelColor or {0, 0, 0}
    local optionsColor      = options.optionsColor or {0.5, 0.5, 0.5}
    local backgroundColor   = options.backgroundColor or {1, 1, 1}
    
    local listener          = options.listener or function() end

    if defaultAnswer == nil then
        defaultAnswer = false
    end

    local parent = options.parent

    local width = options.width or 260
    
    local height = options.height or 45

    local group = display.newGroup()
    
    local listOptions
    local value = false

    if parent then
        parent:insert(group)
    end
    local pnl = display.newImageRect(group, "background.png", width, height)

    local contentHeight = 30 * #data
    if contentHeight >= 180 then
        contentHeight = 150
    end

    local dropdownContent = display.newRoundedRect(group, 0, 0, width, contentHeight + 30, 0)
    dropdownContent.yScale = hideValue
    dropdownContent.anchorY = 0
    dropdownContent.y = dropdownContent.y
    dropdownContent:setFillColor(unpack(contentColor))
    dropdownContent:toBack()

    local label = display.newText(group, label, 0 - pnl.contentWidth/2 + 12.5, 0, font, textSize)
    label:setFillColor(unpack(labelColor))
    label.anchorX = 0
    
    local lblOptionSelected = display.newText(group, "Select Options", 0, label.y, font, textSize * 0.8)
    lblOptionSelected:setFillColor(unpack(optionsColor))
    lblOptionSelected.anchorX = 0
    lblOptionSelected.x = label.x + label.contentWidth/2 + lblOptionSelected.contentWidth/2 + 12 - moveLeftSelector
    
    if defaultAnswer then
        lblOptionSelected.text = data[1]
        value = data[1]
    end

    local btnDrop = display.newImageRect(group, "btn_drop.png", 20, 20)
    btnDrop.x = btnDrop.x + pnl.contentWidth/2 - btnDrop.contentWidth


    function group:reset()
        if defaultAnswer then
            lblOptionSelected.text = data[1]
            value = data[1]
        else
            lblOptionSelected.text = "Select Options"
            value = false
        end
    end

    local function onRowRender( event )
 
        -- Get reference to the row group
        local row = event.row
        local params = row.params
        -- Cache the row "contentWidth" and "contentHeight" because the row bounds can change as children objects are added
        local rowHeight = row.contentHeight
        local rowWidth = row.contentWidth
        row.bg = display.newRect(row, 0 + rowWidth/2, 0 + rowHeight/2, rowWidth, rowHeight)
        row.bg:setFillColor(unpack(contentColor))

        row.rowTitle = display.newText( row, params.data, 0, 0, nil, 14 )
        row.rowTitle:setFillColor( 0 )
     
        -- Align the label left and vertically centered
        row.rowTitle.anchorX = 0
        row.rowTitle.x = 20
        row.rowTitle.y = rowHeight * 0.5
    end

    local function onRowTouch( event )
        local target = event.target
        local phase = event.phase
        if target.isTouching then
            return false
        end
        if phase == "press" then
            target.bg:setFillColor(0.8, 1, 0.8)
        elseif phase == "release" then
            target.isTouching = true
            timer.performWithDelay(100, function()

                listOptions.alpha = 0

                lblOptionSelected.text = target.rowTitle.text
                value = target.rowTitle.text

                listener({target = group, value = value, phase = "selection"}) -- Callback to home scene

                transition.to(btnDrop, {time = 100, rotation = 0, onComplete = function()
                    btnDrop.isDropDown = false
                end})

                transition.to(dropdownContent, {time = 100, yScale = hideValue})
            end, 1)
        end
    end
    -- Create the widget
    listOptions = widget.newTableView(
        {
            left = 0 - 130,
            top = 0 + pnl.contentHeight/2,
            height = contentHeight,
            width = width,
            hideBackground = true,
            hideScrollBar = true,
            onRowRender = onRowRender,
            onRowTouch = onRowTouch
            -- listener = scrollListener
        }
    )


    group:insert(listOptions)

    function btnDrop:touch(event)
        if ( event.phase == "began" ) then

            self.xScale = 0.9
            self.yScale = 0.9
            -- Set touch focus
            display.getCurrentStage():setFocus( self )
            self.isFocus = true
         
        elseif ( self.isFocus ) then
            if ( event.phase == "moved" ) then
                return true
            elseif ( event.phase == "ended" or event.phase == "cancelled" ) then
                self.xScale = 1
                self.yScale = 1
                if btnDrop.isDropDown then
                    listener({target = group, value = value, phase = "hide"})
                    listOptions.alpha = 0
                    transition.to(btnDrop, {time = 100, rotation = 0, onComplete = function()
                        btnDrop.isDropDown = false
                    end})
                    transition.to(dropdownContent, {time = 100, yScale = hideValue})
                else
                    listener({target = group, value = value, phase = "show"})
                    if listOptions then
                        listOptions:reloadData()
                    end
                    btnDrop.isDropDown = true
                    transition.to(btnDrop, {time = 100, rotation = 90, onComplete = function()
                        listOptions.alpha = 1
                    end})
                    transition.to(dropdownContent, {time = 100, yScale = 1})
                end
                -- Reset touch focus
                display.getCurrentStage():setFocus( nil )
                self.isFocus = nil
            end
        end
        return true        
    end

    function group:getValue()
        return value
    end
    
    function btnDrop:finalize()
        self:removeEventListener("touch")
    end
    
    function group:init()
        self.x, self.y = x, y
        self.ox, self.oy = self.x, self.y

        listOptions.alpha = 0
        -- Insert 40 rows
        for i = 1, #data do
            local isCategory = false
            local rowHeight = 30
            local rowColor = { default={1,1,1, 0}, over={1,0.5,0, 0} }
            local lineColor = { 0.5, 0.5, 0.5 , 0}
        
        
            -- Insert a row into the tableView
            listOptions:insertRow(
                {
                    isCategory = isCategory,
                    rowHeight = rowHeight,
                    rowColor = rowColor,
                    lineColor = lineColor,
                    params = {
                        data = data[i]
                    }
                }
            )
        end

        btnDrop:addEventListener("touch")
        btnDrop:addEventListener("finalize")
    end
    group:init()
    return group
end

return M
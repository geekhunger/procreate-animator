-- PICO-8 color palette
colorPico8 = {
    color(0, 0, 0, 255),
    color(29, 43, 83, 255),
    color(126, 37, 83, 255),
    color(0, 135, 81, 255),
    color(171, 82, 54, 255),
    color(95, 87, 79, 255),
    color(194, 195, 199, 255),
    color(255, 241, 232, 255),
    color(255, 0, 77, 255),
    color(255, 163, 0, 255),
    color(255, 236, 39, 255),
    color(0, 228, 54, 255),
    color(41, 173, 255, 255),
    color(131, 118, 156, 255),
    color(255, 119, 168, 255),
    color(255, 204, 170, 255),
    color(255, 255, 255, 255)
}

colorPico8.black       = colorPico8[1]
colorPico8.dark_blue   = colorPico8[2]
colorPico8.dark_purple = colorPico8[3]
colorPico8.dark_green  = colorPico8[4]
colorPico8.brown       = colorPico8[5]
colorPico8.dark_gray   = colorPico8[6]
colorPico8.light_gray  = colorPico8[7]
colorPico8.light_white = colorPico8[8]
colorPico8.red         = colorPico8[9]
colorPico8.orange      = colorPico8[10]
colorPico8.yellow      = colorPico8[11]
colorPico8.green       = colorPico8[12]
colorPico8.blue        = colorPico8[13]
colorPico8.indigo      = colorPico8[14]
colorPico8.pink        = colorPico8[15]
colorPico8.peach       = colorPico8[16]
colorPico8.white       = colorPico8[17]


-- Codea's Orientation Handler (rewritten). Now this callback fires only if something really changed.
-- displayMode also triggers this event!
-- If displayMode is provided before(!) setup() then Codea knows its screen size upfront and doesn't call this callback before setup
-- If displayMode isn't provided at all or...
-- If displayMode is provided inside(!) setup() then Codea doesn't know its final screen size and will fire this callback after setup
-- When reload button clicked there are no more orientationChanged() calls because Codea caches results from above
do
    local _orientationChanged = orientationChanged or function() end
    local portrait = table.concat({PORTRAIT, PORTRAIT_UPSIDE_DOWN, PORTRAIT_ANY}, ",")
    local landscape = table.concat({LANDSCAPE_LEFT, LANDSCAPE_RIGHT, LANDSCAPE_ANY}, ",")
    local prevOrientation = CurrentOrientation
    local prevWidth = WIDTH
    local prevHeight = HEIGHT
    
    local function name(orientation)
        if portrait:find(orientation) then
            return "PORTRAIT"
        else
            return "LANDSCAPE"
        end
    end
    
    local function screen()
        return {
            prevOrientation = prevOrientation,
            currOrientation = CurrentOrientation,
            prevOrientationName = name(prevOrientation),
            currOrientationName = name(CurrentOrientation),
            prevWidth = prevWidth,
            currWidth = WIDTH,
            prevHeight = prevHeight,
            currHeight = HEIGHT
        }
    end
    
    function orientationChanged()
        if prevWidth ~= WIDTH or prevHeight ~= HEIGHT then -- device rotated 90°
            _orientationChanged(screen())
            prevOrientation = CurrentOrientation
            prevWidth = WIDTH
            prevHeight = HEIGHT
        elseif prevOrientation ~= CurrentOrientation then
            if (landscape:find(CurrentOrientation) and landscape:find(prevOrientation)) -- device rotated 180°
            or (portrait:find(CurrentOrientation) and portrait:find(prevOrientation))
            then
                _orientationChanged(screen())
                prevOrientation = CurrentOrientation
            end
        end
    end
end


-- Codea's Multitouch Handler (rewritten)
do
    local touches = {}
    local expiredTouches = 0
    local gestureCountdown = .08 -- ADJUST!
    local touchesAutoDispatcher
    local dispatchTouches = touched or function() end
    RESTING = 3 -- new touch state
    
    function touched(touch)
        -- Identify touch
        local gesture, uid = #touches > 0 and touches[1].initTime + gestureCountdown < ElapsedTime
        for r, t in ipairs(touches) do
            if touch.id == t.id then uid = r end
            touches[r].state = RESTING
        end
        
        -- Cache updates
        local rt = touches[uid] or {}
        local template = {
            id = rt.id or touch.id,
            state = touch.state,
            tapCount = CurrentTouch.tapCount,
            initTime = rt.initTime or ElapsedTime,
            duration = ElapsedTime - (rt.initTime or ElapsedTime),
            initX = rt.initX or touch.x,
            initY = rt.initY or touch.y,
            x = touch.x,
            y = touch.y,
            prevX = touch.prevX,
            prevY = touch.prevY,
            deltaX = touch.deltaX,
            deltaY = touch.deltaY,
            radius = touch.radius,
            radiusTolerance = touch.radiusTolerance,
            force = remapRange(touch.radius, 0, touch.radius + touch.radiusTolerance, 0, 1)
        }
        
        if uid then
            -- Update touches
            touches[uid] = template
            
            -- Dispatch touches
            if touch.state == ENDED then
                -- First touch expired while gesture still active (or waiting to get active)
                if expiredTouches == 0 then
                    -- Gesture was waiting to get active
                    if touchesAutoDispatcher then
                        -- Sync all touch states to BEGAN
                        -- Still dispatch the planed BEGAN state from Auto-Dispatch
                        for r, t in ipairs(touches) do
                            touches[r].state = BEGAN
                            touches[r].initX = t.x
                            touches[r].initY = t.y
                        end
                        dispatchTouches(table.unpack(touches))
                        
                        -- Cancel gesture!
                        tween.reset(touchesAutoDispatcher)
                        touchesAutoDispatcher = nil
                    end
                    
                    -- Sync all touch states to ENDED
                    for r, t in ipairs(touches) do
                        touches[r].state = ENDED
                    end
                    -- Dispatch ENDED
                    dispatchTouches(table.unpack(touches))
                end
                
                -- Delete all touches when all expired
                expiredTouches = expiredTouches + 1
                if expiredTouches == #touches then
                    touches = {}
                    expiredTouches = 0
                end
            else
                -- Dispatch MOVING
                if not touchesAutoDispatcher and gesture and expiredTouches == 0 then
                    dispatchTouches(table.unpack(touches))
                end
            end
        else
            -- Register touch
            -- Ignore new touches when gesture already active
            if not gesture and touch.state == BEGAN then
                table.insert(touches, template)
                uid = #touches
                
                -- Auto-Dispatch touches
                if uid == 1 then
                    -- Dispatch BEGAN ... when gesture gets active
                    touchesAutoDispatcher = tween.delay(gestureCountdown, function()
                        -- Sync all touch states to BEGAN
                        for r, t in ipairs(touches) do
                            touches[r].state = BEGAN
                            touches[r].initX = t.x
                            touches[r].initY = t.y
                        end
                        -- Dispatch BEGAN
                        dispatchTouches(table.unpack(touches))
                        touchesAutoDispatcher = nil
                    end)
                end
            end
        end
    end
end


-- Codea API extention to detect device shaking events
-- Provide a deviceShaking() callback function to respond to shake events - just like orientationChanged()
-- The first rough shake will trigger the listening process
-- The event handler will then listen next n seconds to see if the shake motion continues
do
    local _draw = draw
    local eventTimer = .5 -- listener lifetime
    local intensity = 1.5 -- min. shake intensity to trigger this event
    
    function draw()
        if UserAcceleration.x > intensity or UserAcceleration.y > intensity or UserAcceleration.z > intensity then
            _shakeEventUpdatedAt = ElapsedTime
            _shakeEventBeganAt = _shakeEventBeganAt or _shakeEventUpdatedAt
            
            if ElapsedTime - _shakeEventBeganAt >= eventTimer then
                if deviceShaking then
                    deviceShaking()
                end
            end
        end
        
        if _shakeEventUpdatedAt and ElapsedTime > _shakeEventBeganAt + eventTimer then
            _shakeEventUpdatedAt = nil
            _shakeEventBeganAt = nil
        end
        
        if _draw then
            _draw()
        end
    end
end

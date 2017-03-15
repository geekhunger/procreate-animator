
-- Procreate Animation Player v1.2.0
-- (c) jack0088@me.com

function setup()
    -- Styles
    displayMode(FULLSCREEN)
    textAlign(CENTER)
    textMode(CENTER)
    rectMode(CENTER)
    
    -- Sprite
    spr_src = readImage("Dropbox:dotted")
    spr_frm = loadstring(readProjectData("spr_frm", "return{vec2(0,0)}"))()
    spr_curr_frm = 1
    
    -- Frame
    frm_mask = {}
    frm_width = math.tointeger(readProjectData("frm_width", 128))
    frm_height = math.tointeger(readProjectData("frm_height", 256))
    frm_fps = math.tointeger(readProjectData("frm_fps", 24))
    
    -- Labels
    lbl = {}
    lbl[1] = Label{label = "Width"} -- frm_width label
    lbl[2] = Label{label = "Height"} -- frm_height label
    lbl[3] = Label{label = frm_width} -- frm_width value
    lbl[4] = Label{label = frm_height} -- frm_height value
    lbl[5] = Label{label = frm_fps.." fps"} -- frm_fps value
    lbl[6] = Label{label = "Frame"} -- spr_frm label
    lbl[7] = Label{label = spr_curr_frm.." / "..#spr_frm} -- spr_frm value
    
    -- Buttons
    btn = {}
    local size_s = vec2(40, 40)
    local size_m = vec2(60, 60)
    
    -- frm_width smaller
    btn[1] = Button{label = "-", width = size_s.x, height = size_s.y, callback = function()
        frm_width = math.max(0, frm_width - 1)
        lbl[3].label = frm_width
        orientationChanged()
    end}
    
    -- frm_width bigger
    btn[2] = Button{label = "+", width = size_s.x, height = size_s.y, callback = function()
        frm_width = math.min(999, frm_width + 1)
        lbl[3].label = frm_width
        orientationChanged()
    end}
    
    -- frm_height smaller
    btn[3] = Button{label = "-", width = size_s.x, height = size_s.y, callback = function()
        frm_height = math.max(0, frm_height - 1)
        lbl[4].label = frm_height
        orientationChanged()
    end}
    
    -- frm_height bigger
    btn[4] = Button{label = "+", width = size_s.x, height = size_s.y, callback = function()
        frm_height = math.min(999, frm_height + 1)
        lbl[4].label = frm_height
        orientationChanged()
    end}
    
    -- frm_fps less
    btn[5] = Button{label = "-", width = size_s.x, height = size_s.y, frequency = .2, callback = function()
        frm_fps = math.max(1, frm_fps - 1)
        lbl[5].label = frm_fps.." fps"
        btn[7].frequency = 1/frm_fps
        btn[8].frequency = btn[7].frequency
    end}
    
    -- frm_fps more
    btn[6] = Button{label = "+", width = size_s.x, height = size_s.y, frequency = .2, callback = function()
        frm_fps = math.min(60, frm_fps + 1)
        lbl[5].label = frm_fps.." fps"
        btn[7].frequency = 1/frm_fps
        btn[8].frequency = btn[7].frequency
    end}
    
    -- spr_frm prev
    btn[7] = Button{label = "<", width = size_s.x, height = size_s.y, frequency = 1/frm_fps, callback = function()
        spr_curr_frm = spr_curr_frm == 1 and #spr_frm or spr_curr_frm - 1
        lbl[7].label = spr_curr_frm.." / "..#spr_frm
    end}
    
    -- spr_frm next
    btn[8] = Button{label = ">", width = size_s.x, height = size_s.y, frequency = 1/frm_fps, callback = function()
        spr_curr_frm = spr_curr_frm == #spr_frm and 1 or spr_curr_frm + 1
        lbl[7].label = spr_curr_frm.." / "..#spr_frm
    end}
    
    -- spr_src save
    btn[9] = Button{label = "SAV", width = size_m.x, height = size_m.y, frequency = math.huge, callback = function()
        local w = frm_width
        local h = frm_height
        local f = #spr_frm
        
        while f > 1 do
            local newW = w + frm_width
            local newH = h + frm_height
            if newH < newW then
                h = newH
                f = f - w / frm_width
            else
                w = newW
                f = f - h / frm_height
            end
        end
        
        local i = 0
        local rows = h / frm_height
        local cols = w / frm_width
        local dir = "Dropbox"
        local assets = assetList(dir, SPRITES)
        local atlas = image(w, h)
        
        for k, key in ipairs(assets) do
            if tostring(readImage(dir..":"..key)) == tostring(spr_src) then
                dir = dir..":"..key.."_"..frm_width.."x"..frm_height
                break
            end
        end
        
        setContext(atlas)
        for r = rows, 1, -1 do
            for c = 1, cols do
                i = i + 1
                if i > #spr_frm then break end
                local frm_pos = vec2(c*frm_width - frm_width, r*frm_height - frm_height)
                local spr_pos = vec2(frm_width*.5, frm_height*.5) + spr_frm[i]
                clip(frm_pos.x, frm_pos.y, frm_width, frm_height)
                sprite(spr_src, spr_pos.x + frm_pos.x, spr_pos.y + frm_pos.y)
                clip()
            end
        end
        setContext()
        saveImage(dir, atlas)
        alert(dir, string.format("%.0fx%.0f spritesheet saved to", cols, rows))
    end}
    
    -- spr_frm remove
    btn[10] = Button{label = "-F", width = size_m.x, height = size_m.y, callback = function()
        if #spr_frm > 1 then
            table.remove(spr_frm, spr_curr_frm)
            btn[7].callback()
        end
    end}
    
    -- spr_frm add
    btn[11] = Button{label = "F+", width = size_m.x, height = size_m.y, callback = function()
        table.insert(spr_frm, spr_curr_frm + 1, vec2(0, 0))
        btn[8].callback()
    end}
    
    -- spr_frm clear
    btn[12] = Button{label = "CLR", width = size_m.x, height = size_m.y, frequency = math.huge, callback = function()
        spr_frm = {vec2(0, 0)}
        btn[7].callback()
    end}
end

function orientationChanged()
    if frm_width and frm_height then
        -- Frame
        local rem_width = WIDTH - frm_width
        local rem_height = HEIGHT - frm_height
        
        frm_mask[1] = vec4(rem_width*.25, HEIGHT - rem_height*.25, rem_width*.5, rem_height*.5) -- top left
        frm_mask[2] = vec4(WIDTH*.5, HEIGHT - rem_height*.25, frm_width, rem_height*.5) -- top center
        frm_mask[3] = vec4(WIDTH - rem_width*.25, HEIGHT - rem_height*.25, rem_width*.5, rem_height*.5) -- top right
        frm_mask[4] = vec4(rem_width*.25, HEIGHT*.5, rem_width*.5, frm_height) -- middle left
        frm_mask[5] = vec4(WIDTH - rem_width*.25, HEIGHT*.5, rem_width*.5, frm_height) -- middle right
        frm_mask[6] = vec4(rem_width*.25, rem_height*.25, rem_width*.5, rem_height*.5) -- bottom left
        frm_mask[7] = vec4(WIDTH*.5, rem_height*.25, frm_width, rem_height*.5) -- bottom center
        frm_mask[8] = vec4(WIDTH - rem_width*.25, rem_height*.25, rem_width*.5, rem_height*.5) -- bottom right
        
        -- Labels
        lbl[1].x, lbl[1].y = 50, HEIGHT - 50 -- frm_width label
        lbl[2].x, lbl[2].y = WIDTH - 195, HEIGHT - 50 -- frm_height label
        lbl[3].x, lbl[3].y = 165, HEIGHT - 50 -- frm_width value
        lbl[4].x, lbl[4].y = WIDTH - 75, HEIGHT - 50 -- frm_height value
        lbl[5].x, lbl[5].y = 90, 50 -- frm_fps value
        lbl[6].x, lbl[6].y = WIDTH - 220, 50 -- spr_frm label
        lbl[7].x, lbl[7].y = WIDTH - 90, 50 -- spr_frm value
        
        -- Buttons
        btn[1].x, btn[1].y = 120, HEIGHT - 50 -- frm_width -
        btn[2].x, btn[2].y = 210, HEIGHT - 50 -- frm_width +
        btn[3].x, btn[3].y = WIDTH - 120, HEIGHT - 50 -- frm_height -
        btn[4].x, btn[4].y = WIDTH - 30, HEIGHT - 50 -- frm_height +
        btn[5].x, btn[5].y = 30, 50 -- frm_fps -
        btn[6].x, btn[6].y = 150, 50 -- frm_fps +
        btn[7].x, btn[7].y = WIDTH - 150, 50 -- spr_frm prev
        btn[8].x, btn[8].y = WIDTH - 30, 50 -- spr_frm next
        btn[12].x, btn[12].y = WIDTH*.5 - btn[12].width*1.5, HEIGHT - 50 -- spr_src save
        btn[9].x, btn[9].y = WIDTH*.5 - btn[9].width*.5, HEIGHT - 50 -- spr_src save
        btn[10].x, btn[10].y = WIDTH*.5 + btn[10].width*.5, HEIGHT - 50 -- spr_frm remove
        btn[11].x, btn[11].y = WIDTH*.5 + btn[11].width*1.5, HEIGHT - 50 -- spr_frm add
    end
end

function draw()
    background(36, 39, 65, 255)
    
    -- Canvas
    clip(WIDTH*.5 - frm_width*.5, HEIGHT*.5 - frm_height*.5, frm_width, frm_height)
    
    if spr_dragging then
        -- Onion skin
        local onion_prev = math.max(1, spr_curr_frm - 1)
        local onion_next = math.min(#spr_frm, spr_curr_frm + 1)
        
        pushStyle()
        if spr_curr_frm > 1 then
            tint(53, 91, 239, 120)
            sprite(spr_src, WIDTH*.5 + spr_frm[onion_prev].x, HEIGHT*.5 + spr_frm[onion_prev].y)
        end
        if spr_curr_frm < #spr_frm then
            tint(0, 255, 0, 120)
            sprite(spr_src, WIDTH*.5 + spr_frm[onion_next].x, HEIGHT*.5 + spr_frm[onion_next].y)
        end
        popStyle()
        clip()
    else
        if spr_frm[spr_curr_frm] == vec2(0, 0) then
            clip()
        end
    end
    
    sprite(spr_src, WIDTH*.5 + spr_frm[spr_curr_frm].x, HEIGHT*.5 + spr_frm[spr_curr_frm].y)
    clip()
    
    -- Frame
    if #frm_mask == 0 then
        orientationChanged()
    else
        for m = 1, #frm_mask do
            fill(112, 58, 114, 132)
            rect(frm_mask[m].x, frm_mask[m].y, frm_mask[m].z, frm_mask[m].w)
        end
    end
    
    -- Labels
    for l = 1, #lbl do
        lbl[l]:draw()
    end
    
    text("x: "..spr_frm[spr_curr_frm].x.."    y: "..spr_frm[spr_curr_frm].y, WIDTH*.5, 50)
    
    -- Buttons
    for b = 1, #btn do
        btn[b]:draw()
    end
end

function touched(touch)
    -- Buttons
    for b = 1, #btn do
        btn[b]:touched(touch)
    end
    
    -- Canvas
    if touch.state == MOVING then
        -- Sprite
        if touch.x > 0 and touch.x < WIDTH and touch.y > 100 and touch.y < HEIGHT - 100 then
            spr_frm[spr_curr_frm].x = spr_frm[spr_curr_frm].x + touch.deltaX
            spr_frm[spr_curr_frm].y = spr_frm[spr_curr_frm].y + touch.deltaY
            spr_dragging = true
        end
    else
        spr_dragging = nil
    end
    
    if touch.state == ENDED then
        local pos = {}
        for i, v in ipairs(spr_frm) do
            table.insert(pos, "vec2"..tostring(v))
        end
        saveProjectData("frm_fps", frm_fps)
        saveProjectData("frm_width", frm_width)
        saveProjectData("frm_height", frm_height)
        saveProjectData("spr_frm", "return{"..table.concat(pos, ",").."}")
    end
end

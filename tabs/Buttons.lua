Button = class(Label)

function Button:init(params)
    self.callback = params.callback
    self.frequency = params.frequency or .025
    Label.init(self, params)
end

function Button:draw()
    if self.active then
        fill(156, 44, 87, 255)
    else
        fill(47, 96, 156, 255)
    end
    rect(self.x, self.y, self.width, self.height)
    fill(175, 155, 136, 255)
    text(self.label, self.x, self.y)
    
    -- Long press handler
    if self.press_timer and self.press_timer < ElapsedTime then
        if not self.spawn_timer or (self.spawn_timer and self.spawn_timer < ElapsedTime) then
            if self.spawn_timer then
                self.callback()
            end
            self.spawn_timer = ElapsedTime + self.frequency
        end
    end
end

function Button:touched(touch)
    if touch.x > self.x - self.width*.5
    and touch.x < self.x + self.width*.5
    and touch.y > self.y - self.height*.5
    and touch.y < self.y + self.height*.5 then
        self.press_timer = self.press_timer or (ElapsedTime + .25)
        self.active = true
        if touch.state == ENDED then
            self.press_timer = nil
            self.active = nil
            self.callback()
        end
    else
        self.press_timer = nil
        self.active = nil
    end
end

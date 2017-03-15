Label = class()

function Label:init(params)
    font("SourceSansPro-Light")
    fontSize(30)
    
    self.label = params.label
    local label_width, label_height = textSize(self.label)
    self.x = params.x or 0
    self.y = params.y or 0
    self.width = params.width or label_width
    self.height = params.height or label_height
end

function Label:draw()
    fill(30, 27, 25, 255)
    text(self.label, self.x, self.y)
end

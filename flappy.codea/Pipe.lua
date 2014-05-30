NOISE_SCALE = 0.7

Pipe = class()

function Pipe:init(w, h)
    -- you can accept and set parameters here
    self.img = self:rect(w, h)
end

function Pipe:draw(x, y, w, h)
    -- Codea does not automatically call this method
    pushStyle()
    spriteMode(CORNER)
    sprite(self.img, x, y)
    popStyle()
end

function Pipe:rect(w, h)
    local img = image(w, h)
    local tilew, tileh = w / 8, h / 10
    
    setContext(img)
    noStroke()
    noSmooth()
    for x = 1, w/tilew do
        for y = 1, h/tileh do
            local v = noise(x * NOISE_SCALE, y * NOISE_SCALE)
            fill(0, (v+1) * 0.5 * 255, 0)
            rect((x-1)*tilew, (y-1)*tileh, tilew, tileh)
        end
    end
    setContext()
    return img
end

function Pipe:touched(touch)
    -- Codea does not automatically call this method
end

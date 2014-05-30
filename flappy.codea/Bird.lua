Bird = class()

function Bird:init(r)
    -- you can accept and set parameters here
    self.img1 = self:createBird()
end

function Bird:draw()
    -- Codea does not automatically call this method
    pushStyle()
    spriteMode(CORNER)
    sprite(self.img1, x, y)
    popStyle()
end

function Bird:createBird(w, h)
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

function Bird:touched(touch)
    -- Codea does not automatically call this method
end

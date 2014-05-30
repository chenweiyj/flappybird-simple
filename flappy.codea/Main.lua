-- flappy
displayMode(FULLSCREEN)
supportedOrientations(PORTRAIT)

-- bug fix
-- if the bird is collided between the bottom pipe
-- abd the top pipe, next time the game begins, the
-- physics body of these pipes are not cleared.
-- although we cannot see them, the objects still are there.
-- 2014-03-24: it is fixed by destroying the physics bodies of pipes.

-- todo: pixel style

-- Use this function to perform your initial setup
function setup()
    music()
    
    READY = 1
    PLAYING = 2
    DYING = 3
    ROUNDUP = 4
    gamestate = READY
    
    -- some static varables
    gap = HEIGHT/4
    w = WIDTH/10 -- pipe width is w*2
    speed = 4
    startdist = WIDTH -- longer gives more time to be ready to play
    pipedist = WIDTH/2
    minpipel = 0.145*WIDTH
    pipecount = 3
    
    pipe = {}
    pipetop = {}
    both = {}
    toph = {}
    if readLocalData("hiscore") ~= nil then
        hiscore = readLocalData("hiscore")
    else
        hiscore = 0
    end
    base = {}
    for i = -200, WIDTH + 200, 100 do
        table.insert(base, {x = i})
    end
    
    ground = physics.body(EDGE, vec2(0, 70), vec2(WIDTH, 70))
    bird = physics.body(CIRCLE, 43)
    bird.gravityScale = 5
    birdspeed = 3*HEIGHT/5
    bird.interpolate = true
    parameter.watch("bird.linearVelocity")
    
    pixelp = {}
    pixelptop = {}
    
    initialise()
end

function initialise()
    bird.type = STATIC
    bird.position = vec2(WIDTH*(1-0.618), HEIGHT/2)
    flash = 0
    deadcount = 0 -- no use
    score = 0
    
    for i = 1, pipecount do
        -- destroy the physics bodies of pipes first
        if pipe[i] ~= nil then
            pipe[i]:destroy()
            pipe[i] = nil
        end
        if pipetop[i] ~= nil then
            pipetop[i]:destroy()
            pipetop[i] = nil
        end
        
        -- then create a new physics body
        both[i] = math.random(HEIGHT * 2.5 / 7) + minpipel
        toph[i] = HEIGHT - (both[i] + gap)
        x = startdist + pipedist * i
        pipe[i] = physics.body(POLYGON, vec2(-w, -both[i]/2), vec2(-w, both[i]/2), vec2(w, both[i]/2), vec2(w, -both[i]/2))
        pipe[i].position = vec2(x, both[i]/2)
        pipe[i].type = STATIC
        pipetop[i] = physics.body(POLYGON, vec2(-w, -toph[i]/2), vec2(-w, toph[i]/2), vec2(w, toph[i]/2), vec2(w, -toph[i]/2))
        pipetop[i].position = vec2(x, HEIGHT - toph[i]/2)
        pipetop[i].type = STATIC
        pipetop[i].flag = 0
        
        pixelp[i] = Pipe(2*w, both[i])
        pixelptop[i] = Pipe(2*w, toph[i])
    end
end

-- This function gets called once every frame
function draw()
    -- This sets a dark background color
    if flash == 1 then
        background(255, 200, 20)
        flash = flash + 1
        sound(SOUND_EXPLODE, 17)
        bird.linearVelocity = vec2(0, birdspeed/2)
    else
        background(40, 40, 50, 255)
    end
    
    if gamestate == READY then
        bird.type = STATIC
        fill(255)
        font("Futura-Medium")
        fontSize(64)
        text("Get Ready!", WIDTH/2, 2*HEIGHT/3)
        fontSize(32)
        text("Tap to start", WIDTH/2, HEIGHT/3)
    else
        bird.type = DYNAMIC
    end
    
    -- This sets the line thickness
    --strokeWidth(5)
    
    -- Do your drawing here
    
    --fill(0, 0, 0, 255)
    -- each time those three rectangles are drawn again and again
    -- with x slightly decreased (default by 2).
    -- showing the effect that they are moving slowly
    fill(44, 131, 48, 255)
    for k, p in pairs(pipe) do
        pixelp[k]:draw(p.x + p.points[1].x, p.y + p.points[1].y, 2*w, both[k])
        if gamestate == PLAYING then
            p.x = p.x + -speed
            if p.x < -w then p.x = p.x + pipedist*pipecount end
        end
    end
    for k, p in  pairs(pipetop) do
        pixelptop[k]:draw(p.x + p.points[1].x, p.y + p.points[1].y, 2*w, toph[k])
        if gamestate == PLAYING then
            p.x = p.x + -speed
            if p.x < bird.x and p.flag == 0 then
                score = score + 1
                p.flag = 1
                sound(SOUND_PICKUP, 11981)
            end
            if p.x < -w then
                p.x = p.x + pipedist*pipecount
                p.flag = 0
            end
        end
    end
    
    -- draw the bird after the pipes
    if bird.linearVelocity.y > 0 then
        pushMatrix()
        translate(bird.x, bird.y)
        rotate(30)
        sprite("SpaceCute:Beetle Ship", 0, 0, 100, 100)
        popMatrix()
    elseif bird.linearVelocity.y < -birdspeed/2 then
        pushMatrix()
        translate(bird.x, bird.y)
        rotate(-10)
        sprite("SpaceCute:Beetle Ship", 0, 0, 100, 100)
        popMatrix()
    elseif gamestate == DYING or gamestate == ROUNDUP then
        pushMatrix()
        translate(bird.x, bird.y)
        rotate(-90)
        sprite("SpaceCute:Beetle Ship", 0, 0, 100, 100)
        popMatrix()
    else
        sprite("SpaceCute:Beetle Ship", bird.x, bird.y, 100, 100)
    end
    
    -- draw grass backgound
    for i, b in pairs(base) do
        sprite("Platformer Art:Block Grass", b.x, 45, 100, 100)
        if gamestate == READY or gamestate == PLAYING then
            b.x = b.x + -speed
            if b.x < -100 then b.x = b.x + 1200 end
        end
    end
    
    -- display score
    fill(255)
    fontSize(64)
    text(score, WIDTH/2, 11*HEIGHT/12)
    
    if gamestate == DYING then
        deadcount = deadcount + 1
        if deadcount > 25 then
            gamestate = ROUNDUP
        end
    end
    if gamestate == ROUNDUP then
        if score > hiscore then
            hiscore = score
            saveLocalData("hiscore", score)
        end
        fill(255)
        fontSize(64)
        text("Game Over!", WIDTH/2, 6*HEIGHT/7)
        -- draw the score board
        fill(168, 144, 51, 255)
        rect(WIDTH/6, 13*HEIGHT/24, 2*WIDTH/3, HEIGHT/6)
        fill(255)
        fontSize(32)
        text("SCORE: "..score, WIDTH/2, 16*HEIGHT/24)
        text("BEST: "..hiscore, WIDTH/2, 14*HEIGHT/24)
        fill(218, 195, 72, 255)
        rect(3*WIDTH/12, 5*HEIGHT/14, WIDTH/2, 2*HEIGHT/14)
        fill(166, 39, 39, 255)
        fontSize(64)
        text("Play Again!", WIDTH/2, 6*HEIGHT/14)
    end
end

function collide(c)
    if c.state == BEGAN then
        gamestate = DYING
        flash = flash + 1
        for i = 1, pipecount do
            -- set physics bodies of pipes inactive
            -- make the bird go through them
            if pipe[i] ~= nil then
                pipe[i].active = false
            end
            if pipetop[i] ~= nil then
                pipetop[i].active = false
            end
        end
    end
end

function touched(t)
    if t.state == BEGAN then
        if gamestate == READY then
            gamestate = PLAYING
            bird.type = DYNAMIC
            bird.linearVelocity = vec2(0, birdspeed)
            sound(DATA, "ZgNAIwBAPyRjQC9XehJbvvYwiz54c/o+QQAKen5AWVdMentA")
        elseif gamestate == PLAYING then
            bird.linearVelocity = vec2(0, birdspeed)
            if bird.y > HEIGHT then
                bird.linearVelocity = vec2(0, -bird.radius*2)
            end
            sound(DATA, "ZgNAIwBAPyRjQC9XehJbvvYwiz54c/o+QQAKen5AWVdMentA")
        elseif gamestate == ROUNDUP and -- other conditions
            CurrentTouch.x > 3*WIDTH/12 and
            CurrentTouch.x < 3*WIDTH/12 + WIDTH/2 and
            CurrentTouch.y > 5*HEIGHT/14 and
            CurrentTouch.y < 5*HEIGHT/14 + 2*HEIGHT/14
        then
            gamestate = READY
            initialise()
        end
    end
end
    
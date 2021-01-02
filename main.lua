function love.load()
    resetGame()
    enemyMoveSfx = love.audio.newSource("enemy move.wav", "static")
    moveSfx = love.audio.newSource("move.wav", "static")
    winSfx = love.audio.newSource("win.wav", "static")
    dieSfx = love.audio.newSource("die.wav", "static")
end

function resetGame()
    player = {
        x = math.abs(love.graphics.getWidth()/32/2),
        y = math.abs(love.graphics.getHeight()/32/2),
        movement = 1
    }
    
    otherPlayer = {
        x = math.abs(love.graphics.getWidth()/32/2),
        y = math.abs(love.graphics.getHeight()/32/2)
    }
    
    phaseHistory = {}
    
    trails = {}
    
    currentLevel = 1
    movements = 1
    nextMovement = 1
end

function love.draw()
    for i,v in ipairs(trails) do
        love.graphics.setColor(0,1,0,v.alpha)
        love.graphics.rectangle("fill", v.x*32,v.y*32, 32, 32)
    end

    love.graphics.setColor(1,0,0)
    love.graphics.rectangle("line", otherPlayer.x*32, otherPlayer.y*32, 32, 32)
    love.graphics.setColor(0,0,1)
    love.graphics.rectangle("fill", player.x*32, player.y*32, 32, 32)
end

function love.update(dt)
    if movements > 0 then
        nextMovement = nextMovement - 1*dt
        if nextMovement < 0 then
            nextMovement = 0.25
            movements = movements - 1
            if love.math.random(1,2) == 1 then
                if love.math.random(1,2) == 1 then
                    otherPlayer.x = otherPlayer.x + 1
                else
                    otherPlayer.x = otherPlayer.x - 1
                end
            else
                if love.math.random(1,2) == 1 then
                    otherPlayer.y = otherPlayer.y + 1
                else
                    otherPlayer.y = otherPlayer.y - 1
                end
            end
            if otherPlayer.x > love.graphics.getWidth()/32-1 then
                otherPlayer.x = 0
            elseif otherPlayer.x == -1 then
                otherPlayer.x = love.graphics.getWidth()/32 - 1
            end
            if otherPlayer.y > love.graphics.getHeight()/32 - 1 then
                otherPlayer.y = 0
            elseif otherPlayer.y == -1 then
                otherPlayer.y = love.graphics.getHeight()/32 - 1
            end
            enemyMoveSfx:setPitch(love.math.random(50,100)/100)
            love.audio.stop(enemyMoveSfx)
            love.audio.play(enemyMoveSfx)
            trails[#trails+1] = {
                x = otherPlayer.x,
                y = otherPlayer.y,
                alpha = 1.5
            }
            phaseHistory[#phaseHistory + 1] = {
                x = otherPlayer.x,
                y = otherPlayer.y
            }
        end
    end

    for i,v in ipairs(trails) do
        v.alpha = v.alpha - 1*dt
        if v.alpha < 0 then
            table.remove(trails, i)
        end
    end
end

function love.keypressed(key)
    if movements == 0 then
        if key == "left" then
            player.x = player.x - 1
        elseif key == "right" then
            player.x = player.x + 1
        elseif key == "up" then
            player.y = player.y - 1
        elseif key == "down" then
            player.y = player.y + 1
        end
        if player.x > love.graphics.getWidth()/32-1 then
            player.x = 0
        elseif player.x == -1 then
            player.x = love.graphics.getWidth()/32-1
        end
        if player.y > love.graphics.getHeight()/32-1 then
            player.y = 0
        elseif player.y == -1 then
            player.y = love.graphics.getHeight()/32-1
        end
        if phaseHistory[player.movement].x ~= player.x or phaseHistory[player.movement].y ~= player.y then
            love.audio.play(dieSfx)
            love.window.showMessageBox( "L", "You lose. Sorry.\n\nYou made it to Level "..currentLevel )
       
            resetGame()
        else
        
            player.movement = player.movement + 1
            if player.movement > #phaseHistory then
                phaseHistory = {}
                player.movement = 1
                currentLevel = currentLevel + 1
                movements = currentLevel
                love.audio.play(winSfx)
            else
                love.audio.stop(moveSfx)
                moveSfx:setPitch(love.math.random(50,100)/100)
                love.audio.play(moveSfx)
            end
        end
    end
end
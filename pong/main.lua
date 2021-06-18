--a working iteration of pong :) 
--still requires a lot of cleanup though. 

push = require 'push'

Class = require 'class'

require 'Ball'
require 'Paddle'


WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

--defining the actual game window size 
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200



function love.load()
  
  --window Title
  love.window.setTitle('Pong')
  
  --this is to disable the bilinear aliasing and make things appear pixelated
  love.graphics.setDefaultFilter('nearest', 'nearest')
  
  --using bit5x3 font to replicate the original retro style
  smallFont = love.graphics.newFont('font.ttf', 8)
  
  --using the same font but bigger
  scoreFont = love.graphics.newFont('font.ttf', 32)
  
  --setting the font as active
  love.graphics.setFont(smallFont)
  
  --resizing the game window 
  push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
    fullscreen = false,
    resizable = true,
    vsync = true
  })

  player1Score = 0
  player2Score = 0 
  
  player1 = Paddle(10, 30, 5, 20)
  player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)
  
  ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4 , 4)
  
  --using os time that increments every second
  math.randomseed(os.time())
  
  sounds = {['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
            ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
            ['wall_hit'] = love.audio.newSource('sounds/ball_hit.wav', 'static')
          }
  gameState = 'start'
  
  love.keyboard.keysPressed = {}
  
  ball:reset()

end

function love.resize(w, h)
  push:resize(w, h)  
end

function love.update(dt)

  if gameState == 'start' then
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
      gameState = 'play'
    end
  
  end

  
  if gameState =='play' then
    if ball:collides(player1) then
      ball.dx = -ball.dx * 1.2
      ball.x = player1.x + 5 
      
      if ball.y < 0 then
        ball.dy = -math.random(10, 150)
      else 
        ball.dy = math.random(10, 150)
      end
      
      sounds['paddle_hit']:play()
      
    elseif ball:collides(player2) then
      ball.dx = -ball.dx * 1.2
      ball.x = player2.x - 5
      
      if ball.y < 0 then
        ball.dy = -math.random(10, 150)
      else 
        ball.dy = math.random(10, 150)
      end
      sounds['paddle_hit']:play()

    end
    
    --ball collision with the top and bottom walls
    if ball.y > VIRTUAL_HEIGHT then
      ball.dy = -ball.dy
      ball.y = ball.y - 5
      sounds['wall_hit']:play()
    elseif ball.y < 0 then
      ball.dy = -ball.dy
      ball.y = ball.y + 5
      sounds['wall_hit']:play()
    end
    
    --scoring
    if ball.x < 0 then
      player2Score = player2Score + 1
      sounds['score']:play()
      ball:reset()
    elseif ball.x > VIRTUAL_WIDTH then
      player1Score = player1Score + 1
      ball:reset()
      sounds['score']:play()
    end  
      
    
  end
  
  --player1 movement
  --decreasing Y value to go up
  if love.keyboard.isDown('w') then
    player1.dy = -PADDLE_SPEED
    
  --increasing Y value to go down
  elseif love.keyboard.isDown('s') then
    player1.dy = PADDLE_SPEED
  else 
    player1.dy = 0   
  end
  
  --player2 movement
  if love.keyboard.isDown('up') then
    player2.dy = -PADDLE_SPEED
  
  elseif love.keyboard.isDown('down') then 
    player2.dy = PADDLE_SPEED
    
  else 
    player2.dy = 0 
  end
  
  --ball movement
  if gameState == 'play' then
    ball:update(dt)
  end
  
  player1:update(dt)
  player2:update(dt)
  
  function love.keypressed(key) 
    if key == "escape" then 
      love.event.quit()
    end  
    love.keyboard.keysPressed[key] = true
  end
end  

function love.keyboard.wasPressed(key)
  if love.keyboard.keysPressed[key] then 
    return true 
  else 
    return false
  end
end  


function love.draw()
  
  push:apply('start')
  
  --displaying title text
  love.graphics.setFont(smallFont)
  love.graphics.printf('Pong!', 0, 20, VIRTUAL_WIDTH, 'center')
  
  --changing active font
  love.graphics.setFont(scoreFont)

  --displaying player scores
  love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
  love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
  
  ball:render()
  player1:render()
  player2:render()
  
  
  
  push:apply('end')
  
end
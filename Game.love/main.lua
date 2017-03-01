enemy = {}
enemies_controller = {} 
enemies_controller.enemies = {}
enemies_controller.image = love.graphics.newImage("enemy.png")
particle_systems = {}
particle_systems.list = {}
particle_systems.image = love.graphics.newImage("particle.png")

function particle_systems:spawn(x, y)
  local ps = {}
  ps.x = x
  ps.y = y
  ps.ps = love.graphics.newParticleSystem(particle_systems.image, 32)
  ps.ps:setParticleLifetime(2, 4)
  ps.ps:setEmissionRate(5)
  ps.ps:setSizeVariation(1)
  ps.ps:setLinearAcceleration(-20, -20, 20, 20)
  ps.ps:setColors(100, 255, 100, 255, 0, 255, 0, 255)
  table.insert(particle_systems.list, ps)
end

function particle_systems:draw()
  for _, v in pairs(particle_systems.list) do
    love.graphics.draw(v.ps, v.x, v.y)
  end
end

function particle_systems:update(dt)
  for _, v in pairs(particle_systems.list) do
    v.ps:update(dt)
  end
end

function particle_systems:cleanup()
	if game_win == "true" then
		for _,v in pairs(particle_systems.list) do
			table.remove(particle_systems.list, ps)
		end
	end
end

function checkCollisions(enemies, bullets)
  for _,e in ipairs(enemies) do
    for _,b in ipairs(bullets) do
		for i = 1, #enemies do
      		if b.y <= enemies[i].y + enemies[i].height and b.x > enemies[i].x and b.x < enemies[i].x + enemies[i].width then
        		particle_systems:spawn(e.x, e.y)
        		table.remove(bullets, 1)
				table.remove(enemies, i)
				love.audio.play(explosion)
				break
      		end
    	end
  	end
  end
end

function love.load()
--GAME OVER STATUS
  game_over = false
  game_win = false
--CREATE BACKGROUND IMAGE AND SOUND
  background = love.graphics.newImage("background.png")
  backgroundAudio = love.audio.newSource("background.mp3")
  explosion = love.audio.newSource("explosion.mp3")
  backgroundAudio:setVolume(0.7)
  backgroundAudio:setPitch(0.5)
  love.audio.play(backgroundAudio)  
--CREATE PLAYER
  player = {}
  player.x = 375
  player.y = 545
  player.lives = 3  
  player.bullets = {}
  player.cooldown = 20
  player.speed = 4
--LOAD PLAYER IMAGE
  player.image = love.graphics.newImage("player.png")
--LOAD ROCKET SOUND
  player.fire_sound = love.audio.newSource("rocket.wav")
--CREATE FIRE FUNCTION
  player.fire = function()
    if player.cooldown <= 0 then
      love.audio.play(player.fire_sound)
      player.cooldown = 23
      bullet = {}
      bullet.x = player.x + 15
      bullet.y = player.y
      table.insert(player.bullets, bullet)
    end
  end
--SPAWN ENEMIES
  enemies_controller:spawnEnemy(0,0)
  enemies_controller:spawnEnemy(50, 50)
  enemies_controller:spawnEnemy(100, 0)
  enemies_controller:spawnEnemy(150, 50)
  enemies_controller:spawnEnemy(200, 0)
  enemies_controller:spawnEnemy(250, 50)
  enemies_controller:spawnEnemy(300, 0)
  enemies_controller:spawnEnemy(350, 50)
  enemies_controller:spawnEnemy(400, 0)
  enemies_controller:spawnEnemy(450, 50)
  enemies_controller:spawnEnemy(500, 0)
  enemies_controller:spawnEnemy(550, 50)
  enemies_controller:spawnEnemy(600, 0)
  enemies_controller:spawnEnemy(650, 50)
  enemies_controller:spawnEnemy(700, 0)
  enemies_controller:spawnEnemy(750, 50)
end
--ENEMY CREATION FUNCTION
function enemies_controller:spawnEnemy(x, y)
  enemy = {}
  enemy.x = x
  enemy.y = y
  enemy.height = 50
  enemy.width = 50
  enemy.bullets = {}
  enemy.cooldown = 20
  enemy.speed = 10
  table.insert(self.enemies, enemy)
end

function enemy:fire()
  if self.cooldown <= 0 then
    self.cooldown = 20
    bullet = {}
    bullet.x = self.x + 35
    bullet.y = self.y
    table.insert(self.bullets, bullet)
  end
end

function love.update(dt)
  particle_systems:update(dt)
  player.cooldown = player.cooldown - 1

  if love.keyboard.isDown("left") and player.x > 0 then
    player.x = player.x - player.speed
  elseif love.keyboard.isDown("right") and player.x < 760 then
    player.x = player.x + player.speed
  end

  if love.keyboard.isDown("space") then
    player.fire()
  end

  if #enemies_controller.enemies == 0 then
  	game_win = true
  end

  for _,e in pairs(enemies_controller.enemies) do
  	if e.y >= love.graphics.getHeight()-50 then
  		game_over = true
  	end
    e.y = e.y + 0.5
  end

  for i,b in ipairs(player.bullets) do
    if b.y < -10 then
      table.remove(player.bullets, i)
    end
    b.y = b.y - 10
  end
  checkCollisions(enemies_controller.enemies, player.bullets)
end

function love.draw()
-- DRAW BACKGROUND
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(background, 0, 0, 0)
-- DRAW WIN/LOSE MESSAGE
	if game_over then
		love.graphics.print("Game Over!")
		return
	elseif game_win then
		love.graphics.print("You Win!!")
	end

--DRAW EXPLOSION
	particle_systems:draw()
  

-- DRAW THE PLAYER
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(player.image, player.x, player.y, 0, 0.5)
-- DRAW THE ENEMIES
  love.graphics.setColor(255, 255, 255)
  for _,e in pairs(enemies_controller.enemies) do
    love.graphics.draw(enemies_controller.image, e.x, e.y, 0, 0.5)
  end
-- CREATE LIVES SECTION
  love.graphics.setColor(255, 255, 255)
  love.graphics.print("Lives:"..player.lives, 400, 0)
-- DRAW BULLETS
  love.graphics.setColor(255, 255, 255)
  for _,b in pairs(player.bullets) do
    love.graphics.rectangle("fill", b.x, b.y, 2, 2)
  end
end
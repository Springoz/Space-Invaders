-- Variáveis do jogador
local player = {
    x = 200,
    y = 500,
    velocidade = 200,
    velocidadevert = 200,
    width = 40,
    height = 20,
    balas = {},
    imagem = nil,
}

-- Variáveis dos inimigos
local aliens = {
    balasaliens = {},
    velocidade = 200,
    width = 40,
    height = 20,
    imagemalien = nil,
}

local alienShootTimer = 0
local alienShootInterval = 1  -- Intervalo de 1 segundo entre tiros dos aliens
local velocidade_aliens = 100
local largura_aliens = 40
local altura_aliens = 20
local defeatedaliens = 0

-- Geração de aliens
local spawnTimer = 0
local spawnRate = 2

-- Função para criar inimigos
function spawnEnemy(x, y)
    local enemy = {
        x = x,
        y = y,
        balasaliens = {},  -- Inicialize as balas dos aliens como uma tabela vazia
        width = aliens.width,  -- Defina a largura igual à largura dos aliens
        height = aliens.height,  -- Defina a altura igual à altura dos aliens
    }
    table.insert(aliens, enemy)
end

-- Carrega o jogo
function love.load()
    love.window.setTitle("Space Invaders")
    love.window.setMode(400, 600)

    -- Carrega a fonte do contador
    fonteContador = love.graphics.newFont(12)

    -- Carrega o sprite do jogador
    player.imagem = love.graphics.newImage("ship.png")

    -- Carrega o sprite dos aliens
    aliens.imagemalien = love.graphics.newImage("alien.png")
end

-- Função para criar tiros dos aliens
function alienshoot()
    for _, alien in ipairs(aliens) do
        local balaalien = {
            x = alien.x + alien.width / 1.5,  -- Ajuste a posição do tiro conforme necessário
            y = alien.y + alien.height,  -- Posição vertical abaixo do alien
            velocidade = 200,  -- Velocidade do tiro dos aliens
            color = {1, 0, 0, 1}  -- Cor do tiro dos aliens (por exemplo, vermelho)
        }
        table.insert(alien.balasaliens, balaalien)
    end
    alienShootTimer = 0  -- Reinicialize o temporizador aqui
end

-- Função para criar tiros do jogador
function shoot()
    local bala = {
        x = player.x + player.width / 1.2,
        y = player.y,
        velocidade = 300,
        color = {0, 1, 0, 1}  -- Cor verde neon (RGBA)
    }
    table.insert(player.balas, bala)
end

-- Atualiza
function love.update(dt)
    -- Sistema de velocidade 
    local moveX, moveY = 0, 0

    if love.keyboard.isDown("left") then
        moveX = moveX - 1
    end

    if love.keyboard.isDown("right") then
        moveX = moveX + 1
    end

    if love.keyboard.isDown("up") then
        moveY = moveY - 1
    end

    if love.keyboard.isDown("down") then
        moveY = moveY + 1
    end

    local moveLength = math.sqrt(moveX * moveX + moveY * moveY)
    if moveLength > 0 then
        moveX = moveX / moveLength
        moveY = moveY / moveLength
    end

    player.x = player.x + player.velocidade * moveX * dt
    player.y = player.y + player.velocidadevert * moveY * dt

    -- Verifica se o jogador atingiu os limites da tela e aplica o loop de movimento
    if player.x > love.graphics.getWidth() then
        player.x = 0
    elseif player.x + player.width < 0 then
        player.x = love.graphics.getWidth()
    end

    -- Verifica se o jogador atingiu os limites da tela vertical
    if player.y < 0 then
        player.y = 0
    elseif player.y + player.height > love.graphics.getHeight() then
        player.y = love.graphics.getHeight() - player.height
    end

    -- Atualiza o movimento dos inimigos
    for i, enemy in ipairs(aliens) do
        enemy.y = enemy.y + velocidade_aliens * dt
        if enemy.y > love.graphics.getHeight() then
            table.remove(aliens, i)
        end
    end

    alienShootTimer = alienShootTimer + dt

    if alienShootTimer >= alienShootInterval then
        -- Chamada da função para os aliens atirarem
        alienshoot()
    end

    -- Atualiza o movimento dos tiros do jogador
    for i, bala in ipairs(player.balas) do
        bala.y = bala.y - bala.velocidade * dt
        if bala.y < 0 then
            table.remove(player.balas, i)
        end
    end

    -- Atualiza o movimento dos tiros dos aliens
    for i, alien in ipairs(aliens) do
        for j, balaalien in ipairs(alien.balasaliens) do
            balaalien.y = balaalien.y + balaalien.velocidade * dt  -- Mude de subtração para adição
            if balaalien.y > love.graphics.getHeight() then
                table.remove(alien.balasaliens, j)
            end
        end
    end

    -- Sistema de colisão entre tiros e aliens
    for i, bala in ipairs(player.balas) do
        for j, enemy in ipairs(aliens) do
            if bala.x > enemy.x and bala.x < enemy.x + largura_aliens and
                bala.y > enemy.y and bala.y < enemy.y + altura_aliens then
                table.remove(player.balas, i)
                table.remove(aliens, j)
                defeatedaliens = defeatedaliens + 1
            end
        end
    end

    -- Gera aliens
    spawnTimer = spawnTimer + dt
    if spawnTimer > spawnRate then
        spawnEnemy(math.random(0, love.graphics.getWidth() - largura_aliens), -altura_aliens)
        spawnTimer = 0
    end
end

-- Gera o jogo
function love.draw()
    -- Gera o jogador
    love.graphics.draw(player.imagem, player.x, player.y)

    -- Desenha os inimigos
    for _, enemy in ipairs(aliens) do
        love.graphics.draw(aliens.imagemalien, enemy.x, enemy.y)
    end

    -- Gera os tiros do jogador
    for _, bala in ipairs(player.balas) do
        love.graphics.setColor(bala.color)  -- Define a cor do tiro
        love.graphics.rectangle("fill", bala.x, bala.y, 2, 5)
        love.graphics.setColor(1, 1, 1, 1)  -- Restaura a cor padrão (branco)
    end

    -- Gera os tiros dos aliens
    for _, alien in ipairs(aliens) do
        for _, balaalien in ipairs(alien.balasaliens) do
            love.graphics.setColor(balaalien.color)  -- Define a cor do tiro
            love.graphics.circle("fill", balaalien.x, balaalien.y, 2, 5)
            love.graphics.setColor(1, 1, 1, 1)  -- Restaura a cor padrão (branco)
        end
    end

    -- Fonte do contador
    love.graphics.setFont(fonteContador)

    -- Gera o contador
    love.graphics.print("Derrotados: " .. defeatedaliens, 10, 10)
end

-- Função para atirar
function love.keypressed(key)
    if key == "space" then
        shoot()
    end
end
class World:
    ships = [shiptex, slightshiptex, damagedshiptex, verydamagedshiptex]
    player = Player { xy_0, shiptex }

    bullets = []
    lastbullet = gl_time()
    firerate = 0.15

    enemyships = [enemyshiptex, enemyshiptex2, enemyshiptex3]
    enemies = []
    enemymaxhp = 5

    score = 0

    worldsize = 20.0
    timevar = 0.01
    new_worldsize = 0.0

    def render_background():
        gl_translate float(gl_window_size()) / 2.0:
            // Background layer 1
            gl_set_primitive_texture(0, bgtexlayer1)
            gl_rect(float(gl_window_size())/2.0, 1)
            // Background layer 2
            gl_set_primitive_texture(0, bgtexlayer2)
            gl_rect(float(gl_window_size())/2.0, 1)

    def update_worldsize(pos1, pos2):
        timevar += gl_delta_time()
        if timevar <= 1.0:
            new_worldsize = lerp(pos1, pos2, timevar)
        return new_worldsize
                
    def update():
        render_background()
        gl_text("health: {ceiling(player.health)} - score: {score}")
        gl_translate float(gl_window_size()) / 2.0:
            let scale = gl_window_size().y / worldsize
            gl_scale(scale)

            let tomouse = player.update(float(gl_window_size()) / scale / 2.0)

            // Update player texture based on health
            if player.health <= 80.0 and player.health > 50.0:
                player.texture = ships[1]
            elif player.health <= 50.0 and player.health > 20.0:
                player.texture = ships[2]
            elif player.health <= 20.0:
                player.texture = ships[3]

            member lastenemy = gl_time()
            if lastenemy < gl_time():
                member random_enemies = 0
                // Spawn different enemy ships
                if score >= 100 and score < 200:
                    random_enemies = rnd(2)
                elif score >= 200:
                    random_enemies = rnd(3)
                enemies.push(Enemy { sincos(rnd(360)) * worldsize * 2.0, enemymaxhp, xy{1.0,1.0}, enemyships[random_enemies]})

                //Spawn Bosses
                if score == 10:
                    enemies.push(Enemy { sincos(rnd(360)) * worldsize * 2.0, enemymaxhp * 4, xy{2.0,2.0}, bosstex})

                member enemyrate = 1.0
                lastenemy += enemyrate
                enemyrate *= 0.999

            if lastbullet < gl_time():
                bullets.push(Bullet { player.pos, tomouse, bulletlasertex })
                lastbullet += firerate

            enemies = filter(enemies) e:
                e.update(player, bullets, enemymaxhp)
                if not e.hp: score++
                e.hp

            bullets = filter(bullets) b:
                b.update(worldsize * 2.0)
                b.alive

            gl_translate gl_local_mouse_pos(0):
                gl_set_primitive_texture(0, crosshairtex)
                gl_rect(xy { 0.4, 0.4 }, 1)

            if score >= 100:
                firerate = 0.13
            if score >= 200:
                worldsize = update_worldsize(20.0, 25.0)
            if score >= 250:
                firerate = 0.11
            if score >= 400:
                firerate = 0.1
            if score >= 500:
                worldsize = update_worldsize(25.0, 30.0)
                firerate = 0.09

        return player.health
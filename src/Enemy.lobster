class Enemy : Entity
    hp:int
    size: xy_f
    texture:resource<texture>

    def update(player, bullets, maxhp):
        let enemyspeed = 3
        let playervec = player.pos - pos
        let playerdir = normalize(playervec)
        pos += playerdir * gl_delta_time() * enemyspeed
        for(bullets) b:
            if magnitude(b.pos - pos) < 1.0:
                hp = max(0, --hp)
                b.alive = false
        if magnitude(playervec) < 1.0:
            player.damage(gl_delta_time() * 25.0)
        renderEntity(playerdir, size, texture)
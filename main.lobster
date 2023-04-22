import std
import vec
import color
import gl

fatal(gl_window("2D Space Shooter", 1280, 720))

check(gl_set_font_name("data/fonts/US101/US101.ttf") and gl_set_font_size(32), "can\'t load font!")

let bgtex = gl_load_texture("galaxy.jpg")
assert bgtex
let shiptex = gl_load_texture("MainShip.png")
assert shiptex
let enemyshiptex = gl_load_texture("EnemyShip.png")
assert enemyshiptex
let bullettex = gl_load_texture("bullet.png")
assert bullettex
let crosshairtex = gl_load_texture("crosshair.png")
assert crosshairtex

class Entity:
    pos:xy_f

    def renderEntity(dir, tex):
        gl_translate pos:
            gl_rotate_z dir:
                gl_set_primitive_texture(0, tex)
                gl_rect(xy { 1.0, 1.0 }, 1)

class Player : Entity
    health = 100.0

    def update(bounds):
        let speed = 10
        let dir = xy_f { (gl_button("d") >= 1) - (gl_button("a") >= 1),
                        (gl_button("s") >= 1) - (gl_button("w") >= 1) }
        let newpos = pos + normalize(dir) * gl_delta_time() * speed
        if not any(abs(newpos) > bounds):
            pos = newpos
        let tomouse = normalize(gl_local_mouse_pos(0) - pos)
        renderEntity(tomouse, shiptex)
        return tomouse

    def damage(amount):
        health -= amount
        if health <= 0.0:
            health = 0.0

class Bullet : Entity
    dir:xy_f
    alive = true

    def update(maxdist):
        let bulletspeed = 15
        pos += dir * gl_delta_time() * bulletspeed
        gl_translate pos:
            gl_color color_yellow:
                gl_set_primitive_texture(0, bullettex)
                gl_rect(xy { 0.5, 0.5 }, 1)
        if magnitude(pos) > maxdist:
            alive = false

class Enemy : Entity
    hp:int

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
        renderEntity(playerdir, enemyshiptex)

class World:
    player = Player { xy_0 }

    bullets = []
    lastbullet = gl_time()
    firerate = 0.15

    enemies = []
    enemymaxhp = 5

    score = 0

    worldsize = 20.0
    timevar = 0.01
    new_worldsize = 0.0

    def render_background():
        gl_set_primitive_texture(0, bgtex)
    
        gl_rect(float(gl_window_size())/2.0, 1)

    def update_worldsize(pos1, pos2):
        timevar += gl_delta_time()
        if timevar <= 1.0:
            new_worldsize = lerp(pos1, pos2, timevar)
        return new_worldsize
                
    def update():
        gl_translate float(gl_window_size()) / 2.0:
            render_background()
            let scale = gl_window_size().y / worldsize
            gl_scale(scale)

            let tomouse = player.update(float(gl_window_size()) / scale / 2.0)

            member lastenemy = gl_time()
            if lastenemy < gl_time():
                enemies.push(Enemy { sincos(rnd(360)) * worldsize * 2.0, enemymaxhp})
                member enemyrate = 1.0
                lastenemy += enemyrate
                enemyrate *= 0.999

            if lastbullet < gl_time():
                bullets.push(Bullet { player.pos, tomouse })
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

while gl_frame() and gl_button("escape") != 1:
    gl_clear(color_black)

    gl_set_shader("textured")
    
    gl_color(color_white)

    static highscore = 0
    static w = nil::World

    if w:
        gl_text("health: {ceiling(w.player.health)} - score: {w.score} - highscore: {highscore}")
        if not w.update():
            highscore = max(highscore, w.score)
            w = nil
    else:
        gl_text("highscore: {highscore}")
        let msg = "press space to play!"
        gl_translate float(gl_window_size() - gl_text_size(msg)) / 2.0:
            gl_text(msg)
        if gl_button("space") == 1:
            w = World {}
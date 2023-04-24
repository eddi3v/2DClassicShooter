import std
import vec
import color
import gl
import gui

import "src/Entity.lobster"
import "src/Player.lobster"
import "src/Enemy.lobster"
import "src/Bullet.lobster"

fatal(gl_window("2D Space Shooter", 1280, 720))

check(gl_set_font_name("data/fonts/US101/US101.ttf") and gl_set_font_size(32), "can\'t load font!")

let bgmusic = play_ogg("assets/bg_fast.ogg", -1) 
if bgmusic: sound_volume(bgmusic, 0.2) else: print "can\'t load music!"
sound_pause(bgmusic)

let bgtex = gl_load_texture("assets/galaxy.jpg")
let shiptex = gl_load_texture("assets/MainShip.png")
let enemyshiptex = gl_load_texture("assets/EnemyShip.png")
let bullettex = gl_load_texture("assets/bullet.png")
let bulletlasertex = gl_load_texture("assets/bullet_laser.png")
let crosshairtex = gl_load_texture("assets/crosshair.png")

assert bgtex
assert shiptex
assert enemyshiptex
assert bullettex
assert bulletlasertex
assert crosshairtex

var clicked = false
var focused = false

class World:
    player = Player { xy_0, shiptex }

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
        gl_translate float(gl_window_size()) / 2.0:
            gl_set_primitive_texture(0, bgtex)
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

            member lastenemy = gl_time()
            if lastenemy < gl_time():
                enemies.push(Enemy { sincos(rnd(360)) * worldsize * 2.0, enemymaxhp, enemyshiptex})
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

while gl_frame() and gl_button("escape") != 1:
    gl_clear(color_black)

    gl_set_shader("textured")
    
    gl_color(color_white)

    gui_setclickcolors(color_grey, color_dark_grey)

    static highscore = 0
    static w = nil::World

    if w:
        if not w.update():
            highscore = max(highscore, w.score)
            w = nil
            sound_pause(bgmusic)
    else:
        gui_start(gl_window_size(), 1, 1, true):
            gui_vblock(1, 0):
                gui_text("highscore: {highscore}")
                gui_space(1.0)
                gui_button():
                    gui_border(xy_1i * 2):
                        gui_text("Play Game")
                fn:
                    clicked = not clicked
                fn:
                    focused = not focused
                if clicked:
                    w = World {}
                    sound_resume(bgmusic)
                    clicked = false
import std
import vec
import color
import gl
import gui

import "src/Entity.lobster"
import "src/Player.lobster"
import "src/Enemy.lobster"
import "src/Bullet.lobster"
import "src/World.lobster"

fatal(gl_window("2D Space Shooter", 1280, 720))

check(gl_set_font_name("data/fonts/US101/US101.ttf") and gl_set_font_size(32), "can\'t load font!")

// Background music
let bgmusic = play_ogg("assets/sound/bg_fast.ogg", -1) 
if bgmusic: sound_volume(bgmusic, 0.15) else: print "can\'t load music!"
sound_pause(bgmusic)

// Background Textures
let bgtex = gl_load_texture("assets/galaxy.jpg")
let bgtexlayer1 = gl_load_texture("assets/bg_layer1.png")
let bgtexlayer2 = gl_load_texture("assets/bg_layer2.png")

// Player Ship
let shiptex = gl_load_texture("assets/ships/MainShip.png")
let slightshiptex = gl_load_texture("assets/ships/MainShipSlightDamage.png")
let damagedshiptex = gl_load_texture("assets/ships/MainShipDamage.png")
let verydamagedshiptex = gl_load_texture("assets/ships/MainShipVeryDamage.png")

// Enemy Ships
let enemyshiptex = gl_load_texture("assets/ships/EnemyShip.png")
let enemyshiptex2 = gl_load_texture("assets/ships/EnemyShip2.png")
let enemyshiptex3 = gl_load_texture("assets/ships/EnemyShip3.png")
let bosstex = gl_load_texture("assets/ships/EnemyBoss.png")

let bulletlasertex = gl_load_texture("assets/bullets/01.png")
let crosshairtex = gl_load_texture("assets/crosshair.png")

// Make sure all the textures are loaded and they exist
assert bgtex
assert bgtexlayer1
assert bgtexlayer2

assert shiptex
assert slightshiptex
assert damagedshiptex
assert verydamagedshiptex

assert enemyshiptex
assert enemyshiptex2
assert enemyshiptex3

assert bosstex
assert bulletlasertex
assert crosshairtex

var clicked = false
var focused = false

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
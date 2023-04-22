class Player : Entity
    health = 100.0
    texture:resource<texture>

    def update(bounds):
        let speed = 10
        let dir = xy_f { (gl_button("d") >= 1) - (gl_button("a") >= 1),
                        (gl_button("s") >= 1) - (gl_button("w") >= 1) }
        let newpos = pos + normalize(dir) * gl_delta_time() * speed
        if not any(abs(newpos) > bounds):
            pos = newpos
        let tomouse = normalize(gl_local_mouse_pos(0) - pos)
        renderEntity(tomouse, xy{1.0,1.0}, texture)
        return tomouse

    def damage(amount):
        health -= amount
        if health <= 0.0:
            health = 0.0
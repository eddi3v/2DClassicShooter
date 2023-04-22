class Bullet : Entity
    dir:xy_f
    alive = true
    texture:resource<texture>

    def update(maxdist):
        let bulletspeed = 15
        pos += dir * gl_delta_time() * bulletspeed
        gl_translate pos:
            gl_rotate_z dir:
                gl_set_primitive_texture(0, texture)
                gl_rect(xy { 0.5, 0.5 }, 1)
        if magnitude(pos) > maxdist:
            alive = false
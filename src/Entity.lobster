class Entity:
    pos:xy_f

    def renderEntity(dir, size:xy_f, tex:resource<texture>):
        gl_translate pos:
            gl_rotate_z dir:
                gl_set_primitive_texture(0, tex)
                gl_rect(size, 1)
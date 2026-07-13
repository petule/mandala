require_relative '../mandala_node'

class FloorNode < MandalaNode
  def initialize(x, y, z, rot_z, w, d, color, circle: false, texture_key: nil)
    super(x, y, z, rot_z, w, d, color)
    @circle      = circle
    @texture_key = texture_key
  end

  private

  def draw(app, _wall_h, textures)
    if @circle
      r   = @w / 2.0
      tex = @texture_key && textures[@texture_key]
      if tex
        app.fill(255)
        app.texture_mode(1)
        app.begin_shape
        app.texture(tex)
        app.vertex(-r, -r, 0.0, 0.0, 0.0)
        app.vertex( r, -r, 0.0, 1.0, 0.0)
        app.vertex( r,  r, 0.0, 1.0, 1.0)
        app.vertex(-r,  r, 0.0, 0.0, 1.0)
        app.end_shape(2)
      else
        app.begin_shape
        60.times do |i|
          a = Math::PI * 2.0 * i / 60
          app.vertex(r * Math.cos(a), r * Math.sin(a), 0.0)
        end
        app.end_shape(2)
      end
    else
      app.box(@w, @d, 3)
    end
  end
end

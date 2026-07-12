require_relative '../mandala_node'

class FloorNode < MandalaNode
  def initialize(x, y, z, rot_z, w, d, color, circle: false)
    super(x, y, z, rot_z, w, d, color)
    @circle = circle
  end

  private

  def draw(app, _wall_h, _textures)
    if @circle
      slices = 60
      r = @w / 2.0
      app.begin_shape
      slices.times do |i|
        a = Math::PI * 2.0 * i / slices
        app.vertex(r * Math.cos(a), r * Math.sin(a), 0)
      end
      app.end_shape(2)
    else
      app.box(@w, @d, 3)
    end
  end
end

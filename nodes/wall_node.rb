require_relative '../mandala_node'

class WallNode < MandalaNode
  def initialize(x, y, z, rot_z, w, d, color, max_h: Float::INFINITY)
    super(x, y, z, rot_z, w, d, color)
    @max_h = max_h
  end

  private

  def draw(app, wall_h, _textures)
    h = [[wall_h, 2.0].max, @max_h].min
    app.push_matrix
    app.translate(0, 0, h / 2.0)
    app.box(@w, @d, h)
    app.pop_matrix
  end
end

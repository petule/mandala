class MandalaNode
  attr_accessor :children

  def initialize(x, y, z, rot_z, w, d, color = [180, 50, 50])
    @x, @y, @z = x, y, z
    @rot_z  = rot_z
    @w      = w
    @d      = d
    @color  = color
    @children = []
  end

  def add_child(node)
    @children << node
  end

  def render(app, wall_h, textures = {})
    app.push_matrix
    app.translate(@x, @y, @z)
    app.rotate_z(@rot_z)
    app.fill(*@color)
    app.no_stroke
    draw(app, wall_h, textures)
    @children.each { |c| c.render(app, wall_h, textures) }
    app.pop_matrix
  end

  private

  def draw(app, wall_h, textures); end
end

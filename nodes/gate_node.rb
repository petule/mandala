require_relative '../mandala_node'

class GateNode < MandalaNode
  attr_accessor :gate_angle

  def initialize(x, y, z, rot_z, w, d, color)
    super
    @gate_angle = Math::PI / 2.0
  end

  private

  def draw(app, _wall_h, _textures)
    tier_h = @d / 3.0
    depth  = 8.0
    gap    = @w

    app.push_matrix
    app.rotate_x(-@gate_angle)

    # Two vertical posts framing the opening
    [-1, 1].each do |side|
      app.push_matrix
      app.translate(side * gap / 2.0, 0, @d / 2.0)
      app.box(2.0, depth, @d)
      app.pop_matrix
    end

    # Top lintel across the opening
    app.push_matrix
    app.translate(0, 0, @d - 2.0)
    app.box(gap, depth, 4.0)
    app.pop_matrix

    # Three tiers — only wings extending beyond the opening, centre stays open
    3.times do |i|
      full_w = gap * (1.0 + i * 0.6)
      wing_w = (full_w - gap) / 2.0
      next if wing_w <= 0
      z = i * tier_h + tier_h / 2.0
      [-1, 1].each do |side|
        app.push_matrix
        app.translate(side * (gap / 2.0 + wing_w / 2.0), 0, z)
        app.box(wing_w, depth, tier_h)
        app.pop_matrix
      end
    end

    app.pop_matrix
  end
end

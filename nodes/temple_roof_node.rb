require_relative '../mandala_node'

class TempleRoofNode < MandalaNode
  PLATFORM_COLOR = [140, 155, 175].freeze
  EAVE_COLOR     = [125, 140, 160].freeze
  BRACKET_COLOR  = [200, 155,  50].freeze
  RED_COLOR      = [195,  40,  35].freeze
  WINDOW_COLOR   = [60,   90, 160].freeze
  ROOF_COLOR     = [110,  75,  35].freeze
  SPHERE_COLOR   = [ 80, 130, 210].freeze

  DESCENT_AMOUNT = 350.0

  attr_accessor :roof_progress

  def initialize(x, y, z, scale: 100, rot_y_deg: 0, color_roof: ROOF_COLOR)
    super(x, y, z, 0, 0, 0, PLATFORM_COLOR)
    @s             = scale.to_f
    @rot_y         = rot_y_deg * Math::PI / 180.0
    @color_roof    = color_roof
    @roof_progress = 0.0
  end

  def render(app, wall_h, textures = {})
    return if @roof_progress <= 0.0
    progress = [@roof_progress.to_f, 1.0].min
    app.push_matrix
    app.translate(@x.to_f, @y.to_f, @z.to_f + (1.0 - progress) * DESCENT_AMOUNT)
    app.rotate_z(@rot_z.to_f)
    app.no_stroke
    draw(app, wall_h, textures)
    @children.each { |c| c.render(app, wall_h, textures) }
    app.pop_matrix
  end

  private

  def draw(app, _wall_h, _textures)
    app.rotate_y(@rot_y)
    draw_platform(app)
    draw_brackets(app)
    draw_lower_eave(app)
    draw_red_body(app)
    draw_upper_eave(app)
    draw_hip_roof(app)
    draw_finial(app)
  end

  def draw_platform(app)
    app.fill(*PLATFORM_COLOR)
    box_at(app, 0, 0, 0.06 * @s,  3.1 * @s, 3.1 * @s, 0.12 * @s)
  end

  def draw_brackets(app)
    app.fill(*BRACKET_COLOR)
    bw = 2.85 * @s
    bh = 0.08 * @s
    bt = 0.14 * @s
    z  = 0.16 * @s
    [ [0,          bw / 2.0,  bw, bt],
      [0,         -bw / 2.0,  bw, bt],
      [ bw / 2.0,  0,          bt, bw],
      [-bw / 2.0,  0,          bt, bw] ].each do |ox, oy, w, d|
      box_at(app, ox, oy, z, w, d, bh)
    end
  end

  def draw_lower_eave(app)
    app.fill(*EAVE_COLOR)
    box_at(app, 0, 0, 0.26 * @s,  2.7 * @s, 2.7 * @s, 0.10 * @s)
  end

  def draw_red_body(app)
    # rectangle — wider in x, shorter in y
    app.fill(*RED_COLOR)
    box_at(app, 0, 0, 0.61 * @s,  1.5 * @s, 0.8 * @s, 0.5 * @s)
    app.fill(*WINDOW_COLOR)
    hw_y = 0.40 * @s
    hw_x = 0.75 * @s
    ww   = 0.28 * @s
    wh   = 0.18 * @s
    wd   = 0.04 * @s
    wz   = 0.60 * @s
    [ [0, hw_y], [0, -hw_y] ].each do |ox, oy|
      box_at(app, ox, oy, wz, ww, wd, wh)
    end
    [ [hw_x, 0], [-hw_x, 0] ].each do |ox, oy|
      box_at(app, ox, oy, wz, wd, ww, wh)
    end
  end

  def draw_upper_eave(app)
    app.fill(*EAVE_COLOR)
    box_at(app, 0, 0, 0.90 * @s,  1.72 * @s, 1.72 * @s, 0.09 * @s)
  end

  def draw_hip_roof(app)
    app.fill(*@color_roof)
    draw_frustum(app, 0.95 * @s, 1.08 * @s, 0.86 * @s, 0.62 * @s)
    draw_frustum(app, 1.08 * @s, 1.24 * @s, 0.62 * @s, 0.60 * @s)
    box_at(app, 0, 0, 1.30 * @s, 1.30 * @s, 1.30 * @s, 0.12 * @s)
  end

  def draw_frustum(app, base_z, top_z, bh, th)
    [
      [[-bh,  bh], [ bh,  bh], [ th,  th], [-th,  th]],
      [[ bh, -bh], [-bh, -bh], [-th, -th], [ th, -th]],
      [[-bh,  bh], [-bh, -bh], [-th, -th], [-th,  th]],
      [[ bh, -bh], [ bh,  bh], [ th,  th], [ th, -th]],
    ].each do |pts|
      app.begin_shape
      pts.each_with_index do |(x, y), i|
        app.vertex(x, y, i < 2 ? base_z : top_z)
      end
      app.end_shape(2)
    end
    app.begin_shape
    app.vertex(-th, -th, top_z)
    app.vertex( th, -th, top_z)
    app.vertex( th,  th, top_z)
    app.vertex(-th,  th, top_z)
    app.end_shape(2)
  end

  def draw_finial(app)
    app.fill(*SPHERE_COLOR)
    app.push_matrix
    app.translate(0, 0, 1.48 * @s)
    app.sphere(0.1 * @s)
    app.pop_matrix
  end

  def box_at(app, x, y, z, w, d, h)
    app.push_matrix
    app.translate(x, y, z)
    app.box(w, d, h)
    app.pop_matrix
  end
end

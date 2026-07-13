require_relative '../mandala_node'

class SyllableNode < MandalaNode
  RISE_AMOUNT = 60.0

  attr_accessor :syllable_progress

  def initialize(x, y, z, rot_z, w, h, texture_key)
    super(x, y, z, rot_z, w, h, [255, 255, 255])
    @texture_key       = texture_key
    @hw                = w.to_f / 2.0
    @ch                = h.to_f
    @syllable_progress = 0.0
  end

  def render(app, wall_h, textures = {})
    return if @syllable_progress <= 0.0
    progress = [@syllable_progress.to_f, 1.0].min
    app.push_matrix
    app.translate(@x.to_f, @y.to_f, @z.to_f - (1.0 - progress) * RISE_AMOUNT)
    app.rotate_z(@rot_z.to_f)
    app.fill(*@color)
    app.no_stroke
    draw(app, wall_h, textures)
    @children.each { |c| c.render(app, wall_h, textures) }
    app.pop_matrix
  end

  private

  def draw(app, _wall_h, textures)
    tex = textures[@texture_key]
    return unless tex

    tex_aspect  = tex.width.to_f / tex.height
    quad_aspect = @hw * 2.0 / @ch

    if tex_aspect > quad_aspect
      display_hw = @hw
      display_ch = @hw * 2.0 / tex_aspect
    else
      display_ch = @ch
      display_hw = @ch * tex_aspect / 2.0
    end

    z0 = (@ch - display_ch) / 2.0
    z1 = z0 + display_ch

    app.fill(255)
    app.no_stroke
    app.texture_mode(1)
    app.begin_shape
    app.texture(tex)
    app.vertex(0, -display_hw, z1,  0.0, 0.0)
    app.vertex(0,  display_hw, z1,  1.0, 0.0)
    app.vertex(0,  display_hw, z0,  1.0, 1.0)
    app.vertex(0, -display_hw, z0,  0.0, 1.0)
    app.end_shape(2)
  end
end

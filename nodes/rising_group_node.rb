require_relative '../mandala_node'

class RisingGroupNode < MandalaNode
  def initialize(x, y, z, max_height, rise_amount)
    super(x, y, z, 0, 0, 0, [0, 0, 0])
    @max_height  = max_height.to_f
    @rise_amount = rise_amount.to_f
  end

  def render(app, wall_h, textures = {})
    progress = [wall_h / @max_height, 1.0].min
    app.push_matrix
    app.translate(@x.to_f, @y.to_f, @z.to_f - (1.0 - progress) * @rise_amount)
    @children.each { |c| c.render(app, wall_h, textures) }
    app.pop_matrix
  end
end

require_relative '../mandala_node'

class DomeNode < MandalaNode
  attr_accessor :dome_height

  def initialize(x, y, z, rot_z, w, d, color, texture_key, u_repeat: 4, v_repeat: 2)
    super(x, y, z, rot_z, w, d, color)
    @texture_key = texture_key
    @dome_height = 0.0
    @u_repeat    = u_repeat
    @v_repeat    = v_repeat
  end

  private

  def draw(app, _wall_h, textures)
    r_h     = @w
    r_v     = @d
    slices  = 36
    stacks  = 8
    h       = [@dome_height, 2.0].max
    max_lat = Math.asin([h / r_v, 1.0].min)
    u_period = slices / @u_repeat
    v_period = stacks / @v_repeat
    if (tex = textures[@texture_key])
      app.fill(255)
      app.texture_mode(1)
      stacks.times do |i|
        lat0 = max_lat * i.to_f / stacks
        lat1 = max_lat * (i + 1).to_f / stacks
        cos0 = Math.cos(lat0); sin0 = Math.sin(lat0)
        cos1 = Math.cos(lat1); sin1 = Math.sin(lat1)
        v_tile = i % v_period
        v0 = 1.0 - v_tile.to_f / v_period
        v1 = 1.0 - (v_tile + 1).to_f / v_period
        slices.times do |j|
          lon0 = Math::PI * 2.0 * j / slices
          lon1 = Math::PI * 2.0 * (j + 1) / slices
          u_tile = j % u_period
          u0 = u_tile.to_f / u_period
          u1 = (u_tile + 1).to_f / u_period
          app.begin_shape
          app.texture(tex)
          app.vertex(r_h * cos0 * Math.cos(lon0), r_h * cos0 * Math.sin(lon0), r_v * sin0, u0, v0)
          app.vertex(r_h * cos0 * Math.cos(lon1), r_h * cos0 * Math.sin(lon1), r_v * sin0, u1, v0)
          app.vertex(r_h * cos1 * Math.cos(lon1), r_h * cos1 * Math.sin(lon1), r_v * sin1, u1, v1)
          app.vertex(r_h * cos1 * Math.cos(lon0), r_h * cos1 * Math.sin(lon0), r_v * sin1, u0, v1)
          app.end_shape(2)
        end
      end
    else
      slices.times do |j|
        lon0 = Math::PI * 2.0 * j / slices
        lon1 = Math::PI * 2.0 * (j + 1) / slices
        app.begin_shape
        app.vertex(r_h * Math.cos(lon0), r_h * Math.sin(lon0), 0)
        app.vertex(r_h * Math.cos(lon1), r_h * Math.sin(lon1), 0)
        app.vertex(r_h * Math.cos(lon1), r_h * Math.sin(lon1), h)
        app.vertex(r_h * Math.cos(lon0), r_h * Math.sin(lon0), h)
        app.end_shape(2)
      end
    end
  end
end

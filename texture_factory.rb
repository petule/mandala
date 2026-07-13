class TextureFactory
  # X-quadrant tints: [r, g, b, opacity] — applied as linear mix over green texture
  QUADRANT_TINTS = {
    north: [220,  50,  70, 0.70],   # red/pink
    west:  [255, 195,   0, 0.65],   # golden yellow
    east:  [  0,   0,   0, 0.00],   # original green (no tint)
    south: [215, 235, 255, 0.60],   # white-blue (lightens toward clouds)
  }.freeze

  def initialize(app, argb)
    @app  = app
    @argb = argb
  end

  def circle(base_tex, diameter, tile_size)
    r_sq = (diameter / 2.0) ** 2
    cx   = diameter / 2
    img  = @app.create_image(diameter, diameter, @argb)
    base_tex.load_pixels
    img.load_pixels
    tw = base_tex.width
    th = base_tex.height
    diameter.times do |py|
      diameter.times do |px|
        dx = px - cx; dy = py - cx
        if dx * dx + dy * dy <= r_sq
          tx = (px * tw / tile_size.to_f).to_i % tw
          ty = (py * th / tile_size.to_f).to_i % th
          img.pixels[py * diameter + px] = base_tex.pixels[ty * tw + tx]
        else
          img.pixels[py * diameter + px] = 0
        end
      end
    end
    img.update_pixels
    img
  end

  def quadrant(base_tex, diameter, tile_size)
    cx   = diameter / 2
    img  = @app.create_image(diameter, diameter, @argb)
    base_tex.load_pixels
    img.load_pixels
    tw = base_tex.width
    th = base_tex.height
    diameter.times do |py|
      diameter.times do |px|
        dx = px - cx; dy = py - cx
        tx = (px * tw / tile_size.to_f).to_i % tw
        ty = (py * th / tile_size.to_f).to_i % th
        src = base_tex.pixels[ty * tw + tx]
        sr = (src >> 16) & 0xFF
        sg = (src >> 8)  & 0xFF
        sb =  src        & 0xFF
        sa = (src >> 24) & 0xFF

        quad = dy.abs >= dx.abs ? (dy <= 0 ? :north : :south) : (dx < 0 ? :west : :east)
        tr, tg, tb, op = QUADRANT_TINTS[quad]

        rr = [[( sr * (1.0 - op) + tr * op ).to_i, 0].max, 255].min
        rg = [[( sg * (1.0 - op) + tg * op ).to_i, 0].max, 255].min
        rb = [[( sb * (1.0 - op) + tb * op ).to_i, 0].max, 255].min

        pixel = (sa << 24) | (rr << 16) | (rg << 8) | rb
        pixel -= 0x100000000 if pixel > 0x7FFFFFFF
        img.pixels[py * diameter + px] = pixel
      end
    end
    img.update_pixels
    img
  end
end

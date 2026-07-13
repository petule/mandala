require_relative '../mandala_node'

class DiamondThroneNode < MandalaNode
  # tiers bottom → top (largest → smallest)
  TIERS = [
    { w: 104, h:  9 },
    { w:  92, h:  6 },
    { w:  80, h:  6 },
    { w:  68, h:  5 },
    { w:  56, h:  4 },
  ].freeze

  TOTAL_H = TIERS.sum { |t| t[:h] }

  GOLD   = [215, 178, 70]
  SHADOW = [155, 118, 45]
  ACCENT = [185,  50, 30]

  def initialize(x, y, z)
    super(x, y, z, 0, 0, 0, GOLD)
  end

  private

  def draw(app, _wall_h, _textures)
    z_bottom = 0.0
    TIERS.each_with_index do |tier, idx|
      draw_tier(app, tier[:w].to_f, tier[:h].to_f, z_bottom, idx)
      z_bottom += tier[:h]
    end
    draw_base_ornaments(app)
  end

  def draw_tier(app, w, h, z_bottom, idx)
    shade = [
      [GOLD[0] - (TIERS.size - 1 - idx) * 7, 30].max,
      [GOLD[1] - (TIERS.size - 1 - idx) * 5, 30].max,
      [GOLD[2] - (TIERS.size - 1 - idx) * 3, 10].max,
    ]

    app.fill(*shade)
    app.push_matrix
    app.translate(0.0, 0.0, z_bottom + h / 2.0)
    app.box(w, w, h)
    app.pop_matrix

    app.fill(*SHADOW)
    app.push_matrix
    app.translate(0.0, 0.0, z_bottom + h - 0.7)
    app.box(w + 3.0, w + 3.0, 1.4)
    app.pop_matrix
  end

  def draw_base_ornaments(app)
    bw   = TIERS.first[:w].to_f
    bh   = TIERS.first[:h].to_f
    z_bc = bh / 2.0

    app.fill(*ACCENT)
    app.push_matrix
    app.translate(0.0, 0.0, z_bc - bh * 0.15)
    app.box(bw + 2.0, bw + 2.0, bh * 0.3)
    app.pop_matrix

    app.fill(*SHADOW)
    [[-1, -1], [1, -1], [-1, 1], [1, 1]].each do |sx, sy|
      app.push_matrix
      app.translate(sx * (bw / 2.0 - 2.0), sy * (bw / 2.0 - 2.0), z_bc)
      app.box(4.0, 4.0, bh + 1.0)
      app.pop_matrix
    end
  end
end

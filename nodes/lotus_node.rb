require_relative '../mandala_node'

# Generování lotosu
#
# Lotos má dvě části: okvětní lístky a měsíční disk uprostřed.
#
# OKVĚTNÍ LÍSTKY (draw_petals)
# 8 lístků rovnoměrně po kruhu (každý 45° od sebe). Pro každý lístek:
#   pl, pr  — levý a pravý roh základny, leží na inner_r, 22.5° od osy lístku.
#             Sousední lístky sdílejí tyto body → žádné mezery.
#   pt      — špička na outer_r přímo na ose lístku.
#   cp_l, cp_r — kontrolní body Bézierových křivek, také na outer_r.
#
# Tvar lístku = begin_shape se třemi Bézierovými křivkami:
#   1. levá strana:  pl → (cp_l zdvojený) → pt   (kvadratická křivka)
#   2. pravá strana: pt → (cp_r zdvojený) → pr   (symetricky)
#   3. základna:     pr → bc1, bc2 → pl           (oblouk podél inner_r,
#                                                   kubická aproximace 45° oblouku)
#
# 3D tloušťka: horní plocha na z=PETAL_THICKNESS, spodní na z=0,
# boční hrany aproximovány vzorkováním Bézierových křivek.
#
# MĚSÍČNÍ DISK (draw_moon_disk)
# Bílá elipsa o průměru inner_r * 2 — zakryje střed kde se základny sbíhají.

class LotusNode < MandalaNode
  PETAL_COUNT     = 8
  PETAL_THICKNESS = 4.0
  TWO_PI = Math::PI * 2.0
  THETA  = Math::PI / 8.0                              # 22.5° — each petal spans exactly 45°
  ARC_K  = (4.0 / 3.0) * Math.tan(Math::PI / 16.0)   # bezier handle for 45° circular arc

  # cardinal dot colors: petal index → RGB (right, front, left, back)
  CARDINAL_DOTS = {
    0 => [  0, 180,  80],   # right → green
    2 => [  0, 100, 220],   # front → blue
    4 => [255, 215,   0],   # left  → yellow
    6 => [255, 255, 255],   # back  → white
  }.freeze

  # pastel rainbow: HSV(hue, 0.3, 1.0) — 8 evenly spaced hues, mainly white
  PETAL_COLORS = [
    [255, 179, 179],  # red
    [255, 236, 179],  # orange
    [217, 255, 179],  # yellow-green
    [179, 255, 198],  # green
    [179, 255, 255],  # cyan
    [179, 198, 255],  # blue
    [217, 179, 255],  # violet
    [255, 179, 236],  # pink
  ].freeze

  attr_accessor :syllable_progress

  def initialize(x, y, z, inner_r, outer_r, color)
    super(x, y, z, 0, outer_r - inner_r, inner_r, color)
    @inner_r          = inner_r.to_f
    @outer_r          = outer_r.to_f
    @syllable_progress = 0.0
  end

  private

  def draw(app, _wall_h, _textures)
    draw_petals(app)
    draw_petal_dots(app)
    draw_moon_disk(app)
    app.fill(*@color)
    app.no_stroke
  end

  def draw_petals(app)
    th    = PETAL_THICKNESS
    h_arc = ARC_K * @inner_r
    app.stroke(255, 215, 0)
    app.stroke_weight(1.5)

    PETAL_COUNT.times do |i|
      a = TWO_PI * i / PETAL_COUNT
      app.fill(*PETAL_COLORS[i])

      # base corners sit exactly on the inner circle, 22.5° either side of petal axis
      pl   = [Math.cos(a - THETA) * @inner_r, Math.sin(a - THETA) * @inner_r]
      pr   = [Math.cos(a + THETA) * @inner_r, Math.sin(a + THETA) * @inner_r]
      pt   = [Math.cos(a) * @outer_r,          Math.sin(a) * @outer_r]

      # control points at outer_r — petal sides converge to a sharp tip
      cp_l = [Math.cos(a - THETA) * @outer_r, Math.sin(a - THETA) * @outer_r]
      cp_r = [Math.cos(a + THETA) * @outer_r, Math.sin(a + THETA) * @outer_r]

      # base arc: cubic bezier approximation of 45° arc on inner circle
      bc1 = [pr[0] + h_arc * Math.sin(a + THETA), pr[1] - h_arc * Math.cos(a + THETA)]
      bc2 = [pl[0] - h_arc * Math.sin(a - THETA), pl[1] + h_arc * Math.cos(a - THETA)]

      # top face
      app.begin_shape
      app.vertex(pl[0], pl[1], th)
      app.bezier_vertex(cp_l[0], cp_l[1], th, cp_l[0], cp_l[1], th, pt[0], pt[1], th)
      app.bezier_vertex(cp_r[0], cp_r[1], th, cp_r[0], cp_r[1], th, pr[0], pr[1], th)
      app.bezier_vertex(bc1[0], bc1[1], th, bc2[0], bc2[1], th, pl[0], pl[1], th)
      app.end_shape(2)

      # bottom face (reversed winding so normal faces down)
      app.begin_shape
      app.vertex(pl[0], pl[1], 0)
      app.bezier_vertex(bc2[0], bc2[1], 0, bc1[0], bc1[1], 0, pr[0], pr[1], 0)
      app.bezier_vertex(cp_r[0], cp_r[1], 0, cp_r[0], cp_r[1], 0, pt[0], pt[1], 0)
      app.bezier_vertex(cp_l[0], cp_l[1], 0, cp_l[0], cp_l[1], 0, pl[0], pl[1], 0)
      app.end_shape(2)

      # side edges: approximate each bezier segment with small quads
      draw_petal_edge(app, pl,  cp_l, cp_l, pt,  th, 4)   # left side
      draw_petal_edge(app, pt,  cp_r, cp_r, pr,  th, 4)   # right side
      draw_petal_edge(app, pr,  bc1,  bc2,  pl,  th, 4)   # base arc
    end
  end

  # sample the cubic bezier and connect z=th to z=0 with quads
  def draw_petal_edge(app, p0, p1, p2, p3, th, n = 8)
    pts = (0..n).map { |k| bezier_pt(p0, p1, p2, p3, k.to_f / n) }
    pts.each_cons(2) do |qa, qb|
      app.begin_shape
      app.vertex(qa[0], qa[1], th)
      app.vertex(qb[0], qb[1], th)
      app.vertex(qb[0], qb[1], 0)
      app.vertex(qa[0], qa[1], 0)
      app.end_shape(2)
    end
  end

  def bezier_pt(p0, p1, p2, p3, t)
    mt = 1.0 - t
    [
      mt**3 * p0[0] + 3 * mt**2 * t * p1[0] + 3 * mt * t**2 * p2[0] + t**3 * p3[0],
      mt**3 * p0[1] + 3 * mt**2 * t * p1[1] + 3 * mt * t**2 * p2[1] + t**3 * p3[1],
    ]
  end

  def draw_petal_dots(app)
    alpha = ((1.0 - [@syllable_progress.to_f / 0.2, 1.0].min) * 255).to_i
    return if alpha <= 0

    mid_r = (@inner_r + @outer_r) / 2.0
    app.no_stroke
    CARDINAL_DOTS.each do |i, color|
      a = TWO_PI * i / PETAL_COUNT
      app.fill(color[0], color[1], color[2], alpha)
      app.push_matrix
      app.translate(0, 0, PETAL_THICKNESS + 0.1)
      app.ellipse(Math.cos(a) * mid_r, Math.sin(a) * mid_r, 6.0, 6.0)
      app.pop_matrix
    end
  end

  def draw_moon_disk(app)
    app.fill(255, 255, 255)
    app.stroke(255, 215, 0)
    app.stroke_weight(2)
    app.push_matrix
    app.translate(0, 0, PETAL_THICKNESS)
    app.ellipse(0, 0, @inner_r * 2.5, @inner_r * 2.5)
    app.pop_matrix
  end
end

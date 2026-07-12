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
# MĚSÍČNÍ DISK (draw_moon_disk)
# Bílá elipsa o průměru inner_r * 2 — zakryje střed kde se základny sbíhají.
#
# Pořadí kreslení: nejdřív lístky, pak disk přes ně.

class LotusNode < MandalaNode
  PETAL_COUNT = 8
  TWO_PI = Math::PI * 2.0
  THETA  = Math::PI / 8.0                              # 22.5° — each petal spans exactly 45°
  ARC_K  = (4.0 / 3.0) * Math.tan(Math::PI / 16.0)   # bezier handle for 45° circular arc

  def initialize(x, y, z, inner_r, outer_r, color)
    super(x, y, z, 0, outer_r - inner_r, inner_r, color)
    @inner_r = inner_r.to_f
    @outer_r = outer_r.to_f
  end

  private

  def draw(app, _wall_h, _textures)
    draw_petals(app)
    draw_moon_disk(app)
    app.fill(*@color)
    app.no_stroke
  end

  def draw_petals(app)
    h_arc = ARC_K * @inner_r
    app.stroke(255, 215, 0)
    app.stroke_weight(1.5)

    PETAL_COUNT.times do |i|
      a = TWO_PI * i / PETAL_COUNT

      # base corners sit exactly on the inner circle, 22.5° either side of petal axis
      # adjacent petals share these points → no gaps on the circle
      pl = [Math.cos(a - THETA) * @inner_r, Math.sin(a - THETA) * @inner_r]
      pr = [Math.cos(a + THETA) * @inner_r, Math.sin(a + THETA) * @inner_r]
      pt = [Math.cos(a) * @outer_r,          Math.sin(a) * @outer_r]

      # control points at outer_r, same angles as base corners
      # → petal sides start radially outward then converge to a sharp tip
      cp_l = [Math.cos(a - THETA) * @outer_r, Math.sin(a - THETA) * @outer_r]
      cp_r = [Math.cos(a + THETA) * @outer_r, Math.sin(a + THETA) * @outer_r]

      # base arc: cubic bezier approximation of 45° arc on inner circle (clockwise)
      bc1 = [pr[0] + h_arc * Math.sin(a + THETA), pr[1] - h_arc * Math.cos(a + THETA)]
      bc2 = [pl[0] - h_arc * Math.sin(a - THETA), pl[1] + h_arc * Math.cos(a - THETA)]

      app.begin_shape
      app.vertex(pl[0], pl[1], 0)
      # left side — quadratic bezier (CP repeated) to sharp outer tip
      app.bezier_vertex(cp_l[0], cp_l[1], 0,  cp_l[0], cp_l[1], 0,  pt[0], pt[1], 0)
      # right side — symmetric, back to base
      app.bezier_vertex(cp_r[0], cp_r[1], 0,  cp_r[0], cp_r[1], 0,  pr[0], pr[1], 0)
      # base — arc closing along the inner circle
      app.bezier_vertex(bc1[0], bc1[1], 0,  bc2[0], bc2[1], 0,  pl[0], pl[1], 0)
      app.end_shape
    end
  end

  def draw_moon_disk(app)
    app.fill(255, 255, 255)
    app.stroke(255, 215, 0)
    app.stroke_weight(2)
    app.ellipse(0, 0, @inner_r * 2.5, @inner_r * 2.5)
  end
end

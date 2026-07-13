require_relative 'nodes/floor_node'
require_relative 'nodes/lotus_node'
require_relative 'nodes/wall_node'
require_relative 'nodes/gate_node'
require_relative 'nodes/fire_dome_node'
require_relative 'nodes/vajra_dome_node'
require_relative 'nodes/diamond_throne_node'
require_relative 'nodes/rising_group_node'
require_relative 'nodes/syllable_node'

class MandalaScene
  HALF_PI = (Math::PI / 2.0).freeze
  TWO_PI  = (Math::PI * 2.0).freeze
  T_WALL  = 7.freeze
  Z_LIFT  = 7.freeze

  # petal index → syllable texture key (0=right, 2=front, 4=left, 6=back)
  SYLLABLE_PETALS = {
    2 => :hung,
    0 => :a,
    6 => :om,
    4 => :tram,
  }.freeze

  attr_reader :root, :gates, :fire_dome, :vajra_dome

  def initialize(max_height)
    @max_height = max_height
    @gates = []
    @root = build
  end

  def update_dome(h)
    @fire_dome.dome_height = h
  end

  def update_vajra(h)
    @vajra_dome.dome_height = h
  end

  def update_gates(progress)
    @gates.each_with_index do |gate, i|
      delay = (i % 4) * 0.08
      t = [[progress - delay, 0.0].max / [1.0 - delay, 0.01].max, 1.0].min
      gate.gate_angle = HALF_PI * (1.0 - t)
    end
  end

  def update_gate_push(offset)
    @gates.each { |gate| gate.gate_offset = offset }
  end

  def update_syllables(progress)
    @syllables.each { |s| s.syllable_progress = progress }
    @lotus.syllable_progress = progress
  end

  private

  def build
    root   = FloorNode.new(0, 0, 0, 0, 0, 0, [0, 0, 0])
    root.add_child(FloorNode.new(0, 0, 2, 0, 840, 840, [35, 90, 45], circle: true, texture_key: :green))
    lifted = MandalaNode.new(0, 0, Z_LIFT, 0, 0, 0)
    build_palace(lifted)
    build_inner(lifted)
    build_domes(lifted)
    root.add_child(lifted)
    root
  end

  def build_domes(root)
    @vajra_dome = VajraDomeNode.new(0, 0, 0, 0, 405, @max_height * 3.0, [255, 255, 255])
    root.add_child(@vajra_dome)
    @fire_dome = FireDomeNode.new(0, 0, 0, 0, 420, @max_height * 3.5, [230, 75, 10])
    root.add_child(@fire_dome)
  end

  def build_palace(root)
    [
      [240, [240, 240, 240]],
      [228, [40, 90, 200]],
      [216, [190, 45, 45]],
      [204, [210, 190, 40]],
    ].each do |half, color|
      add_wall_with_gate(root, 0,     -half, 0,       half, T_WALL, color, gate_h: @max_height)
      add_wall_with_gate(root, 0,      half, 0,       half, T_WALL, color, gate_h: @max_height)
      add_wall_with_gate(root, -half,     0, HALF_PI, half, T_WALL, color, gate_h: @max_height)
      add_wall_with_gate(root,  half,     0, HALF_PI, half, T_WALL, color, gate_h: @max_height)
      [[-half, -half], [half, -half], [-half, half], [half, half]].each do |rx, ry|
        root.add_child(WallNode.new(rx, ry, 0, 0, T_WALL, T_WALL, color))
      end
    end
  end

  #vnitrek mandaly
  def build_inner(root)
    root.add_child(FloorNode.new(0, 0, 0, 0, 400, 400, [255, 255, 255], texture_key: :inner))
    rise = RisingGroupNode.new(0, 0, 0, @max_height, DiamondThroneNode::TOTAL_H + 2)
    rise.add_child(DiamondThroneNode.new(0, 0, 0))
    lotus = build_lotus
    rise.add_child(lotus)
    root.add_child(rise)
  end

  def build_lotus
    @lotus    = LotusNode.new(0, 0, DiamondThroneNode::TOTAL_H + 2, 28, 77, [255, 170, 200])
    @syllables = []
    mid_r = (28.0 + 77.0) / 2.0
    # back-to-front order so closer syllables render on top (painter's algorithm with DISABLE_DEPTH_MASK)
    # 6=om(back), 4=tram(left), 0=a(right), hri(center), 2=hung(front)
    [[6, :om, 45, 25], [4, :tram, 80, 50], [0, :a, 45, 25]].each do |petal_i, key, w, h|
      a = TWO_PI * petal_i / LotusNode::PETAL_COUNT
      s = SyllableNode.new(Math.cos(a) * mid_r, Math.sin(a) * mid_r, 0, a, w, h, key)
      @syllables << s
      @lotus.add_child(s)
    end
    [:hri, :hung].each_with_index do |key, i|
      petal_i = i == 0 ? nil : 2
      if petal_i
        a = TWO_PI * petal_i / LotusNode::PETAL_COUNT
        s = SyllableNode.new(Math.cos(a) * mid_r, Math.sin(a) * mid_r, 0, a, 80, 50, key)
      else
        s = SyllableNode.new(0, 0, 0, HALF_PI, 80, 50, key)
      end
      @syllables << s
      @lotus.add_child(s)
    end
    @lotus
  end

  def add_wall_with_gate(root, cx, cy, rot_z, half, t, color, gap = 30, gate_h: @max_height)
    seg = half - gap / 2.0
    off = (half + gap / 2.0) / 2.0

    if rot_z == 0
      dir     = cy <= 0 ? -1 : 1
      adj_seg = seg - t / 2.0
      adj_off = off - t / 4.0
      root.add_child(WallNode.new(cx - adj_off, cy, 0, 0,       adj_seg, t, color))
      root.add_child(WallNode.new(cx + adj_off, cy, 0, 0,       adj_seg, t, color))
      gate_rot = dir < 0 ? Math::PI : 0
      gate = GateNode.new(cx, cy + dir * t / 2.0, 0, gate_rot, gap, gate_h, color)
    else
      dir      = cx <= 0 ? -1 : 1
      root.add_child(WallNode.new(cx, cy - off, 0, HALF_PI, seg, t, color))
      root.add_child(WallNode.new(cx, cy + off, 0, HALF_PI, seg, t, color))
      gate_rot = dir < 0 ? HALF_PI : -HALF_PI
      gate = GateNode.new(cx + dir * t / 2.0, cy, 0, gate_rot, gap, gate_h, color)
    end

    root.add_child(gate)
    @gates << gate
  end
end

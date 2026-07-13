require_relative 'nodes/floor_node'
require_relative 'nodes/lotus_node'
require_relative 'nodes/wall_node'
require_relative 'nodes/gate_node'
require_relative 'nodes/fire_dome_node'
require_relative 'nodes/vajra_dome_node'

class MandalaScene
  HALF_PI = (Math::PI / 2.0).freeze
  TWO_PI  = (Math::PI * 2.0).freeze
  T_WALL = 10.freeze
  Z_LIFT = 10.freeze

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

  private

  def build
    root   = FloorNode.new(0, 0, 0, 0, 0, 0, [0, 0, 0])
    root.add_child(FloorNode.new(0, 0, 2, 0, 840, 840, [35, 90, 45], circle: true, texture_key: :green))
    lifted = MandalaNode.new(0, 0, Z_LIFT, 0, 0, 0)
    build_domes(lifted)
    build_palace(lifted)
    build_inner(lifted)
    root.add_child(lifted)
    root
  end

  def build_domes(root)
    @fire_dome = FireDomeNode.new(0, 0, 0, 0, 420, @max_height * 3.5, [230, 75, 10])
    root.add_child(@fire_dome)
    @vajra_dome = VajraDomeNode.new(0, 0, 0, 0, 405, @max_height * 3.0, [255, 255, 255])
    root.add_child(@vajra_dome)
  end

  def build_palace(root)
    [
      [240, [240, 240, 240]],
      [220, [40, 90, 200]],
      [200, [190, 45, 45]],
      [180, [210, 190, 40]],
    ].each do |half, color|
      gate_h = 395 - half - T_WALL / 2.0
      add_wall_with_gate(root, 0,     -half, 0,       half, T_WALL, color, gate_h: gate_h)
      add_wall_with_gate(root, 0,      half, 0,       half, T_WALL, color, gate_h: gate_h)
      add_wall_with_gate(root, -half,     0, HALF_PI, half, T_WALL, color, gate_h: gate_h)
      add_wall_with_gate(root,  half,     0, HALF_PI, half, T_WALL, color, gate_h: gate_h)
      [[-half, -half], [half, -half], [-half, half], [half, half]].each do |rx, ry|
        root.add_child(WallNode.new(rx, ry, 0, 0, T_WALL, T_WALL, color))
      end
    end
  end

  def build_inner(root)
    root.add_child(FloorNode.new(0, 0, 0, 0, 360, 360, [255, 255, 255], texture_key: :inner))
    build_lotus(root)
  end

  def build_lotus(root)
    # TODO: slabiky na platkach lotosu —  zatim jen tecky udelat a pak textura slabik, matemaricky to nevykreslim ani za dobu trvani vesmiru :(
    root.add_child(LotusNode.new(0, 0, 2, 28, 77, [255, 170, 200]))
  end

  def add_wall_with_gate(root, cx, cy, rot_z, half, t, color, gap = 30, gate_h: @max_height * 1.6)
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

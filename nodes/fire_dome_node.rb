require_relative 'dome_node'

class FireDomeNode < DomeNode
  def initialize(x, y, z, rot_z, w, d, color)
    super(x, y, z, rot_z, w, d, color, :fire, u_repeat: 6, v_repeat: 2)
  end
end

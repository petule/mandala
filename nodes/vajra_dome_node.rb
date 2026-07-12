require_relative 'dome_node'

class VajraDomeNode < DomeNode
  def initialize(x, y, z, rot_z, w, d, color)
    super(x, y, z, rot_z, w, d, color, :vajra, u_repeat: 4, v_repeat: 2)
  end
end

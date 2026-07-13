class CameraFlythrough
  # [duration_frames, cam_x, cam_y, cam_z, rot_x, rot_y]
  SEGMENTS = [
    [180,   0,   0, -850,  1.35, 0.2],
    [220,   0,   0, -480,  0.80, 1.0],
    [200,   0,   0, -280,  0.38, 2.2],
    [180,  50,  20, -150,  0.06, 3.3],
    [200,   0,   0, -220, -0.12, 4.3],
    [220,   0,   0, -650,  1.10, 5.6],
  ].freeze

  attr_reader :active

  def initialize
    @active = false
    @seg    = 0
    @frame  = 0
    @start  = nil
  end

  def toggle(cam_x, cam_y, cam_z, rot_x, rot_y)
    @active = !@active
    return unless @active

    @seg   = 0
    @frame = 0
    @start = [cam_x, cam_y, cam_z, rot_x, rot_y]
  end

  # Returns [cam_x, cam_y, cam_z, rot_x, rot_y], or nil when finished/inactive.
  def update
    return nil unless @active

    seg = SEGMENTS[@seg]
    unless seg
      @active = false
      return nil
    end

    dur, *target = seg
    t = (@frame.to_f / dur).clamp(0.0, 1.0)
    t = t * t * (3.0 - 2.0 * t)

    result = @start.each_with_index.map { |s, i| s + (target[i] - s) * t }

    @frame += 1
    if @frame >= dur
      @start = result.dup
      @seg  += 1
      @frame = 0
      @active = false if @seg >= SEGMENTS.size
    end

    result
  end
end

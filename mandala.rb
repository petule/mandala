require 'propane'
require_relative 'mandala_scene'
require_relative 'texture_factory'

class Mandala < Propane::App
  ANIM_STEP = 2.0.freeze
  SPEED = 6.0.freeze
  def settings
    size(1600, 1200, P3D)
  end

  def setup
    sketch_title '3D Mandala'
    @cam_x, @cam_y, @cam_z = 0.0, 0.0, -250.0
    @rot_x, @rot_y = 1.0, 0.5
    @wall_height  = 0.0
    @max_height   = 100.0
    @gate_push    = 0.0
    @gate_push_max = 20.0
    @vajra_height    = 20.0
    @vajra_max       = @max_height * MandalaScene::VAJRA_H_FACTOR
    @syllable_height = 0.0
    @syllable_max    = @max_height
    @dome_height     = 10.0
    @dome_max        = @max_height * MandalaScene::DOME_H_FACTOR
    @scene        = MandalaScene.new(@max_height)
    raw_green = load_image('textures/green.png')
    tf = TextureFactory.new(self, ARGB)
    @textures = {
      fire:  load_image('textures/fire.jpg'),
      vajra: load_image('textures/vajra.jpeg'),
      green: tf.circle(raw_green, MandalaScene::GREEN_D, 100),
      inner: tf.quadrant(raw_green, 400, 60),
      hung:  load_image('textures/sylabes/hung.png'),
      a:     load_image('textures/sylabes/a.png'),
      om:    load_image('textures/sylabes/om.png'),
      tram:  load_image('textures/sylabes/tram.png'),
      hri:   load_image('textures/sylabes/hri.png'),
    }
  end

  def draw
    background(15)
    lights
    handle_keyboard

    up_held   = key_pressed? && key == CODED && key_code == UP
    down_held = key_pressed? && key == CODED && key_code == DOWN

    if up_held
      if @vajra_height >= @vajra_max
        @dome_height = [@dome_height + ANIM_STEP, @dome_max].min
      elsif @gate_push >= @gate_push_max
        @vajra_height = [@vajra_height + ANIM_STEP, @vajra_max].min
      elsif @syllable_height >= @syllable_max
        @gate_push = [@gate_push + ANIM_STEP, @gate_push_max].min
      elsif @wall_height >= @max_height
        @syllable_height = [@syllable_height + ANIM_STEP, @syllable_max].min
      end
    elsif down_held
      if @dome_height > 0
        @dome_height = [@dome_height - ANIM_STEP, 0.0].max
      elsif @vajra_height > 0
        @vajra_height = [@vajra_height - ANIM_STEP, 0.0].max
      elsif @gate_push > 0
        @gate_push = [@gate_push - ANIM_STEP, 0.0].max
      elsif @syllable_height > 0
        @syllable_height = [@syllable_height - ANIM_STEP, 0.0].max
      end
    end

    @scene.update_vajra(@vajra_height)
    @scene.update_syllables(@syllable_height / @syllable_max)
    @scene.update_dome(@dome_height)
    @scene.update_gates(@wall_height / @max_height)
    @scene.update_gate_push(@gate_push)

    translate(width / 2.0, height / 2.0, 0)
    translate(@cam_x, @cam_y, @cam_z)
    rotate_x(@rot_x)
    rotate_y(@rot_y)

    push_matrix
    fill(135, 195, 215)
    no_stroke
    rect_mode(CENTER)
    rect(0, 0, 900, 900)
    pop_matrix

    @scene.root.render(self, @wall_height, @textures)
  end

  def mouse_dragged
    @rot_x += (mouse_y - pmouse_y) * 0.005
    @rot_y += (mouse_x - pmouse_x) * 0.005
  end

  def handle_keyboard
    return unless key_pressed?

    if key == CODED
      case key_code
      when UP then @wall_height = [@wall_height + ANIM_STEP, @max_height].min
      when DOWN
        if @dome_height <= 0 && @vajra_height <= 0 && @gate_push <= 0 && @syllable_height <= 0
          @wall_height = [@wall_height - ANIM_STEP, 0.0].max
        end
      end
    else
      case key
      when 'w', 'W' then @cam_z += SPEED
      when 's', 'S' then @cam_z -= SPEED
      when 'a', 'A' then @cam_x += SPEED
      when 'd', 'D' then @cam_x -= SPEED
      end
    end
  end
end

Mandala.new
sleep

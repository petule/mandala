require 'propane'
require_relative 'mandala_scene'

class Mandala < Propane::App
  def settings
    size(1600, 1200, P3D)
  end

  def setup
    sketch_title '3D Mandala'
    @cam_x, @cam_y, @cam_z = 0.0, 0.0, -250.0
    @rot_x, @rot_y = 1.0, 0.5
    @wall_height  = 0.0
    @max_height   = 100.0
    @vajra_height = 20.0
    @vajra_max    = @max_height * 3.0
    @dome_height  = 10.0
    @dome_max     = @max_height * 3.5
    @scene        = MandalaScene.new(@max_height)
    @textures = {
      fire:  load_image('textures/fire.jpg'),
      vajra: load_image('textures/vajra.jpeg'),
      green: make_circle_texture(load_image('textures/green.png'), 840, 100)
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
        @dome_height = [@dome_height + 2.0, @dome_max].min
      elsif @wall_height >= @max_height
        @vajra_height = [@vajra_height + 2.0, @vajra_max].min
      end
    end
    if down_held
      if @dome_height > 0
        @dome_height = [@dome_height - 2.0, 0.0].max
      elsif @vajra_height > 0
        @vajra_height = [@vajra_height - 2.0, 0.0].max
      end
    end

    @scene.update_vajra(@vajra_height)
    @scene.update_dome(@dome_height)
    @scene.update_gates(@wall_height / @max_height)

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

  def make_circle_texture(base_tex, diameter, tile_size)
    r_sq = (diameter / 2.0) ** 2
    cx   = diameter / 2
    img  = create_image(diameter, diameter, ARGB)
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

  def handle_keyboard
    speed       = 6.0
    height_step = 2.0
    return unless key_pressed?

    if key == CODED
      case key_code
      when UP then @wall_height = [@wall_height + height_step, @max_height].min
      when DOWN
        if @dome_height <= 0 && @vajra_height <= 0
          @wall_height = [@wall_height - height_step, 0.0].max
        end
      end
    else
      case key
      when 'w', 'W' then @cam_z += speed
      when 's', 'S' then @cam_z -= speed
      when 'a', 'A' then @cam_x += speed
      when 'd', 'D' then @cam_x -= speed
      end
    end
  end
end

Mandala.new
sleep

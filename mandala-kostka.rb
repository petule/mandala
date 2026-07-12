require 'propane'
#https://github.com/ruby-processing/propane-examples
# https://github.com/ruby-processing/propane
class TestKrychle < Propane::App

  def settings
    size(600, 600, P3D)
  end

  def setup
    sketch_title 'Test Krychle'
  end

  def draw
    background(40)
    lights

    translate(width / 2, height / 2, 0)
    rotate_x(frame_count * 0.02)
    rotate_y(frame_count * 0.02)

    fill(200, 50, 50)
    box(150)
  end
end

# Spuštění
TestKrychle.new

# aby proces hned neskončil
sleep
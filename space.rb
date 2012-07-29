require "rubygems"
require "rubygame"

include Rubygame

Rubygame.init



class SpaceShip
    include Sprites::Sprite

    def initialize
        super()

        @image = Surface.load "spaceship.png"
        @rect = @image.make_rect
        @rect.x = 400
        @rect.y = 500
    end

    def move dx, dy
       @rect.x += dx
       @rect.y += dy

       
       screen_size = [800, 600]
       w = screen_size[0] - @rect.w
       h = screen_size[1] - @rect.h

       if @rect.x > w
           @rect.x = w

       elsif @rect.x < 0
           @rect.x = 0

       elsif @rect.y > h
           @rect.y = h

       elsif @rect.y < 0
           @rect.y = 0
       end
    end

    def move_to_pos x, y
        @rect.x = x
        @rect.y = y
    end
end

class Alien
    include Sprites::Sprite

    def initialize x, y
        super()

        @image = Surface.load "alien.png"

        @rect = @image.make_rect
        @rect.x = x
        @rect.y = y
    end


    def move dx, dy
        @rect.x += dx
        @rect.y += dy
    end

    def move_down
        @rect.y += rand(2)
    end

    def on_board w, h
        (0 < @rect.x and @rect.x < w) and (0 < @rect.y and @rect.y < h)
    end
end


class Fire
    include Sprites::Sprite

    def initialize x, y, image
        super()

        @image = Surface.load image

        @rect = @image.make_rect
        @rect.x = x
        @rect.y = y
    end
 end

class LaserFire < Fire

    def initialize x, y
        super x, y, "fire.png"
    end

    def move
        @rect.y -= 1
    end
end

class Bonus
    include Sprites::Sprite

    def initialize x, y
        super()

        @image = Surface.load "bonus.png"

        @rect = @image.make_rect
        @rect.x = x
        @rect.y = y
    end
end

class Map
    attr_accessor :alien
    attr_accessor :bonus
    def initialize alien, bonus
        @alien = alien
        @bonus = bonus
    end
end

class MapGenerator
    attr_accessor :alien
    def initialize n
        @alien = []
        start_y = 300
        pos_x = Array((40..720).step(40))
        (0..n).each do |i|
            k = rand(5) + 1

            line = pos_x.shuffle[0...k] 
            line.each do |item|
                @alien << (Alien.new item, start_y)
            end
            start_y -= rand(100) + 100
        end
    end
end
        
@map_g = MapGenerator.new 20





@clock = Clock.new
@clock.target_framerate = 30
@clock.enable_tick_events



@screen = Screen.open [800, 600]
@event_queue = EventQueue.new


@background = Surface.load "background.png"
@background.blit @screen, [0, 0]


@sprites = Sprites::Group.new
Sprites::UpdateGroup.extend_object @sprites
@player = SpaceShip.new
@sprites << @player

@fires = Sprites::Group.new
Sprites::UpdateGroup.extend_object @fires

@aliens = Sprites::Group.new
Sprites::UpdateGroup.extend_object @aliens

@bonus = Sprites::Group.new
Sprites::UpdateGroup.extend_object @bonus

@map_g.alien.each {|m| @aliens << m}


Rubygame::enable_key_repeat 0.03, 0.03

@screen_size = [800, 600]

@moves = { K_LEFT  => [-10,   0],
           K_RIGHT => [ 10,   0],
           K_UP    => [  0, -10],
           K_DOWN  => [  0,  10]
         }

@points = 0
@killed = 0
@life = 5
#@start_time = time.time()
@ammo = 20
@cycles = 0

TTF.setup
point_size = 15
$font = TTF.new "DejaVuSans-Bold.ttf", point_size

smooth = true
GREEN = [0x00, 0x99, 0x00]
@label = { "points" => 0,
           "killed" => 1,
           "life"   => 2,
           "ammo"   => 3,
           "cycles" => 4
         }


@screen.flip



play = true
while play do

    [@sprites, @fires, @aliens, @bonus].each { |x| x.undraw @screen, @background }

    @event_queue.each do |event|
    case event
        when QuitEvent
            play = false
        when KeyDownEvent
            
            if @moves.include? event.key
                x, y = @moves[event.key]
                @player.move x, y
            end

            case event.key

                when K_Z
                    p1 = [@player.rect.x,      @player.rect.y - 5]
                    p2 = [@player.rect.x + 38, @player.rect.y - 5]

                    left_fire  = LaserFire.new p1[0], p1[1]
                    right_fire = LaserFire.new p2[0], p2[1]

                    @fires << left_fire
                    @fires << right_fire

                when K_Q
                    x = (rand @screen_size[0] - 200) + 100
                    y = (rand @screen_size[1] - 200) + 100 
                    @aliens << (Alien.new x, y)

                when K_W
                    x = (rand @screen_size[0] - 200) + 100
                    y = (rand @screen_size[1] - 200) + 100 
                    @bonus << (Bonus.new x, y)
                    
            end
        end
    end

    @fires.each  { |f| f.move }
    @aliens.each { |a| a.move_down }
    
    [@sprites, @aliens, @bonus, @fires].each { |x| x.draw @screen }


    @label.each do |k, v|
        lab = $font.render_utf8 "%s: %s" %[k, v], smooth, GREEN
        rt = lab.make_rect
        rt.topleft = [1, v * 20]
        lab.blit @screen, rt
    end

    @screen.flip

end

Rubygame.quit


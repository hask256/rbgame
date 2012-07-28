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
    end
end


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


Rubygame::enable_key_repeat 0.03, 0.03

play = true
while play do


    @sprites.undraw @screen, @background

    @event_queue.each do |event|
    case event
        when QuitEvent
            play = false
        when KeyDownEvent
            case event.key
                when K_UP:   @player.move 0, -10
                when K_DOWN: @player.move 0, 10
                when K_LEFT:   @player.move -10, 0
                when K_RIGHT: @player.move 10, 0
            end
        end
    end
    
    @sprites.draw @screen
    @screen.flip

end

Rubygame.quit


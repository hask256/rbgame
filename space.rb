require "rubygems"
require "rubygame"

include Rubygame

class SpaceShip
    include Sprites::Sprite

    def initialize x, y
        super()

        @x = x
        @y = y
        @image = Surface.load "spaceship.png"
        @rect = @image.make_rect
        @rect.x = 400
        @rect.y = 500
    end

    def move dx, dy
       @rect.x = dx
       @rect.y = dy
    end
end

@clock = Clock.new
@clock.target_framerate = 30
@clock.enable_tick_events


@screen = Screen.open [800, 600]
@event_queue = EventQueue.new
@event_queue.enable_new_style_events


@sprites = Sprites::Group.new
Sprites::UpdateGroup.extend_object @sprites
@sprites << (SpaceShip.new 100,100)


play = true
while play do

    @event_queue.each do |event|
        case event
            when Events::QuitRequested
                play = false
        end
    end

    @sprites.draw @screen
    @screen.flip

end


require 'thor/group'
require 'inquirer'
require 'jarvis/questions/create_test'
require 'artii'

module Questions
  # top class
  class Menu < Thor::Group

    def navigation
      system('clear')
      a = Artii::Base.new font: 'slant'
      puts a.asciify('Jarvis').white.on_blue

      menu = [
        'Create test on BlazeMeter',
        'Quit'
      ]
      menu_idx = Ask.list 'Menu', menu

      case menu[menu_idx]
      when 'Create test on BlazeMeter'
        Questions::CreateTest.start
      end
    end

  end
end

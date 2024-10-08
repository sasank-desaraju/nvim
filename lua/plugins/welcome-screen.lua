return {
  -- dashboard to greet
  {
    'goolord/alpha-nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local alpha = require 'alpha'
      local dashboard = require 'alpha.themes.dashboard'

      -- Set header
      -- Headers ASCII text can be made at https://patorjk.com/software/taag/
      -- Using the logo is best handled by making a local variable and passing it to the dashboard.section.header.val as below
      local logo_arasaka = [[
        ⠀⠀⣀⣀⡀⠀⠀⣀⣀⣀⣀⣀⣀⠀⠀⠀⣀⣀⣀⠀⠀⠀⠀⠀⣀⣀⠀⠀⠀⠀⣀⣀⡀⠀⢀⣀⡀⠀⢀⣀⣀⣀⣀⣀⡀⠀⠀
        ⣴⣿⠟⠛⢿⣦⡀⣿⡟⠛⠛⠛⣿⣷⣰⣿⠟⠛⢿⣷⡄⢠⣠⣤⣿⠻⠗⠀⣴⣿⠟⠛⢿⣦⣸⣿⣧⣾⡿⢛⣿⡿⠟⠻⣿⣦⠀
        ⣿⡇⠀⠀⠀⣿⡇⣿⣷⣄⡀⠀⠉⠁⣿⣇⠀⠀⠀⣿⡇⣀⡉⠻⢿⣶⣄⡰⣿⣇⠀⠀⠀⣿⡿⣿⣿⣅⡀⢸⣿⡀⠀⠀⢸⣿⠀
        ⠙⠿⣷⣶⣦⣿⡇⠛⠋⠛⢿⣷⣤⡀⠙⠿⣷⣶⡦⣿⡇⢿⣷⣶⣶⣿⣿⣿⠙⠿⣷⣶⡆⣿⡟⠛⠋⠻⢿⣶⣿⣿⣷⣶⣼⣿
      ]]

      local logo_browndalf = [[

██████╗ ██████╗  ██████╗ ██╗    ██╗███╗   ██╗██████╗  █████╗ ██╗     ███████╗
██╔══██╗██╔══██╗██╔═══██╗██║    ██║████╗  ██║██╔══██╗██╔══██╗██║     ██╔════╝
██████╔╝██████╔╝██║   ██║██║ █╗ ██║██╔██╗ ██║██║  ██║███████║██║     █████╗  
██╔══██╗██╔══██╗██║   ██║██║███╗██║██║╚██╗██║██║  ██║██╔══██║██║     ██╔══╝  
██████╔╝██║  ██║╚██████╔╝╚███╔███╔╝██║ ╚████║██████╔╝██║  ██║███████╗██║     
╚═════╝ ╚═╝  ╚═╝ ╚═════╝  ╚══╝╚══╝ ╚═╝  ╚═══╝╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝     
      ]]

      local logo_ad_astra = [[
,-.----.                                                      ,-.----.                                 
\    /  \             __  ,-.                                 \    /  \             __  ,-.            
|   :    |          ,' ,'/ /|                       .--.--.   |   :    |          ,' ,'/ /|            
|   | .\ :   ,---.  '  | |' |           ,--.--.    /  /    '  |   | .\ :   ,---.  '  | |' | ,--.--.    
.   : |: |  /     \ |  |   ,'          /       \  |  :  /`./  .   : |: |  /     \ |  |   ,'/       \   
|   |  \ : /    /  |'  :  /           .--.  .-. | |  :  ;_    |   |  \ : /    /  |'  :  / .--.  .-. |  
|   : .  |.    ' / ||  | '             \__\/: . .  \  \    `. |   : .  |.    ' / ||  | '   \__\/: . .  
:     |`-''   ;   /|;  : |             ," .--.; |   `----.   \:     |`-''   ;   /|;  : |   ," .--.; |  
:   : :   '   |  / ||  , ;            /  /  ,.  |  /  /`--'  /:   : :   '   |  / ||  , ;  /  /  ,.  |  
|   | :   |   :    | ---'            ;  :   .'   \'--'.     / |   | :   |   :    | ---'  ;  :   .'   \ 
`---'.|    \   \  /                  |  ,     .-./  `--'---'  `---'.|    \   \  /        |  ,     .-./ 
  `---`     `----'                    `--`---'            ___   `---`     `----'          `--`---'     
                  ,---,                                 ,--.'|_                                        
                ,---.'|                                 |  | :,'   __  ,-.                             
                |   | :                       .--.--.   :  : ' : ,' ,'/ /|                             
   ,--.--.      |   | |           ,--.--.    /  /    '.;__,'  /  '  | |' | ,--.--.                     
  /       \   ,--.__| |          /       \  |  :  /`./|  |   |   |  |   ,'/       \                    
 .--.  .-. | /   ,'   |         .--.  .-. | |  :  ;_  :__,'| :   '  :  / .--.  .-. |                   
  \__\/: . ..   '  /  |          \__\/: . .  \  \    `. '  : |__ |  | '   \__\/: . .                   
  ," .--.; |'   ; |:  |          ," .--.; |   `----.   \|  | '.'|;  : |   ," .--.; |                   
 /  /  ,.  ||   | '/  '         /  /  ,.  |  /  /`--'  /;  :    ;|  , ;  /  /  ,.  |                   
;  :   .'   \   :    :|        ;  :   .'   \'--'.     / |  ,   /  ---'  ;  :   .'   \                  
|  ,     .-./\   \  /          |  ,     .-./  `--'---'   ---`-'         |  ,     .-./                  
 `--`---'     `----'            `--`---'                                 `--`---'                      
      ]]

      local logo_ars_longa = [[
                                           ,--,                                                            
                                         ,--.'|                                                            
              __  ,-.                    |  | :     ,---.        ,---,                                     
            ,' ,'/ /|  .--.--.           :  : '    '   ,'\   ,-+-. /  |  ,----._,.                         
   ,--.--.  '  | |' | /  /    '          |  ' |   /   /   | ,--.'|'   | /   /  ' /   ,--.--.               
  /       \ |  |   ,'|  :  /`./          '  | |  .   ; ,. :|   |  ,"' ||   :     |  /       \              
 .--.  .-. |'  :  /  |  :  ;_            |  | :  '   | |: :|   | /  | ||   | .\  . .--.  .-. |             
  \__\/: . .|  | '    \  \    `.         '  : |__'   | .; :|   | |  | |.   ; ';  |  \__\/: . .             
  ," .--.; |;  : |     `----.   \        |  | '.'|   :    ||   | |  |/ '   .   . |  ," .--.; |             
 /  /  ,.  ||  , ;    /  /`--'  /        ;  :    ;\   \  / |   | |--'   `---`-'| | /  /  ,.  |             
;  :   .'   \---'    '--'.     /         |  ,   /  `----'  |   |/       .'__/\_: |;  :   .'   \            
|  ,     .-./          `--'---'           ---`-'           '---'        |   :    :|  ,     .-./            
 `--`---'            ___                                                 \   \  /  `--`---'                
            ,--,   ,--.'|_                        ,---,                   `--`-'       ,--,                
          ,--.'|   |  | :,'                     ,---.'|     __  ,-.                  ,--.'|                
     .---.|  |,    :  : ' :                     |   | :   ,' ,'/ /|             .---.|  |,      .--.--.    
   /.  ./|`--'_  .;__,'  /    ,--.--.           :   : :   '  | |' | ,---.     /.  ./|`--'_     /  /    '   
 .-' . ' |,' ,'| |  |   |    /       \          :     |,-.|  |   ,'/     \  .-' . ' |,' ,'|   |  :  /`./   
/___/ \: |'  | | :__,'| :   .--.  .-. |         |   : '  |'  :  / /    /  |/___/ \: |'  | |   |  :  ;_     
.   \  ' .|  | :   '  : |__  \__\/: . .         |   |  / :|  | ' .    ' / |.   \  ' .|  | :    \  \    `.  
 \   \   ''  : |__ |  | '.'| ," .--.; |         '   : |: |;  : | '   ;   /| \   \   ''  : |__   `----.   \ 
  \   \   |  | '.'|;  :    ;/  /  ,.  |         |   | '/ :|  , ; '   |  / |  \   \   |  | '.'| /  /`--'  / 
   \   \ |;  :    ;|  ,   /;  :   .'   \        |   :    | ---'  |   :    |   \   \ |;  :    ;'--'.     /  
    '---" |  ,   /  ---`-' |  ,     .-./        /    \  /         \   \  /     '---" |  ,   /   `--'---'   
           ---`-'           `--`---'            `-'----'           `----'             ---`-'               
      ]]

      local logo_fortis_fortuna = [[
                               ___                                                                ___                                          
  .--.,                      ,--.'|_    ,--,                         .--.,                      ,--.'|_                                        
,--.'  \   ,---.    __  ,-.  |  | :,' ,--.'|                       ,--.'  \   ,---.    __  ,-.  |  | :,'          ,--,      ,---,              
|  | /\/  '   ,'\ ,' ,'/ /|  :  : ' : |  |,      .--.--.           |  | /\/  '   ,'\ ,' ,'/ /|  :  : ' :        ,'_ /|  ,-+-. /  |             
:  : :   /   /   |'  | |' |.;__,'  /  `--'_     /  /    '          :  : :   /   /   |'  | |' |.;__,'  /    .--. |  | : ,--.'|'   |  ,--.--.    
:  | |-,.   ; ,. :|  |   ,'|  |   |   ,' ,'|   |  :  /`./          :  | |-,.   ; ,. :|  |   ,'|  |   |   ,'_ /| :  . ||   |  ,"' | /       \   
|  : :/|'   | |: :'  :  /  :__,'| :   '  | |   |  :  ;_            |  : :/|'   | |: :'  :  /  :__,'| :   |  ' | |  . .|   | /  | |.--.  .-. |  
|  |  .''   | .; :|  | '     '  : |__ |  | :    \  \    `.         |  |  .''   | .; :|  | '     '  : |__ |  | ' |  | ||   | |  | | \__\/: . .  
'  : '  |   :    |;  : |     |  | '.'|'  : |__   `----.   \        '  : '  |   :    |;  : |     |  | '.'|:  | : ;  ; ||   | |  |/  ," .--.; |  
|  | |   \   \  / |  , ;     ;  :    ;|  | '.'| /  /`--'  /        |  | |   \   \  / |  , ;     ;  :    ;'  :  `--'   \   | |--'  /  /  ,.  |  
|  : \    `----'   ---'      |  ,   / ;  :    ;'--'.     /         |  : \    `----'   ---'      |  ,   / :  ,      .-./   |/     ;  :   .'   \ 
|  |,'                        ---`-'  |  ,   /   `--'---'          |  |,'                        ---`-'   `--`----'   '---'      |  ,     .-./ 
`--'                                   ---`-'                      `--'                             ___                           `--`---'     
                                               ,---,  ,--,                                        ,--.'|_                                      
                                             ,---.'|,--.'|            ,--,                        |  | :,'                                     
                                             |   | :|  |,           ,'_ /|     .---.              :  : ' :                                     
                                ,--.--.      |   | |`--'_      .--. |  | :   /.  ./|   ,--.--.  .;__,'  /                                      
                               /       \   ,--.__| |,' ,'|   ,'_ /| :  . | .-' . ' |  /       \ |  |   |                                       
                              .--.  .-. | /   ,'   |'  | |   |  ' | |  . ./___/ \: | .--.  .-. |:__,'| :                                       
                               \__\/: . ..   '  /  ||  | :   |  | ' |  | |.   \  ' .  \__\/: . .  '  : |__                                     
                               ," .--.; |'   ; |:  |'  : |__ :  | : ;  ; | \   \   '  ," .--.; |  |  | '.'|                                    
                              /  /  ,.  ||   | '/  '|  | '.'|'  :  `--'   \ \   \    /  /  ,.  |  ;  :    ;                                    
                             ;  :   .'   \   :    :|;  :    ;:  ,      .-./  \   \ |;  :   .'   \ |  ,   /                                     
                             |  ,     .-./\   \  /  |  ,   /  `--`----'       '---" |  ,     .-./  ---`-'                                      
                              `--`---'     `----'    ---`-'                          `--`---'                                                  
      ]]

      -- dashboard.section.header.val = vim.split(logo_arasaka, '\n')
      -- dashboard.section.header.val = vim.split(logo_browndalf, '\n')
      -- dashboard.section.header.val = vim.split(logo_ad_astra, '\n')
      -- dashboard.section.header.val = vim.split(logo_ars_longa, '\n')
      -- dashboard.section.header.val = vim.split(logo_fortis_fortuna, '\n')
      math.randomseed(os.time())
      local chosen_logo = ({ logo_browndalf, logo_ad_astra, logo_ars_longa, logo_fortis_fortuna })[math.random(4)]
      dashboard.section.header.val = vim.split(chosen_logo, '\n')

      -- {
      --   [[=================     ===============     ===============   ========  ========]],
      --   [[\\ . . . . . . .\\   //. . . . . . .\\   //. . . . . . .\\  \\. . .\\// . . //]],
      --   [[||. . ._____. . .|| ||. . ._____. . .|| ||. . ._____. . .|| || . . .\/ . . .||]],
      --   [[|| . .||   ||. . || || . .||   ||. . || || . .||   ||. . || ||. . . . . . . ||]],
      --   [[||. . ||   || . .|| ||. . ||   || . .|| ||. . ||   || . .|| || . | . . . . .||]],
      --   [[|| . .||   ||. _-|| ||-_ .||   ||. . || || . .||   ||. _-|| ||-_.|\ . . . . ||]],
      --   [[||. . ||   ||-'  || ||  `-||   || . .|| ||. . ||   ||-'  || ||  `|\_ . .|. .||]],
      --   [[|| . _||   ||    || ||    ||   ||_ . || || . _||   ||    || ||   |\ `-_/| . ||]],
      --   [[||_-' ||  .|/    || ||    \|.  || `-_|| ||_-' ||  .|/    || ||   | \  / |-_.||]],
      --   [[||    ||_-'      || ||      `-_||    || ||    ||_-'      || ||   | \  / |  `||]],
      --   [[||    `'         || ||         `'    || ||    `'         || ||   | \  / |   ||]],
      --   [[||            .===' `===.         .==='.`===.         .===' /==. |  \/  |   ||]],
      --   [[||         .=='   \_|-_ `===. .==='   _|_   `===. .===' _-|/   `==  \/  |   ||]],
      --   [[||      .=='    _-'    `-_  `='    _-'   `-_    `='  _-'   `-_  /|  \/  |   ||]],
      --   [[||   .=='    _-'          '-__\._-'         '-_./__-'         `' |. /|  |   ||]],
      --   [[||.=='    _-'                                                     `' |  /==.||]],
      --   [[=='    _-'                        N E O V I M                         \/   `==]],
      --   [[\   _-'                                                                `-_   /]],
      --   [[ `''                                                                      ``' ]],
      -- },
      --

      -- "      ████                                              ████      "],
      -- "      ██▓▓██                                          ██  ██      ",
      -- "      ██▓▓▓▓██                                      ██    ██      ",
      -- "  ██████▓▓▓▓▓▓██████████████████████████████████████      ██████  ",
      -- "  ██░░░░░░▓▓▓▓▓▓░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░      ░░░░░░██  ",
      -- "  ██▓▓▒▒▒▒▒▒▓▓▓▓▓▓▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒      ▒▒▒▒▒▒  ██  ",
      -- "  ██▓▓▒▒▒▒▒▒▒▒▓▓▓▓▓▓▒▒▒▒▒▒▒▒▒▒▒▒░░▒▒▒▒▒▒▒▒▒▒▒▒      ░░▒▒▒▒    ██  ",
      -- "  ██░░▓▓▓▓▒▒▒▒▒▒▓▓▓▓▒▒▒▒▒▒▒▒▒▒▒▒░░▒▒▒▒▒▒▒▒▒▒▒▒    ▒▒▒▒▒▒    ░░██  ",
      -- "  ██░░▓▓▓▓▓▓▓▓▒▒▒▒▓▓▒▒▒▒▒▒▒▒▒▒▒▒░░▒▒▒▒▒▒▒▒▒▒▒▒  ▒▒▒▒        ░░██  ",
      -- "  ██░░▒▒▓▓▓▓▓▓▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░▒▒▒▒▒▒▒▒  ▒▒▒▒▒▒        ▒▒░░██  ",
      -- "  ██▒▒▒▒▒▒▓▓▓▓▓▓▒▒▒▒▒▒▓▓▓▓▒▒▒▒▒▒░░▒▒▒▒▒▒    ▒▒▒▒        ▒▒▒▒  ██  ",
      -- "  ██▓▓▓▓▓▓▒▒▒▒▓▓▓▓▒▒▒▒▒▒▓▓▓▓▒▒▒▒░░▒▒▒▒    ▒▒▒▒▒▒    ▒▒▒▒      ██  ",
      -- "  ██░░▓▓▓▓▒▒▒▒▒▒▓▓▒▒▒▒▒▒▒▒▓▓▒▒▒▒░░▒▒    ░░▒▒  ▒▒  ░░▒▒      ░░██  ",
      -- "  ██▒▒▒▒▓▓▓▓▒▒▒▒▒▒▒▒▓▓▒▒▒▒▒▒▓▓    ▒▒  ▒▒▒▒    ▒▒▒▒▒▒      ▒▒  ██  ",
      -- "  ██▓▓▓▓▒▒▓▓▓▓▓▓▒▒▒▒▓▓▓▓▓▓▒▒      ▒▒▒▒▒▒      ▒▒▒▒      ▒▒    ██  ",
      -- "  ██░░▓▓▓▓▒▒▒▒▓▓▒▒▓▓▒▒▒▒▓▓        ▒▒▒▒    ▒▒▒▒  ▒▒  ▒▒▒▒    ░░██  ",
      -- "  ██░░▓▓▓▓▓▓▓▓▒▒▒▒▓▓▒▒▒▒      ░░░░▒▒▒▒  ░░▒▒    ▒▒▒▒        ░░██  ",
      -- "  ██░░▒▒▓▓▓▓▓▓▓▓▒▒▒▒▓▓▓▓    ▒▒▒▒░░  ▒▒▒▒▒▒    ▒▒▒▒        ▒▒░░██  ",
      -- "  ██░░░░░░▓▓▓▓▓▓░░░░░░▓▓  ░░░░      ░░      ░░░░░░      ░░░░░░██  ",
      -- "  ██░░▒▒▒▒▒▒▓▓▓▓░░▒▒▒▒▒▒▒▒▒▒      ░░▒▒    ░░    ▒▒    ░░▒▒▒▒░░██  ",
      -- "  ██░░▓▓▓▓▒▒▒▒▓▓▒▒▓▓▓▓▓▓▒▒    ▒▒░░  ▒▒▒▒▒▒      ▒▒  ▒▒▒▒    ░░██  ",
      -- "  ██░░▒▒▓▓▓▓▓▓▒▒▒▒▒▒▓▓▓▓    ▒▒      ▒▒▒▒      ▒▒▒▒▒▒      ▒▒░░██  ",
      -- "  ██░░▒▒▓▓▓▓▓▓▓▓▒▒▓▓▒▒▓▓  ▒▒      ▒▒▒▒      ▒▒  ▒▒        ▒▒░░██  ",
      -- "  ██░░▒▒▒▒▒▒▓▓▓▓▒▒▓▓▓▓▒▒▒▒    ▒▒░░  ▒▒    ▒▒    ▒▒    ▒▒▒▒▒▒░░██  ",
      -- "  ██░░▒▒▓▓▒▒▒▒▒▒▒▒▓▓▓▓▓▓▒▒  ▒▒      ▒▒▒▒▒▒      ▒▒▒▒▒▒▒▒  ▒▒░░██  ",
      -- "  ██░░▒▒▓▓▓▓▓▓▓▓▒▒▒▒▒▒▓▓  ▒▒      ▒▒▒▒      ▒▒▒▒▒▒        ▒▒░░██  ",
      -- "  ██░░▒▒▒▒▓▓▓▓▓▓▒▒▒▒▒▒▒▒░░    ▒▒░░▒▒▒▒    ░░▒▒  ▒▒      ▒▒▒▒░░██  ",
      -- "  ██░░▒▒▒▒▒▒▒▒▓▓▒▒▓▓▓▓▓▓▒▒  ▒▒      ▒▒▒▒▒▒      ▒▒  ▒▒▒▒▒▒▒▒░░██  ",
      -- "  ██░░▒▒▒▒▓▓▓▓▒▒▒▒▒▒▓▓▓▓  ▒▒      ▒▒▒▒        ▒▒▒▒▒▒    ▒▒▒▒░░██  ",
      -- "  ██░░▒▒▒▒▒▒▓▓▓▓▒▒▒▒▒▒▒▒░░  ▒▒▒▒░░▒▒▒▒    ░░▒▒▒▒      ░░▒▒▒▒░░██  ",
      -- "  ██░░▒▒▒▒▒▒▒▒▓▓▓▓▒▒▓▓▓▓  ▒▒▒▒      ▒▒▒▒▒▒    ▒▒    ▒▒▒▒▒▒▒▒░░██  ",
      -- "  ██░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▓▓▒▒▒▒  ▒▒░░▒▒        ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░██  ",
      -- "  ██░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒  ▒▒▒▒    ▒▒    ░░▒▒▒▒      ▒▒▒▒▒▒▒▒░░██  ",
      -- "  ██░░░░▒▒▒▒▒▒▒▒▓▓▓▓▒▒▒▒▒▒      ░░▒▒▒▒      ▒▒    ▒▒▒▒▒▒▒▒░░░░██  ",
      -- "  ██████░░░░▒▒▒▒▒▒▓▓▒▒▒▒    ▒▒▒▒░░        ▒▒▒▒  ▒▒▒▒▒▒░░░░██████  ",
      -- "        ████░░░░▒▒▒▒▒▒    ░░          ▒▒░░▒▒▒▒▒▒▒▒░░░░████        ",
      -- "            ████░░░░▒▒      ▒▒    ▒▒▒▒▓▓▓▓▓▓▒▒░░░░████            ",
      -- "                ██      ▒▒▒▒▒▒▒▒░░▒▒▒▒▒▒▒▒▓▓▓▓▓▓██                ",
      -- "              ██    ████░░░░▒▒▒▒░░▒▒▒▒░░░░████▓▓▓▓██              ",
      -- "            ██    ██    ████░░░░░░░░░░████    ██▓▓▓▓██            ",
      -- "          ████████          ████░░████          ████████          ",
      -- "                                ██                                "
      -- The above art is from https://textart.sh/topic/anime
      --
      -- [[                                                                       ]],
      -- [[                                                                       ]],
      -- [[                                                                       ]],
      -- [[                                                                       ]],
      -- [[                                                                       ]],
      -- [[                                                                       ]],
      -- [[                                                                       ]],
      -- [[                                                                     ]],
      -- [[       ████ ██████           █████      ██                     ]],
      -- [[      ███████████             █████                             ]],
      -- [[      █████████ ███████████████████ ███   ███████████   ]],
      -- [[     █████████  ███    █████████████ █████ ██████████████   ]],
      -- [[    █████████ ██████████ █████████ █████ █████ ████ █████   ]],
      -- [[  ███████████ ███    ███ █████████ █████ █████ ████ █████  ]],
      -- [[ ██████  █████████████████████ ████ █████ █████ ████ ██████ ]],
      -- [[                                                                       ]],
      -- [[                                                                       ]],
      -- [[                                                                       ]],

      -- Set menu
      dashboard.section.buttons.val = {
        dashboard.button('e', '  > New file', ':ene <BAR> startinsert <CR>'),
        dashboard.button('f', '󰈞  > Find file', ':Telescope find_files<CR>'),
        dashboard.button('r', '  > Recent', ':Telescope oldfiles<CR>'),
        dashboard.button('s', '  > Settings', ':e $MYVIMRC | :cd %:p:h<cr>'),
        dashboard.button('q', '󰅚  > Quit NVIM', ':qa<CR>'),
      }

      local fortune = require 'alpha.fortune'
      dashboard.section.footer.val = fortune {
        fortune_list = {
          { 'We suffer more in imagination than in reality.', '', '- Seneca' },
          { 'So smile would ya? While we still got something to smile about.', '', '- Sargeant AJ Johnson' },
          { 'Learn the rules like a pro, so you can break them like an artist.', '', '- Pablo Picasso' },
          { 'By always thinking unto them.', '', ' - Isaac Newton' },
          { 'We who cut mere stones must always be envisioning cathedrals.', '', "- Medieval quarry workers' creed" },
          -- { 'You otter be proud of yourself!', '', '— 🦦' },
          -- { 'Hello from the otter slide!', '', '— Otterdele' },
          -- { 'To otter space!', '', '— 🦦' },
          -- { "What if I say I'm not like the otters?", '', '— Foo Fighters' },
          -- { 'Nothing is im-paw-sible 🐾', '', '— 🐕' },
        },
      }

      -- Send config to alpha
      alpha.setup(dashboard.opts)
    end,
  },
}

require 'colorize'
require_relative 'lib/xmrpoolsearch.rb'
require 'optparse'
b1 = %q{
 __       __                                                          __                             __                         
|  \     /  \                                                        |  \                           |  \                        
| $$\   /  $$  ______   _______    ______    ______    ______        | $$____   __    __  _______  _| $$_     ______    ______  
| $$$\ /  $$$ /      \ |       \  /      \  /      \  /      \       | $$    \ |  \  |  \|       \|   $$ \   /      \  /      \ 
| $$$$\  $$$$|  $$$$$$\| $$$$$$$\|  $$$$$$\|  $$$$$$\|  $$$$$$\      | $$$$$$$\| $$  | $$| $$$$$$$\\$$$$$$  |  $$$$$$\|  $$$$$$\
| $$\$$ $$ $$| $$  | $$| $$  | $$| $$    $$| $$   \$$| $$  | $$      | $$  | $$| $$  | $$| $$  | $$ | $$ __ | $$    $$| $$   \$$
| $$ \$$$| $$| $$__/ $$| $$  | $$| $$$$$$$$| $$      | $$__/ $$      | $$  | $$| $$__/ $$| $$  | $$ | $$|  \| $$$$$$$$| $$      
| $$  \$ | $$ \$$    $$| $$  | $$ \$$     \| $$       \$$    $$      | $$  | $$ \$$    $$| $$  | $$  \$$  $$ \$$     \| $$      
 \$$      \$$  \$$$$$$  \$$   \$$  \$$$$$$$ \$$        \$$$$$$        \$$   \$$  \$$$$$$  \$$   \$$   \$$$$   \$$$$$$$ \$$      
                                                                                                                                
                                                                                                                                                                                                                                                           
}

b2 = %q{
███    ███  ██████  ███    ██ ███████ ██████   ██████      ██   ██ ██    ██ ███    ██ ████████ ███████ ██████  
████  ████ ██    ██ ████   ██ ██      ██   ██ ██    ██     ██   ██ ██    ██ ████   ██    ██    ██      ██   ██ 
██ ████ ██ ██    ██ ██ ██  ██ █████   ██████  ██    ██     ███████ ██    ██ ██ ██  ██    ██    █████   ██████  
██  ██  ██ ██    ██ ██  ██ ██ ██      ██   ██ ██    ██     ██   ██ ██    ██ ██  ██ ██    ██    ██      ██   ██ 
██      ██  ██████  ██   ████ ███████ ██   ██  ██████      ██   ██  ██████  ██   ████    ██    ███████ ██   ██ 
                                                                                                                                 
}

b3 = %q{
                                                                                      
#    #  ####  #    # ###### #####   ####     #    # #    # #    # ##### ###### #####  
##  ## #    # ##   # #      #    # #    #    #    # #    # ##   #   #   #      #    # 
# ## # #    # # #  # #####  #    # #    #    ###### #    # # #  #   #   #####  #    # 
#    # #    # #  # # #      #####  #    #    #    # #    # #  # #   #   #      #####  
#    # #    # #   ## #      #   #  #    #    #    # #    # #   ##   #   #      #   #  
#    #  ####  #    # ###### #    #  ####     #    #  ####  #    #   #   ###### #    # 
}

b4 = %q{

                                                                          oooo                                    .                      
                                                                          `888                                  .o8                      
ooo. .oo.  .oo.    .ooooo.  ooo. .oo.    .ooooo.  oooo d8b  .ooooo.        888 .oo.   oooo  oooo  ooo. .oo.   .o888oo  .ooooo.  oooo d8b 
`888P"Y88bP"Y88b  d88' `88b `888P"Y88b  d88' `88b `888""8P d88' `88b       888P"Y88b  `888  `888  `888P"Y88b    888   d88' `88b `888""8P 
 888   888   888  888   888  888   888  888ooo888  888     888   888       888   888   888   888   888   888    888   888ooo888  888     
 888   888   888  888   888  888   888  888    .o  888     888   888       888   888   888   888   888   888    888 . 888    .o  888     
o888o o888o o888o `Y8bod8P' o888o o888o `Y8bod8P' d888b    `Y8bod8P'      o888o o888o  `V88V"V8P' o888o o888o   "888" `Y8bod8P' d888b    
                                                                                                                                         
}


banners = [b1,b2,b3,b4].each_with_index.to_a


ban, i = banners
puts ban[0].red

count = 0
options = {}
OptionParser.new do |parser|
  parser.on("--addr [addr]", "input Monero address.") do |a|
    options[:addr] = a
  end
  parser.on("--pt [PT]", "Print table") do |b|
    options[:pt] = true
  end
  parser.on("--gruff [GRUFF]", "create bar graph.") do |b|
    options[:gruff] = true
  end
  parser.on("--total", "Get total") do |b|
    options[:total] = true
  end
  parser.on("--debug", "debug") do |d|
    options[:debug] = true
  end
  parser.on("--pools", "pools") do |pp|
    options[:pools] = true
  end
end.parse!(into: options)

if options[:addr]
    if options[:pt]
        Pools.print_table(options[:addr], options[:debug] || false)
    end
end
if options[:gruff]
    Pools.gruff(options[:addr], options[:debug] || false)
end
if options[:total]
    t = Pools::get_total(options[:addr], options[:debug] || false)
    puts "Total: #{t}"
end
if options[:pools]
    Pools::get_pools(options[:addr], options[:debug] || false)
end
if options.count <= 1
    puts "\nInvalid command. Use ruby search.rb --help\n\n\n".red
end
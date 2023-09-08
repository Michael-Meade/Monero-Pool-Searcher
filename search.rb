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


banners = []
banners << b1
banners << b2
banners << b3
banners << b4

ban = banners.sample
r   = rand(0..5)
if r.even?
    puts ban.to_s.green
else
    puts ban.to_s.red
end

begin
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
    end.parse!
rescue
    puts "\nInvalid command. Use ruby search.rb --help\n\n\n".red if count > 0
    count +=1
end
if options[:addr]
    if options[:pt]
        if options[:debug]
            Pools.print_table(options[:addr], options[:debug])
        else
            Pools.print_table(options[:addr], false)
        end
    end
end
if options[:gruff]
    if options[:debug]
        Pools.gruff(options[:addr], options[:debug])
    else
        Pools.gruff(options[:addr], false)
    end
end
if options[:total]
    if options[:debug]
        t = Pools::get_total(options[:addr], options[:debug])
    else
       t = Pools::get_total(options[:addr], false) 
    end
    puts "Total: #{t}"
end
if options[:pools]
    if options[:debug]
        Pools::get_pools(options[:addr], options[:debug])
    else
        Pools::get_pools(options[:addr], false)
    end
end
if options.count <= 1
    puts "\nInvalid command. Use ruby search.rb --help\n\n\n".red
end
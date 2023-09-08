# frozen_string_literal: true
require 'httparty'
require 'json'
require 'bigdecimal'
require 'gruff'
require 'terminal-table'
require 'nokogiri'
  module Pools
    def self.usd(bal)
        prices= HTTParty.get('https://www.worldcoinindex.com/coin/monero')
        dom = Nokogiri::HTML(prices.body)
        price = dom.css('.coinprice')[0].text
        price = price.gsub(/\r\n?/, "").delete(' ').tr('$','').to_f
        usd   = price * bal
    end
    def self.get_total(addr, debug = false)
        t = 0
        Pools.constants.select do |c|
            k = Pools.const_get(c).new(addr, debug).get
            t += k["total"] if not k.nil?
        end
    return t
    end
    def self.get_pools(addr, debug = false)
        t = 0
        Pools.constants.select do |c|
            k = Pools.const_get(c).new(addr, debug).get
            t += k["total"] if k.to_h.key?("total")
            puts k["name"].to_s + " - " + k["total"].to_s if not k.nil?
        end
        usd = usd(t)
        puts "\n\nTotal: #{t}"
        puts "USD: $#{usd}"
    end
    def self.array(addr, debug = false)
        out = []
        Pools.constants.select do |c|
            k = Pools.const_get(c).new(addr, debug).get
            out << [k["name"], k["total"], k["balance"], k["paid"], k["hashrate"]] if not k.nil?
        end
    return out
    end
    def self.color(num)
        ii = []
        t  = num.times.map { "%06x" % (rand * 0xffffff) }.to_a
        t.each {|i| ii << "##{i}" }
        return ii
      end
    def self.gruff(addr, debug = false)
        out = basic(addr, debug)
        g = Gruff::Bar.new(10000)
        g.title  = @title
        g.colors = color(out.count)
        g.label_formatting = "%.3f"
        g.hide_line_numbers = true
        g.show_labels_for_bar_values = true
        #@g.group_spacing = 15
        out.each do |data|
          g.data(data[0], data[1])
        end
        g.write("pools.png")
    end
    def self.print_table(addr, debug = false)
        t = 0
        out   = array(addr, debug)
        out.each {|i| t += i[1]}
        table = Terminal::Table.new
        table.title    = addr
        table.headings = ["Pool", "Total", "Balance", "Paid", "HashRate"]
        table.rows     = out
        table.style    = {:width => @width, :border => :unicode_round, :alignment => :center }
        puts table
        puts "Total: #{t}"
        usd = usd(t)
        puts "USD: $ #{usd.round(2)}"
    end
    def self.basic(addr, debug)
        o = []
        Pools.constants.select do |c|
            k = Pools.const_get(c).new(addr, debug).get
            o << [k["name"], k["total"]] if not k.nil?
        end
    return o
    end
    class NanoPool
        def initialize(address, debug)
            @address = address
            @debug = debug
        end
        def address
            @address
        end
        def url
            "https://api.nanopool.org/v1/xmr/user/#{address}"
        end
        def get
            begin
                rsp     = HTTParty.get(url).response.body
                main    = JSON.parse(rsp)
                results = {}
                if main["status"] != false || main["error"] != "Account not found"
                    results["balance"]             = main["data"]["balance"]
                    results["paid"]                = main["data"]["paid"]
                    results["hashrate"]            = main["data"]["hashrate"]
                    results["total"]               = main["data"]["balance"].to_f + main["data"]["paid"].to_f
                    results["name"]                = "nanopool"
                end
            return results if !results.empty?
            rescue => e
                puts e if @debug
                results["balance"]  = 0.0
                results["paid"]     = 0.0
                results["total"]    = 0.0
                results["hashrate"] = 0.0
                results["name"]     = "nanopool"
                return results
            end
        end
    end
    class TwoMiners
        def initialize(address, debug)
            @address = address
            @debug   = debug
        end
        def address
            @address
        end
        def url
            "https://xmr.2miners.com/api/accounts/#{address}"
        end
        def get
            begin
                rsp      = HTTParty.get(url).response
                body     = rsp.body
                if rsp.code.to_i != 404                
                    main     = JSON.parse(body)
                    stats    =  main["stats"]
                    results  = {}
                    paid     = stats["paid"].to_f / 1000000000000
                    bal      = stats["balance"].to_f / 1000000000000
                    results["paid"]     =  paid
                    results["balance"]  = bal
                    results["total"]    = bal.to_f + paid.to_f
                    results["hashrate"] = main["hashrate"]
                    results["name"]     = "TwoMiners"
                return results
                end
            rescue => e
                results = {}
                puts e if @debug
                results["balance"]  = 0.0
                results["paid"]     = 0.0
                results["total"]    = 0.0
                results["name"]     = "TwoMiners"
                results["hashrate"] = 0.0
                return results
            end
        end
    end
    class HashVaultPro
        def initialize(address, debug)
            @address = address
            @debug   = debug
        end
        def address
            @address
        end
        def url
            "https://api.hashvault.pro/v3/monero/wallet/#{address}/stats?chart=total&inactivityThreshold=10"
        end
        def get
            begin
                rsp      = HTTParty.get(url).response.body                
                main     = JSON.parse(rsp)
                if !main.has_key?("error")
                        paid     = main["revenue"]["totalPaid"].to_f / 1000000000000
                        bal      = main["revenue"]["confirmedBalance"].to_f / 10000000000000
                        hashrate = main["collective"]["hashRate"]
                        results  = {}
                        results["paid"]     = paid
                        results["balance"]  = bal
                        results["hashrate"] =  hashrate
                        results["name"]     = "HashVaultPro"
                        # paid + balance 
                        results["total"]    = bal.to_f + paid.to_f
                    return results if !results.empty?
                end
            rescue => e
                results = {}
                puts e if @debug
                results["balance"]  = 0.0
                results["paid"]     = 0.0
                results["total"]    = 0.0
                results["name"]     = "HashVaultPro"
                results["hashrate"] = 0.0
                return results
            end
        end
    end
    class ZeroPool
        def initialize(address, debug)
            @address = address
            @debug   = debug
        end
        def address
            @address
        end
        def url
            "https://xmr.zeropool.io:8119/stats_address?address=#{address}"
        end
        def get
            begin
                rsp      = HTTParty.get(url).response.body                
                main     = JSON.parse(rsp)
                results  = {}
                results["name"]     = "xmr.zeropool.io"
                if !main.has_key?("error")
                        paid     = main["revenue"]["totalPaid"].to_f / 1000000000000
                        bal      = main["revenue"]["confirmedBalance"].to_f / 10000000000000
                        hashrate = main["collective"]["hashRate"]
                        results["paid"]     = paid
                        results["balance"]  = bal
                        results["hashrate"] =  hashrate
                        results["name"]     = "xmr.zeropool.io"
                        # paid + balance 
                        results["total"]    = bal.to_f + paid.to_f
                    return results if !results.empty?
                else
                    results["balance"]  = 0.0
                    results["paid"]     = 0.0
                    results["total"]    = 0.0
                    results["hashrate"] = 0.0
                    return results
                end
            rescue => e
                puts e.backtrace  if @debug
                results["balance"]  = 0.0
                results["paid"]     = 0.0
                results["total"]    = 0.0
                results["name"]     = "xmr.zeropool.io"
                results["hashrate"] = 0.0
                return results
            end
        end
    end
    class MineXmr
        def initialize(address, debug)
            @address = address
            @debug   = debug
        end
        def address
            @address
        end
        def url
            "https://minexmr.com/api/pool/get_wid_stats?address=#{address}"
        end
        def get
            begin
                rsp     = HTTParty.get(url).response.body
                main    = JSON.parse(rsp)
                main = main.shift if main.kind_of?(Array)
                if main["error"].to_s != "no workers found"
                    results = {}
                    balance = main["balance"].to_f / 1000000000000
                    paid    = main["paid"].to_f / 1000000000000
                    results["balance"]  = balance
                    results["paid"]     = 
                    results["hashrate"] = main["hashrate"]
                    results["name"]     = "xmrmine.com"
                    results["total"]    = balance.to_f + paid.to_f
                return results
                end
            rescue => e
                results = {}
                puts e if @debug
                results["balance"]  = 0.0
                results["paid"]     = 0.0
                results["total"]    = 0.0
                results["name"]     = "xmrmine.com"
                results["hashrate"] = 0.0
                return results
            end
        end
    end
    class XMRPoolEU
        def initialize(address, debug)
            @address = address
            @debug   = debug
        end
        def address
            @address
        end
        def url
            "https://web.xmrpool.eu:8119/stats_address?address=#{address}&longpoll=false"
        end
        def get
            begin
                rsp     = HTTParty.get(url).response.body
                if !rsp.include?("error")
                    main    = JSON.parse(rsp)["stats"]
                    results = {}
                    bal     = main["balance"].to_f / 1000000000000
                    results["balance"]  = bal
                    if !main.has_key?("paid")
                        results["paid"] = 0
                        paid            = 0
                    else
                        paid    = main["paid"].to_f / 1000000000000
                        results["paid"] = paid
                    end
                    results["hashrate"] = main["hash"]
                    results["total"]    = bal + paid
                    results["name"]     = "xmrpool.eu"
                    return results
                end
            rescue => e
                results = {}
                puts e if @debug
                results["balance"] = 0.0
                results["paid"]    = 0.0
                results["total"]   = 0.0
                results["name"]     = "xmrpool.eu"
                results["hashrate"] = 0.0
                return results
            end
        end
    end
    class XmrGntl
        def initialize(address, debug)
            @address = address
            @debug   = debug
        end
        def address
            @address
        end
        def url
            "https://xmr.gntl.uk/api/miner/#{address}/stats"
        end
        def get
            begin
                rsp      = HTTParty.get(url).response
                body     = rsp.body
                if rsp.code.to_i != 404         
                    main     = JSON.parse(body)
                    results  = {}
                    paid     = main["amtPaid"].to_f / 1000000000000
                    bal      = main["amtDue"].to_f / 1000000000000
                    results["paid"]     =  paid
                    results["balance"]  = bal
                    results["total"]    = bal.to_f + paid.to_f
                    results["hashrate"] = 0.0
                    results["name"]     = "gntl.uk"
                    return results
                end
            rescue => e
                results = {}
                puts e if @debug
                results["amtDue"]     = 0.0
                results["amtPaid"]    = 0.0
                results["total"]      = 0.0
                results["name"]       = "gntl.uk"
                results["hashrate"]   = 0.0
            end
        end
    end
    class Monerod
        def initialize(address, debug)
            @address = address
            @debug   = debug
        end
        def address
            @address
        end
        def url
            "https://np-api.monerod.org/miner/#{address}/stats"
        end
        def get
            begin
                results  = {}
                rsp      = HTTParty.get(url).response
                body     = rsp.body
                results["name"]     = "monerod.org"
                if rsp.code.to_i != 404         
                    main     = JSON.parse(body)
                    paid     = main["amtPaid"].to_f / 1000000000000
                    bal      = main["amtDue"].to_f / 1000000000000
                    results["paid"]     =  paid
                    results["balance"]  = bal
                    results["total"]    = bal.to_f + paid.to_f
                    results["hashrate"] = 0.0
                    
                    return results
                end
            
            rescue => e
                results = {}
                puts e if @debug
                results["amtDue"]     = 0.0
                results["amtPaid"]    = 0.0
                results["total"]      = 0.0
                results["hashrate"]   = 0.0
            end
        end
    end
    class SupportXmr
        def initialize(address, debug)
            @address = address
            @debug   = debug
        end
        def address
            @address
        end
        def url
            "https://supportxmr.com/api/miner/#{address}/stats"
        end
        def get
            begin
                rsp     = HTTParty.get(url).response.body
                main    = JSON.parse(rsp)
                results = {}
                bal     = main["amtDue"] / 1_000_000_000_000
                paid    = main["amtPaid"].to_f /  1000000000000
                results["balance"]  = bal
                results["paid"]     = paid
                results["hashrate"] = main["hash"]
                results["total"]    = bal+paid
                results["name"]     = "supportxmr.com"
                return results
            rescue => e
                results = {}
                puts e if @debug
                results["balance"] = 0.0
                results["paid"]    = 0.0
                results["total"]   = 0.0
                results["name"]     = "supportxmr.com"
                return results
            end
        end
    end
    class MultiPools
        def initialize(address, debug)
            @address = address
            @debug   = debug
        end
        def address
            @address
        end
        def url
            "https://multi-pools.com/api/pools/xmr_solo/miners/#{address}"
        end
        def get
            begin
                rsp     = HTTParty.get(url).response.body
                main    = JSON.parse(rsp)
                results = {}
                bal     = main["totalPaid"] / 1_000_000_000_000
                paid    = main["pendingBalance"].to_f /  1000000000000
                results["balance"]  = bal
                results["paid"]     = paid
                results["hashrate"] = main["hash"]
                results["total"]    = bal+paid
                results["name"]     = "MultiPools.com"
                results["hashrate"] = 0.0
                return results
            rescue => e
                results = {}
                puts e if @debug
                results["balance"] = 0.0
                results["paid"]    = 0.0
                results["total"]   = 0.0
                results["hashrate"] = 0.0
                results["name"]     = "MultiPools.com"
                return results
            end
        end
    end
    class MoneroHash
        def initialize(address, debug)
            @address = address
            @debug   = debug
        end
        def address
            @address
        end
        def url
            "https://monerohash.com/api/stats_address?address=#{address}"
        end
        def get
            begin
                rsp     = HTTParty.get(url).response.body
                main    = JSON.parse(rsp)
                if not main.has_key?("error")
                    results = {}
                    results["name"] = "MoneroHash"
                    if main["payments"].empty?
                        results["total"] = 0
                    end
                return results
                end
            rescue => e
                results = {}
                puts e if @debug
                results["balance"]  = 0.0
                results["paid"]     = 0.0
                results["total"]    = 0.0
                results["name"]     = "monerohash.com"
                results["hashrate"] = 0.0
                return results
            end
        end
    end
    class C3Pool
        def initialize(address, debug)
            @address = address
            @debug   = debug
        end
        def address
            @address
        end
        def url
            "https://api.c3pool.com/miner/#{address}/stats"
        end
        def get
            begin
                rsp     = HTTParty.get(url).response.body
                main    = JSON.parse(rsp)
                results = {}
                bal     = main["amtDue"] / 1_000_000_000_000
                paid    = main["amtPaid"].to_f /  1000000000000
                results["balance"]  = bal
                results["paid"]     = paid
                results["hashrate"] = main["hash"]
                results["total"]    = bal+paid
                results["name"]     = "c3Pool.com"
                return results
            rescue => e
                results = {}
                puts e if @debug
                results["balance"] = 0.0
                results["paid"]    = 0.0
                results["total"]   = 0.0
                results["name"]     = "c3Pool.com"
                return results
            end
        end
    end
end

#https://api.c3pool.com/miner/43ZBkWEBNvSYQDsEMMCktSFHrQZTDwwyZfPp43FQknuy4UD3qhozWMtM4kKRyrr2Nk66JEiTypfvPbkFd5fGXbA1LxwhFZf/stats

#https://monero.herominers.com/api/stats_address?address=43ZBkWEBNvSYQDsEMMCktSFHrQZTDwwyZfPp43FQknuy4UD3qhozWMtM4kKRyrr2Nk66JEiTypfvPbkFd5fGXbA1LxwhFZf&longpoll=false
#"49ubSTdDp9hPmYE7paRM6PZFLmqvsedZ56MXLUT8mvYnTzjVCKGDbpuW4RVdvZon228uWnkjoJN8S6w5S4LdgeK8UBMMEhJ")
#47vcMwEwosJRc4bCAcRRw7WwezTRn8dCHBjTnYXsZG3UR3Eya88PN3rZKexzwJojRMGVexryHmy47NXmNuDyZirWSexaEYv
#4A3UaV5a2kZLd8dNBPDMA7BBhJGyCxcFVip3rJCgnhcciSzempVCwB4AZGf3KNWVeEihAGoF4ZYhhU6bePeEP3eh9ke26P7
#43ZBkWEBNvSYQDsEMMCktSFHrQZTDwwyZfPp43FQknuy4UD3qhozWMtM4kKRyrr2Nk66JEiTypfvPbkFd5fGXbA1LxwhFZf
#https://supportxmr.com/api/miner/43ZBkWEBNvSYQDsEMMCktSFHrQZTDwwyZfPp43FQknuy4UD3qhozWMtM4kKRyrr2Nk66JEiTypfvPbkFd5fGXbA1LxwhFZf/stats
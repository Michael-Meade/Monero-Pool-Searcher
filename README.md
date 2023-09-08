<h1 align="center">Monero Pool Search</h1>
<div align="center">
  
**[Pools that it supports](https://github.com/Michael-Meade/xmr_pools/blob/main/README.md#pools-that-it-currently-supports) • 
[About](https://github.com/Michael-Meade/xmr_pools/blob/main/README.md#About) • 
[Installing gems](https://github.com/Michael-Meade/xmr_pools/blob/main/README.md#Installing-gems) • 
[Installation](https://github.com/Michael-Meade/xmr_pools/blob/main/README.md#Installation) • 
[Build gem](https://github.com/Michael-Meade/xmr_pools/blob/main/README.md#Build-gem) •
[Help](https://github.com/Michael-Meade/xmr_pools/blob/main/README.md#Help-Menu) •
[Adding Pool](https://github.com/Michael-Meade/xmr_pools/blob/main/README.md#Adding-Pool) •
[Screenshots](https://github.com/Michael-Meade/xmr_pools/blob/main/README.md#screenshots) •
[License](https://github.com/Michael-Meade/xmr_pools/blob/main/README.md#License)**
</div>



# Pools currently supported
* supportxmr.com
* minexmr.com
* hashvault.pro
* nanopool.org
* 2miners.com
* MoneroHash.com
* xmrpool.eu
* gntl.uk
* monerod.org
* xmr.zeropool.io
* c3Pool.com

# About
This tool purpose is to allow the user to search a bunch of different Monero mining pools for a certain address. The script will then add up Monero that was mined and display the results. When I dig into files that were dropped on my honey pot, I often run into malware that tries to mine Monero on my honeypot. This script could be used to get a better idea on how much profit the malicious threat actor has made by mining on unauthorized computers.


# Installing gems manually
```ruby
gem install gruff
gem install terminal-table
gem install httparty
gem install colorize
gem install nokogiri
```
Note that if you install the gem all these gems will be automatically installed. 

# Installating

Add this line to your application's Gemfile:

```ruby
gem 'xmrpoolsearch'
```

And then execute:

```ruby
bundle install
```
Or install it yourself as:
```ruby
gem install xmrpoolsearch
```

# Build Gem
```ruby
sudo apt-get install libmagickcore-dev
sudo apt install imagemagick
```
Installing imagemagick. This is needed to create the graphs. 

```ruby
sudo gem build xmrpoolsearch.gemspec
```
This will build the gem form scratch. You might need to delete the current versioned .gem file for the gem to be built. If you do not want to build the gem from scratch you can skip the build command and just use the install command below.  
```ruby
sudo gem install xmrpoolsearch-0.1.0.gem
```
This will install the gem on your system. This is needed to use the code. If you do not want to install the gem you can use the `lib.rb` file. To use, put `require_relative 'lib'` on the first line of file and you can do the same stuff. 


# Build Gem on Windows
Download and install <a href='https://imagemagick.org/script/download.php#windows'>ImageMagick<a/>. In order to install the rmagick gem the imagemagick executable has to be in the system environment path. Next type `environment` in the windows search bar. After the window opens click `Environment Variables`. Highlight the row that says Path and click edit. Click new and enter `C:\Program Files\ImageMagick-7.1.0-Q16-HDRI\magick.exe`. If errors consist replace the file link with the right one in `C:\Program File`. 
  
 Enter `gem install xmrpoolsearch-0.1.1.gem` to install the gem.

# Help Menu
```ruby
ruby search.rb --h
```

# Print Table
```ruby
ruby search.rb --addr 4A3UaV5a2kZLd8dNBPDMA7BBhJGyCxcFVip3rJCgnhcciSzempVCwB4AZGf3KNWVeEihAGoF4ZYhhU6bePeEP3eh9ke26P7 --pt
```

# Save Results in Bar Graph
```ruby
ruby search.rb --addr 4A3UaV5a2kZLd8dNBPDMA7BBhJGyCxcFVip3rJCgnhcciSzempVCwB4AZGf3KNWVeEihAGoF4ZYhhU6bePeEP3eh9ke26P7 --gruff
```

# Get Total
```ruby
ruby search.rb --addr 4A3UaV5a2kZLd8dNBPDMA7BBhJGyCxcFVip3rJCgnhcciSzempVCwB4AZGf3KNWVeEihAGoF4ZYhhU6bePeEP3eh9ke26P7 --total
```
# List Results
```ruby
ruby search.rb --addr 4A3UaV5a2kZLd8dNBPDMA7BBhJGyCxcFVip3rJCgnhcciSzempVCwB4AZGf3KNWVeEihAGoF4ZYhhU6bePeEP3eh9ke26P7 --list
```

# Print table & get total
```ruby
ruby search.rb --addr 4A3UaV5a2kZLd8dNBPDMA7BBhJGyCxcFVip3rJCgnhcciSzempVCwB4AZGf3KNWVeEihAGoF4ZYhhU6bePeEP3eh9ke26P7 --pt --total
```

# Debug
```ruby
ruby search --addr 4A3UaV5a2kZLd8dNBPDMA7BBhJGyCxcFVip3rJCgnhcciSzempVCwB4AZGf3KNWVeEihAGoF4ZYhhU6bePeEP3eh9ke26P7 --debug
```

# Pools
```ruby
ruby search --addr 4A3UaV5a2kZLd8dNBPDMA7BBhJGyCxcFVip3rJCgnhcciSzempVCwB4AZGf3KNWVeEihAGoF4ZYhhU6bePeEP3eh9ke26P7 --pools
```
# Gem usage
```ruby
require  'xmrpoolsearch'
addr = "8ALdP9yTXenfNjgpm5TrRf7TGoBr8aUKU3kQcu7CLzfVJZYMXTohVb85GrRu7dy8PsTYrcisdG9LdMTmkuPRdZN7CnFsVWB"
Pools::get_pools(addr)
Pools::print_table(addr)
```

# Adding Pool

```ruby
class SupportXmr
    def initialize(address)
        @address = address
    end
    def address
        @address
    end
    def url
        "https://supportxmr.com/api/miner/#{address}/stats"
    end
    def get
        rsp     = HTTParty.get(url).response.body
        main    = JSON.parse(rsp)
        results = {}
        bal     = main["amtDue"].to_f / 1000000000000
        paid    = main["amtPaid"].to_f / 1000000000000
        results["balance"]  = bal
        results["paid"]     = paid
        results["hashrate"] = main["hash"]
        results["total"]    = bal + paid
        results["name"]     = "supportxmr.com"
    return results
    end
end
```


# Screenshots
<img src="https://user-images.githubusercontent.com/47438130/148231462-4f57d0bd-16f4-41bc-9be8-0eeb46622591.png" alt="Bar graph of pools"  width="300" height="300"/>
The image above is an example of what the bar graph looks like.

<img src="https://user-images.githubusercontent.com/47438130/148247555-fa95c268-c334-495d-9d38-2c7c367d4492.png" alt="Get total mined"/>
Example of the results when --total is used.

<br>
<img src="https://user-images.githubusercontent.com/47438130/148247851-f5886897-93cc-4934-8889-b2df732ee6e0.png" alt="printing table"/>
Example of the --pt command, which will print the results in a table.
<br>
<img src="https://user-images.githubusercontent.com/47438130/148248098-190bf6c9-eccc-42ab-9cf0-05ef273631b0.png" alt="Using pt and total"/>
The image above shows that the --pt and the --total command can be used together. The total will be printed under the table. 
<br>


# License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).


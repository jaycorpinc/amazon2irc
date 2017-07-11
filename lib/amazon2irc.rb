require "amazon2irc/version"
require 'rss'
require "socket"
require "yaml"
require 'mechanize'
require 'nokogiri'


module Amazon2irc
  class Process
	attr_accessor :conn
	def initialize opts
		@opts = opts
		@items = []
		init_persistent_array
		connect
		wait
		loop do
			scanning if @opts['rss']
			spidering if @opts['spidering']
			write_persistent_array
			sleep @opts['scan-delay']
		end

	end

	def init_persistent_array
		unless File.exist? File.expand_path "store.yml"
			open('store.yml', 'w') {|f| YAML.dump(@items, f)}
		else
			@items = load_persistent_array
		end
		
	end

	def load_persistent_array
		@items = open('store.yml') {|f| YAML.load(f) }
	end

	def write_persistent_array
		open('store.yml', 'w') {|f| YAML.dump(@items, f)}
	end

	def connect
		@conn = TCPSocket.open(@opts['server'], @opts['port'])
		print("addr: ", @conn.addr.join(":"), "\n")
		print("peer: ", @conn.peeraddr.join(":"), "\n")
		@conn.puts "USER testing 0 * Testing"
		@conn.puts "NICK #{@opts['botnick']}"
		@conn.puts "JOIN #{@opts['channel']}"
		@conn.puts "PRIVMSG #{@opts['channel']} :Bot Scanning: #{@opts['keywords'].flatten}"
	end

	def wait
		(1..10).each do |i|
		  msg = @conn.gets
		  puts msg
		end	
	end	


	def scanning
		parse(pullDeals)
		@conn.puts "PRIVMSG #{@opts['channel']} :Bot Scanned: #{@opts['keywords'].flatten}"
	end


	def spidering
		@opts['keywords'].each do |item|
			@conn.puts "PRIVMSG #{@opts['channel']} :Bot Spidering: #{item}"
			AmazonMechanize.scan(item).each do |res|
				unless @items.include? res
					irc_logger2(res)
					@items.push("#{res}")
  					sleep @opts['chat-delay']

				end
			end
			@conn.puts "PRIVMSG #{@opts['channel']} :Bot Spidered: #{item}"
		end

	end

	def pullDeals
		rss = RSS::Parser.parse('https://rssfeeds.s3.amazonaws.com/goldbox', false)
		rss.items
	end

	def parse items
		items.each do |item|
			unless @items.include? "#{item.title}"
				kw_match(item)
		  	end	
		end
	end

	def kw_match item
		@opts['keywords'].each do |kw| 
			if item.title.downcase.include? kw.downcase
  				irc_logger(item)
  				@items.push("#{item.title}")
  				sleep @opts['chat-delay']
  			end
  		end
	end

	def irc_logger item
		@conn.puts "PRIVMSG #{@opts['channel']} :#{item.title} - #{item.link}"	  				
	end

	def irc_logger2 item
		@conn.puts "PRIVMSG #{@opts['channel']} :#{item}/ref=sr_1_2?s=prime-day&psr=PDAY&ie=UTF8&qid=1499752396&sr=1-2&keywords="	  				
	end
 end





class AmazonMechanize
	def self.scan keyword
		begin
			items = []
			agent = Mechanize.new
			agent.max_history = nil # unlimited history
			html = agent.get("https://www.amazon.com/s/ref=nb_sb_noss?url=search-alias%3Dprime-day&field-keywords=#{keyword}")
			
			loop do
					doc = Nokogiri::HTML::Document.parse(html.body)

					doc.xpath('//*[@class="s-item-container"]').each do |item|
						last_title=''
						offer_link=''
						item.css('a').each do |a|
							last_title=a['title'] unless a['title'].to_s.length == 0
							offer_link = a['href'] unless (a.to_s.length == 0 || (a['href'].include?("offer")) || (a['href'].include?("Reviews"))  || (a['href'].include?("void(0)")) || (a['href'].include?("Promotions")) )
						end
						items.push("#{last_title} : #{offer_link}") if last_title.downcase.include? keyword.downcase
					end

					next_page=false
					html.links.each do |l|
						next_page=true if l.text.include? 'Next Page'
						sleep 5 if l.text.include? 'Next Page'
						html = l.click if ((l.text.include? 'Next Page') && (l.href.to_s.length > 10))
						next  if l.text.include? 'Next Page'
					end
				return items if next_page == false
			end
		rescue => error
			puts "Error! #{error}"
			return items
		end
	end
end


end

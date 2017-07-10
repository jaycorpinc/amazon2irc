require "amazon2irc/version"
require 'rss'
require "socket"
require "yaml"


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
			scanning
			write_persistent_array
			sleep @opts['scan-delay']
		end

	end

	def init_persistent_array
		unless File.exist? File.expand_path "store.yml"
			open('store.yml', 'w') {|f| YAML.dump(@items, f)}
		end
		load_persistent_array
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
  end
end

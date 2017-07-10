Install gem: gem install amazon2irc


Demo: 

require 'amazon2irc'

opts = {}

opts['botnick'] = "JayCorpIncRBot"

opts['server'] = "irc.freenode.net"

opts['port'] = "6667"

opts['channel'] = "\#jaycorpinc"

opts['keywords']= [ 'ryzen', 'atx', 'projector', 'x370', 'motherboard', 'atx case', 'm.2', 'projector screen', 'seasonic', 'ddr-3200', '4k']

opts['chat-delay']=1.5

opts['scan-delay']=30

Amazon2irc::Process.new(opts)
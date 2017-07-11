Pulls down Amazon deals via spidering or RSS feed, checks it for keywords, then sends it along to the irc chat specified. Stores previously seen deals with YAML, outputs new deals every 30s (not including chat delay). A quickly hacked Amazon Prime Day helper.

Homepage: https://github.com/jaycorpinc/amazon2irc

Install gem:

`gem install amazon2irc`


Demo: 

`
require 'amazon2irc'

opts = {}

opts['botnick'] = "JayCorpIncRBot"

opts['server'] = "irc.freenode.net"

opts['port'] = "6667"

opts['channel'] = "\#jaycorpinc"

opts['keywords']= [ 'ryzen', 'atx', 'projector', 'x370', 'motherboard', 'atx case', 'm.2', 'projector screen', 'seasonic', 'ddr-3200', '4k']

opts['chat-delay']=1.5

opts['scan-delay']=30

opts['rss']=false

opts['spidering']=true

Amazon2irc::Process.new(opts)
`


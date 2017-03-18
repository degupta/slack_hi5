#!/usr/bin/ruby

require 'rest-client'
require 'json'

base = "https://parsable.slack.com/api/channels.history?channel=#{ENV['SLACK_CHANNEL']}&token=#{ENV['SLACK_TOKEN']}"
ts   = nil

`mkdir -p messages`

i = 1
last_messages = nil
while true
  url = base + (ts ? "&latest=#{ts}" : "")
  
  print "Getting #{i}.json for #{ts} ... "
  json = JSON.parse(RestClient.get(url).body)
  unless json["ok"]
    puts json.to_json
    break
  end
  
  last_messages = json["messages"]
  has_more = json["has_more"]
  ts = last_messages.last["ts"]

  puts "Writing out #{i}.json, Num Messages : #{last_messages.size}, #{has_more}"
  File.open("messages/#{i}.json", 'w') { |file| file.write(json.to_json) }
  i += 1
  break unless has_more
end
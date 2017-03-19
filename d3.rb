#!/usr/bin/ruby

require 'json'


users_hash = {}
users      = []
links      = []

text = File.open('counts.csv').read
text.gsub!(/\r\n?/, "\n")

text.each_line do |line|
  from, to, count = line.strip.split(",")
  unless users_hash[from]
    users_hash[from] = true
    users << {id: from, group: 1}
  end
  unless users_hash[to]
    users_hash[to] = true
    users << {id: to, group: 1}
  end
  links << {source: from, target: to, value: (count.to_i / 53.0 * 10).ceil.to_i}
end

json = {nodes: users, links: links}
puts json.to_json
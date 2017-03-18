#!/usr/bin/ruby

require 'json'


def clean_giver(giver)
  (case giver
  when '<mailto:eric@parsable.com|eric@parsable.com>'
    'EricChen'
  when 'ab belani'
    'AbhishekBelani'
  when 'E Novak'
    'EBNovak'
  else
    giver
  end).delete(' ')
end

def clean_receiver(receiver)
  receiver = receiver.delete('),./')
  case receiver
  when 'YanDavidErlich'
    'Yan-DavidErlich'
  when 'E Novak', 'eb', 'ENovak'
    'EBNovak'
  when 'abbelani'
    'AbhishekBelani'
  when 'paulbrink'
    'PaulBrink'
  when 'mei'
    'MeiChen'
  when 'ericchen'
    'EricChen'
  when 'BethMatteucci\'s'
    'BethMatteucci'
  when 'matt', 'Matt'
    'MattSmall'
  when 'gil'
    'GilZhaiek'
  when 'tian'
    'TianGeng'
  when 'Kiyomi'
    'KiyomiOtani'
  else
    receiver
  end
end

mentions = []

givers    = {}
receivers = {}
hi_fives  = []
everybody = {}

Dir["messages/*.json"].each do |f|
  json = JSON.parse(File.read(f))
  json["messages"].each do |m|
    unless m["attachments"]
      # puts "Skipping #{m.to_json}"
      next
    end
    attachment = m["attachments"].first
    pretext = attachment["pretext"]
    unless pretext
      # puts "Skipping #{m.to_json}"
      next
    end
    
    idx = [pretext.index("shared") || pretext.size, pretext.index("gave") || pretext.size].min
    if idx == pretext.size
      puts "Unknown Hi5 giver #{m.to_json}"
      next
    end

    giver = clean_giver(pretext[0...idx].strip)
    everybody[giver] = true
    
    text  = attachment["text"]
    text.scan(/@[^\s\/]+[\s\/]/).map(&:strip).each do |receiver|
      receiver = receiver.delete('@').strip
      receiver = clean_receiver(receiver)
      next if receiver == 'thewholeSFoffice'
      everybody[receiver] = true

      (receivers[receiver] ||= []) << giver
      (givers[giver]       ||= []) << receiver
      hi_fives << {g: giver, r: receiver}
    end
  end
end

# puts givers.keys.inspect
# puts; puts;
# puts receivers.keys.inspect
# puts; puts; puts; puts;
# hi_fives.each {|x| puts x.inspect }

ids = everybody.keys.sort
name_to_ids = {}
ids.each_with_index { |id, i| name_to_ids[id] = i + 1 }

File.open("ids.txt", 'w') do |file|
  ids.each_with_index do |id, i|
    file.write("#{id},#{i+1}\n")
  end
end


File.open("hi5.txt", 'w') do |file|
  hi_fives.each do |hi5|
    file.write("#{hi5[:g]},#{hi5[:r]}\n")
  end
end










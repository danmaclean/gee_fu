class Badge
require 'net/http'
require "rubygems"
require "json"


def self.goget(url, email, badge)

card = getCard(url, email, badge)
badge = getBadge(url, badge)

end

def self.getCard(url, emai, badge)

getter = "#{url}/cards/update/#{email}/#{badge}";

uri = URI(getter)
req = Net::HTTP.get(uri)
json = JSON.parse(req)
end

def self.getBadge(url, badge)

puts "getting badge"

getter = "#{url}/badges/#{badge}";

uri = URI(getter)
req = Net::HTTP.get(uri)
json = JSON.parse(req)
end

end
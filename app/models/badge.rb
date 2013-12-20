class Badge
require 'net/http'
require "rubygems"
require "json"


def self.goGet(url, email, badge)

card = getCard(url, email, badge)
badge = getBadge(url, badge)

bundle = card + badge
return bundle
end

def self.getCard(url, email, badge)

getter = "#{url}/cards/update/#{email}/#{badge}";

uri = URI(getter)
req = Net::HTTP.get(uri)
json = req.to_json
return req
end

def self.getBadge(url, badge)

getter = "#{url}/badges/#{badge}";

uri = URI(getter)
req = Net::HTTP.get(uri)
json = req.to_json
return req
end

end
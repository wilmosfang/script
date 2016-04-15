#!/usr/local/rvm/rubies/ruby-2.3.0/bin/ruby
##
##
##Author:wilmosfang
##For baidu API
##Get get weather of last 7 days from baidu
#ref http://apistore.baidu.com/apiworks/servicedetail/112.html
#

#


##require area
require 'date'
require 'time'
require 'httparty'
require 'elasticsearch'


##manully config area
api = Hash.new
api["apikey"] = "xxxxxxxxxapikeyxxxxxxx"
api["baseurl"] = "http://apis.baidu.com/apistore/weatherservice"
api["recent7"] = "#{api["baseurl"]}/recentweathers"

city_id = {	"beijing" => "101010100"  ,
		"shenzhen" => "101280601" ,
		"chengdu" => "101270101" ,
		"guangzhou" => "101280101" ,
		"shanghai" => "101020100" 
	  }


##get date from baidu
city_id.values.each  do |i|  

res = JSON.parse((HTTParty.get("#{api["recent7"]}?cityid=#{i}", :headers => {"apikey" => "#{api["apikey"]}"})).to_s)

client = Elasticsearch::Client.new url: 'http://localhost:9200'

cityname = res["retData"]["city"]

	res["retData"]["history"].each do |j|
		eventdate = j["date"]
		aqi = j["aqi"].to_i
		fengxiang = j["fengxiang"]
		fengli = j["fengli"]
		hightemp = j["hightemp"].gsub('℃','').to_i
		lowtemp = j["lowtemp"].gsub('℃','').to_i
		type = j["type"]
		eventstamp = Time.parse("#{eventdate} 23:50:00").to_i * 1000
		eventid = "#{i}_#{eventdate}"
		##format output 
		printf("%s\t%s\t%d\t%s\t%s\t%d\t%d\t%s\n",eventdate,cityname,aqi,fengxiang,fengli,hightemp,lowtemp,type)
		#
		client.index  index: 'weather', type: 'stat', id: eventid , body: { timestamp: eventstamp, cityname: cityname,  aqi: aqi , fengxiang: fengxiang, fengli: fengli, hightemp: hightemp ,lowtemp: lowtemp , type: type  }
	end

end



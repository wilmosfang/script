#!/usr/local/rvm/rubies/ruby-2.3.0/bin/ruby
#
#
#Author:fangzheng
#For umeng API
#Get newuser DAU DAT retentions(1,7) for iOS and Android  
#usage : ruby x.rb <1-N>



##require area
require 'date'
require 'time'
require 'httparty'
require 'elasticsearch'


##manully config area
account = "test@example.com"
password = "test"
android_app = "测试-Android"
ios_app = "测试-iPhone"


##static config restful API
baseurl = "http://api.umeng.com"
api = Hash.new
api["auth"] = "#{baseurl}/authorize"
api["apps"] = "#{baseurl}/apps"
api["dau"] = "#{baseurl}/base_data"
api["dat"] = "#{baseurl}/durations"
api["ret"] = "#{baseurl}/retentions"


##get time
today = Date.today
yestoday = today - (ARGV[0]).to_i 
todays = today.strftime("%Y-%m-%d")
yestodays = yestoday.strftime("%Y-%m-%d")
yestodayr1s = (yestoday - 1).strftime("%Y-%m-%d")
yestodayr7s = (yestoday - 7).strftime("%Y-%m-%d")



##get token
token = HTTParty.post("#{api["auth"]}" , :body => "email=#{account}&password=#{password}")['auth_token']


##init hash and app array
android = Hash.new
ios = Hash.new
applist = Array[android,ios]
android["appname"] = android_app
ios["appname"] = ios_app


##umeng api bug fix 
##
#
android["appkey"] = "xxxxxxappkeyxxxxxxxxx"
ios["appkey"] = "xxxxxxxxxappkeyxxxxxxxxxxx" 



##get date from umeng
applist.each do |i|
	i["urlencode"] = URI.encode("#{i["appname"]}")
	#i["appkey"] = HTTParty.get("#{api["apps"]}?q=#{i["urlencode"]}&auth_token=#{token}")[0]["appkey"]
        i["newuser"] = HTTParty.get("#{api["dau"]}?date=#{yestodays}&appkey=#{i["appkey"]}&auth_token=#{token}")["new_users"]
        i["dau"] = HTTParty.get("#{api["dau"]}?date=#{yestodays}&appkey=#{i["appkey"]}&auth_token=#{token}")["active_users"]
	i["dat"] = HTTParty.get("#{api["dat"]}?appkey=#{i["appkey"]}&auth_token=#{token}&start_date=#{yestodays}&end_date=#{yestodays}&period_type=daily")["average"]
	i["ret1"] = HTTParty.get("#{api["ret"]}?appkey=#{i["appkey"]}&auth_token=#{token}&start_date=#{yestodayr1s}&end_date=#{yestodayr1s}&period_type=daily")[0]["retention_rate"][0]
	i["ret7"] = HTTParty.get("#{api["ret"]}?appkey=#{i["appkey"]}&auth_token=#{token}&start_date=#{yestodayr7s}&end_date=#{yestodayr7s}&period_type=daily")[0]["retention_rate"][6]
	i["dats"] = Time.parse("1970-01-10" + " " + i["dat"]).to_i - Time.parse("1970-01-10 00:00:00").to_i
        i["date"] = yestodays
end



##avg dat and dats (dat from string to seconds)
avgdat = Time.at((Time.parse("1970-01-10" + " " + ios["dat"]).to_i + Time.parse("1970-1-10" + " " + android["dat"]).to_i )/2).strftime("%H:%M:%S")
avgdats = (ios["dats"] + android["dats"])/2


##format output 
printf("%s\t%d\t%d\t%d\t%d\t%d\t%d\t%s\t%s\t%s\t%.1f\t%.1f\t%.1f\t%.1f\t%.1f\t%.1f\n",android["date"],ios["newuser"],android["newuser"],ios["newuser"]+android["newuser"],ios["dau"],android["dau"],ios["dau"]+android["dau"],ios["dat"],android["dat"],avgdat,ios["ret1"],android["ret1"],(ios["ret1"]+android["ret1"])/2,ios["ret7"],android["ret7"],(ios["ret7"]+android["ret7"])/2)


##get stat datetime
eventstamp = Time.parse("#{android["date"]} 23:50:00").to_i * 1000


##save to es
client = Elasticsearch::Client.new url: 'http://localhost:9200'
client.index  index: 'umeng', type: 'stat', id: android["date"] , body: { timestamp: eventstamp, ios_new: ios["newuser"],  android_new: android["newuser"] , sum_new: (ios["newuser"]+android["newuser"]), ios_dau: ios["dau"], andriod_dau: android["dau"] ,sum_dau: (ios["dau"]+android["dau"]) , ios_dat: ios["dats"] , android_dat: android["dats"], avg_dat: avgdats  , ios_rat1: ios["ret1"] , android_rat1: android["ret1"] , avg_rat1: (ios["ret1"]+android["ret1"])/2 , ios_rat7: ios["ret7"] , android_rat7: android["ret7"] , avg_rat7: (ios["ret7"]+android["ret7"])/2 }

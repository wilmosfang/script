#!/usr/local/rvm/rubies/ruby-2.6.3/bin/ruby
# 2019.07.18
#
#

## dep pkg
require 'toml'
require 'influxdb'
require 'logger'
require 'pr_geohash'
require 'ip2location_ruby'

## config area to file 
config = <<-TOML
[task]
ip_list = ["114.114.114.114","114.114.115.115","223.5.5.5","223.6.6.6","180.76.76.76","119.29.29.29","182.254.116.116","1.2.4.8","210.2.4.8","117.50.11.11","52.80.66.66","101.226.4.6","218.30.118.6","123.125.81.6","140.207.198.6","8.8.8.8","8.8.4.4","9.9.9.9","208.67.222.222","208.67.220.220","199.91.73.222","178.79.131.110","61.132.163.68","202.102.213.68","219.141.136.10","219.141.140.10","61.128.192.68","61.128.128.68","218.85.152.99","218.85.157.99","202.100.64.68","61.178.0.93","202.96.128.86","202.96.128.166","202.96.134.33","202.96.128.68","202.103.225.68","202.103.224.68","202.98.192.67","202.98.198.167","222.88.88.88","222.85.85.85","219.147.198.230","219.147.198.242","202.103.24.68","202.103.0.68","222.246.129.80","59.51.78.211","218.2.2.2","218.4.4.4","61.147.37.1","218.2.135.1","202.101.224.69","202.101.226.68","219.148.162.31","222.74.39.50","219.146.1.66","219.147.1.66","218.30.19.40","61.134.1.4","202.96.209.133","116.228.111.118","202.96.209.5","180.168.255.118","61.139.2.69","218.6.200.139","219.150.32.132","219.146.0.132","222.172.200.68","61.166.150.123","202.101.172.35","61.153.177.196","61.153.81.75","60.191.244.5","123.123.123.123","123.123.123.124","202.106.0.20","202.106.195.68","221.5.203.98","221.7.92.98","210.21.196.6","221.5.88.88","202.99.160.68","202.99.166.4","202.102.224.68","202.102.227.68","202.97.224.69","202.97.224.68","202.98.0.68","202.98.5.68","221.6.4.66","221.6.4.67","202.99.224.68","202.99.224.8","202.102.128.68","202.102.152.3","202.102.134.68","202.102.154.3","202.99.192.66","202.99.192.68","221.11.1.67","221.11.1.68","210.22.70.3","210.22.84.3","119.6.6.6","124.161.87.155","202.99.104.68","202.99.96.68","221.12.1.227","221.12.33.227","202.96.69.38","202.96.64.68","221.131.143.69","112.4.0.55","211.138.180.2","211.138.180.3","218.201.96.130","211.137.191.26"]
## ip_list = ["114.114.114.114","211.137.191.26"]

[time]
start_time = ""

[limit]
num = 604800
batch = 2000

[database]
host = "localhost"
port = "8086"
db = "new_test"
table = "data"
i2l_path =  "/dpvs/IP2LOCATION.BIN"

[log]
log_path = "./rb.log"
## debug,info,warn,error,fatal
log_level = "debug"
TOML

## parse config
conf = TOML::Parser.new(config).parsed

## begin logger
logger = Logger.new(conf["log"]["log_path"])

case conf["log"]["log_level"]
when "debug"
        logger.level = Logger::DEBUG
when "info"
        logger.level = Logger::INFO
when "warn"
        logger.level = Logger::WARN
when "error"
        logger.level = Logger::ERROR
when "fatal"
        logger.level = Logger::FATAL
else
        logger.level = Logger::INFO
end

logger.info "service start"

## connect the db 
influxdb = InfluxDB::Client.new conf["database"]["db"] , host: conf["database"]["host"], open_timeout: 40 , retry: 6
logger.info "source db connect"

i2l = Ip2location.new.open(conf["database"]["i2l_path"])
logger.info "source i2l db connect"


## get task list
ip_list = []
ip_list = conf["task"]["ip_list"]


## generate ip hash 
geo_hash = Hash.new
ip_list.each { |item|
	ip_latitude = i2l.get_latitude(item)
	ip_longitude = i2l.get_longitude(item)
	geo_hash[item] = {
	 	city: i2l.get_city(item),
=begin
		latitude: ip_latitude,
		longitude: ip_longitude,
=end
		geohash: GeoHash.encode(ip_latitude, ip_longitude)
	}
}
logger.info "hash done"


## init the loop data
now_ts = Time.now.to_i
index = 0 
batch = conf["limit"]["batch"]
len = ip_list.length
res_list = []

conf["limit"]["num"].times {
	ip_index = index%len
	target = {
		series: conf["database"]["table"],
		values: {value: rand(1..150)},
		tags:{
			ip: ip_list[ip_index],
			city: geo_hash[ip_list[ip_index]][:city],
			geohash: geo_hash[ip_list[ip_index]][:geohash]	 
		},
		timestamp: now_ts + index
	}
	res_list.append(target)
=begin
	pp index
	pp ip_index
	pp ip_list[ip_index]
	pp geo_hash[ip_list[ip_index]]
	pp geo_hash[ip_list[ip_index]].class
	pp geo_hash[ip_list[ip_index]][:city]
	pp geo_hash[ip_list[ip_index]][:geohash]
	pp target
=end
	if res_list.length % batch == 0 
		influxdb.write_points( res_list, "s")
		res_list = []
		logger.info index
	end 	
	index += 1 
}
## write the rest data 
influxdb.write_points( res_list, "s")
logger.info index

logger.info "task done"

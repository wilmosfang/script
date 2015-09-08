#!/usr/bin/perl
#version 0.1
#init error_log_dig_nginx.pl
#used for dig nginx log error
#
#



use strict;
use Getopt::Std;

my %opts;
my %client;
my %server;
my %host;
my %request;
my %referrer;
my %errorinfo;

my $error=0;
my $total=0;
my $limit=0;
my $flag=0;
my $nofile=0;

getopts('f:h:n:',\%opts);
&help_info() if $opts{h};
&help_info() unless $opts{f};


open ERROR_LOG , "< $opts{f}" or die "Can't open $opts{f}!";
while (<ERROR_LOG>){
$error++  if $_ =~ /\[(error)\]/;
$nofile++ if $_ =~ /\(2: No such file or directory\)/; 
$errorinfo{$1}++ && $errorinfo{Total}++ if $_ =~ /\d+#0:\s\*\d+\s(.*?),\s/;
$client{$1}++ && $client{Total}++ if $_ =~ /client: (\S+),/; 	
$server{$1}++ && $server{Total}++ if $_ =~ /server: (\S+),/;
$request{$1}++ && $request{Total}++ if $_ =~ /request: "(\S+ \S+ \S+)"/;
$host{$1}++ && $host{Total}++ if $_ =~ /host: "(\S+)"/;
$referrer{$1}++ && $referrer{Total}++ if $_ =~ /referrer: "(\S+)"/;
$total++;

}
close ERROR_LOG;
if ($opts{n}){ $limit=$opts{n};}
else {$limit=$total;};

printf "total lines:%-d\nerror count:%-d\nerror ration:%6.3f\%\nnofile count:%-d\nnofile ration:%6.3f\%\n",$total,$error,$error/$total*100,$nofile,$nofile/$total*100;


print "\n"x4;
$flag=0;
printf "%-5s\t %+10s\t%s\n","times","ratio(%)","Client";
foreach (sort{$client{$b} <=> $client{$a}} keys(%client)){
printf "%-5d\t%10.3f\%\t%s\n",$client{$_},$client{$_}/$client{Total}*100,$_;
last if (++$flag >= $limit);
};

print "\n"x4;
$flag=0;
printf "%-5s\t %+10s\t%s\n","times","ratio(%)","Server";
foreach (sort{$server{$b} <=> $server{$a}} keys(%server)){
printf "%-5d\t%10.3f\%\t%s\n",$server{$_},$server{$_}/$server{Total}*100,$_;
last if (++$flag >= $limit);
};

print "\n"x4;
$flag=0;
printf "%-5s\t %+10s\t%s\n","times","ratio(%)","Host";
foreach (sort {$host{$b} <=> $host{$a}} keys(%host)){
printf "%-5d\t%10.3f\%\t%s\n",$host{$_},$host{$_}/$host{Total}*100,$_;
last if (++$flag >= $limit);
};


print "\n"x4;
$flag=0;
printf "%-5s\t %+10s\t%s\n","times","ratio(%)","Request";
foreach (sort {$request{$b} <=> $request{$a}} keys(%request)){
printf "%-5d\t%10.3f\%\t%s\n",$request{$_},$request{$_}/$request{Total}*100,$_;
last if (++$flag >= $limit);
};


print "\n"x4;
$flag=0;
printf "%-5s\t %+10s\t%s\n","times","ratio(%)","Referrer";
foreach (sort {$referrer{$b} <=> $referrer{$a}} keys(%referrer)){
printf "%-5d\t%10.3f\%\t%s\n",$referrer{$_},$referrer{$_}/$referrer{Total}*100,$_;
last if (++$flag >= $limit);
};



print "\n"x4;
$flag=0;
printf "%-5s\t %+10s\t%s\n","times","ratio(%)","ErrorInfo";
foreach (sort {$errorinfo{$b} <=> $errorinfo{$a}} keys(%errorinfo)){
printf "%-5d\t%10.3f\%\t%s\n",$errorinfo{$_},$errorinfo{$_}/$errorinfo{Total}*100,$_;
last if (++$flag >= $limit);
};














sub help_info {
print <<EOF
Usage:
	$0 -f <error_log_of_nginx> [-h] -[n]
	-h optical argument
		display this help info
	-n optical argument
		limit the output lines
	-f specified the path of the nginx error log
Example:
	command:
	$0 -f /path/to/error.log-20150312
	$0 -f /path/to/error.log-20150312 -n 30
EOF
;
exit 0;
};

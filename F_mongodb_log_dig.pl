#!/usr/bin/perl
#version 0.1
#init mongodb_log_dig.pl
#
#
#



use strict;
use Getopt::Std;

my %opts;
my %type;
my %subtype;
my %ns;

my $total=0;
my $sumtime=0;
my $flag=0;
my $abc='';
my $limit=0;

my @record=();
my @timelist=();

getopts('f:h:n:',\%opts);
&help_info() if $opts{h};
&help_info() unless $opts{f};


open MONGO_LOG , "< $opts{f}" or die "Can't open $opts{f}!";
while (<MONGO_LOG>){

@record = split (/\s+/);
$type{$record[2]}++ ;
$subtype{$record[4]}++;
$ns{$record[5]}++;
if ($record[-1] =~ /(\d+)ms/ )  {
	push @timelist,$1;
	$sumtime+= $1 ;
};
$total++;



}
close MONGO_LOG;
if ($opts{n}){ $limit=$opts{n};}
else {$limit=$total;};

printf "[summary info]\n\n";
printf "total lines:%-d\ntotal time:%-d ms\n",$total,$sumtime;




print "\n"x4;
printf "[The op type range]\n\n";
$flag=0;
printf "%-5s\t %+10s\t%s\n","times","ratio(%)","TYPE";
foreach (sort{$type{$b} <=> $type{$a}} keys(%type)){
printf "%-5d\t%10.3f\%\t%s\n",$type{$_},$type{$_}/$total*100,$_;
last if (++$flag >= $limit);
};

print "\n"x4;
printf "[The subop type range]\n\n";
$flag=0;
printf "%-5s\t %+10s\t%s\n","times","ratio(%)","subTYPE";
foreach (sort{$subtype{$b} <=> $subtype{$a}} keys(%subtype)){
printf "%-5d\t%10.3f\%\t%s\n",$subtype{$_},$subtype{$_}/$total*100,$_;
last if (++$flag >= $limit);
};

print "\n"x4;
printf "[The ns range]\n\n";
$flag=0;
printf "%-5s\t %+10s\t%s\n","times","ratio(%)","NS";
foreach (sort {$ns{$b} <=> $ns{$a}} keys(%ns)){
printf "%-5d\t%10.3f\%\t%s\n",$ns{$_},$ns{$_}/$total*100,$_;
last if (++$flag >= $limit);
};




print "\n"x4;
printf "[The time spent on top%-5d OPS]\n\n",$limit;
$flag=0;
foreach ( sort {$b <=> $a} @timelist ){
printf "spend time %20.10f\%\n",$_/$sumtime*100;
$abc = $_ . "ms";
system("grep \'$abc\' $opts{f}");
last if (++$flag >= $limit);

}










sub help_info {
print <<EOF
Usage:
	$0 -f <slowquery_log_of_mongodb> [-h] -[n]
	-h optical argument
		display this help info
	-n optical argument
		limit the output lines
	-f specified the path of the mongo query log
Example:
	command:
	$0 -f /path/to/mongodb.log-20150312
	$0 -f /path/to/monbodb.log-20150312 -n 30
EOF
;
exit 0;
};

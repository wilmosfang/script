#!/usr/bin/perl


#require Expect cpan
#require F_mongodb_log_dig.pl  
#require F_automail_mongo_slowqueryresault.bash 
#need at least two opts
#1.host password file
#2.grep patten 


use Expect;
use File::Temp;
use Getopt::Std;
use strict;


my (%opts,$hostname,$username,$password,$tmpdir,$timeout,$exp,$remotedir,$userbin,$scp,$ssh,$patt,$remotefile,$limit);

getopts( 'p:g:n:h',\%opts );
&help_info() if $opts{h};
&help_info() unless $opts{p};
&help_info() unless $opts{g};
if ($opts{n}){ $limit=$opts{n};}
else {$limit=20;};


$patt = $opts{g};
$tmpdir=mkdtemp("/home/bhuser/slow/tmpdirXXXXXX");
$remotedir="/tmp/mongoslow";
$remotefile="/var/log/mongo/mongod.log";
$timeout=100;
$userbin='/home/bhuser/bin';
$scp='/usr/bin/scp';
$ssh='/usr/bin/ssh';


open PASSFILE,"< $opts{p}" or die "Can't open $opts{p}!";
while(<PASSFILE>){
        $_ =~ s/(^\s+|\s+$)//;
        chomp($_);
	($hostname,$username,$password)=split (/\s+/,$_);
	
#flush remote dir and generate the new log file

	$exp = Expect->spawn("$ssh $username\@$hostname  '
		rm /tmp/mongoslow/* ;
		hostname;
		echo remote_dir_is_clean ; 
		grep $patt  $remotefile  >  /tmp/mongoslow/$patt.log ;
		echo remote_log_is_generated; '
        	");
	$exp->expect($timeout,
        	[ qr/\(yes\/no\)/i,sub { my $self = shift;$self->send("yes\n");exp_continue;}],
        	[ qr/password:/i,sub { my $self = shift;$self->send("$password\n");exp_continue;}],
        	);

#download log to localhost
	$exp = Expect->spawn("$scp $username\@$hostname:$remotedir/$patt.log  $tmpdir/$patt.log");
	$exp->expect($timeout,
        	[ qr/\(yes\/no\)/i,sub { my $self = shift;$self->send("yes\n");exp_continue;}],
        	[ qr/password:/i,sub { my $self = shift;$self->send("$password\n");exp_continue;}],
        	[ qr/100\%/,sub { my $self = shift;$self->soft_close();}],
        	);

#generate slowlog report
	system("$userbin/F_mongodb_log_dig.pl -f $tmpdir/$patt.log -n $limit > $tmpdir/$patt.txt ; echo report-is-done");
}

close PASSFILE;


system("$userbin/F_automail_mongo_slowqueryresault.bash  $tmpdir");



sub help_info {
print <<EOF

Usage:
        $0 -p <password_file> -g <grep patten> [-n number] [-h]
        -h optical argument
                display this help info
	-g specified the grep patten of mongodb log
		no space include in the arg
        -p specified the path of password file
	-n specified the number limit
		default is 20
Example:
        command:
         $0  -p /path/to/passwordfile -g 2015-09-05T 
         $0  -p /path/to/passwordfile -g 2015-09-06T -n 30
    
EOF
;
exit  0;
}

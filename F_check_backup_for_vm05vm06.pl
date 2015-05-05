#!/usr/bin/perl


#require Expect
#require Getopt::Std
#

use Expect;
use Getopt::Std;
use strict;

my (%opts,$host,$user,$pass);

getopts( 'p:h',\%opts );
&help_info() if $opts{h};
&help_info() unless $opts{p};

#bakdir info
my $bakdir="/data/backupdir";
my $baklog="$bakdir/backuplog/backup.log";
my $patt="innobackupex.*completed";
my $chkfile="xtrabackup_checkpoints";
my $num=10;

#comment
my $com1="-"x40;
my $com2="----LSN_Status"."-"x26;
my $com3="----Backup_Resault"."-"x22;

#set expect timeout 
my $timeout=3;


open PASSFILE,"< $opts{p}" or die "Can't open $opts{p}!";
while(<PASSFILE>){
        $_ =~ s/(^\s+|\s+$)//;
        chomp($_);
        ($host,$user,$pass)=split (/\s+/,$_);
}
close PASSFILE;

#autocheck of bhvm05 and bhvm06
foreach (("bhvm05","bhvm06")){

#my $exp = Expect->spawn("ssh $user\@$host  'ssh $_ \"echo $com1; hostname; echo $com2; cat $bakdir/2015-*/$chkfile ; echo $com3;grep $patt  $baklog | tail -n $num \" ' ");
my $exp = Expect->spawn("ssh $user\@$host  'ssh $_ \"
	echo $com1;
	hostname; 
	echo $com2; 
	cat $bakdir/2015-*/$chkfile; 
	echo $com3;
	grep $patt  $baklog | tail -n $num; \" ' 
	");
$exp->expect($timeout,
        [ qr/\(yes\/no\)/i,sub { my $self = shift;$self->send("yes\n");exp_continue;}],
	[ qr/password:/i,sub { my $self = shift;$self->send("$pass\n");exp_continue;}],
        );
}




sub help_info {
print <<EOF

Usage:
        $0 -p <password_file> [-h]
        -h optical argument
                display this help info
        -p specified the path of password file
Example:
        command:
         $0  -p /path/to/passwordfile
    
EOF
;
exit  0;
}

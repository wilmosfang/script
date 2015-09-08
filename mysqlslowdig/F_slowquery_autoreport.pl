#!/usr/bin/perl


#require Expect cpan
#require pt-query-digest percona toolkit
#require F_automail_slowqueryresault.bash
#require F_dealwithreport.bash
#need two opts
#1.host password file
#2.db password file


use Expect;
use File::Temp;
use Getopt::Std;
use strict;


my (%opts,$hostname,$username,$password,$tmpdir,$timeout,$exp,$remotedir,$dbuser,$dbpass,$userbin,$scp,$ssh);

getopts( 'p:d:h',\%opts );
&help_info() if $opts{h};
&help_info() unless $opts{p};
&help_info() unless $opts{d};
$tmpdir=mkdtemp("/home/testuser/slow/tmpdirXXXXXX");
$remotedir="/home/testuser/slowquery";
#$mysqldir="/var/lib/mysql";
$timeout=15;
$userbin='/home/testuser/bin';
$scp='/usr/bin/scp';
$ssh='/usr/bin/ssh';

open PASSDB,"< $opts{d}" or die "Can't open $opts{d}!";
while(<PASSDB>){
        $_ =~ s/(^\s+|\s+$)//;
        chomp($_);
        ($dbuser,$dbpass)=split (/\s+/,$_);
}

close PASSDB;

open PASSFILE,"< $opts{p}" or die "Can't open $opts{p}!";
while(<PASSFILE>){
        $_ =~ s/(^\s+|\s+$)//;
        chomp($_);
	($hostname,$username,$password)=split (/\s+/,$_);
	
#flush the *.gz for slow log to update on each host

	$exp = Expect->spawn("$ssh $username\@$hostname  '
		rm /home/testuser/slowquery/* ;
		hostname ; 
		echo rm_gz_is_done;
		find /var/lib/mysql/  -maxdepth 1   -name \'*.gz\'  -exec ls -t {} \\;  | tail -n 1  | xargs -I {} cp {} /home/testuser/slowquery/ ; 
        	hostname ;
		echo gz_copy_is_done; '
        	");
	$exp->expect($timeout,
        	[ qr/\(yes\/no\)/i,sub { my $self = shift;$self->send("yes\n");exp_continue;}],
        	[ qr/password:/i,sub { my $self = shift;$self->send("$password\n");exp_continue;}],
        	);

#download the *.gz for each host
	$exp = Expect->spawn("$scp $username\@$hostname:$remotedir/*.gz  $tmpdir/$hostname.slowlog.gz");
	$exp->expect($timeout,
        	[ qr/\(yes\/no\)/i,sub { my $self = shift;$self->send("yes\n");exp_continue;}],
        	[ qr/password:/i,sub { my $self = shift;$self->send("$password\n");exp_continue;}],
        	[ qr/100\%/,sub { my $self = shift;$self->soft_close();}],
        	);
#unzip the *.gz
	system("/bin/gunzip $tmpdir/$hostname.slowlog.gz ; echo gunzip-is-done");
#generate slowlog report
	system("/usr/bin/pt-query-digest $tmpdir/$hostname.slowlog > $tmpdir/$hostname.slowlog.report ; echo report-is-done");
#generate doc for each report
	system("$userbin/F_dealwithreport.bash $tmpdir/$hostname.slowlog.report  4 $tmpdir/$hostname.slowlog.report  > $tmpdir/$hostname.doc ; echo doc-is-done");
#add doc to summary
	system("/bin/cat  $tmpdir/$hostname.doc >> $tmpdir/summary.doc ; echo add-doc-to-summary");
#generate sql for each report
	system("/bin/cat $tmpdir/$hostname.doc  | grep '#    SHOW' | sed 's/#    //' >  $tmpdir/$hostname.sql ; echo sql-is-done");
#update the sql to remote dir 
	$exp = Expect->spawn("$scp $tmpdir/$hostname.sql  $username\@$hostname:$remotedir ");
	$exp->expect($timeout,
        	[ qr/\(yes\/no\)/i,sub { my $self = shift;$self->send("yes\n");exp_continue;}],
        	[ qr/password:/i,sub { my $self = shift;$self->send("$password\n");exp_continue;}],
        	[ qr/100\%/,sub { my $self = shift;$self->soft_close();}],
        	);
#generate table details	
	$exp = Expect->spawn("$ssh $username\@$hostname  '
		mysql -u $dbuser -p$dbpass  < $remotedir/$hostname.sql  > $remotedir/$hostname.table.details  ; 
		echo table-details-is-done ;'
		");
	$exp->expect($timeout,
        	[ qr/\(yes\/no\)/i,sub { my $self = shift;$self->send("yes\n");exp_continue;}],
        	[ qr/password:/i,sub { my $self = shift;$self->send("$password\n");exp_continue;}],
        	[ qr/table-details-is-done/,sub { my $self = shift;$self->soft_close();}],
        	);
#download the table details
	$exp = Expect->spawn("$scp $username\@$hostname:$remotedir/$hostname.table.details  $tmpdir/ ");
	$exp->expect($timeout,
        	[ qr/\(yes\/no\)/i,sub { my $self = shift;$self->send("yes\n");exp_continue;}],
        	[ qr/password:/i,sub { my $self = shift;$self->send("$password\n");exp_continue;}],
        	[ qr/100\%/,sub { my $self = shift;$self->soft_close();}],
        	);
}

close PASSFILE;


system("$userbin/F_automail_slowqueryresault.bash  $tmpdir");



sub help_info {
print <<EOF

Usage:
        $0 -p <password_file> -d <dbpassword_file> [-h]
        -h optical argument
                display this help info
        -p specified the path of password file
	-d specified the path of db password file
Example:
        command:
         $0  -p /path/to/passwordfile -d /path/to/dbpasswordfile
    
EOF
;
exit  0;
}

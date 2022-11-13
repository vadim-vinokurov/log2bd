#!/usr/bin/perl
use DBI;
use strict;
use warnings;
use Email::Address;
use Try::Tiny;
use Config::Tiny;
use 5.010;

my $config = Config::Tiny->read( 'config.ini' );
my $user = $config->{connect}->{user};
my $driver  = $config->{connect}->{driver};
my $host = $config->{connect}->{host};
my $port = $config->{connect}->{port};
my $pass = $config->{connect}->{pass};
my $dbname = $config->{connect}->{dbname};
my $dsn = "DBI:$driver:dbname = $dbname";

my $dbh = DBI->connect($dsn, $user, $pass, { RaiseError => 1 }) 
   or die $DBI::errstr;


my @flag=("<=","=>","->","**","==","@");
my $filename = 'out';

open my $fh, '<', $filename or die "Failed to open file: $filename"; 

while(chomp(my $line = <$fh>)) {
	my @insertArray = split(' ',$line);

	my $insertQuote = do { local $" = q<' '>; qq<'@insertArray'> };
	
	my @data = split(' ',$insertQuote);

	my $dt = join ' ', @insertArray[0,1];	
	my @dt = do { local $" = q<' '>; qq<'$dt'> };

	my @s = splice @insertArray, 3,-1;	
	@s = do { local $" =  qq<'@s'> };

	if(index( $line, '<=' )<1){
		my @addrs = Email::Address->parse($line);
  		foreach my $addr (@addrs) {
			my $addr = do { local $" = q<' '>; qq<'$addr'> };
			try{
				my $sth = $dbh->prepare("INSERT INTO log.log (created, int_id, str,address) values (@dt, @data[2],@s[0],$addr)");
				$sth->execute() or die $DBI::errstr;
			} 
			catch {
		 		warn "got dbi error: $_";
			}
  }
}else{
try{
				my $sth = $dbh->prepare("INSERT INTO log.message (created, id, int_id, str) values (@dt,'id='||nextval('log_id'), @data[2],@s[0])");
				$sth->execute() or die $DBI::errstr;
			} 
			catch {
		 		warn "got dbi error: $_";
			}
}
};	

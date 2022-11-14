#!/usr/bin/perl
use strict;
use warnings;
use DBI;
use Try::Tiny;
use CGI qw(param);
use CGI qw(:standard);
use locale;
use POSIX qw(locale_h);
setlocale(LC_CTYPE, 'ru_RU.CP1251');
setlocale(LC_ALL, 'ru_RU.CP1251');
use Config::Tiny;
use 5.010;

print qq(Content-type: text/html; charset=windows-1251);

my $config = Config::Tiny->read( '../config.ini' );
my $user = $config->{connect}->{user};
my $driver  = $config->{connect}->{driver};
my $host = $config->{connect}->{host};
my $port = $config->{connect}->{port};
my $pass = $config->{connect}->{pass};
my $dbname = $config->{connect}->{dbname};
my $dsn = "DBI:$driver:dbname = $dbname";

my $dbh = DBI->connect($dsn, $user, $pass, { RaiseError => 1 }) or die $DBI::errstr;
if (!$dbh) {
        print "<h3>ERROR.</h3> \n $DBI::errstr \n";
}
if ($dbh) {
        print "<h3>Opened database successfully</h3> \n";
        $dbh->disconnect();
}
my $search = uc( param('search') || undef);




print header;
print start_html;
print "<head>";
print "<title>title</title>";
print "</head>";
print "<body>";

print "<form action='' method=post>";
print '<input type=text name=search value="'.($search || '').'">';
print "<input type=submit value=search>";
print "</form>";

my $sth = $dbh->prepare("SELECT created,id,str FROM log.message") or die "prepare statement failed: $dbh->errstr()";

$sth->execute() or die "execution failed: $dbh->errstr()"; 

my($created,$id,$str);

print("$created\t$id\t$str\n");

# loop through each row of the result set, and print it
while(($created,$id,$str) = $sth->fetchrow()){
   print("$created\t$id\t$str\n");                   
};


$sth->finish();
$dbh->disconnect();


print "</body>";

print end_html;


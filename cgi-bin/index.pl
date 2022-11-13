#!/usr/bin/perl
# Подключаем основные модули
use strict;
use warnings;
use DBI;
use Try::Tiny;
# use CGI qw(param);
use CGI qw(:standard);
use locale;
use POSIX qw(locale_h);
setlocale(LC_CTYPE, 'ru_RU.CP1251');
setlocale(LC_ALL, 'ru_RU.CP1251');



print qq(Content-type: text/html; charset=windows-1251);
 
print "hi\n";

print header;
print start_html;
print "<head>";
print "<title>title</title>";
print "</head>";
print "<body>";



my $driver  = "Pg"; 
my $host='localhost';
my $port='5432';
my $user='vadim';
my $pass='0291094';
my $dbname="postgres";
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



print "<p>str</p>";

print "<form action='' method=post>";
print '<input type=text name=search value="'.($search || '').'">';
print "<input type=submit value=search>";
print "</form>";


unless ($search) {print 'count - 0'; exit}

$search =~s /[^ws-]/ /g;

$search =~s /s+/ /g;

print "<p>$search</p>";

my $sql = "SELECT created, id, int_id,str,status FROM log.message where upper(str) like '%$search%'' LIMIT 100";
my $sth = $dbh->prepare($sql);
$sth->execute() || die $DBI::errstr;

my $i = 1;
while (my $row = $sth->fetchrow_hashref()) {
# Печатаем строку результата
    print $i, ' - <a href="', $$row{'url'}, '">', $$row{'title'}, '<a><br>',
          $$row{'description'}, '<br><br>';
    $i++
}
$sth->finish();
# Отключаемся от базы данных
$dbh->disconnect();
print "</body>";
print end_html;







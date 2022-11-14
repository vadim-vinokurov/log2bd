#!/usr/bin/perl
# Подключаем основные модули
use strict;
use warnings;
use DBI;
use CGI qw(param);
use locale;
use POSIX qw(locale_h);
setlocale(LC_CTYPE, 'ru_RU.CP1251');
setlocale(LC_ALL, 'ru_RU.CP1251');
use Config::Tiny;
use 5.010;


my $config = Config::Tiny->read( '../config.ini' );
my $user = $config->{connect}->{user};
my $driver  = $config->{connect}->{driver};
my $host = $config->{connect}->{host};
my $port = $config->{connect}->{port};
my $pass = $config->{connect}->{pass};
my $dbname = $config->{connect}->{dbname};
my $dsn = "DBI:$driver:dbname = $dbname";

my $search = param('search') || undef;

print "Content-type: text/html; charset=windows-1251 ";
# Форма запроса
print '<form action='' method=get>';
print '<input type=text name=search value="'.($search || '').'">';
print '<input type=submit value=search>';
print '</form>';
# Если запрос пустой, то останавливаем скрипт
unless ($search) {print 'Результатов запроса - 0'; exit}
# На всякий случай "чистим" полученные данные
$search =~s /[^ws-]/ /g;

print "tet";

$search =~s /s+/ /g;
# Подключаемся к базе данных

my $dbh = DBI->connect($dsn, $user, $pass, { RaiseError => 1 }) or die $DBI::errstr;
# Формируем запрос

my $sth = $dbh->prepare(
"with t as (
select t1.created,t1.str,t2.created,t2.str from log.message t1, log.log t2
where t1.int_id=t2.int_id
order by t1.int_id,t2.int_id
)
select * from t"
) or die "prepare statement failed: $dbh->errstr()";

$sth->execute() || die $DBI::errstr;
# Устанавливаем счетчик
my $i = 1;
while (my $row = $sth->fetchrow_hashref()) {

 print $i,$$row{'created'},'  ',
          $$row{'id'}, '  '  ,
          $$row{'int_id'},'  ',
          $$row{'str'}, '  ',
          $$row{'status'}, '  ';
    $i++
}

$sth->finish();
# Отключаемся от базы данных
$dbh->disconnect();

if ($i == 1) {print 'Результатов запроса - 0'}
else {print 'Результатов запроса - ', $i - 1}

exit;
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

my $driver  = "Pg"; 
my $host='localhost';
my $port='5432';
my $user='vadim';
my $pass='0291094';
my $dbname="postgres";
my $dsn = "DBI:$driver:dbname = $dbname";

# Получаем поисковый запрос
my $search = param('search') || undef;

# Сразу отправляем заголовок браузеру
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
# "Сжимаем" пробельные символы
$search =~s /s+/ /g;
# Подключаемся к базе данных

my $dbh = DBI->connect($dsn, $user, $pass, { RaiseError => 1 }) or die $DBI::errstr;
# Формируем запрос
my $sql = "SELECT
                created, id, int_id,str,status
           FROM log.message
           LIMIT 100";
my $sth = $dbh->prepare($sql);
$sth->execute() || die $DBI::errstr;
# Устанавливаем счетчик
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

if ($i == 1) {print 'Результатов запроса - 0'}
else {print 'Результатов запроса - ', $i - 1}

exit;
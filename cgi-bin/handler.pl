
my $driver  = "Pg"; 
my $host='localhost';
my $port='5432';
my $user='vadim';
my $pass='0291094';
my $dbname="postgres";
my $dsn = "DBI:$driver:dbname = $dbname";

my $dbh = DBI->connect($dsn, $user, $pass, { RaiseError => 1 }) 
   or die $DBI::errstr;

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
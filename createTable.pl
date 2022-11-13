use DBI;
use strict;
use warnings;
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

my $message = qq(CREATE TABLE LOG.message (
	created		TIMESTAMP (0) WITHOUT TIME ZONE NOT NULL,
	id				VARCHAR NOT NULL,
	int_id 		CHAR (16) NOT NULL,
	str			VARCHAR NOT NULL,
	status 		BOOL,
	CONSTRAINT 	message_id_pk PRIMARY KEY (id)
);

);


my $log = qq(CREATE TABLE log.log (
	created 	TIMESTAMP (0) WITHOUT TIME ZONE NOT NULL,
	init_id	CHAR (16) NOT NULL,
	str		VARCHAR,
	address	VARCHAR
);

);

my @idx = (
	"CREATE INDEX message_created_idx ON log.message (created)",
	"CREATE INDEX message_int_id_idx ON log.message (int_id)",
	"CREATE INDEX log_address_idx ON log.log USING hash (address)"
);


try{

$dbh->do($message);
$dbh->do($log);

$dbh->commit;

for (my $i = 0; $i < @idx; $i++) {
	$dbh->do(@idx[$i]);	
};

$dbh->disconnect();
print "Table created successfully\n";

}
catch{
   print $DBI::errstr;
};


package logln;
use base 'Exporter';
our @EXPORT=qw(logln);
our $VERSION="1.0";

sub logln{
	local $\ = "\n";
	print @_;
}
1;

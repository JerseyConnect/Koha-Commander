# KohaCommander API response handler

package KohaCommander::Service ;

use KohaCommander ;
use Apache2::Const -compile => qw( DECLINED OK );

sub handler{
	
	my $req = shift ;
	
	my $notes = $req->pnotes() ;
	while ( my ($key, $value) = each(%$notes) ) {
		print "$key => $value\n";
	}
#	$req->print( $req->pnotes( 'action' ) ) ;
	
	$req->print( 'I am exiting normally.' ) ;
	
	return Apache2::Const::OK ;
	
}

1 ;
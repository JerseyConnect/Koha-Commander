# KohaCommander API response handler

package KohaCommander::Service ;

use strict ;
use warnings ;

use KohaCommander ;
use KohaCommander::Auth ;

use Apache2::Const -compile => qw( DECLINED OK );

sub handler{
	
	my $req = shift ;
	
	my $notes = $req->pnotes() ;
	while ( my ($key, $value) = each(%$notes) ) {
		print "$key => $value\n";
	}
	
	$req->print( 'This service is not yet implemented' ) 
		and return Apache2::Const::OK
		unless KohaCommander::Service->can( $req->pnotes('action') ) ;
	
	my $action = $req->pnotes('action') ;
	KohaCommander::Service->$action( $req ) ;
	
	$req->print( 'I am exiting normally.' ) ;
	
	return Apache2::Const::OK ;
	
}

sub listInstances{
	
	my ( $self, $req ) =  @_ ;
	
	my $user = KohaCommander::Auth->getUserInfo() ;
	
	
	
}

#
# Get info on the requested instance, or on a property of that instance specified in the path info
#
sub getInstance{
	
	my ( $self, $req ) =  @_ ;
	
	my $instance = $req->pnotes('instance') ;
	my $instance_name = $req->pnotes('requested_object') ;
	my $path_info = $req->pnotes('path_info') ;
	
	$req->print( 'Getting info for instance: ' . $instance ) ;
	
}

1 ;

package KohaCommander::Service::Authn ;

use strict;
use warnings;
  
use Apache2::Access ;
use Apache2::RequestUtil ;
use KohaCommander::Auth ;
  
use Apache2::Const -compile => qw(OK DECLINED HTTP_UNAUTHORIZED);

sub handler{
	my $req = shift ;
	
	my ( $status, $password ) = $req->get_basic_auth_pw ;
	
	# let Apache to fire the dialog if we don't have credentials yet
	return $status unless $status == Apache2::Const::OK ;
	
	if( KohaCommander::Auth->authenticate( $req->user, $password ) ) {
		
		# If user is valid, pass him along to the authz handler
		return Apache2::Const::OK ;
		
	}
	
	$req->note_basic_auth_failure ;
	return Apache2::Const::HTTP_UNAUTHORIZED ;
}

1 ;
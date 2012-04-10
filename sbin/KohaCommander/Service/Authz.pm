# KohaCommander Authorization package
# Verify that the user (who has already authenticated) can access the requested instance(s)

package KohaCommander::Service::Authz ;

use strict ;
use warnings ;

use Apache2::Access ;
use Apache2::RequestUtil ;
use KohaCommander::Auth ;

use Apache2::Const -compile => qw(OK HTTP_UNAUTHORIZED NOT_FOUND);

sub handler{
	
	my $req = shift ;
	
	# Load user info from the Auth package, which hides user implementation
	#  and also grants us access to authz functions
	my $userInfo = KohaCommander::Auth->getUserInfo( $req->user ) ;
	
	my $action = $req->pnotes('action') ;
	my $instance_name = $req->pnotes('requested_object') ;

	#
	# Check for authorization to perform each action
	#
	
	if( $action eq 'listInstances' && KohaCommander::Auth->hasInstances() ) {
		return Apache2::Const::OK ;
	}
	
	# When trying to create an instance, the instance name may or may not be included in the URI
	if( $action eq 'createInstance' && KohaCommander::Auth->canCreateInstance( $instance_name ) ) {
		return Apache2::Const::OK ;
	}
	
	# All other operations on a particular instance require the instance name in the URI
	if( $instance_name ne '' ) {
		
		# Disable this to prevent spiders from discovering instance names
		use Koha::Contrib::Common::Instance ;
		if( ! Koha::Contrib::Common::Instance->exists( $instance_name ) ) {
			return Apache2::Const::NOT_FOUND ;
		}
		
		
		if( $action eq 'getInstance' && KohaCommander::Auth->canViewInstance( $instance_name ) ) {
			$req->pnotes( 'instance'	=> KohaCommander::Auth->getInstanceInfo() );
			return Apache2::Const::OK ;
		}
		
		if( $action eq 'manageInstance' && KohaCommander::Auth->canManageInstance( $instance_name ) ) {
			$req->pnotes( 'instance'	=> KohaCommander::Auth->getInstanceInfo() );
			return Apache2::Const::OK ;
		}
		
		if( $action eq 'deleteInstance' && KohaCommander::Auth->canDeleteInstance( $instance_name ) ) {
			$req->pnotes( 'instance'	=> KohaCommander::Auth->getInstanceInfo() );
			return Apache2::Const::OK ;
		}
	}
	
	# List actions not yet implemented
	
	$req->note_basic_auth_failure() ;
	return Apache2::Const::HTTP_UNAUTHORIZED ;
	
}

1 ;
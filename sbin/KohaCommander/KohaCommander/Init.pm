# Resource loader and parser for Koha Commander

package KohaCommander::Init ;

use strict;
use warnings;

#use KohaCommander ;
use KohaCommander::Service::Authn ;

use Apache2::RequestRec ;
use Apache2::RequestIO ;
use Apache2::RequestUtil ;
use Apache2::ServerUtil ;
use Apache2::ServerRec ;
use Apache2::Process ;
use APR::Table ;

use Apache2::Const -compile => qw(DECLINED OK HTTP_UNAUTHORIZED);

sub handler{
	my $req = shift ;

	# All URLs handled by Perl
	$req->handler( "perl-script" ) ;
	
	if ( $req->uri() =~ m/^\/api\// ) {
		
		# A web service URL
		# Register all the appropriate handlers

#		These require AuthType, AuthName, and Require in the appropriate Apache config block
		$req->push_handlers( PerlAuthenHandler	=> 'KohaCommander::Service::Authn' ) ;
		$req->push_handlers( PerlAuthzHandler	=> 'KohaCommander::Service::Authz' ) ;

#		This one needs no other config
		$req->push_handlers( PerlResponseHandler => 'KohaCommander::Service' ) ;
		
		# If the user is requesting a particular isntance, note that for authz module
		if( my ( $instance_name, $sep, $action ) = $req->uri() =~ m/instance\/([^\/]+)(\/?)(.*?)$/ ) {
			
			if( $req->method() eq 'PUT' ) {
			
				$req->pnotes( 'action'				=> 'createInstance'	) ;
				$req->pnotes( 'requested_object'	=> $instance_name	) ;
				
			} elsif( $req->method() eq 'DELETE' ) {
				
				$req->pnotes( 'action'				=> 'deleteInstance'	) ;
				$req->pnotes( 'requested_object'	=> $instance_name	) ;
				
			} elsif( $req->method() eq 'POST' ) {
				
				if( $instance_name eq 'add' ) {

					$req->pnotes( 'action'				=> 'createInstance'	) ;
					$req->pnotes( 'requested_object'	=> ''	) ;
					
				} elsif( $action eq 'delete' ) {

					$req->pnotes( 'action'				=> 'deleteInstance'	) ;
					$req->pnotes( 'requested_object'	=> $instance_name	) ;
					
				} else {
					
					$req->pnotes( 'action'				=> 'manageInstance'	) ;
					$req->pnotes( 'requested_object'	=> $instance_name	) ;
					
				}
				
			} elsif( $req->method() eq 'GET' ) {
				
				$req->pnotes( 'action'				=> 'getInstance' 	) ;
				$req->pnotes( 'requested_object'	=> $instance_name	) ;
				
			}

		} elsif( $req->uri() =~ m/instance(\/?)$/ ) {

			# list available instances
			$req->pnotes( 'action'				=> 'listInstances' 	) ;
			$req->pnotes( 'requested_object'	=> ''	) ;
			
		} else {
			
			# list available methods
			$req->pnotes( 'action'				=> 'getSystemInfo' 	) ;
			$req->pnotes( 'requested_object'	=> ''	) ;
			
		}
		
	} else {
		
		# A normal web page URL
		
		# Disable HTTP auth for non-service pages
		$req->push_handlers( PerlAuthenHandler	=> \&return_OK ) ;
		
		# Use the CGI page handler to process template files
		$req->push_handlers( PerlResponseHandler => 'KohaCommander::CGI' ) ;
		
	}
	
	return Apache2::Const::OK ;
	
}

sub return_OK{
	return Apache2::Const::OK ;
}

1 ;
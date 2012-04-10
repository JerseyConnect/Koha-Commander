# KohaCommander web page handler

package KohaCommander::CGI ;

use strict;
use warnings;

use Apache2::Request ;
use Apache2::Directive ;
use Apache2::Const -compile => qw( DECLINED OK HTTP_MOVED_TEMPORARILY HTTP_NOT_FOUND HTTP_FORBIDDEN ) ;
use Apache::Session::File ;
use Template qw( :template );

use KohaCommander qw( :common );
use KohaCommander::Auth ;

use Data::Dumper ;

our $session_id ;
our $session_params = {
	Directory		=> '/tmp/koha-commander-sessions',
	LockDirectory	=> '/tmp/koha-commander-sessions'
};

sub handler{
	my $req = Apache2::Request->new( shift ) ;

	# This is the root of the template hierarchy - declare it here for 'use strict' compat
	my $websrc = '' ;
	
	# This is the array of messages to pass to templates
	my @tmpl_messages = [] ;
	
	# Load files from Koha Commander distribution as long as WEB_ROOT is defined
	if( KohaCommander->can('WEB_ROOT') ) {
		
		$websrc = KohaCommander->WEB_ROOT ;
		
	} else {
		
		# Load files from the DocumentRoot - NOT currently working
		my $conf_tree = Apache2::Directive::conftree() ;
		$websrc = $conf_tree->lookup('DocumentRoot') ;
		
	}

	# Find the requested template by name
	# /(.*\/)(.*)$/ - path regex
	my ( $path, $file_name ) = $req->uri =~ m/(.*\/)(.*)$/ ;
	$file_name = 'home' if $file_name eq '' ;

	#
	# Handle static resources ( CSS / JS / images )
	#
	return Apache2::Const::OK if( $file_name =~ m/(.+)\.(css|js|jpg|gif|png)$/ );

	warn '-----------------------------------START ' . $path . $file_name . '---------------------------------' . "\n" ;

	my $template = Template->new({ 
		INCLUDE_PATH  => "$websrc",
		 PRE_PROCESS  => 'header.html',
		POST_PROCESS  => 'footer.html',
		OUTPUT        => $req,     		# send output to the Apache request
	}) || return fail( $req, Apache2::Const::HTTP_NOT_FOUND, $template::ERROR ) ;


	#
	# Initialize session and add it to the headers
	#
	warn 'Initializing session...' ;
	init_session( $req ) ;
	warn '.. done.' ;
	
	my $session_cookie = "SESSION_ID=$session_id";
	$req->headers_out->{"Set-Cookie"} = $session_cookie;
	$req->err_headers_out->{"Set-Cookie"} = $session_cookie;
	
	# If user requested file from a subdirectory, change the path for that template
	$path = substr( $path, 1 ) ;
	
	#
	# Check whether user is attempting to log out
	#
	if( $req->param('logout') ) {
		
		if( logout( $req ) ) {
			
			$path = '' ;
			$file_name = 'login' ;
			
			push @tmpl_messages, { 
				class => 'info', 
				text => 'Logged out successfully'
			} ;
			
		}
		
	}
	
	#
	# Check whether user is attempting to log in
	#
	if( $req->param('login') ) {
		
		warn 'Trying to log in to:' . $path . $file_name ;
		
		if( login( $req ) ) {

			warn 'Log in succeeeded' ;
			
#			die Dumper( %session ) ;
			
			# If user has logged in, redirect to the home page
			$req->err_headers_out->add('Location'	=> '/home') ;

			warn 'Redirecting' ;

			return Apache2::Const::HTTP_MOVED_TEMPORARILY ;
			
		} else {
			
			warn 'login failed';
			
			$path = '' ;
			$file_name = 'login' ;

			# Either create a hash and push it on to the messages array: 
			#my %error_message = (
			#	class	=> 'error',
			#	text	=> 'Login failed'
			#) ;
			#push @tmpl_messages, { %error_message } ;

			# Or push an inline hash on to the array directly
			push @tmpl_messages, { 
				class => 'info', 
				text => 'There was a problem'
			} ;
			
		}
		
	}

	# Add URIs to this whitelist to allow unregistered access
	my @public_uris = qw( home login help ) ;
	
	warn 'Checking for URI visibility' ;
	
	if( is_logged_in( $req ) || ( $path eq '' && $file_name ~~ @public_uris ) ) {

		warn 'URI is public or user is logged in' ;

		# User is logged in OR this is a public URI - allow the function to continue
		
	} else {
		
		# Your choice - throw 403, load error page in place, or redirect to login

#		return Apache2::Const::HTTP_FORBIDDEN ;
#		die 'Caught unauthenticated access attempt for: ' . $path . $file_name ;
		
		$path = '' ;
		$file_name = 'error' ;

		push @tmpl_messages, { 
			class => 'error', 
			text  => 'You do not have access to the page you requested'
		} ;
		
		# If user hasn't logged in, redirect to the login page
		#$req->err_headers_out->add('Location'	=> '/login') ;
		#return Apache2::Const::HTTP_MOVED_TEMPORARILY ;
		
	}
	
	$file_name = $file_name . '.html' ;

	# BAD - generates a valid Hashref that can be included in an array def but cannot be push'd onto one
#	my $message = {
#		class	=> 'c',
#		text	=> 'Wawawa'
#	} ;

	# GOOD - generates a valid Hash that can be pushed onto an array 
#	my %message = (
#		class	=> 'c',
#		text	=> 'Wawawa'
#	) ;

#	my @messages = [
#		{ class=> 'a', text => 'AAA' }, 
#		{ class=> 'b', text => 'bcD' }
#	] ;

#	push @messages, { %message } ;
	
	my %session = get_session();
	
	my $tmpl_params = {
		title	 	=> 'Koha Commander',
		logged_in	=> $session{logged_in},
		messages 	=> [ @tmpl_messages ]
	} ;
	
	warn 'Building response for: ' . $path . $file_name ;
	
	$req->content_type('text/html');
	
	$template->process( $path . $file_name, $tmpl_params ) 
		|| return fail( $req, Apache2::Const::HTTP_NOT_FOUND, $template->error() ) ;
	
	warn 'About to return contents for: ' . $path . $file_name ;
	
	warn '-----------------------------------DONE---------------------------------' . "\n" ;
	
	return Apache2::Const::OK ;
}

sub is_logged_in{
	
	my $r = shift ;
	
	my %session = get_session( $r ) ;
	
#	die %session ;
	
	if( scalar( keys %session ) && $session{logged_in} ) {
		return 1 ;
	}
	
	return 0 ;
	
}

sub login{
	
	my $r = shift ;
	my $username = $r->param('username') ;
	my $password = $r->param('password') ;
	
	
	if( KohaCommander::Auth->authenticate( $username, $password ) ) {
		
		my $userInfo = KohaCommander::Auth->getUserInfo() ;
		
		# set session cookie to store: logged_in flag, username
		set_session( {
			logged_in	=> 1,
			username	=> $userInfo->{'user_name'}
		} ) ;
		
		# Return success
		return 1 ;
	}
	return 0 ;
}

sub logout{
	
	# set session cookie to reflect logged out
	set_session( {
		logged_in	=> 0
	} ) ;
	
	# delete session cookie
	destroy_session();
}

sub init_session{
	
	my $r = shift ;
	
	my %session ;

	my $cookie = $r->headers_in->{'Cookie'} ;
	if( defined( $cookie ) && $cookie ne '' ) {
		$cookie =~ s/^SESSION_ID=(\w+)(\;.+)?/$1/;
	}
	
	if ( defined $cookie && $cookie ne '' ) {
		warn 'Found existing session with key: ' . $cookie ;
	}

	if( scalar keys %session == 0 ) {
	
		warn 'Trying to build a session with key: ' . $cookie ;
		
		my ($err);
		{
			local $@;
			%session = eval {
				my %sess ;
				tie %sess, 'Apache::Session::File', $cookie, $session_params;
				return %sess ;
			} ;
			$err = $@;
		}
		if( $err ) {
			warn 'There was an error building your session' ;
			
			undef $cookie ;
			undef %session ;
			tie %session, 'Apache::Session::File', $cookie, $session_params;
		}
		
#		tie %session, 'Apache::Session::File', $cookie, $session_params;
		
	}

	warn Dumper( %session ) ;
	warn 'Session has: ' . scalar( keys( %session ) ) . ' stored values' ;
	
	if( ! defined $cookie ) {
		
		warn 'Cookie was not set - Setting session by ID: ' . $session{'_session_id'} ;
		
		$session{'initialized'} = 1;
		$cookie = $session{'_session_id'} ;
		
	}

	$session_id = $cookie ;
	
}

# Get a copy of the session data
sub get_session{
	
	if( ! defined( $session_id) || $session_id eq '' ) {
		return 0 ;
	}

	my %session ;
	tie %session, 'Apache::Session::File', $session_id, $session_params;
	
	warn 'Getting session contents' ;
	warn Dumper( %session ) ;
	return %session ;
	
}

# Set or update session variables
sub set_session{
	
	my ( $options ) = @_ ;

	my %session ;
	tie %session, 'Apache::Session::File', $session_id, $session_params;

	# Store passed options to session
	while ( my ($key, $value ) = each %$options ) {
		$session{$key} = $value ;
	}
	
}

sub destroy_session{
	
	my %session ;
	tie %session, 'Apache::Session::File', $session_id, $session_params;
	tied(%session)->delete ;
	
}

# Return a 404 any time a template is requested that we can't find
sub fail{
    my ($r, $status, $message) = @_ ;
#    $r->log_reason($message, $r->filename) ;
    return $status ;
}

1 ;
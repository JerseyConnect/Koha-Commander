#!/usr/bin/perl
# Koha Commander perl script for koha-* commands
# This script is called by the C wrapper, so it runs as root and should do as little as possible

use lib qw(/usr/sbin/KohaCommander);
use Koha::Contrib::Common ;
use Koha::Contrib::Common::Instance ;
use KohaCommander ;
use Getopt::Long ;

use warnings ;
use strict ;

my @allowed_actions = qw/ info create remove enable disable backup restore stop-index start-index restart-index rebuild-index enable-mail disable-mail / ;

my $action = shift or die 'What do you command? Use "help" or "--help" for usage info.' . "\n" ;
my $instance_name = shift || '' ;

#print 'I am: ' . $> . ' or ' . getpwuid( $< ) ;

# Catch requests for help
if( $action =~ /^([\-]*)help$/ ) {
	die 'Here is my usage info.' . "\n" ;
}

# Ensure the requested action is permitted by this script
if( ! grep { /^$action$/ } @allowed_actions ) {
	die 'Not a valid action.' . 'Use "help" or "--help" for usage info.' . "\n" ;
}

# Ensure the requested instance is at least well-formed (not an exploit attempt)
if( $instance_name !~ m/([a-zA-Z0-9\-\_]+)/ ) {
	die 'Not a well-formed instance name.' . "\n" ;
} else {
	$instance_name = $1 ;
}

my $user_name = '' ;
my $format = '' ;

GetOptions(
	'username|u=s'		=> $user_name,
	'result-format|f=s'	=> $format
) ;

# If username was set on the command line, check it for validity
if( $user_name ) {
	
	# Ensure the requested username is at least well-formed (not an exploit attempt)
	if( $user_name && $user_name !~ m/([a-zA-Z0-9\-\_]+)/ ) {
		die 'Not a well-formed username.' . "\n" ;
	} else {
		$user_name = $1 ;
	}
	
} else {
	$user_name = '' ;
}

# Ensure the requested instance name is not too long 
# When using the sh script, usernames have '-koha' appended to them so they have to be under 12 chars
# When specifying a username with the Perl script, make sure it's under 17 chars for MySQL
if( KohaCommander::USE_KOHA_COMMON_SCRIPTS ) {
	
	if( $instance_name !~ m/^([\w]{1,11})$/ ) {
		die 'Instance name is too long.' . "\n" ;
	}
	
} else {

	if( $instance_name !~ m/^([\w]{1,31})$/ ) {
		die 'Instance name is too long.' . "\n" ;
	}
	
	if( $user_name !~ m/^([\w]{1,16})$/ ) {
		die 'Username is too long.' . "\n" ;
	}
	
}


$ENV{'PATH'} = '/bin:/usr/bin:/usr/sbin' ;

if( $action eq 'info' ) {
	get_info( $instance_name, $format ) ;
}
if( $action eq 'create' ) {
	create( $instance_name, $user_name, $format ) ;
}
if( $action eq 'remove' ) {
	remove( $instance_name, $format ) ;
}


#######################################################
#                Action subroutines                   #
#######################################################

sub get_info{
	my ($instance_name, $result_format ) = @_ ;
	
	my $instance = Koha::Contrib::Common::Instance->init( $instance_name ) ;

	if( $instance->{ name } ) {

		print $instance->{hostname} . "\n";
		print $instance->{intra_hostname} . "\n";

	} else {
		print 'Instance was not found' ;
	}
	
	
}

sub create{
	
	print 'Creating instance...' . "\n" ;
	$instance_name = shift ;
	
	if( KohaCommander::USE_KOHA_COMMON_SCRIPTS ) {
		sh_create( $instance_name ) ;
	} else {
		perl_create( $instance_name, $user_name ) ;
	}
	
	{
		sub sh_create{
			my @create_args = ( '/usr/sbin/koha-create', '--create-db', $instance_name ) ;
#			return system ( @create_args ) == 0 ;
		}
		
		sub perl_create{
			my $instance = Koha::Contrib::Common::Instance->create(
				$instance_name, 
				{
					'username'	=> $user_name
				}
			);
		}
	}
}

sub remove{
	
}


1 ;
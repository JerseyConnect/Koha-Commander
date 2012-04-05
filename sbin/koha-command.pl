#!/usr/bin/perl
# Koha Commander perl script for koha-* commands
# This script is called by the C wrapper, so it runs as root and should do as little as possible

use lib qw(/usr/sbin/KohaCommander);
use Koha::Contrib::Common ;
use Getopt::Long ;

use warnings ;
use strict ;

my @allowed_actions = qw/ create delete enable disable backup restore stop-index start-index restart-index rebuild-index enable-mail disable-mail / ;

my $action = shift or die 'What do you command? Use "help" or "--help" for usage info.' . "\n" ;
my $instance_name = shift || '' ;

#print 'I am: ' . $> . ' or ' . getpwuid( $< ) ;

# Catch requests for help
if( $action =~ /^([\-]*)help$/ ) {
	die 'Here is my usage info!' . "\n" ;
}
if( $action eq 'help' || $action eq '--help' ) {
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

my $user_name = 0 ;

GetOptions(
	'username|u=s'	=> $user_name
) ;

$ENV{'PATH'} = '/bin:/usr/bin:/usr/sbin' ;

if( $action eq 'create' ) {
	create( $instance_name ) ;
}


sub create{
	print 'Creating instance...' . "\n" ;
	$instance_name = shift ;
}


1 ;
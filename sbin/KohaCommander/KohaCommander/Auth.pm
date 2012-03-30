# Koha Commander Authentication - for access to the Debian commands for koha-common

package KohaCommander::Auth ;
use warnings ;
use strict ;

# These are the default authentication and authorization handlers
use KohaCommander::Auth::User ;
use KohaCommander::Auth::Instance ;

our $currentUser = 0;
our $currentInstance = 0;

sub authenticate{
	
	my KohaCommander::Auth $self = shift ;
	my ( $username, $password ) = @_ ;

	return 0 unless $username ;
	
	$currentUser = KohaCommander::Auth::User->init();
	
	if( $password ) {
		$currentUser->login( $username, $password );
	} else {
		$currentUser->validate( $username ) ;
	}
	
	return $currentUser->{user_id} != 0 ;
	
}

# Fill in user info based on username passed
# For use after authentication or just to get user details
#  Note: it should not be assumed that this will return credentials
sub getUserInfo{

	my KohaCommander::Auth $self = shift ;

	if( my $user = shift ) {
		$currentUser = KohaCommander::Auth::User->init( $user ) ;
	}

	return $currentUser;
}

#
# ---------------------------------------------------------------------
# Functions for accessing Instances and info on instances
# All access should be through this class, freeing up the Instance and User classes
# ---------------------------------------------------------------------
#

# Return whether user has access to any Koha instances
# Return number of accessible instances or 0 if none
sub hasInstances{

	my KohaCommander::Auth $self = shift ;
	return 1 ;
}

# Return 'all', an array of available instance names, or false if not authorized
sub canBrowseInstances{
	
	my KohaCommander::Auth $self = shift ;
	# If username is of format 'koha_*', limit instance to username match
}

# Return whether user is authorized to view a particular Koha instance
sub canViewInstance{
	
	my KohaCommander::Auth $self = shift ;
	my $instance_name = shift ;
	
	$currentInstance = KohaCommander::Auth::Instance->init( $instance_name ) ;
	return ( $currentInstance->can_read( $currentUser ) );
	
	return 0 ;
	
}

# Return whether user is authorized to manage a particular Koha instance
sub canManageInstance{
	
	my KohaCommander::Auth $self = shift ;
	my $instance_name = shift ;
	
	$currentInstance = KohaCommander::Auth::Instance->init( $instance_name ) ;
	return ( $currentInstance->can_manage( $currentUser ) );
}

# Return whether user is authorized to delete a particular Koha instance
sub canDeleteInstance{
	
	my KohaCommander::Auth $self = shift ;
	my $instance_name = shift ;

	$currentInstance = KohaCommander::Auth::Instance->init( $instance_name ) ;
	return ( $currentInstance->can_delete( $currentUser ) );
	
}

# Return whether user is authorized to create additional Koha instances
# Return # of remaining instances or 0 / false if none left
# If passed a name, will check whether name is available AND user is allowed to create
sub canCreateInstance{
	
	my KohaCommander::Auth $self = shift ;
	my $instance_name = shift if $_ ;
	
}

1 ;
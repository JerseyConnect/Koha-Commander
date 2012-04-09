# Koha Commander - instance authz management
# This will usually be coupled with the user authn package in User.pm
# Reads the uid / gid from the /etc/koha/sites/<sitename> directory to determine user authorization

package KohaCommander::Auth::Instance ;

use strict;
use warnings;

use KohaCommander ;
use Koha::Contrib::Common ;
use Koha::Contrib::Common::Instance ;

use fields qw( instance instance_name owner_id group_id ) ;

sub init{

	my KohaCommander::Auth::Instance $self = shift ;
	unless ( ref $self ) {
		$self = fields::new( $self ) ;
		$self->{instance_name} = 0 ;
	}
	if( my $instance_name = shift ) {
		$self->{instance} = $self->get_instance( $instance_name ) ;
		if( $self->{instance} ) {
			$self->{instance_name} = $self->{instance}->{name} ;
			$self->get_instance_permissions() ;
		}
	}
	
	return $self;
}

sub can_read{
	
	my KohaCommander::Auth::Instance $self = shift ;
	my $user = shift if @_ ;
	
	return 0 unless $self->{instance_name} ;
	
	return $user->{is_admin} 
		|| $user->{user_id} == $self->{owner_id} 
		|| $user->{group_id} == $self->{group_id} ;
	
#	return 0 ;
}

sub can_manage{
	
	my KohaCommander::Auth::Instance $self = shift ;
	my $user = shift if @_ ;

	return 0 unless $self->{instance_name} ;
	
	return $user->{is_admin} 
		|| $user->{user_id} == $self->{owner_id} ;
	
	return 0 ;
}

sub can_delete{
	
	my KohaCommander::Auth::Instance $self = shift ;
	my $user = shift if @_ ;

	return 0 unless $self->{instance_name} ;
	
	return $user->{is_admin} 
		|| $user->{user_id} == $self->{owner_id} ;
	
	return 0 ;
}

# scrub instance name and verify that it really exists
sub get_instance{
	
	my KohaCommander::Auth::Instance $self = shift ;
	my $instance_name = shift ;
	
	$instance_name =~ s/[\W]//g;
	
	if( Koha::Contrib::Common::Instance->exists( $instance_name ) ) {
		return Koha::Contrib::Common::Instance->init( $instance_name ) ;
	}
		
	return 0 ;
}

sub get_instance_permissions{

	my KohaCommander::Auth::Instance $self = shift ;

	return 0 unless $self->{instance_name} ;

	my $sites_path = Koha::Contrib::Common::KOHA_SITE_ROOT ;
	my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = stat($sites_path . $self->{instance_name} . '/') ;
	
	if( $uid && $gid ) {
		$self->{owner_id} = $uid ;
		$self->{group_id} = $gid ;
	}
	
	return $self ;
	
}

1 ;
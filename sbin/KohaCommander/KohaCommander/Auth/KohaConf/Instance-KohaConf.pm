# Koha Commander - instance authz management
# Reads user from koha-conf.xml file to determine authorization
# This will usually be coupled with the user authn package in User.pm

package KohaCommander::Auth::Instance ;

use KohaCommander qw( :common ) ;
use fields qw( instance_name instance_id status ) ;

sub init{

	my KohaCommander::Auth::Instance $self = shift ;
	unless ( ref $self ) {
		$self = fields::new( $self ) ;
		$self->{instance_id} = 0 ;
	}

	if( my $instance_name = shift ) {
		$self->{instance_name} = $self->get_instance( $instance_name ) ;
	}
	
	return $self;
}

sub can_read{
	
	my KohaCommander::Auth::Instance $self = shift ;
	my $user = shift if @_ ;
	
	if( $user ) {
		return $self->scanForUser( $user ) ;
	}
	return 0 ;
}

sub can_manage{
	
	my KohaCommander::Auth::Instance $self = shift ;
	my $user = shift if @_ ;
	
	if( $user ) {
		return $self->scanForUser( $user ) ;
	}
	return 0 ;
}

sub can_delete{
	
	my KohaCommander::Auth::Instance $self = shift ;
	my $user = shift if @_ ;

	if( $user ) {
		return $user->{is_admin} ;
	}
	
	return 0 ;
}

# This function is static - doesn't run in the context of the current instance
sub can_create{
	
	my KohaCommander::Auth::Instance $self = shift ;
	my $user = shift if @_ ;

	if( $user ) {
		return $user->{is_admin} ;
	}
	
	return 0 ;
	
}

# scrub instance name and verify that it really exists
sub get_instance{

	my KohaCommander::Auth::Instance $self = shift ;
	my $instance_name = shift ;
	
	return $instance_name ;
}

sub scanForUser{

	my KohaCommander::Auth::Instance $self = shift ;
	my $user_name = shift ;

	my $path = KohaCommander::KOHA_SITE_ROOT . $self->{instance_name} ;
	my $xp = XML::XPath->new( filename => $path . '/koha-conf.xml' ) ;
	my $username = $xp->findvalue( '/yazgfs/config/user' ) ;

	if( $username == $user_name ) {
			
		return 1 ;
	}
	
	return 0 ;
}

1 ;
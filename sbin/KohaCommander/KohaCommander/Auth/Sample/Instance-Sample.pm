# Koha Commander - instance authz management
# This will usually be coupled with the user authn package in User.pm

package KohaCommander::Auth::Instance ;
use fields qw( instance_name instance_id status ) ;

sub init{

	my KohaCommander::Auth::Instance $self = shift ;
	unless ( ref $self ) {
		$self = fields::new( $self ) ;
		$self->{instance_id} = 0 ;
	}
	
	return $self;
}

sub can_read{
	
	my KohaCommander::Auth::Instance $self = shift ;
	my $user = shift if @_ ;
	
	return 0 ;
}

sub can_manage{
	
	my KohaCommander::Auth::Instance $self = shift ;
	my $user = shift if @_ ;
	
	return 0 ;
}

sub can_delete{
	
	my KohaCommander::Auth::Instance $self = shift ;
	my $user = shift if @_ ;
	
	return 0 ;
}

1 ;
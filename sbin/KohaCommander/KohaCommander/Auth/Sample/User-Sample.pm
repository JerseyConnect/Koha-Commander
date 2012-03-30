# Koha Commander - user management
# A template for user authentication functions

package KohaCommander::Auth::User ;
use fields qw( user_name user_id group_id is_admin ) ;

sub init{

	my KohaCommander::Auth::User $self = shift ;
	unless ( ref $self ) {
		$self = fields::new( $self ) ;
		$self->{user_id} = 0 ;
	}
	
	if( my $user_id = shift ) {
		$self->getUserDetails( $user_id );
	}
	
	return $self;
}

# Handle logins
sub login{
	
	my KohaCommander::Auth::User $self = shift ;

	my ( $username, $password ) = @_ ;
	
	#pwauth returns 0 for success, and non-zero for failure
	if( my_authenticate_func( $username, $password ) ) {
		
		# login failed
		
		return $self ;
		
	} else {
		
		#login succeeded

		$self->getUserDetails( $username ) ;
		return $self;
		
	}
	
}

# Handle OAuth or other single-datum authentication 
sub validate{

	my KohaCommander::Auth::User $self = shift ;
	return 0 ;
	
}

sub getUserDetails{
	
	my KohaCommander::Auth::User $self = shift ;
	
	if( my $username = shift ) {
		
	}
	
}

1 ;
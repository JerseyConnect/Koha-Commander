# Koha Commander - user management
# Passes authentication requests to a subordinate handler

package KohaCommander::Auth::User ;
use fields qw( user_name user_id group_id is_admin ) ;

# optionally define subordinate handlers to call
use constant HANDLERS => qw( XPath ) ;
if( HANDLERS ) {
	foreach $handler (HANDLERS) {
		require "KohaCommander/Auth/User-" . $handler . ".pm" ;
	}
}

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
# Koha Commander - user management
# Uses XPath to scan koha-conf.xml files for user info
# koha-conf.xml files must be readble by Apache (possibly a bad idea)

package KohaCommander::Auth::User ;
use KohaCommander qw( :common ) ;

use XML::XPath ;

use fields qw( user_name user_id group_id is_admin password ) ;

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
	
	if( $self->scanForUser( $username ) && $password == $self->{password} ) {
		
		# login succeeded
		
#		$self->getUserDetails( $username ) ;
		return $self ;
		
	} else {
		
		#login failed

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

		# Get details on user to return
		$self->scanForUser( $username ) ;
		
		return $self;
	
	}
	
}

sub scanForUser{

	my KohaCommander::Auth::User $self = shift ;
	my $user_name = shift ;

	my $path = KohaCommander::KOHA_SITE_ROOT ;
	
	chomp (my @dir = `ls $path`);
	foreach $site_name ( @dir ) {
		
		my $xp = XML::XPath->new( filename => KohaCommander::KOHA_SITE_ROOT . $site_name . '/koha-conf.xml' );

		my $username = $xp->findvalue( '/yazgfs/config/user' ) ;
		my $password = $xp->findvalue( '/yazgfs/config/pass' ) ;

		if( $username == $user_name ) {
			$self->{user_name} = $username ;
			$self->{password}  = $password ;
			
			return 1 ;
		}

	}
	
	return 0 ;
}

1 ;
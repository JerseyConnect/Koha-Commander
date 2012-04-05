# Koha Commander - user management
# Uses PAM for access to the Linux user database

package KohaCommander::Auth::User ;

use Authen::PAM ;
use POSIX qw( ttyname ) ;

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
	
	$service = "koha-commander";
	$tty_name = ttyname(fileno(STDIN));
	
	sub my_conv_func {
		my @res;
		while ( @_ ) {
			my $code = shift;
			my $msg = shift;
			my $ans = "";
			
			$ans = $username if ($code == PAM_PROMPT_ECHO_ON() );
			$ans = $password if ($code == PAM_PROMPT_ECHO_OFF() );
			
			push @res, (PAM_SUCCESS(),$ans);
		}
		push @res, PAM_SUCCESS();
		return @res;
	}

	ref($pamh = new Authen::PAM($service, $username, \&my_conv_func)) ||
		die "Error code $pamh during PAM init!";
	
	$res = $pamh->pam_set_item(PAM_TTY(), $tty_name);
	$res = $pamh->pam_authenticate;

	if( $res == PAM_SUCCESS() ) {
		
		#login succeeded

		$self->getUserDetails( $username ) ;
		return $self;
		
	} else {

		# login failed
		
		print $pamh->pam_strerror($res) . "\n" ;
		return $self ;
		
		
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
		# We can rely on our access to shadowed /etc/passwd 
		#  since we aren't verifying a password
		my (
			$name,
			$passwd,
			$uid,
			$gid, 
			$quota,
			$comment,
			$gcos,
			$dir,
			$shell,
			$expire
		) = getpwnam( $username );	
		
		return $self unless $name;
		
		$self->{user_name} = $name ;
		$self->{user_id}  = $uid ;
		$self->{group_id} = $gid ;
		$self->{is_admin} = 0 ;
	
	}
	
}

1 ;
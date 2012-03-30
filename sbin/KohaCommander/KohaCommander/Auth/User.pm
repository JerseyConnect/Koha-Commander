# Koha Commander - user management
# Uses pwauth for limited access to the Linux user database

package KohaCommander::Auth::User ;
use fields qw( user_name user_id group_id is_admin ) ;

# Use this constant to define which groups contain admins - admins will be allowed access to any instance, and can create / delete
use constant ADMIN_GROUPS => qw( admin adm ) ;

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
	
	$pwauth_path= "/usr/sbin/pwauth";

	sub trypass {
		my $userid= $_[0];
		my $passwd= $_[1];
		
		open PWAUTH, "|$pwauth_path" or die("Could not run $pwauth_path");
		print PWAUTH "$userid\n$passwd\n";
		close PWAUTH;
		return $?;
	}
	
	#pwauth returns 0 for success, and non-zero for failure
	if( trypass( $username, $password ) ) {
		
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
		
		return $self unless ADMIN_GROUPS ;
		
		foreach $admin_group (ADMIN_GROUPS) {
			my ($gname,$passwd,$gid,$members) = getgrnam( $admin_group );
			@members = split( ' ', $members ) ;
			
			for( @members ) {
				if( $name eq $_ ) {
					$self->{is_admin} = 1 ;
					last ;
					return $self ;
				}
			}
		}
		
		
	}
	
}

1 ;
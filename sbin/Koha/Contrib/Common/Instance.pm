# Koha Common - Instance management package
# Provides a Perl interface for creating and managing Koha instances

package Koha::Contrib::Common::Instance ;

use strict ;
use warnings ;

use Koha::Contrib::Common ;
use Koha::Contrib::Common::Settings ;
use Koha::Contrib::Common::Instance::Settings ;

use fields qw( name hostname intra_hostname settings user enabled mail_enabled indexer_running mysql_host mysql_port mysql_schema mysql_user ) ;

our $error_msg = '' ;

=head1 NAME

A package for managing Koha instances created with koha-create

=head1 METHODS

=cut

=head2 init ( $instance name )
Create a Koha instance object

=cut
sub init{
	my Koha::Contrib::Common::Instance $self = shift ;
	
	unless ( ref $self ) {
		$self = fields::new( $self ) ;
		$self->{ name } = '' ;
		$self->{ enabled } = 0 ;
	}
	
	# Would love to combine these two lines, but strict hates it
	if( my $instance_name = shift) {
		if( $self->exists( $instance_name ) ) {
			
			$self->{ name } = $instance_name ;
			$self->{ settings } = Koha::Contrib::Common::Instance::Settings->init( $instance_name );
			$self->get_instance_data() ;
		}
	}
	
	return $self ;
}

=head2 exists ( $instance name )
Check for a Koha instance by the name specified
Return 1 if found, 0 if not found

=cut
sub exists{
	
	my ( $self, $instance_name ) = @_ ;
	
	# Sanitize instance name
	$instance_name =~ s/[\W]//g ;
	
	my $instance_path = Koha::Contrib::Common->KOHA_SITE_ROOT . '/' . $instance_name ;

	return 0 unless(-d $instance_path ) ;
	
	return 1 ;
	
}


=head2 create ( $instance name, %params )
Create a new Koha instance - return 1 if successful, or sets class var $error_msg and returns 0 if failed

Params is a hashref with one or more of the following keys:
	username	=>
	db-op		=> create|populate|request
	configfile	=> 
	defaultsql	=>
	marcflavor	=>
	zebralang	=>

=cut

sub create{
	
	my ( $self, $instance_name, $params ) = @_ ;
	
}

=head2 remove ( $instance name )
Delete a Koha instance

=cut

sub remove{
	
}

=head2 delete ( $instance name )
Delete a Koha instance

=cut
sub enable{
	
}

=head2 delete ( $instance name )
Delete a Koha instance

=cut
sub disable{
	
}

=head2 delete ( $instance name )
Delete a Koha instance

=cut
sub reindex{
	
}

=head2 delete ( $instance name )
Delete a Koha instance

=cut
sub backup{
	
}

=head2 delete ( $instance name )
Delete a Koha instance

=cut
sub restore{
	
}

=head2 get_instance_data ()
Get details about a Koha instance

=cut
sub get_instance_data{
	
	my Koha::Contrib::Common::Instance $self = shift ;
	
	my $instance_name = shift || $self->{ name };
	
	# Make sure we have the instance name so we can proceed
	return 0 unless $self->{name} ;
	
	#----------------------------------------
	# Check whether this instance is enabled
	#
	
	# 1 - Check that link exists in sites-enabled directory
	$self->{ enabled } = (-l '/etc/apache2/sites-enabled/' . $instance_name ) ;

	# 2 - Check that closed sign isn't up in vhost
	if( $self->{ enabled } ) {
		if(	open FILE, "</etc/apache2/sites-available/" . $instance_name ) {
				
			my $file_contents = do { local $/; <FILE> };
	
			if( $file_contents =~ m/\n[^\#]+apache-shared-disable/ ) {
				$self->{ enabled } = 0 ;
			}
			close FILE or warn 'There was an error closing the file handle';
		}
	}
	
	#----------------------------------------------
	# Check whether this instance has mail enabled
	#
	
	$self->{ mail_enabled } = (-e Koha::Contrib::Common::KOHA_SERVER_ROOT . '/' . $self->{name} . '/email.enabled' );
	
	#-------------------------------------------------
	# Check status of indexer for this instance
	#
	
	# 1 - Get userid of associated user
	my $uid = getpwnam( ($self->{user} || $instance_name) );
	
	# Fall back to koha-common user naming if name passed was invalid
	$uid = getpwnam( ( $instance_name . '-koha' ) ) unless $uid ;

	# 2 - Run ps -U <userid> and capture PIDs of daemon and zebrasrv
	chomp (my @procs = `ps -o pid -U $uid --no-headers -C zebrasrv -C daemon`);
	$self->{ indexer_running } = scalar(@procs) > 0 ;
	
	if( $self->{ indexer_running } ) {
		foreach my $proc (@procs) {
			if( $proc =~ m/([\d]+)/ ) {
				my $pid = $1 ;
				# 3 - $is_running = kill 0, <PID>;
				$self->{ indexer_running } = $self->{ indexer_running } and kill 0, $pid ;
				
			}
		}
	}
	
	#----------------------------------------------------
	# Get details from the koha-conf.xml file
	#
	$self->{ mysql_host }   = $self->{ settings }->read('hostname') ;
	$self->{ mysql_port }   = $self->{ settings }->read('port') ;
	$self->{ mysql_schema } = $self->{ settings }->read('database') ;
	$self->{ mysql_user }   = $self->{ settings }->read('user') ;
	
	#-----------------------------------------------------
	# Get details from master config file(s)
	# TODO: get these values from Apache instead
	#
	$self->{ hostname }       = $self->{ name }
	 . Koha::Contrib::Common::Settings->read( 'DOMAIN' ) ;
	 
	$self->{ intra_hostname } = Koha::Contrib::Common::Settings->read( 'INTRAPREFIX' )
	 . $self->{ name }
	 . Koha::Contrib::Common::Settings->read( 'INTRASUFFIX' )
	 . ( Koha::Contrib::Common::Settings->read( 'INTRAPORT' ) eq '80' ? '' : ':' . Koha::Contrib::Common::Settings->read( 'INTRAPORT' ) )
	 . Koha::Contrib::Common::Settings->read( 'DOMAIN' ) ;
}

1 ;
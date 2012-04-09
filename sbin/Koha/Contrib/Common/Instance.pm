# Koha Common - Instance management package
# Provides a Perl interface for creating and managing Koha instances

package Koha::Contrib::Common::Instance ;

use strict ;
use warnings ;

use Koha::Contrib::Common ;
use Koha::Contrib::Common::Settings ;

our $error_msg = '' ;

=head1 NAME

A package for managing Koha instances created with koha-create

=head1 METHODS

=cut

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

Params is a hash with one or more of the following keys:
	adminuser	=>
	db-op		=> create|populate|request
	configfile	=> 
	defaultsql	=>
	marcflavor	=>
	zebralang	=>

=cut

sub create{
	
	my ( $self, $instance_name, %params ) = @_ ;
	
}

=head2 delete ( $instance name )
Delete a Koha instance

=cut

sub delete{
	
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

1 ;
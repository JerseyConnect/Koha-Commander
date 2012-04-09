# Package for managing Koha instance settings
# Can read (and optionally write to) koha-conf.xml
package Koha::Contrib::Common::Instance::Settings ;

use strict ;
use warnings ;

use Koha::Contrib::Common ;
use Koha::Contrib::Common::Instance ;
use XML::XPath ;

our %settings ;
our $instance_name = '' ;
our $xpath = '';

# Specify the instance whose settings we want to work with
sub init{
	my ( $self, $instance ) = @_ ;
	if ( Koha::Contrib::Common::Instance->exists( $instance ) ) {
		
		$instance_name = $instance ;
		
		my $path = Koha::Contrib::Common::KOHA_SITE_ROOT . $instance_name ;
		$xpath = XML::XPath->new( filename => $path . '/koha-conf.xml' ) ;
	}
	
	return $instance_name ne '' ;
}

# Retrieve a setting from the Koha instance config file
sub read{
	my ( $self, $setting_name ) = @_ ;
	
	return 0 unless $instance_name ;
	return 0 unless $setting_name ;
	
	$setting_name = '/yazgfs/config/' . $setting_name
		unless $setting_name =~ m/^\// ;
	
	my $setting_value = $xpath->findvalue( $setting_name ) ;
	
#	%settings{ $setting_name } = $setting_value ;
	
	return $setting_value ;
	
}

# Store a setting to the Koha instance config file
sub write{
	my ( $self, $setting_name, $setting_value ) = @_ ;
	return 0 if $instance_name eq '' ;
	
}

# Scan the Koha instance config file (internal function)
sub scan{
	my ( $self ) = @_ ;
	return 0 if $instance_name eq '' ;
	
}



1 ;
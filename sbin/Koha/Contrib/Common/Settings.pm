# Package for managing koha-common settings
# Can read (and optionally write to) koha-sites.conf
package Koha::Contrib::Common::Settings ;

use strict ;
use warnings ;

use Koha::Contrib::Common ;

our %settings = () ;

# Retrieve a setting from the koha-common config files
sub read{
	my Koha::Contrib::Common::Settings $self = shift ;
	my $setting_name = shift || '' ;
	
	# Scan the file(s) for settings unless we already have
	$self->scan() unless scalar( %settings );
	
	return $settings{$setting_name} ;
}

# Store a setting to the koha-common config files
sub write{

	my Koha::Contrib::Common::Settings $self = shift ;
	my $setting_name  = shift || '' ;
	my $setting_value = shift || '' ;
	
	# Scan the file(s) for settings unless we already have
	$self->scan() unless scalar( %settings );
}

# Scan the koha-common config files (internal function)
sub scan{
	
	my $config_line ;

	# First read defaults from koha-create
	if( open FILE, Koha::Contrib::Common::KOHA_COMMON_SCRIPT_PATH . '/koha-create' ) {

		while ( $config_line = <FILE> ) {
			if( $config_line =~ m/^([\w]+)\=\"([^\"]*)\"/ ) {
				$settings{$1} = $2 ;
			}
			
		}

		close FILE ;
	}
	
	# Then let custom settings override
	if( open FILE, Koha::Contrib::Common::KOHA_SYSTEM_ROOT . '/koha-sites.conf' ) {

		while ( $config_line = <FILE> ) {
			if( $config_line =~ m/([\w]+)\=\"([^\"]+)\"/ ) {
				$settings{$1} = $2 ;
			}
			
		}

		close FILE ;
	}
	
}



1 ;
# Core package - holds settings, constants, etc.

package KohaCommander ;

use strict;
use warnings;

use constant KOHA_SITE_ROOT => '/etc/koha/sites/' ;

# Default web interface files - comment this out to fall back to your vhost's DocumentRoot
# make sure this folder is readable by Apache if you are using it
use constant WEB_ROOT		=> '/usr/sbin/KohaCommander/www/' ;


# Don't edit this unless you've added a new constant (which you shouldn't)

our @EXPORT_OK = (
	'KOHA_SITE_ROOT',
	'WEB_ROOT'
) ;

our %EXPORT_TAGS = (
	common => [
		'KOHA_SITE_ROOT',
		'WEB_ROOT'
	]
) ;

1 ;
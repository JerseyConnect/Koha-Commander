#!/bin/sh

KOHA_COMMANDER_PATH=/usr/sbin/KohaCommander
KOHA_COMMANDER_USER=koha-commander
KOHA_COMMANDER_GROUP=koha-commander
HOSTNAME=`hostname -f`

#
# Create Koha Commander user
#

echo "Creating the Koha Commander user: $KOHA_COMMANDER_USER."

adduser --no-create-home \
	--disabled-login \
	--gecos "Koha Commander management user" \
	--home "${KOHA_COMMANDER_PATH}" \
	--ingroup "${KOHA_COMMANDER_GROUP}" \
	--quiet "${KOHA_COMMANDER_USER}"

echo "..done\n"

#
# Create KohaCommander directory (if needed) and copy non-install files there
#

echo "Creating Koha Commander directory: $KOHA_COMMANDER_PATH."

mkdir -p $KOHA_COMMANDER_PATH
cp -R ./sbin/* ${KOHA_COMMANDER_PATH}/

echo "..done\n"

#
# Change ownership of all files to koha-commander
#

echo "Giving Koha Commander files to the Koha Commander user."

chown -R ${KOHA_COMMANDER_USER}:${KOHA_COMMANDER_GROUP} ${KOHA_COMMANDER_PATH}/*

echo "..done\n"

#
# Create /tmp/koha-commander-sessions directory - owned by koha-commander, group www-data, perm 775 (770?)
#

echo "Creating session directory for web interface users."

mkdir /tmp/koha-commander-sessions
chown ${KOHA_COMMANDER_USER}:${KOHA_COMMANDER_GROUP} /tmp/koha-commander-sessions

echo "..done.\n";

echo "Building the koha-command wrapper."

#
# Make koha-command.pl executable
#
chmod +x ${KOHA_COMMANDER_PATH}/koha-command.pl

#
# Create a C wrapper for koha-command.pl so we can setuid in Perl >= 5.12
#
sed -i "s|KOHA_COMMANDER_PATH|${KOHA_COMMANDER_PATH}|g" ${KOHA_COMMANDER_PATH}/koha-command.c
cc -o ${KOHA_COMMANDER_PATH}/koha-command ${KOHA_COMMANDER_PATH}/koha-command.c

#
# Set ownership of C wrapper to root
#
chown root ${KOHA_COMMANDER_PATH}/koha-command

#
# Set setuid bit on C wrapper
#
chmod +s ${KOHA_COMMANDER_PATH}/koha-command

echo "..done\n"


#
# Prompt the user to make sure shadow access is needed
#

read -p "Are you using the Linux user database as your authentication source? (Y/n): " build_auth

if [ x"$build_auth" != xn -o x"$build_auth" != xn ]; then

	#
	# Add user to shadow group for PAM access (if using PAM for authentication -- would love to use pwauth instead, but distro copy only works with www-data user)
	#
	usermod -a -G shadow ${KOHA_COMMANDER_USER}
	
	#
	# Add PAM config (if using PAM for authentication)
	#
	cp ./install/pam-config/koha-commander /etc/pam.d/
	
	#
	# Update Apache vhost config
	#

else
	echo "WARNING: You must set up your authentication source and configure Koha Commander before it will run.\n"
fi


#
# Update Apache vhost config
#

echo "Adding your Koha Commander site to Apache."

sed "
 s/KOHA_COMMANDER_USER/${KOHA_COMMANDER_USER}/g
 s/KOHA_COMMANDER_GROUP/${KOHA_COMMANDER_GROUP}/g
 s|KOHA_COMMANDER_PATH|${KOHA_COMMANDER_PATH}|g
 s/SERVER_HOSTNAME/${HOSTNAME}/g" ./install/apache-config/koha-commander-admin > /etc/apache2/sites-available/koha-commander-admin
 
a2ensite koha-commander-admin

echo "..done.\n"

echo "All done!\n"

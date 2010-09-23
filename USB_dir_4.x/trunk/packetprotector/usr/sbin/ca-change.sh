#!/bin/sh
#
# /packetprotector/usr/sbin/ca-change.sh
#
# Script to change the CA info from the defaults
# (ie. Charlie and Packetprotector.org, etc.) to
# your own personal info.

# I want to get these from the web ui, thats the next step.
# Set the new variables to what you want
COUNTRY=US	# Two letter code
PROVINCE=CA	# Two letter code
CITY="Springfield"
ORG="Example"
EMAIL="you@example.com"
# Number of days for certificate expiration
# the default from Packetprotector is 7300
# Change the NEW_DAYS variable to what you want
DEFAULT_DAYS=7300
NEW_DAYS=7300

# Backup original files, just in case
if [ ! -d /etc/easy-rsa/bkup-files ] ; then
	mkdir /etc/easy-rsa/bkup-files
fi
cd /etc/easy-rsa
cp ./vars ./bkup-files
cp ./openssl.3 ./bkup-files
for i in `grep "countryName.*\= [A-Z][A-Z]" * | cut -d: -f1` ; do
	cp ./$i ./bkup-files
done

# load current variables (start with KEY_)
. ./vars

# Edit the vars file
sed -i "s/KEY_COUNTRY=$KEY_COUNTRY/KEY_COUNTRY=$COUNTRY/" ./vars
sed -i "s/KEY_PROVINCE=$KEY_PROVINCE/KEY_PROVINCE=$PROVINCE/" ./vars
sed -i "s/KEY_CITY=\"$KEY_CITY\"/KEY_CITY=\"$CITY\"/" ./vars
sed -i "s/KEY_ORG=\"$KEY_ORG\"/KEY_ORG=\"$ORG\"/" ./vars
sed -i "s/KEY_EMAIL=\"$KEY_EMAIL\"/KEY_EMAIL=\"$EMAIL\"/" ./vars

#  Edit the one file that doesnt have countryName (openssl.3),
#  then Use the countryName filelist and change everything else
sed -i "s/emailAddress.*\= $KEY_EMAIL/emailAddress\t\= $EMAIL/" ./openssl.3

# Get files with countryName, replace defaults with new variables.
for i in `grep "countryName.*\= [A-Z][A-Z]" * | cut -d: -f1` ; do
    sed -i "s/countryName.*\= $KEY_COUNTRY/countryName\t\= $COUNTRY/" $i
    sed -i "s/stateOrProvinceName.*\= $KEY_PROVINCE/stateOrProvinceName\t\= $PROVINCE/" $i
    sed -i "s/localityName.*\= $KEY_CITY.*/localityName\t\= \"$CITY\"/" $i
    sed -i "s/0.organizationName.*\= $KEY_ORG/0.organizationName\t\= \"$ORG\"/" $i
    sed -i "s/emailAddress.*\= $KEY_EMAIL/emailAddress\t\= \"$EMAIL\"/" $i
    # want to get $ORG to lowercase
    LOWERCASE_ORG=`echo "$ORG" | tr '[A-Z]' '[a-z]'`
    sed -i "s/commonName.*\= local.*/commonName\t\= local.$LOWERCASE_ORG/" $i
    sed -i "s/commonName.*\= radius.*/commonName\t\= radius.$LOWERCASE_ORG/" $i
done

# Get files with number of Days, replace defaults with new variables.
for i in `grep $DEFAULT_DAYS * | cut -d: -f1` ; do
    sed -i "s/days $DEFAULT_DAYS/days $NEW_DAYS/" $i
    sed -i "s/days.*\= $DEFAULT_DAYS/days\t\= $NEW_DAYS/" $i
done

#!/bin/bash

while :
 do
if [ -d "/var/lib/jenkins/secrets" ]
then
{
if [ -e "/var/lib/jenkins/secrets/initialAdminPassword" ]
then
TOKEN=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword) \
&& echo "$TOKEN"
exit
fi
}
fi
done
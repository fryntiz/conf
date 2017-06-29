#!/bin/sh

echo "Descargando y ejecutando instalador de composer..."

EXPECTED_SIGNATURE=$(wget -q -O - https://composer.github.io/installer.sig)
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_SIGNATURE=$(php -r "echo hash_file('SHA384', 'composer-setup.php');")

if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE"  ]
then
    >&2 echo 'ERROR: Invalid installer signature'
    rm composer-setup.php
    exit 1
fi

php composer-setup.php --quiet
RESULT=$?
rm composer-setup.php
echo "Instalando en /usr/local/bin/composer..."
sudo install -o root -g root composer.phar /usr/local/bin/composer
rm composer.phar
if [ "`sudo cat /etc/sudoers | tail -c1`" != "" ]
#if test `sudo cat /etc/sudoers | tail -c1`
then
    echo "" | sudo tee -a /etc/sudoers > /dev/null
fi
L="%sudo	ALL=!/usr/local/bin/composer"
if ! sudo cat /etc/sudoers | grep -qs "$L"
then
    echo "Desactivando el uso de composer con sudo..."
    echo "$L" | sudo tee -a /etc/sudoers > /dev/null
else
    echo "Uso de composer con sudo ya desactivado."
fi
exit $RESULT


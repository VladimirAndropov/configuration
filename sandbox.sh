#!/bin/sh
##
## Installs the pre-requisites for running edX on a single Ubuntu 12.04
## instance.  This script is provided as a convenience and any of these
## steps could be executed manually.
##
## Note that this script requires that you have the ability to run
## commands as root via sudo.  Caveat Emptor!
##

##
## Sanity check
##
if [[ `lsb_release -rs` != "14.04" ]]; then
   echo "This script is only known to work on Ubuntu 14.04, exiting...";
   exit;
fi

##
## Set ppa repository source for gcc/g++ 4.8 in order to install insights properly
##
sudo apt-get install -y python-software-properties
sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test

##
## Update and Upgrade apt packages
##
sudo apt-get update -y
sudo apt-get upgrade -y

##
## Install system pre-requisites
##
sudo apt-get install -y build-essential software-properties-common curl git-core libxml2-dev libxslt1-dev python-pip libmysqlclient-dev python-apt python-dev libxmlsec1-dev libfreetype6-dev swig gcc-4.8 g++-4.8
sudo pip install --upgrade pip==8.1.2
sudo pip install --upgrade setuptools==24.0.3
sudo -H pip install --upgrade virtualenv==15.0.2

##
## Update alternatives so that gcc/g++ 4.8 is the default compiler
##
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.8 50
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.8 50

## Did we specify an openedx release?
if [ -n "$OPENEDX_RELEASE" ]; then
  EXTRA_VARS="-e edx_platform_version=$OPENEDX_RELEASE \
    -e certs_version=$OPENEDX_RELEASE \
    -e forum_version=$OPENEDX_RELEASE \
    -e xqueue_version=$OPENEDX_RELEASE \
    -e configuration_version=$OPENEDX_RELEASE \
    -e demo_version=$OPENEDX_RELEASE \
    -e NOTIFIER_VERSION=$OPENEDX_RELEASE \
    -e INSIGHTS_VERSION=$OPENEDX_RELEASE \
    -e ANALYTICS_API_VERSION=$OPENEDX_RELEASE \
  $EXTRA_VARS"
  CONFIG_VER=$OPENEDX_RELEASE
else
  CONFIG_VER="master"
fi

##
## Clone the configuration repository and run Ansible
##
cd /var/tmp
git clone https://github.com/VladimirAndropov/configuration
cd configuration
git checkout $CONFIG_VER

## === Begin path of EdRuX ===========
##
sed -i 's/COMMON_SSH_PASSWORD_AUTH: "no"/COMMON_SSH_PASSWORD_AUTH: "yes"/' /var/tmp/configuration/playbooks/roles/common_vars/defaults/main.yml
sed -i 's/.so.3gf/.so.3/g' /var/tmp/configuration/playbooks/roles/edxapp/tasks/python_sandbox_env.yml
## sed -i 's/{{ elasticsearch_url }}/http:\/\/download.elasticsearch.org\/elastics\/elasticsearch\/{{ elasticsearch_file }}/' /var/tmp/configuration/playbooks/roles/elasticsearch/tasks/main.yml
##
sudo touch /etc/update-motd.d/51-cloudguest
##
sudo ln -s /usr/include/freetype2 /usr/include/freetype
##
## === End path of EdRux ===========


## !!! 
## Сделайте паузу перенесите из архива и поправьте

## а) Замените на название своего домена сточки с domen.my в
## /var/tmp/configuration/playbooks/roles/edxapp/defaults/main.yml 

## b)Посмотрите внутренности следующего файла особенно на размер создаваемого swap файла
## /var/tmp/configuration/playbooks/edx_sandbox.yml

## c)Измените следующий файл вставив свой пароль для mysql
## /root/.my.cnf

## d) Следующие сточки скрипта выполните как обычные команды в консоли для запуска установки 

##
## Install the ansible requirements
##
## cd /var/tmp/configuration
## sudo -H pip install -r requirements.txt

##
## Run the edx_sandbox.yml playbook in the configuration/playbooks directory
##
## cd /var/tmp/configuration/playbooks && sudo ansible-playbook -c local ./edx_sandbox.yml -i "localhost," $EXTRA_VARS
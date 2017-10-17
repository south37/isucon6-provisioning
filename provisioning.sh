#!/bin/bash

set -e

echo "Provisioning Start..."

cd $HOME
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update
sudo apt-get install -y --no-install-recommends ansible git aptitude golang-go tzdata make
rm -rf isucon6-qualify
git clone https://github.com/south37/isucon6-qualify.git
sed -i -e 's:--disable-phar::' isucon6-qualify/provisioning/image/ansible/02_xbuild.yml
(
  cd isucon6-qualify
  make
  ln -s isupam_linux bin/isupam
)
(
  cd isucon6-qualify/provisioning/image/ansible
  PYTHONUNBUFFERED=1 ANSIBLE_FORCE_COLOR=true ansible-playbook -i localhost, *.yml --connection=local -t dev
)
(
  cd isucon6-qualify/provisioning/image
  ./db_setup.sh
)
rm -rf isucon6-qualify
sudo usermod -G sudo -a -s /bin/bash isucon

echo "Provisioning Successful for image"

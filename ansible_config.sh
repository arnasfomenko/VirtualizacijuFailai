#!/bin/sh
apt-get update
apt-get dist-upgrade -y
apt-get install ansible
apt-get install opennebula-tools
cp /etc/ansible/ansible.cfg ~/.ansible.cfg
mkdir ~/my_ansible
touch my_ansible/hosts
sed -i '14s|.*|inventory      = $HOME/my_ansible/hosts|' ~/.ansible.cfg
#ssh-keygen -t rsa

CENDPOINT=https://grid5.mif.vu.lt/cloud3/RPC2
echo -n Type in your password for VU MIF cloud infrastructure:
read -s password
echo

CVMREZ=$(onetemplate instantiate "debian9"  --name webserver-vm  --user luch4001 --password $password  --endpoint $CENDPOINT)
CVMID_web=$(echo $CVMREZ |cut -d ' ' -f 3)

CVMREZ=$(onetemplate instantiate "debian9"  --name db-vm  --user luch4001 --password $password  --endpoint $CENDPOINT)
CVMID_db=$(echo $CVMREZ |cut -d ' ' -f 3)

CVMREZ=$(onetemplate instantiate "debian8-for-virtualization"  --name client-vm  --user luch4001 --password $password  --endpoint $CENDPOINT)
CVMID_client=$(echo $CVMREZ |cut -d ' ' -f 3)

echo "Waiting for VMs to RUN 20 sec."
sleep 20

$(onevm show $CVMID_web --user luch4001 --password $password  --endpoint $CENDPOINT >$CVMID_web.txt)
$(onevm show $CVMID_db --user luch4001 --password $password  --endpoint $CENDPOINT >$CVMID_db.txt)
$(onevm show $CVMID_client --user luch4001 --password $password  --endpoint $CENDPOINT >$CVMID_client.txt)

web_IP=$(cat $CVMID_web.txt | grep PRIVATE\_IP| cut -d '=' -f 2 | tr -d '"')
db_IP=$(cat $CVMID_db.txt | grep PRIVATE\_IP| cut -d '=' -f 2 | tr -d '"')
client_IP=$(cat $CVMID_client.txt | grep PRIVATE\_IP| cut -d '=' -f 2 | tr -d '"')

(echo [webserver];echo "$web_IP";echo [database];echo "$db_IP";echo [client];echo "$client_IP") > my_ansible/hosts

rm $CVMID_web.txt
rm $CVMID_db.txt
rm $CVMID_client.txt

apt-get install git
git clone https://github.com/chlukas/VirtualizacijuFailai.git
shopt -s dotglob nullglob
mv VirtualizacijuFailai/* my_ansible/
rmdir VirtualizacijuFailai

touch dbIP.txt
echo $db_IP > dbIP.txt
mv dbIP.txt my_ansible


echo "GRANT ALL ON virtualizacijos.* TO 'root'@'$web_IP' IDENTIFIED BY 'root'" >> my_ansible/DB_Data.sql

exit 0
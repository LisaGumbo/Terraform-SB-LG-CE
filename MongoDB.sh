sudo yum update -y
echo "name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/amazon/2/mongodb-org/5.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-5.0.asc" >> sudo nano /etc/yum.repos.d/mongodb-org-5.0.repo

# echo -e "[mongodb-org-5.0]\nname=MongoDB Repository\nbaseurl=https://repo.mongodb.org/yum/amazon/2/mongodb-org/5.0/x86_64/\ngpgcheck=1\nenabled=1\ngpgkey=https://www.mongodb.org/static/pgp/server-5.0.asc" > /etc/yum.repos.d/mongodb-org-5.0.repo

sudo yum install -y mongodb-org
which mongo
sudo systemctl status mongod
echo "#  bindIp: 127.0.0.1  # Enter 0.0.0.0,:: to bind to all IPv4 and IPv6 $
bindIpAll: true" >> sudo nano /etc/mongod.conf
# sudo nano /etc/mongod.conf
# # network interfaces
# net:
#   port: 27017
# #  bindIp: 127.0.0.1  # Enter 0.0.0.0,:: to bind to all IPv4 and IPv6 $
#   bindIpAll: true

sudo systemctl start mongod
sudo systemctl status mongod
sudo systemctl enable mongod
#mongoURI=mongodb://<PUBLIC_IPv4_ADDRESSS>:27017

#! /bin/bash
# chmod 400 lisagumbo-ec2-keypair.pem
# ssh -i "lisagumbo-ec2-keypair.pem" ec2-user@3.91.186.6
sudo yum update -y
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash && . ~/.nvm/nvm.sh && nvm install 16.13.0 && nvm use 16.13.0 && node -e "console.log('Running Node.js ' + process.version)"
sudo yum install git && git clone https://github.com/gSchool/sf-t4-pomotodo-fe.git && cd sf-t4-pomotodo-fe && npm install
#echo "REACT_APP_API_URL=http://localhost:5000"
npm run build
npm install -g serve
sudo yum install libcap-devel
sudo setcap cap_net_bind_service=+ep /home/ec2-user/.nvm/versions/node/v16.13.0/bin/node
serve -s build -l 80

#Check Deploy - Before we can build the app, change the API url variable in our .env file to point to our deployed backend
#sudo nano .env
#npm run build
#npm install -g serve

# sudo yum install httpd -y
# sudo systemctl start httpd
# sudo systemctl enable httpd
# echo "The page was created by the user-data" | sudo tee /var/www/html/index.html

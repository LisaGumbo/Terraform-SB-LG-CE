sudo yum update -yum
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash && . ~/.nvm/nvm.sh && nvm install 16.13.0 && nvm use 16.13.0 && node -e "console.log('Running Node.js ' + process.version)"
sudo yum install git
git clone https://github.com/gSchool/sf-t4-demo-pomotodo-be.git && cd sf-t4-pomotodo-be && npm install
echo "mongoURI=mongodb://<PUBLIC_IPv4_DATABASE>:27017" >> sudo nano .env
npm start
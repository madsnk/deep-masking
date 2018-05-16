#First update and install pip, virtualenv etc.
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y install pip
export LC_ALL=C
echo 'export LC_ALL=C' >> ~/.bashrc 
pip install --upgrade pip
pip install virtualenv
virtualenv -p python3 venv
. venv/bin/activate
pip install jupyter
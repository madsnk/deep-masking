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

#Download and install cuda 9.0 and cudnn 7.0
#https://yangcha.github.io/CUDA90/
wget http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/cuda-repo-ubuntu1604_9.0.176-1_amd64.deb
wget http://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1604/x86_64/libcudnn7_7.0.5.15-1+cuda9.0_amd64.deb
wget http://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1604/x86_64/libcudnn7-dev_7.0.5.15-1+cuda9.0_amd64.deb
wget http://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1604/x86_64/libnccl2_2.1.4-1+cuda9.0_amd64.deb
wget http://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1604/x86_64/libnccl-dev_2.1.4-1+cuda9.0_amd64.deb
sudo dpkg -i cuda-repo-ubuntu1604_9.0.176-1_amd64.deb
sudo dpkg -i libcudnn7_7.0.5.15-1+cuda9.0_amd64.deb
sudo dpkg -i libcudnn7-dev_7.0.5.15-1+cuda9.0_amd64.deb
sudo dpkg -i libnccl2_2.1.4-1+cuda9.0_amd64.deb
sudo dpkg -i libnccl-dev_2.1.4-1+cuda9.0_amd64.deb
sudo apt-get update
sudo apt-get install -y cuda=9.0.176-1
sudo apt-get install -y libcudnn7-dev
sudo apt-get install -y libnccl-dev
rm *.deb
export PATH=/usr/local/cuda-9.0/bin${PATH:+:${PATH}}
export LD_LIBRARY_PATH=/usr/local/cuda-9.0/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

echo 'export PATH=/usr/local/cuda-9.0/bin${PATH:+:${PATH}}' >> ~/.bashrc 
echo 'export LD_LIBRARY_PATH=/usr/local/cuda-9.0/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}' >> ~/.bashrc 

#Setup jupyter config
echo "c.NotebookApp.allow_origin = '*'
c.NotebookApp.base_url = '/notebook'
c.NotebookApp.password = 'sha1:7ce4ce303883:5be4dcd79f5a56c93be056dc7b2b48bec39a096b'
c.NotebookApp.port = 8888
" >> ~/.jupyter/jupyter_notebook_config.py

echo "Enter your linux name and press [ENTER]: "
read name
echo "Add the following to the file: /etc/systemd/system/jupyter.service"
echo "------------------------------
[Unit]
Description=Jupyter Notebook

[Service]
Type=simple
PIDFile=/run/jupyter.pid
ExecStart=/home/$name/venv/bin/jupyter-notebook --config=/home/$name/.jupyter/jupyter_notebook_config.py
User=$name
Group=$name
WorkingDirectory=/home/$name/
Restart=always
RestartSec=10
#KillMode=mixed

[Install]
WantedBy=multi-user.target
------------------------------"

echo "Add the following to the file: /etc/systemd/system/tensorboard.service"
echo "------------------------------
[Unit]
Description=Tensorboard

[Service]
Type=simple
PIDFile=/run/tensorboard.pid
ExecStart=/home/$name/venv/bin/tensorboard --logdir=/home/$name/logs/
User=$name
Group=$name
WorkingDirectory=/home/$name/
Restart=always
RestartSec=10
#KillMode=mixed

[Install]
WantedBy=multi-user.target
------------------------------"

sudo systemctl daemon-reload
sudo systemctl enable jupyter.service
sudo systemctl enable tensorboard.service

sudo apt-get install -y nginx

echo "Add the following block to server: /etc/nginx/sites-enabled/default (or sites-available and symlink)"

echo "
location / {
   proxy_pass http://localhost:6006/;
   proxy_http_version 1.1;
}

location /notebook {
    proxy_pass http://localhost:8888;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header Host $http_host;
    proxy_http_version 1.1;
    proxy_redirect off;
    proxy_buffering off;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_read_timeout 86400;
}"

sudo systemctl restart nginx

#Install unzip
sudo apt-get install unzip
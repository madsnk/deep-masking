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
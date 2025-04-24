# Acropora millepora developmental transcriptome visualisation

## To update the deployed app

First login to the dockerserver

```bash
ssh ubuntu@amil2dev.mmb.group
```

Update the code via git

```bash
cd dockerserver/apps/amil2_dev
git pull
```

Update shiny data

```bash
rsync -avur shiny_data/ ubuntu@amil2dev.mmb.group:~/dockerserver/apps/amil2_dev/shiny_data/
```

Build and start docker containers

```bash
cd ~/dockerserver

sudo docker-compose build
sudo docker-compose up
# Once up you can cancel and then run start to have it run in daemon mode
sudo docker-compose start
```


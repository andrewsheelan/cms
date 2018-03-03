# README

* Install Docker (For) Amazon Linux

```unix
sudo yum update -y
sudo yum install -y docker
sudo service docker start
sudo usermod -a -G docker ec2-user
```

* Log out and log back in again to check if ec2-user has access

```unix
docker info
```

* Install Docker Compose (For) Amazon Linux

```unix
sudo curl -L https://github.com/docker/compose/releases/download/1.19.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

* Install git (For) Amazon Linux

```unix
sudo yum install git
```

* Download this repo

* Copy & or Add .env file inside containers/production/.env from env_sample

* Build and Run using docker

```unix
sudo service docker start
docker-compose up
```

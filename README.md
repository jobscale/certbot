### example container
```
git clone https://github.com/jobscale/certbot.git
cd certbot
main() {
  docker build . -t local/certbot
  docker run --rm --name certbot -it local/certbot bash
} && main
```

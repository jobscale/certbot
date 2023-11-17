### example container
```
git clone git@github.com:jobscale/certbot.git
cd certbot
main() {
  docker build . -t local/certbot
  docker run --rm --name certbot -it local/certbot bash
} && main
```

### run
```
./certbot
```

### dns records
```
./simple
```


# Launch local build environmet
Requirements:
 * [docker]
 * [docker-compose]

To launch shell in build environment with current code run in project root:
```bash
$ sudo docker-compose run app /bin/bash
```
It may be convenient to set environment variables for build during launch:
```bash
$ sudo docker-compose run -e PARALLEL_TEST_PROCESSORS=4 app /bin/bash
```
From here you can run the whole test suite
```bash
(container)$ make test
```
Or a single spec
```bash
(container)$ make rspec spec=spec/features/cdr/cdr_exports/new_cdr_export_spec.rb
```
And build debian package
```bash
(container)$ make package
```
Passwordless sudo is installed in container:
```bash
(container)$ sudo apt update && sudo apt install -y vim
```
To relaunch environment with new changes
```bash
(container)$ exit
$ sudo docker-compose build
$ sudo docker-compose run app /bin/bash
```
To shutdown and clean environment
```bash
(container)$ exit
$ sudo docker-compose down
```

[docker]: <https://docs.docker.com/install/>
[docker-compose]: <https://docs.docker.com/compose/>

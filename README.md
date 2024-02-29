gradebook-docker
================

This repository contains build materials for the development docker image gradebook-dev/gradebook. You can run it as:

```bash
docker run --platform linux/amd64 --rm \
    -p 3839:3839 -p 8888:8888 \
    -it gradebook-dev/gradebook:latest
```

The `--platform` option is necessary on computers with Apple silicon. The gradebook application is listening on port 3839. Jupyter Lab is listening on port 8888, and it is only necessary if you would like to proxy RStudio and/or Shiny for doing rapid development of the application.

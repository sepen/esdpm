# esdpm 

Easy Smart Deployment Manager

## Install

Run the install script with root privileges:
```
$ sudo ./install
Installing esdpm to /opt/bin/esdpm
Installing data files to /opt/esdpm
```

Alternatively you can install it to another location:
```
sudo PREFIX=/usr/local ./install.sh 
Installing esdpm to /usr/local/bin/esdpm
Installing data files to /usr/local/esdpm
```

## Usage

Show help information:
```
$ esdpm help
Usage: esdpm command [target] <[option(s)]>

Where commands are:
  init    [GIT_LOCAL_DIR] [GIT_REPO_URL]
  update  [GIT_LOCAL_DIR]
  switch  [GIT_LOCAL_DIR] [GIT_REPO_BRANCH]
  reset   [GIT_LOCAL_DIR] [GIT_REPO_HASH]
  status  [GIT_LOCAL_DIR] <-u|-h|-b|--url|--hash|--branch>
  avail   [GIT_LOCAL_DIR] <-a|--all>
  env

Options for all commands:
  -d|--debug
  -v|--verbose

Examples:
  esdpm init   /var/www/sites/sample.domain https://gitserver.domain/git/test.git
  esdpm update /var/www/sites/sample.domain
  esdpm switch /var/www/sites/sample.domain dev-master --verbose
  esdpm reset  /var/www/sites/sample.domain f8864e8dc63af915b869ffe0ef357c26ccee1470
  esdpm status /var/www/sites/sample.domain --hash
  esdpm avail  /var/www/sites/sample.domain --all
  esdpm env
```


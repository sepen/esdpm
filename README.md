# esdpm 

Easy Smart Deployment Manager


## Usage

Show help information:

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
	  esdpm init   /var/www/vhosts/test http://server.domain/git/test.git
	  esdpm update /var/www/vhosts/test
	  esdpm switch /var/www/vhosts/test dev-master --verbose
	  esdpm reset  /var/www/vhosts/test f8864e8dc63af915b869ffe0ef357c26ccee1470
	  esdpm status /var/www/vhosts/test --hash
	  esdpm avail  /var/www/vhosts/test --all
	  esdpm env

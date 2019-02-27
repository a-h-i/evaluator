

## Generating an ssh key
`ssh-keygen -t rsa -b 4096 -c 'comment about instance' -f ~/.ssh/ident_file`


## Tunnel to Database from a webserver instance
`ssh -L 127.0.0.1:5432:127.0.0.1:5432 db.metguc -i ~/.ssh/ident_file`

## Allowing someone to connect to this instance over SSH

append copy pasted contents of ident_file.pub to `~/.ssh/authorized_keys`

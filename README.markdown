# Go Menu

The Go Menu is a command line utility providing a menu driven interface to
connect to various servers. It uses a CSV file to create a [dialog][dialog] for
selecting a given resource.

This may be useful if:

- You have a lot of servers to which you frequently connect via SSH.
- You run an SSH server from which connections to other servers are allowed.
- You enjoy graphical menus.

## Requirements

The Go Menu currently requires [Bash][bash] and [dialog][dialog].

[bash]: http://en.wikipedia.org/wiki/Bash_(Unix_shell) "Bash Shell"
[dialog]: http://en.wikipedia.org/wiki/Dialog_(software) "Dialog Command"

## Installation

Simply run `make install` from the gomenu directory. By default the `go`
command is installed in `/usr/local/bin`. But you can change this by specify a
prefix like so:

    make install PREFIX=/path/to/my/preferred/bin

## Configuration

The go command reads resources from a CSV file located in one of the following
locations:

- $HOME/.gomenu/resources.csv
- /etc/gomenu/resources.csv
- /opt/gomenu/resources.csv

These files are read in the order above. The columns of the CSV are as follows:

- `name` - The name of the resource. Required. Cannot contain a space.
- `organization` - A short code or abbreviation representing the organization
  that owns the resource. Required. Limited to 3 or 4 characters.
- `comment` - A brief comment or description of the resource. Required. Limited
  to about 30 characters.
- `host` - The actual host name that is the target of the connection. Required.
- `port` - TCP port. Required, but defaults to 22.
- `user` - The user name for the connection. Optional. Defaults to `whoami`.
- `protocol` - Not implemented. Defaults to ssh. This is a placeholder for
  possibly implementing other protocols in the future.

Here some examples:

	Academic,University of Education,List Server,listserv.uof.edu
	MsPiggy,ACME Inc.,Windows File Server,mspiggy.example.com
	RedHat6,ABC Corp,Web Server,redhat6.example.com,4894
	Venus,ACME Inc,Web Server,venus.example.com,4894,bob

## License

The Go Menu is licensed under the [BSD3 License][bsd3]. See LICENSE.txt for more
info.

[bsd3]: https://opensource.org/licenses/BSD-3-Clause "BSD3 License"

# Strap: The Ultimate Dotfiles Framework

> **_NOTE:_**  Strap is currently being ported from a previous version.  It currently works, but it doesn't install very much.  Yet.

`strap` is a dotfiles framework that is designed to do one thing extremely well: 

Strap will take your machine from a zero state (e.g. right after you buy it or receive it from your 
employer) and install and configure everything you want on your machine in a *single command*, in *one shot*.  Run 
strap and you can rest assured that your machine will have your favorite command line tools, system defaults, gui 
applications, and development tools installed and ready to go.

Strap was initially created to help newly-hired software engineers get up and running and
productive in *minutes* after they receive their machine instead of the hours or days it usually takes.  But Strap
isn't limited to software engineering needs - anyone can use Strap to install what they want - graphics software, 
video editing, web browsers, whatever.

## Watch It Run!

Here's a little `strap run` recording to whet your appetite for the things Strap can do for you:

[![asciicast](https://asciinema.org/a/188040.png)](https://asciinema.org/a/188040)


## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/ultimatedotfiles/strap/master/install | bash
```

Then set the following in ~/.bash_profile, ~/.bashrc or ~/.zshrc (or whatever you prefer):

```bash
export PATH="$HOME/.strap/releases/current/bin:$PATH"
```

## Overview

How does strap work?

### It's Just Bash, Man

Strap is a command line tool with a set of sub-commands and plugins written in 100% Bash scripts to ensure it can run
out of the box on pretty much any Mac or Linux machine created in the last few years.  It doesn't require Ruby, 
Python, Java or any other tool to be installed on your box first in order to run (but you can install those 
with Strap as you see fit). Strap should work on any machine with Bash 3.2.57 or later.

That said, don't worry if you prefer ksh or any other shell.  Bash is just used to write and run strap - you 
can install and use ksh or any other shell you prefer.

### Built on the Shoulders of Giants

Don't worry, we're not re-inventing the wheel.
 
Strap is mostly a set of really convenient wrapper functions
and commands built on top of homebrew.  Strap fills a really important gap: while homebrew is primarily concerned with 
managing packages on your machine, Strap leverages that and also enables user and machine-specific configuration for 
those packages.

For example, you might have installed a homebrew package and then in its output, that package says something like:

> After this is installed, modify your ~/.bash_profile or ~/.zshrc to include the following init line...

Well, that's nice, but shouldn't that part be automated too?  Also what about operating system default configuration?
That's not a software package, it's configuration, and homebrew mostly doesn't address those concerns.  But Strap does.

Strap is homebrew + automating 'the last mile' to get you to an ideally-configured machine without
having to work. It is basically: "I want to use one command and that's it.  If you need something from me, 
prompt me, but don't make me do any work at all beyond that."  Now that's what we're talking about!

### Declarative Configuration

Even though Strap is built with bash, you don't have to know bash at all to use it.  Once installed, Strap looks 
at an easy-to-understand `strap.yml` configuration file that lists every thing you want installed or modified
on your system.

It reads this list and *converges* your machine to have the same state represented in the `strap.yml` file:  If 
something in the strap.yml file already exists on your machine, strap just skips it.  If something in the file doesn't
exist yet, strap will install it for you.  It can automatically upgrade things for you too.

This means Strap is *idempotent* - you can run it over and over again, and your machine will be in your desired state
every time you run it. Nice! 

Based on this, you can (and should) run strap regularly to ensure your system is configured how you want it and your 
software is up-to-date at all times.  

### Just Plug It In, Plug It In

Strap was purposefully designed to be lightweight by using a very lean core and providing most functionality in
the form of plugins.  Why is this important?

*Because you can extend Strap for your needs*.

That's right - if Strap doesn't have something you need, you can write a simple bash plugin to provide the 
functionality you need.

And just as cool - Strap provides an import-like functionality for plugins:  a plugin can depend on other plugins and
*import* these plugins' library functions.  This allows you to extend and enhance functionality that may not be in Strap.

And this helps prevent lock-in.  It allows you to get what you need on your timeline without waiting on anyone.  And it 
allows for a community to grow and provide open-source plugins we can all benefit from.  And plugins are just git 
repositories, so they can be added as simply as creating a new git repository.  And because GitHub is pretty much the
de-facto git origin for open-source software these days, Strap has native git and GitHub integration too!  Awesome!

### Customization and Privacy

Because Strap is pluggable, you can 'point' it to any strap-compatible git repository.  This means that you can
have your own git repo that represents the customizations you care about.  And you can share this with the world so 
others can have awesome machine setups just like you.

But sometimes you (or companies) don't want the world to see what is installed on a developer machine for privacy or 
security reasons.  If this is a concern for you, you can host your Strap configuration and plugins in a private git 
repository. Because of Strap's native GitHub integration, it can securely authenticate with GitHub and utlize your 
private git repositories (assuming your GitHub user account has access to said repositories).

You can even mix and match repositories: use Strap's defaults, then add in your personal public repository and also 
add your company's private repository.  Any number of sources can be used during a strap run for machine convergence.

## Usage

Strap is a command line tool.  Assuming the strap installation's `bin` directory is in your `$PATH` as shown in the
installation instructions above, you can just type `strap` and see what happens:

```bash
me@myhost:~$ strap
strap version 0.0.1
usage: strap [options...] <command> [command_options...]
 
commands:
   help        Display help for a command
   run         Runs strap to ensure your machine is fully configured
   version     Display the version of strap
 
See `strap help <command>' for information on a specific command.
For full documentation, see: https://github.com/ultimatedotfiles/strap
```

The `strap` command itself is quite simple - it basically loads some common environment settings and that's pretty 
much it. From there, it delegates most functionality to sub-commands, very similar to how the `git` command-line tool 
works.  The sub-commands available to you are the combined set of Strap's built-in sub-commands and any sub-commands 
made available by any Strap plugins you reference.

## Plugins

Strap is designed to have a lean core with most functionality coming from plugins.  This section explains what plugins
are, how to use them, and how to write your own plugin(s) if you want to add or extend Strap functionality.

### What is a Strap Plugin?

A strap plugin is just a git repository that conforms to a file structure that Strap can 
understand.  This means Strap can pull in functionality from anywhere it can access a git repository via a simple
`git clone` command based on the plugin's unique identifier.

### Strap Plugin Identifier

A Strap plugin identifier is a string that uniquely identifies a plugin's source.

The plugin identifier string format MUST adhere to the following format:

    strap-plugin-id = git-protocol-uri[@version]

where:
  * `git-protocol-uri` equals a [Git Protocol URI](https://git-scm.com/book/en/v2/Git-on-the-Server-The-Protocols)
  * `@version` is an optional version designation suffix starting with the string literal `@` followed by a `version`
    string. If present, the `version` string MUST:
    * equal a tag name in the specified git repository identified by `git-protocol-uri`
    * conform to the semantic version name scheme defined in the
      [Semantic Versioning 2.0.0](https://semver.org/spec/v2.0.0.html) specification.

#### Strap Plugin Identifier with `@version`

Example:

    https:://github.com/acme/hello@1.0.2
    
This tells strap to use the plugin source code obtained by (effectively) running:

```bash
git clone https://github.com/acme/hello
cd hello
git checkout tags/1.0.2
```

#### Strap Plugin Identifier without `@version`
      
If there is not a `@version` suffix in a `strap-plugin-id`, a `@version` value of `@LATEST` will be assumed and the
git repository's default branch will be used as the plugin source.

For example, consider the following Strap plugin id:

    https:://github.com/acme/hello
    
This indicates the plugin source code will be obtained by (effectively) running:

```bash
git clone https://github.com/acme/hello
```
 
and no specific branch will be checked out (implying the default branch will be used, which is `master` in most cases).

> **WARNING**:
> 
> It is *strongly recommended to always specify a `@version` suffix* in every strap plugin idenfier to ensure
> deterministic (repeatable) behavior.  Omitting `@version` suffixes can cause errors or problems
> during a `strap` run.  Omission can be useful while developing a plugin, but it is generally recommended to provide
> a `@version` suffix at all other times.

### Strap Plugins Directory

Any 3rd-party plugin referenced by you (or by other plugins) that are not included in the Strap installation 
are automatically downloaded and stored in your `$HOME/.strap/plugins` directory.

This directory is organized according to the following rules based on `strap-plugin-id`s.

* The URI host part of the id is parsed and split up (tokenized) into a list of separate string elements whenever a 
  dot character ( `.` ) is encountered.  For example, the string `github.com` becomes the list `[github, com]`

* The list order is then reversed.  For example list `[github, com]` becomes list `[com, github]`

* The new (now reversed) list elements are joined together with the forward-slash ( `/` ) character to form a single 
  string. For example, list `[com, github]` becomes the string `com/github`

* The resulting string is appended to the string `$HOME/.strap/plugins/`.  For example: `com/github` becomes 
  `$HOME/.strap/plugins/com/github`

* The uri path in the Strap Plugin ID is appended to the resulting string.
  
  For example, a strap plugin id of `https://github.com/acme/hello` has a URI path of `/acme/hello`.  This implies the 
  resulting string is `$HOME/.strap/plugins/com/github/acme/hello`
* A forward-slash character ( `/` ) and then the `version` string is appended to the resulting string.  If no version 
  is found the string literal `LATEST` is used.
  
  For example, `https://github.com/acme/hello@1.0.2` becomes the string 
  `$HOME/.strap/plugins/com/github/acme/hello/1.0.2` and `https://github.com/acme/hello` becomes the string 
  `$HOME/.strap/plugins/com/github/acme/hello/LATEST`
  
* The resulting string is used to create the directory where that plugin's code will be downloaded, for example:
  
  `mkdir -p $HOME/.strap/plugins/com/github/acme/hello/1.0.2`

### Strap Plugin Structure

A strap plugin is a git repository with the following directories at its root:

* `cmd` is optional and may contain sub-commands that strap can execute.
* `hooks` is optional and may contain executable scripts that strap can run during various lifecycle phases.
* `lib` is optional and may contain scripts which export variables and functions that can be used by other plugins.

Assuming `https://github.com/acme/hello` was a strap plugin repository, here is an example of what its directory 
structure might look like:

```
cmd/
    hello
hooks/
    run
lib/
    hello.sh
```

The above tree shows the following:

* `cmd/hello` is an executable script that can be executed as a strap sub-command.  That is, a strap user could
  type `strap hello` and strap would delegate execution to the `cmd/hello` script.  When committing this file to 
  source control, ensure that the file's executable flag is set, for example `chmod u+x cmd/hello`.

* `hooks/run` is an executable script that will execute when `strap run` is called. For example, if a strap user types
  `strap run` to kick off a run, strap will in turn invoke `hooks/run` as part of that execution phase.  Scripts in 
  the `hooks` directory must match exactly the name of the strap command being run.  Additionally, when committing 
  this file to source control, also ensure that the file's executable flag is set, for example `chmod u+x hooks/run`.

* `lib/hello.sh` is a bash script that may export shell variables and functions that can be sourced (used) by other 
  plugins
  
  For example, if `lib/hello.sh` had a function definition like this:
  
      com::github::acme::hello() { 
        echo "hello"
      }
      
  other plugins could *import* `hello.sh` and then they would be able to invoke `com::github::acme::hello` when they 
  wanted.
  
  We will cover how to import plugin library scripts soon.

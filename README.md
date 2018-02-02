Daily Shells - Commonly needed scripts
======================================

Author: Cristian Stroparo

License: To be defined; meanwhile it is licensed solely according to the author's rules.

---

The _DS - Daily Shells Library_ is a collection of useful shell routines in the form of functions and scripts. Several subjects are covered relating but not limited to file manipulation, tech ops, text processing ...

Currently the ___Bash___ and ___Zsh___ shells are supported.

Some features of this project replicate GNU tools features and those were intentional as to have this possibilities in a non-GNU environment. (Perhaps you are on IBM AIX where policies or sysadmins do not allow for the GNU toolbox for AIX etc.)

Help
----

The dshelp function is the help system entry point. It will output something like this:

```
dsgetfunctions - list daily shells' functions
dsgetscripts - list daily shells' scripts
dshelp - display this help messsage
dsinfo - display environment information
dsversion - display the version of this Daily Shells instance
```

__Important__

___Soon the dshelp command will accept the name of a function or script as an argument and will display its corresponding help and/or usage message.___

Installation
------------

### Automatic

With curl:

```bash
bash -c "$(curl -LSf -o - 'https://raw.githubusercontent.com/stroparo/ds/master/setup.sh')" && . ~/.ds/ds.sh
```

If you do not have curl but have wget:

```bash
bash -c "$(wget -O - 'https://raw.githubusercontent.com/stroparo/ds/master/setup.sh')" && . ~/.ds/ds.sh
```

In restrictive environments with no SSL recognition, allow insecure download:

```bash
FORCE=true bash -c "$(curl -LSf -k -o - 'https://raw.githubusercontent.com/stroparo/ds/master/setup.sh')" && . ~/.ds/ds.sh
```

Last resort as maybe your network will allow downloading zip files:

```bash
curl -LSf -k -o /tmp/ds.zip \
  https://github.com/stroparo/ds/archive/master.zip \
  && unzip /tmp/ds.zip -d "$HOME" \
  && cd "$HOME"/ds-master \
  && [ "$(basename "$PWD")" = 'ds-master' ] \
  && ./setup.sh -f
```

### Manual

You might want to install DS manually when there is a network restriction such as no Internet access for the host etc.

Execute:

1. Create the directory to house the final install which the official DS_HOME variable will point to.
2. Place the files in that DS_HOME directory.
3. Source **ds.sh** in your shell profile i.e.

* .bashrc
* .zshrc
* .profile
* Etcera

The default DS_HOME is $HOME/.ds (~/.ds) so if you install in there, just source ds.sh:

```bash
source ~/.ds/ds.sh
```

Otherwise, specify the directory (after sourcing it will be pointed to by the $DS_HOME environment variable) both as ds.sh's dirname as well as the last argument:

```bash
source {dir}/ds.sh {dir}
```

Plugins
-------

Nowadays lots of software are installed directly from GitHub or other online repositories. In the same spirit, the plugin mechanism for DS aims to be as straightforward as it gets by just cloning a repository and copying it over on top of $DS_HOME, the root Daily Shells directory.

The script that performs this is ```dsplugin.sh``` (also aliased to just ```dsplugin```).

It expects ```user/repo``` as the argument and it will use ___github.com___ as the default. To use another domain just prepend it with a slash like in ```domain/user/repo``` (exactly as in an HTTPS clone URL).

### Examples

```bash
dsplugin stroparo/ds-extras
```

```bash
dsplugin stroparo/ds-stroparo
```

Usage & Examples
----------------

### Aggregate a file

```bash
getmax fieldsep field files...
```

```bash
getmin fieldsep field files...
```

```bash
getsum fieldsep field files...
```

### Append a string to a file only once

```bash
appendunique string file1 file2 ...
```

### End of line: windows to linux

```bash
dos2unix file1 file2 ...
```

### Grep context emulation (GNU grep's -A, -B & -C options)

```bash
grepc [-a afterlines] [-b beforelines] [-c contextlines]
```

Use -a, -b and -c to emulate GNU grep's -A, -B and -C options, respectively.

Default behavior is ```-c 10```.

### Grepping a process

```bash
pgr ExtendedREGEX
```

### INI file section extraction

```bash
getsection sectionpattern filename
```

File ab.txt:

```
[a]
b=1
c=2

[d]
e=3
f=4
```

```bash
getsection a ab.txt
```

Will output:

```
b=1
c=2
```

### Looping commands

```bash
loop command [arguments ...]
```

### Path munging

```bash
pathmunge [-v varname] [-x] {path} [path2 [path3 ...]]
```

* ```-v varname``` causes the ```varname``` variable to be munged instead of the default (```PATH```)
* ```-x``` causes the variable to be exported

### Printing fields with awk

```bash
printawk [-F fieldsep] fieldno1 [fieldno2 ...]
```

* ```-F fieldsep``` works (as in awk) e.g. ```printawk -F, 1 2 ...```

Example:

```bash
printawk 1 3 5
```

Prints fields 1, 3 and 5

### Rename files in a tidy fashion

```bash
rentidy {dir}
```

Renames files and directories recursively at {dir}.

Underscores, camel case instances and other special characters are substituted by a hyphen separator.

### User confirmation and input

```bash
userconfirm message
```

```bash
userinput message
```

Input will be stored in the ```userinput``` variable

```bash
validinput {message} {ere-extended-regex}
```

Input will be stored in the ```userinput``` variable; prompts user for the input repeatedly until it matches the regular expression


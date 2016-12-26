DS - Daily Shells Library
=========================

Author: Cristian Stroparo

License: To be defined; meanwhile it is licensed solely according to the author's rules.

---

Installation
------------

### Automatic

Either:

```bash
curl -o - 'https://raw.githubusercontent.com/stroparo/ds/master/setup.sh' | bash
```

or:

```bash
wget 'https://raw.githubusercontent.com/stroparo/ds/master/setup.sh' -O - | bash
```

### Manual

When there is a restriction such as no Internet access for the host you might want to install DS manually.

Execute:

1. Create the directory to house the installation, which will be known as and pointed to by the DS_HOME variable.
2. Place the files in that DS_HOME directory.
3. Source **ds.sh** in your shell profile i.e.

* .bashrc
* .profile
* Etcera

The default DS_HOME is $HOME/.ds (~/.ds) so if you install in there, just source ds.sh:

```bash
source ~/ds.sh
```

Otherwise, specify the directory (after sourcing, $DS_HOME will point to it) both in the filename and as the first argument:

```bash
source {dir}/ds.sh {dir}
```


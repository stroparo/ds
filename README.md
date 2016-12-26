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

1. Create the directory to house the installation, which will be the DS_HOME.
2. Place the files in that DS_HOME directory.
3. Source **ds.sh** in your shell profile i.e.

* .bashrc
* .profile
* Etcera

The default directory for DS is $HOME/.ds so if you install in there, just source ds.sh:


```bash
source ~/ds.sh
```

Otherwise, specify the directory both in the filename and as the first argument:

```bash
source {dir}/ds.sh {dir}
```


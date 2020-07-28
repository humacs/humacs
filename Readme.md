- [Humacs](#sec-1)
  - [Install](#sec-1-1)
  - [resulting symlinks](#sec-1-2)


# Humacs<a id="sec-1"></a>

## Install<a id="sec-1-1"></a>

Can be to pretty much anywhere

```shell
git clone --recursive https://github.com/humacs/humacs
cd humacs
./install.sh
```

## resulting symlinks<a id="sec-1-2"></a>

```shell
ls -laF ~/ | grep humacs | awk '{print $9, $10, $11}'
```

    lrwxr-xr-x    1 hh    staff        31 28 Jul 09:50 .emacs@ -> /Users/hh/humacs/chemacs/.emacs
    lrwxr-xr-x    1 hh    staff        31 28 Jul 10:58 .emacs-profile@ -> /Users/hh/humacs/.emacs-profile
    lrwxr-xr-x    1 hh    staff        35 28 Jul 10:58 .emacs-profiles.el@ -> /Users/hh/humacs/.emacs-profiles.el
    drwxr-xr-x   14 hh    staff       448 28 Jul 12:16 humacs/

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

    .emacs@ -> /Users/hh/humacs/chemacs/.emacs
    .emacs-profile@ -> /Users/hh/humacs/.emacs-profile
    .emacs-profiles.el@ -> /Users/hh/humacs/.emacs-profiles.el
    humacs/

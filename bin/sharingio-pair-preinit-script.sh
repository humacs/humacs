#!/bin/bash

cat << EOF >> $HOME/.gitconfig
[credential "https://github.com"]
  helper = "!f() { test \\"\\$1\\" = get && echo \\"password=\\$GITHUB_TOKEN\\nusername=\\$SHARINGIO_PAIR_USER\\";}; f"
EOF
git config --global commit.template $HOME/.git-commit-template
cat << EOF > $HOME/.git-commit-template



EOF
for GUEST_NAME in $SHARINGIO_PAIR_GUEST_NAMES; do
    echo "Co-Authored-By: $GUEST_NAME <$GUEST_NAME@users.noreply.github.com>" >> $HOME/.git-commit-template
done
git clone --depth=1 git://github.com/{{ $.Setup.User }}/.sharing.io || \
    git clone --depth=1 git://github.com/sharingio/.sharing.io
(
    ./.sharing.io/init || true
) &
git clone --depth=1 git://github.com/{{ $.Setup.User }}/.doom.d || \
    git clone --depth=1 git://github.com/humacs/.doom.d
(
    cd $HOME/.doom.d
    rm *.el
    org-tangle "${SHARINGIO_PAIR_USER:-ii}".org
    doom sync
)
if [ ! -d "$HOME/.sharing.io/public_html" ]; then
    mkdir -p "$HOME/.sharing.io/public_html"
    echo "Add your site in '$HOME/public_html'" > "$HOME/.sharing.io/index.html"
fi
ln -s "$HOME/.sharing.io/public_html" "$HOME/public_html"
for repo in $(find ~ -type d -name ".git"); do
    repoName=$(basename $(dirname $repo))
    if [ -x $HOME/.sharing.io/$repoName/init ]; then
        cd $repo/..
        $HOME/.sharing.io/$repoName/init &
        continue
    fi
    if [ -x $repo/../.sharing.io/init ]; then
        cd $repo/..
        ./.sharing.io/init &
    fi
done


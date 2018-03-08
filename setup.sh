#!/bin/bash

# I AM BASH NOOB PLS DONT PUNCH ME HARD

CURRENT_WP_PATH=$(cat ~/.config/plasma-org.kde.plasma.desktop-appletsrc | grep -E "^Image=(file)?" | sed -E 's/Image=(file:\/\/)?//')

echo $CURRENT_WP_PATH

if ! test -f ~/.bg.png; then
    if [ $CURRENT_WP_PATH ]; then
        echo blurring your current wallpaper
        echo
        convert $CURRENT_WP_PATH -filter Gaussian -resize 5% -define filter:sigma=2.5 -resize 2000% -attenuate 0.2 +noise Gaussian ~/.bg.png
        sleep 10
    else
        PROMPT=1
        echo creating dummy .bg.png in $HOME
        echo
        touch ~/.bg.png
    fi
fi

SDDM_THEME_PATH=/usr/share/sddm/themes/$(cat /etc/sddm.conf | grep 'Current' | sed -E 's/.*=//')

if ! test -f $SDDM_THEME_PATH/.bg.png; then
    echo copying .bg.png to $SDDM_THEME_PATH
    echo
    sudo cp ~/.bg.png $SDDM_THEME_PATH/.bg.png
fi
sudo chmod 777 $SDDM_THEME_PATH/.bg.png

echo creating sddm config\n
cat $SDDM_THEME_PATH/theme.conf.user | sed -E 's/background=.*/background=.bg.png/' | sed -E 's/type=.*/type=image/' >> /tmp/theme.conf.user
sudo mv $SDDM_THEME_PATH/theme.conf.user $SDDM_THEME_PATH/theme.conf.user.prewpblur
sudo mv /tmp/theme.conf.user $SDDM_THEME_PATH/


echo generating kscreenlockerrc file
echo

KSCREENLOCKER=~/.config/kscreenlockerrc

if test -f ~/.config/kscreenlockerrc; then
    mv $KSCREENLOCKER $KSCREENLOCKER.prewpblur
    echo "[$Version]" > $KSCREENLOCKER
    echo $(grep "update_info" $KSCREENLOCKER.prewpblur) >> $KSCREENLOCKER
else
    echo "[$Version]" > $KSCREENLOCKER
    echo "update_info=kscreenlocker.upd:0.1-autolock" >> $KSCREENLOCKER
fi

cat <<EOF >> $KSCREENLOCKER

[Greeter]
WallpaperPlugin=org.kde.image

[Greeter][Wallpaper][org.kde.image][General]
FillMode=2
Image=file:///home/$USER/.bg.png
EOF

if ! test -d ~/.config/autostart-scripts; then
    mkdir ~/.config/autostart-scripts
fi

if ! test -f ~/.config/autostart-scripts/wpblur.sh; then
    echo enabling script autostart
    echo
    cp ./wpblur.sh ~/.config/autostart-scripts/wpblur.sh
fi

echo starting script for current session
echo
./wpblur.sh &

cat <<EOF
Backups created:
$SDDM_THEME_PATH/theme.conf.user.prewpblur
$KSCREENLOCKER.prewpblur

EOF

if [ $PROMPT ]; then
    echo now please change your wallpaper
else
    echo ready to use
fi

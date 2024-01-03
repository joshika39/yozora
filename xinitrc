#!/bin/sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# start some nice programs

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

session=${1:-i3}

case $session in
	i3|i3wm	)
		startLoc=$HOME/.config/xinit.d	
		if [ -d ~/.config/xinit.d/ ] ; then
			for f in ~/.config/xinit.d/?*.sh ; do
				[ -x "$f" ] && . "$f"
			done
			unset f
		fi

		export POLYBAR_HOME="$HOME/.config/polybar/files"
		export GTK_IM_MODULE=ibus
		export QT_IM_MODULE=ibus
		export XMODIFIERS=@im=ibus	
		$HOME/.fehbg &
		exec i3
		;;

	kde	)
		export KDEWM=/usr/bin/i3
		export GTK_IM_MODULE=ibus
		export QT_IM_MODULE=ibus
		export XMODIFIERS=@im=ibus
		ibus-daemon -drx &
	       	export DESKTOP_SESSION=plasma	
		exec startplasma-x11;;
	twm	)
		twm &
		# xclock -geometry 50x50-1+1 &
		xterm -geometry 80x50+494+51 &
		xterm -geometry 80x20+494-0 &
		exec xterm -geometry 80x66+0+0 -name login
		;;

	*	) exec $1 ;;
esac

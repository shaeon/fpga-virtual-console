#!/usr/bin/env sh
stty cols 100 rows 50
TERM="xterm-256color" mplayer -nosub -noautosub -really-quiet -monitorpixelaspect 0.666 -vo caca $1

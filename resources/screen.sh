#!/bin/bash

connected=$(xrandr | grep HDMI-A-0 | awk '{ print $2 }' )

if [ "$connected" = "connected" ] 
then
	xrandr --output HDMI-A-0 --auto --output eDP --off 
else 
	xrandr --output eDP --auto --output HDMI-A-0 --off
fi

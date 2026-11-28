#!/usr/bin/env bash
ACTION=$1
CHAR=$3
VALUE=$4

if [ "$ACTION" = "Set" ] && [ "$CHAR" = "On" ]; then
  if [ "$VALUE" = "1" ]; then
    if [ ! -L "/sys/bus/usb/drivers/usb/1-1" ]; then
      echo '1-1' > /sys/bus/usb/drivers/usb/bind
    fi
  else
    if [ -L "/sys/bus/usb/drivers/usb/1-1" ]; then
      echo '1-1' > /sys/bus/usb/drivers/usb/unbind
    fi
  fi
elif [ "$ACTION" = "Get" ] && [ "$CHAR" = "On" ]; then
  [ -L "/sys/bus/usb/drivers/usb/1-1" ] && echo 1 || echo 0
fi

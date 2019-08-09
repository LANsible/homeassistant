#!/bin/sh

# NOTE: Create everything in /dev/shm and run entrypoint script to symlink to config
# Needed for:
# https://github.com/OpenZWave/python-openzwave/blob/cdae95f601fef9a935903906eb02e1d9e4f702d1/src-lib/libopenzwave/libopenzwave.pyx#L703
# Home Assistant sets it to:
# https://github.com/home-assistant/home-assistant/blob/8ec75cf88371253c87ff2973856dbe31819c6134/homeassistant/components/zwave/__init__.py#L288

# Also hass makes /deps dir, HA_VERSION file and onboarding file

# Skip when no config mounted, just run with defaults
if [ -d "/config" ]; then
  # For each config file create a symlink
  for file in /config/*; do
    filename=$(basename "$file")
    # Create symlink when it does not exist yet
    if [ ! -e "/dev/shm/$filename" ]; then
      ln -sf "/config/$filename" "/dev/shm/$filename"
    fi
  done
fi

# Create symlink for .storage directory and HA_VERSION
if [ -d "/data" ]; then
  # Create .storage dir when not already there
  if [ -d "/data/.storage" ]; then
    mkdir /data/.storage
  fi

  # Create symlinks needed for persistance
  for symlink in .storage .HA_VERSION; do
    if [ ! -e $symlink ]; then
      ln -sf "/data/$symlink" "/dev/shm/$symlink"
    fi
  done
fi

# Start home assistant
exec "$@"
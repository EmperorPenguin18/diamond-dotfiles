#!/bin/sh

brave-bin \
    --enable-features=UseOzonePlatform \
    --ozone-platform=wayland \
    --password-store=basic \
    $@

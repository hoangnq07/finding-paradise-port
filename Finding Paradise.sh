#!/bin/bash

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
source $controlfolder/device_info.txt

[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR=/$directory/ports/finding_paradise
CONFDIR="$GAMEDIR/conf/"

CUR_TTY=/dev/tty0
$ESUDO chmod 666 $CUR_TTY 2>/dev/null

exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd "$GAMEDIR"

# Ensure the conf directory exists
mkdir -p "$GAMEDIR/conf"

# Set the XDG environment variables for config & savefiles
export XDG_CONFIG_HOME="$CONFDIR"
export XDG_DATA_HOME="$CONFDIR"
export AV_APPDATA="$CONFDIR"

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"

# Extract and organize game files if the GOG installer exists
WOG_FILE=$(ls finding_paradise*.sh 2> /dev/null | head -n 1)

if [ -f "$WOG_FILE" ]; then
    "$controlfolder/7zzs.$DEVICE_ARCH" x -aoa "$WOG_FILE" > "$CUR_TTY"
    if [ -d "data/noarch/game" ]; then
        $ESUDO mv -f data/noarch/game/* "$GAMEDIR/gamedata/" || { echo "Failed to move game directory." > "$CUR_TTY"; sleep 5; exit 1; }
    else
        echo "Game directory not found after extraction." > "$CUR_TTY"
        sleep 5
        exit 1
    fi
    rm -f "$WOG_FILE"
    echo "Setup complete. Have fun playing!" > "$CUR_TTY"
fi

# Clean up unwanted libs if present
[ -d gamedata/lib ] && rm -rf data/ meta/ scripts/ gamedata/lib gamedata/lib64

# Move binary into gamedata
if [ -f falcon_mkxp.bin ]; then
    cp -f falcon_mkxp.bin gamedata/falcon_mkxp.bin
fi
chmod +x "$GAMEDIR/gamedata/falcon_mkxp.bin" 2>/dev/null
$ESUDO chmod -R a+rX "$GAMEDIR/gamedata" 2>/dev/null

# Ensure mkxp.conf settings
if [ -f gamedata/mkxp.conf ]; then
    sed -i 's/^frameSkip=.*/frameSkip=false/' gamedata/mkxp.conf
    sed -i 's/^vsync=.*/vsync=false/' gamedata/mkxp.conf
    sed -i 's/^smoothScaling=.*/smoothScaling=false/' gamedata/mkxp.conf
    sed -i 's/#fullscreen=true/fullscreen=true/' gamedata/mkxp.conf
    grep -q "^execName=" gamedata/mkxp.conf || echo "execName=Finding Paradise" >> gamedata/mkxp.conf
fi

# Ensure preload scripts are in place
mkdir -p "$GAMEDIR/gamedata/preload" "$GAMEDIR/gamedata/mkxp/preload"
cp -f "$GAMEDIR/preload/"* "$GAMEDIR/gamedata/preload/" 2>/dev/null
cp -f "$GAMEDIR/preload/"* "$GAMEDIR/gamedata/mkxp/preload/" 2>/dev/null

# Ensure Fonts are in place
mkdir -p "$GAMEDIR/gamedata/Fonts"
cp -f "$GAMEDIR/Fonts/"* "$GAMEDIR/gamedata/Fonts/" 2>/dev/null

# CPU/GPU governor boost
OLD_CPU_GOV=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null)
GPU_GOV_FILE=$(ls /sys/class/devfreq/*/governor 2>/dev/null | grep -i gpu | head -n 1)
OLD_GPU_GOV=""
[ -n "$GPU_GOV_FILE" ] && OLD_GPU_GOV=$(cat "$GPU_GOV_FILE" 2>/dev/null)
if [ -n "$OLD_CPU_GOV" ]; then
    for g in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo performance | $ESUDO tee "$g" > /dev/null 2>&1
    done
fi
[ -n "$OLD_GPU_GOV" ] && echo performance | $ESUDO tee "$GPU_GOV_FILE" > /dev/null 2>&1

cd "$GAMEDIR/gamedata"

$GPTOKEYB "falcon_mkxp.bin" -c "$GAMEDIR/finding_paradise.gptk" &
pm_platform_helper "$GAMEDIR/gamedata/falcon_mkxp.bin"
./falcon_mkxp.bin

# Restore governors
if [ -n "$OLD_CPU_GOV" ]; then
    for g in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo "$OLD_CPU_GOV" | $ESUDO tee "$g" > /dev/null 2>&1
    done
fi
[ -n "$OLD_GPU_GOV" ] && echo "$OLD_GPU_GOV" | $ESUDO tee "$GPU_GOV_FILE" > /dev/null 2>&1

$ESUDO kill -9 $(pidof gptokeyb) 2>/dev/null
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0 2>/dev/null

pm_finish

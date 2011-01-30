#!/bin/bash

# Usage: ./incremental-run.sh 
# Example: while true; do ./incremental-run.sh; sleep 5; done
# Or: crontab -e, and add a cron job

## Default config

MCHOME=/opt/bukkit # Root MC directory (directory with server jar)
PIGMAP=$MCHOME/pigmap # Location of Pigmap
WORLD=SurvivalWorld # Name of world, located in $MCHOME
OUTPUT=$PIGMAP/tiles

# Path to terrain.png and fire.png, etc. (all images)
# NOTICE!!: Place terrain.png from a texture pack or from minecraft.jar in terrain/.
# I recommend Painterly Pack with the lighter, custom water texture for best experience
TEXTURE=$PIGMAP/terrain

LOGPATH=$MCHOME/logs/pigmap/$(date +%Y%m%d-%H%M).log

CHUNKLIST=$LOGPATH.rsync

# local location for the synced world directory. Do not add a retaliating slash!
# Notice: If you are running a local minecraft server, this will still be used to prevent lag
#   as rsync can copy effectively while the Minecraft server is running
RSYNCWORLD=$MCHOME/rsyncworld

# Set to 0 if the Minecraft server is not on the local machine
LOCAL=1

# If $LOCAL=0, these are required
PASSWPATH=/etc/rsync.password
USER=user
SERVER=mcserver # hostname or ip address
REMOTEWORLD=path/to/world # Relative to root of rsync server

# Number of threads to use
# Should be set to the number of CPUs you have (2 for dual-core,
# 4 for quad, etc.) for maximum speed
THREADS=1

# Base Zoom level block size (in pixels)
# (Just leave as default if you don't know what to do with this)
BASEZOOM=6

# Tile multiplier, controls how many chunks wide a tile is (requires to be >= 1)
# (Again, leave as default if you don't know what to do)
TILEMULTI=1

START=$(date +%s)

echo "Start at: $START" >> $LOGPATH

# Make sure we are in the right directory
cd $MCHOME

# Take snapshot of world
echo "Start snapshot at: $(date +%s)" >> $LOGPATH
echo "Creating snapshot of Minecraft world..."
if [ $LOCAL -eq 1 ]
then
rsync -va $MCHOME/$WORLD/ $RSYNCWORLD > $CHUNKLIST
else
rsync -va --password-file=$PASSWPATH $USER@$SERVER::$REMOTEWORLD $WORLD/ > $CHUNKLIST
fi
echo "End snapshot at: $(date +%s)" >> $LOGPATH

# Copy needed files and directories
echo "Copying needed files and folders at: $(date +%s)" >> $LOGPATH
echo "cp $PIGMAP/web_assets/* $OUTPUT -R" >> $LOGPATH
echo "Copying needed files and folders..."
cp $PIGMAP/web_assets/* $OUTPUT -R
cp $PIGMAP/template.html $OUTPUT/index.html

# Run incremental update
if [ -f $OUTPUT/pigmap.params ]
then
    echo "Start incremental update at: $(date +%s)" >> $LOGPATH
    echo "$PIGMAP/pigmap -i $RSYNCWORLD -o $OUTPUT -g $TEXTURE -h $THREADS -c $CHUNKLIST" >> $LOGPATH
    echo "Starting incremental generation..."
    $PIGMAP/pigmap -i $RSYNCWORLD -o $OUTPUT -g $TEXTURE -h $THREADS -c $CHUNKLIST
else
    echo "Start initial generation at: $(date +%s)" >> $LOGPATH
    echo "$PIGMAP/pigmap -B $BASEZOOM -T $TILEMULTI -i $RSYNCWORLD -o $OUTPUT -g $TEXTURE -h $THREADS" >> $LOGPATH
    echo "Starting initial generation..."
    $PIGMAP/pigmap -B $BASEZOOM -T $TILEMULTI -i $RSYNCWORLD -o $OUTPUT -g $TEXTURE -h $THREADS
fi
if [ $? -ne 0 ]; then
   echo "pigmap returned error";
fi

echo "End incremental update at: $(date +%s)" >> $LOGPATH

# Calculate end time
END=$(date +%s)
DIFF=$(( $END - $START))

echo "It took $DIFF seconds"
echo "It took $DIFF seconds" >> $LOGPATH
let "MINS=$DIFF / 60"
let "HOURS=$MINS / 60"
echo " or $MINS minutes"
echo " or $MINS minutes" >> $LOGPATH
echo " or $HOURS hours"
echo " or $HOURS hours" >> $LOGPATH

echo "End at: $END" >> $LOGPATH
echo "DIFF: $DIFF" >> $LOGPATH 

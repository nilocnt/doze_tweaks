#!/system/bin/sh
set -o standalone

MODDIR=${0%/*}
dir=$MODDIR

# Patches Google Play services app and certain processes/services to be able to use battery optimization and others tweaks.

# GMS doze functions
gms_doze_patch()
{
GMS0="\"com.google.android.gms"\"
STR1="allow-unthrottled-location package=$GMS0"
STR2="allow-ignore-location-settings package=$GMS0"
STR3="allow-in-power-save package=$GMS0"
STR4="allow-in-data-usage-save package=$GMS0"
NULL="/dev/null"
}

{
find /data/adb/* -type f -iname "*.xml" -print |
while IFS= read -r XML; do
for X in $XML; do
if grep -qE "$STR1|$STR2|$STR3|$STR4" $X 2> $NULL; then
sed -i "/$STR1/d;/$STR2/d;/$STR3/d;/$STR4/d" $X
fi
done
done
}
# Call Function
gms_doze_patch


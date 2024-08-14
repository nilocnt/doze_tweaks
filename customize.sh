#!/data/adb/magisk/busybox sh
set -o standalone

set -x

# Set what you want to display when installing your module

ui_print ""
sleep 1
ui_print "************************************"
ui_print "*        <- Doze  Tweaks ->        *"
ui_print "************************************"
sleep 1
ui_print " "
ui_print "Module info: "
ui_print "• Version         : v1 rev"
ui_print " "
ui_print "Device info:"
ui_print "• Brand           : $(getprop ro.product.system.brand) "
ui_print "• Device          : $(getprop ro.product.system.model) "
ui_print "• Processor       : $(getprop ro.product.board) "
ui_print "• Android Version : $(getprop ro.system.build.version.release) "
ui_print "• Architecture    : $(getprop ro.product.cpu.abi) "
ui_print "• Kernel Version  : $(uname -r) "
ui_print "• KSUVer Code     : $KSU_KERNEL_VER_CODE"
ui_print "• MagiskVer Code  : $MAGISK_VER_CODE"
ui_print " "
ui_print "• nilocnt GitHub"
sleep 0.2
ui-print " "
sleep 0.2
ui_print "Notes:"
ui_print "• Do not use the GMS Doze Module"
ui_print "• Do not use the Lyb big.LITTLE force"
sleep 1
ui_print ""
ui_print "- Installing Module Please Wait"

# Check Android API
[ $API -ge 23 ] ||
 abort "- Unsupported API version: $API"

# Patch the XML and place the modified one to the original directory
ui_print "- Patching XML files"
{
GMS0="\"com.google.android.gms"\"
STR1="allow-in-power-save package=$GMS0"
STR2="allow-in-data-usage-save package=$GMS0"
NULL="/dev/null"
}
ui_print "- Searching default XML files"
SYS_XML="$(
SXML="$(find /system_ext/* /system/* /product/* \
/vendor/* -type f -iname '*.xml' -print)"
for S in $SXML; do
if grep -qE "$STR1|$STR2" $ROOT$S 2> $NULL; then
echo "$S"
fi
done
)"

PATCH_SX() {
for SX in $SYS_XML; do
mkdir -p "$(dirname $MODPATH$SX)"
cp -af $ROOT$SX $MODPATH$SX
 ui_print "- Patching: $SX"
sed -i "/$STR1/d;/$STR2/d" $MODPATH/$SX
done

# Merge patched files under /system dir
for P in product vendor; do
if [ -d $MODPATH/$P ]; then
 ui_print "- Moving files to module directory"
mkdir -p $MODPATH/system/$P
mv -f $MODPATH/$P $MODPATH/system/
fi
done
}

# Search and patch any conflicting modules (if present)
# Search conflicting XML files
MOD_XML="$(
MXML="$(find /data/adb/* -type f -iname "*.xml" -print)"
for M in $MXML; do
if grep -qE "$STR1|$STR2" $M; then
echo "$M"
fi
done
)"

PATCH_MX() {
 ui_print "- Searching conflicting XML"
for MX in $MOD_XML; do
MOD="$(echo "$MX" | awk -F'/' '{print $5}')"
 ui_print "  $MOD: $MX"
sed -i "/$STR1/d;/$STR2/d" $MX
done
}

# Find and patch conflicting XML
PATCH_SX && PATCH_MX

# Additional add-on for check gms status
ADDON() {
 ui_print "- Inflating add-on file"
mkdir -p $MODPATH/system/bin
mv -f $MODPATH/gmsc $MODPATH/system/bin/gmsc
}

FINALIZE() {
 ui_print "- Finalizing installation"

# Clean up
 ui_print "- Cleaning obsolete files"
find $MODPATH/* -maxdepth 0 \
              ! -name 'module.prop' \
              ! -name 'post-fs-data.sh' \
              ! -name 'service.sh' \
              ! -name 'LICENSE' \
              ! -name 'uninstall.sh' \
              ! -name 'system' \
              ! -name 'system.prop' \
                -exec rm -rf {} \;

# Settings dir and file permission
 ui_print "- Settings permissions"
set_perm_recursive $MODPATH 0 0 0755 0755
set_perm $MODPATH/system/bin/gmsc 0 2000 0755
}

# Final adjustment
ADDON && FINALIZE

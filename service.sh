#!/system/bin/sh
set -o standalone

# Patches Google Play services app and certain processes/services to be able to use battery optimization and others tweaks.

(   
# Wait until boot completed
until [ $(resetprop sys.boot_completed) -eq 1 ] &&
[ -d /sdcard ]; do
sleep 100
done

# Doze Mode
agresive_doze() {
dumpsys deviceidle enable && settings put global device_idle_constants light_after_inactive_to=30000,light_pre_idle_to=35000,light_idle_to=30000,light_idle_factor=1.7,light_max_idle_to=50000,light_idle_maintenance_min_budget=28000,light_idle_maintenance_max_budget=300000,min_light_maintenance_time=5000,min_deep_maintenance_time=10000,inactive_to=30000,sensing_to=0,locating_to=0,location_accuracy=2000,motion_inactive_to=86400000,idle_after_inactive_to=0,idle_pending_to=30000,max_idle_pending_to=60000,idle_pending_factor=2.1,quick_doze_delay_to=60000,idle_to=3600000,max_idle_to=21600000,idle_factor=1.7,min_time_to_alarm=1800000,max_temp_app_whitelist_duration=20000,mms_temp_app_whitelist_duration=20000,sms_temp_app_whitelist_duration=10000,notification_whitelist_duration=20000,wait_for_unlock=true,pre_idle_factor_long=1.67,pre_idle_factor_short=0.33,deep_idle_to=7200000,deep_max_idle_to=86400000,deep_idle_maintenance_max_interval=86400000,deep_idle_maintenance_min_interval=43200000,deep_still_threshold=0,deep_idle_prefetch=1,deep_idle_prefetch_delay=300000,deep_idle_delay_factor=2,deep_idle_factor=3
}

# GMS components
GMS="com.google.android.gms"
GC1="auth.managed.admin.DeviceAdminReceiver"
GC2="mdm.receivers.MdmDeviceAdminReceiver"
NLL="/dev/null"

# Disable collective device administrators
for U in $(ls /data/user); do
for C in $GC1 $GC2 $GC3; do
pm disable --user $U "$GMS/$GMS.$C" &> $NLL
done
done

# Add GMS to battery optimization
dumpsys deviceidle whitelist -com.google.android.gms &> $NLL

exit 0
)

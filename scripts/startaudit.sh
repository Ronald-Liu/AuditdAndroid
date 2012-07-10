#!/bin/bash

# Requires the latest version of the Android SDK
# @TODO: Automated check that this stuff is in the path...
# @TODO: Still allows a number of adb calls that come through. These seem
#         to spawn and exit and then respawn. They spawn from init so
#         they don't get forked from the original auditd process that's
#         being ignored.

# Start auditd
adb shell auditd

# Start the spade-audit dump running in the background
adb shell spade-audit > ./dumpforspade.log &

# Start getting our rules added.

# Delete all current rules
adb shell auditctl -D

# find our spade-audit process and ignore it
spadeauditpid=$(adb shell ps | grep spade-audit | awk "{print \$2 }")
adb shell auditctl -a exit,never -S all -F pid=$spadeauditpid

# We need to find the auditd process and ignore it
auditdpids=$(adb shell ps | grep auditd | awk "{print \$2 }")
for apid in $auditdpids
do
  adb shell auditctl -a exit,never -S all -F pid=$apid
done

# We need to find the adb process and ignore it
adbpid=$(adb shell ps | grep adb | awk "{print \$2 }")
adb shell auditctl -a exit,never -S all -F pid=$adbpid

#Double check our rules so far
adb shell auditctl -l

# Add our other rules
adb shell auditctl -a exit,always -S clone -S execve -S exit_group -S open -S write -S mkdir -S mkdirat -S mknod -S chmod -S fchmod -S fchmodat -S chown -S fchown32 -S fchownat -S lchown32 -S close -S fork -S unlink -S link -S setuid -S symlink -S unlinkat -S setuid32 -S setreuid32 -S setresuid32


#!/bash/sh
# Copyright (C) 2014  Codethink Limited
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

set -e

mkdir -p tmp/
# get existing devices
#cat /proc/partitions | tr -s ' ' | cut -d ' ' -f 5 > tmp/devices.existing

# do the tegra-uboot-install stuff here...

echo "sleeping..."
#sleep 5
echo "done...."

# u-boot should now be in gadget mode, check the partitions to see what's
# new, this will probably be our jetson, but we'll ask for confirmation
# just to be sure!

#cat /proc/partitions | tr -s ' ' | cut -d ' ' -f 5 > tmp/devices.new
tegra_device=`grep -Fxv -f tmp/devices.existing tmp/devices.new`
echo $tegra_device
set -- $tegra_device

echo "Found /dev/$1 mounted as your jetson, please confirm this is the jetson
device [yes/no]"
read confirm

if [ "$confirm" != "yes" ] && [ "$confirm" != "no" ]; then
    echo "Leaving install process"
    exit
fi;

if [ $confirm != "yes" ]; then
    echo "please enter the device (e.g sdc, not /dev/sdc) of your mounted jetson"
    read tegra_device
    echo "tegra device now $tegra_device"
    # check /proc/partitions again for this device
    cat /proc/partitions | tr -s ' ' | cut -d ' ' -f 5 > tmp/devices.new
    echo "BLAH?"
    tegra_device=`grep $tegra_device tmp/devices.new` || true
    echo "foo? - $tegra_device - BAR - $?"
    if [ "$tegra_device" = "" ]; then
        echo "DIDN'T FIND THIS DEVICE!!!"
    fi;
    exit
else
    echo "Great!"
fi;

# now loop through the above array
echo "Making sure device is unmounted"
for i in $tegra_device
do
   echo "unmount $i"
   umount /dev/$i || true
done

set -- $tegra_device
tegra_device=$1

# partition device
echo "Partitioning device /dev/$tegra_device"
echo "This can cause catastrophic data loss if /dev/$tegra_device is not the Jetson!"
echo "Press enter to confirm, or Ctrl+C to quit (you have been warned!)"
read confirm

fdisk /dev/$tegra_device <<EOF
g

n
1

+1G
n
2


w
EOF

echo "Format /dev/${tegra_device}1 as ext4"
mkfs -t ext2 /dev/${tegra_device}1



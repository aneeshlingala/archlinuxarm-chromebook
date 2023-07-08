echo "Arch Linux ARM for unsupported Chromebooks"

if [[ $EUID -eq 0 ]]; then
    echo ""
else
    echo "Please run this script as root!"
    exit
fi

if [ "$2" == "" ]; then
     echo "Please specify a USB, SD Card, etc. to install to (sda, sdb, etc.)."
fi

TARGET=$(echo $2)
disk_size=$(sudo blockdev --getsize64 "/dev/$TARGET")
sector_size=$(sudo blockdev --getss "/dev/$TARGET")
total_sectors=$((disk_size / sector_size))
start_sector=$(sudo cgpt show -i 1 -b "/dev/$TARGET")
end_sector=$((total_sectors - 1))



if [ "$1" == "--device=kukui" ]; then
     echo ""
     echo "Partitioning the selected device..."
     echo "WARNING: THIS WILL WIPE ALL DATA on the selected drive."
     echo "Press any key to continue..."
     read -s -n 1
     echo ""
     echo "Pressed a key, wiping... You can sit back and relax."
     echo g | fdisk /dev/$(echo $TARGET)
     cgpt create /dev/$(echo $TARGET)
     cgpt add -i 1 -t kernel -b 8192 -s 65536 -l Kernel -S 1 -T 5 -P 10 /dev/$(echo $TARGET)
     sudo cgpt add -i 2 -t data -s "$start_sector" -e "$end_sector" -l Root "/dev/$TARGET"
     sudo mkfs.ext4 "/dev/$(echo $TARGET)"
     cd /tmp
       
 fi

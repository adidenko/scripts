export SRC_IMAGE="http://cloud-images.ubuntu.com/precise/current/precise-server-cloudimg-amd64-disk1.img"
export IMG_ROOT_DEVICE="/dev/sda"

export MNT="/mnt/rallyimg"
sudo mkdir -p $MNT

wget -q -N "$SRC_IMAGE"
IMG=`echo $SRC_IMAGE | awk -F/ '{ print $NF }'`

cp $IMG base.img

sudo guestmount -a base.img -m $IMG_ROOT_DEVICE $MNT

sudo mount -o bind /proc $MNT/proc
sudo mount -o bind /sys $MNT/sys
sudo mount -o bind /dev $MNT/dev

curl -s  https://raw2.github.com/adidenko/scripts/master/setup_qa_vm_image.sh > setup_stuff.sh || \
(
    sudo umount $MNT/sys $MNT/proc $MNT/dev
    sudo umount $MNT
    exit 1
)

sudo cp  setup_stuff.sh $MNT/usr/local/bin/setup_stuff.sh || \
(
    sudo umount $MNT/sys $MNT/proc $MNT/dev
    sudo umount $MNT
    exit 1
)

sudo chmod 755 $MNT/usr/local/bin/setup_stuff.sh || \
(
    sudo umount $MNT/sys $MNT/proc $MNT/dev
    sudo umount $MNT
    exit 1
)

# Run installation script
sudo chroot $MNT /usr/local/bin/setup_stuff.sh || \
(
    sudo umount $MNT/sys $MNT/proc $MNT/dev
    sudo umount $MNT
    exit 1
)

sudo umount $MNT/sys $MNT/proc $MNT/dev
sudo umount $MNT

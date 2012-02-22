#!/bin/bash
PS3="Choose (1-2):"
echo "Choose your kernel from the list below."
select kernel in Kernel Kernel_DEPRECATED
do
	break
done
PS3="Choose (1-2):"
echo "Choose your ramdisk from the list below."
select name in CyanogenMod7 CyanogenMod9 OpenRecovery
do
	break
done

PS3="Choose (1-2):"
echo "Choose your ramdisk compression mode from the list below."
select com in gzip lzma xz
do
	break
done

pack()
{
./repack-bootimg.pl $com zImage $name/ boot.img
rm ./OTA/boot.img
cp ./boot.img ./OTA/
cd ./OTA/
zip -r -9 ../Sign/update.zip ./
cd ../Sign/
java -Xmx512m -jar signapk.jar -w testkey.x509.pem testkey.pk8 update.zip ../#$(cat $(pwd)/../../$kernel/.version)-$name-$(stat -c %y $(pwd)/../../$kernel/arch/arm/boot/zImage | cut -b1-10).zip
rm update.zip
echo "Pack boot OTA package done!"
}

if [ $name = "OpenRecovery" ]; then
cp $(pwd)/../$kernel/arch/arm/boot/zImage ./
rm ./#*.img
./repack-bootimg.pl $com zImage ../OpenRecovery/lite/ramdisk recovery.img
echo "Pack recovery image done!"
else
PS3="Choose (Yes/No):"
echo "Build OTA package?"
select bool in No Yes
do
	break
done
echo "You chose RAMDISK=$name,Kernel=$kernel,VERSION=$(cat $(pwd)/../$kernel/.version)"
cp $(pwd)/../$kernel/arch/arm/boot/zImage ./
rm ./#*.img
./repack-bootimg.pl $com zImage $name/ \#$(cat $(pwd)/../$kernel/.version)-$name-$(stat -c %y $(pwd)/../$kernel/arch/arm/boot/zImage | cut -b1-10).img
echo "Pack boot image done!"
if [ $bool = "Yes" ]; then
pack
else
exit 0
fi
fi

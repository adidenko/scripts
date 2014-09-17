#!/bin/bash
export PATH="/home/adidenko/bin:/usr/lib/lightdm/lightdm:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games"
me=`basename $0`

lock="/tmp/$me.lock"
log="/var/log/get_iso.log"
base="/home/adidenko/iso/fuel/torrents"
suff="DOWNLOADING"

fuel_urls='
http://jenkins-product.srt.mirantis.net:8080/view/Product%20and%20Community/job/fuel_master_iso/lastStableBuild
http://jenkins-product.srt.mirantis.net:8080/job/fuel_5_1_iso/lastStableBuild
'

if [ -f "$lock" ] ; then
	echo "Lock ( $lock ) exists, exiting" >> $log
	exit 0;
else
	touch "$lock"
    for fuel_url in $fuel_urls; do
	# Check/download
	fuel_artifact_url=`curl -s "$fuel_url/api/json?tree=artifacts%5BrelativePath%5D&pretty=true" | grep relativePath | grep iso.data.txt | awk '{print $3}' | sed -e 's#"##g'`
	fuel_download_torrent=`curl -s "$fuel_url/artifact/$fuel_artifact_url" | grep ^HTTP_TORRENT | cut -d= -f2`
	fuel_iso_name=`echo $fuel_download_torrent | egrep -o 'fuel-.*\.iso'`
	fuel_iso_torrent="${fuel_iso_name}.torrent"
	echo $fuel_download_torrent
	if [ ! -f "$base/$fuel_iso_torrent" ] ; then
		wget -O "$base/$fuel_iso_torrent" "$fuel_download_torrent" -a /tmp/wget_fuel.log
		/usr/bin/transmission-remote --auth transmission:transmission --add "$base/$fuel_iso_torrent"
	fi
	rm -f "$lock"
    done
fi

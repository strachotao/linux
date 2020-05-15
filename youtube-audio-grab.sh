#!/bin/bash
# youtube-audio-grab.sh; verze 2020-05-15; strachotao
#  youtube id videa jsou v 64kove soustave
#  
#  do TARGET_FOLDER vygrabuje audio (mp3) z youtube videa

TARGET_FOLDER="/var/www/html/emg52"

python="python3"
ytbin="/usr/local/bin/youtube-dl"

if [ $# -lt 1 ]; then
	echo "Usage:"
	echo "$0 youtube-video-number [youtube-video-number youtube-video-number ...]"
	echo "$0 12345678910"
	echo "$0 12345678910 12345678911"
	echo "$0 https://www.youtube.com/watch?v=12345678910"
	echo "$0 https://www.youtube.com/watch?v=12345678910 https://www.youtube.com/watch?v=12345678911"
	echo "for ytvid in \$(cat youtube-video-links.txt); do $0 \$ytvid; done"
	exit 1
fi

{
	cd "$TARGET_FOLDER" > /dev/null 2>&1
} || { 
	echo "ERROR: can't open $TARGET_FOLDER, check the \$TARGET_FOLDER variable"
	exit 1
}

for video in "$@"; do
	$python $ytbin \
		--restrict-filenames \
		--extract-audio \
		--audio-format mp3 \
		$video
done

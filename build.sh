#!/bin/bash
set -eu -o pipefail

# sort data alphabetically
cat dataset.csv | sort -o dataset.csv

# get cutoff line number
(( LINENUM = $(grep -no '<div id="data">' index.html | sed -n 's/:.*//p') + 1 ))

REINSERT='</div></body></html>'

sed -i "$LINENUM"',$d' index.html

cat dataset.csv | while read LINE; do
	FRONT="$(sed -n 's|;.*||p' <<< "$LINE")"
	BACK="$(sed -n 's|.*;||p' <<< "$LINE")"
	ID="$(sed 's/[ \\/]//g' <<< "$FRONT")"
	BACKFORMATTED="$(perl -pe 's|##(.*?)#(.*?)##|<a href="#\2">\1</a>|g' <<< "$BACK")"
	echo -e "<dt id='""$ID""'><a href='#""$ID""' style='text-decoration:none;color:black !important;'>""$FRONT"" </a><a href='#top' style='text-decoration:none;'>↑</a></dt>\n<dd>"$BACKFORMATTED"</dd>" >> index.html
done

# wrap data in html tags and insert
# concat files
echo "$REINSERT" >> index.html

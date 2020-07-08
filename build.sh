#!/bin/bash
set -eu -o pipefail

# sort data alphabetically
cat dataset.csv | sort -o dataset.csv

# get cutoff line number
(( LINENUM = $(grep -no '<div id="data">' index.html | sed -n 's/:.*//p') + 1 ))

REINSERT='		</div>
		<script>
			document.getElementById("search").value = "";
document.getElementById("search").onkeydown = function(e){
	if(e.keyCode == 13){
		document.getElementById("search").focus();
		window.find(document.getElementById("search").value,0,0,0,0,0,0);
	}
};
document.onkeydown = function(e){
	if(e.keyCode == 8 && (document.getElementById("search") === document.activeElement)){
		document.getElementById("search").focus();
		document.getElementById("search").value = "";
	}
};
		</script>
	</body>
</html>'

sed -i "$LINENUM"',$d' index.html

cat dataset.csv | while read LINE; do
	FRONT="$(sed -n 's|;.*||p' <<< "$LINE")"
	BACK="$(sed -n 's|.*;||p' <<< "$LINE")"
	ID="$(sed 's/[ \\/]//g' <<< "$FRONT")"
	BACKFORMATTED="$(perl -pe 's|#(.*?)#|<a href="#\1">\1</a>|g' <<< "$BACK")"
	echo -e "<dt id='""$ID""'>""$FRONT"" <a href='#top'>↑</a></dt>\n<dd>"$BACKFORMATTED"</dd>" >> index.html 
done

# wrap data in html tags and insert
# concat files
echo "$REINSERT" >> index.html

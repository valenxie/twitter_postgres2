files='
geoTwitter20-05-01.zip
geoTwitter20-05-02.zip
geoTwitter20-05-03.zip
geoTwitter20-05-04.zip
geoTwitter20-05-05.zip
geoTwitter20-05-06.zip
geoTwitter20-05-07.zip
'
for file in $files; do
    nohup python3 -u load_tweets.py --db=postgres://postgres:pass@localhost:15432/ --inputs=/data-fast/twitter\ 2020/$file > nohup.$file &
done

for file in $files; do
    unzip -p /data-fast/twitter2020/$file | sed 's/\\u0000//g' | psql postgres://postgres:pass@localhost:25432/ -c "COPY tweets (data) FROM STDIN csv quote e'\x01' delimiter e'\x02';"
done

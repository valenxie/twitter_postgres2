dir='/data-fast/twitter 2020'
files='
geoTwitter20-04-01.zip
'
#geoTwitter20-04-02.zip
#geoTwitter20-04-03.zip
#geoTwitter20-04-04.zip
#geoTwitter20-04-05.zip
#geoTwitter20-04-06.zip
#geoTwitter20-04-07.zip
mkdir -p nohup

for file in $files; do
    nohup python3 -u load_tweets.py --db=postgresql://postgres:pass@localhost:21133/ --inputs="$dir"/$file > nohup/nohup.$file &
done

for file in $files; do
    unzip -p "$dir"/$file | sed 's/\\u0000//g' | psql postgresql://postgres:pass@localhost:11133/ -c "COPY tweets_jsonb (data) FROM STDIN csv quote e'\x01' delimiter e'\x02';"
done

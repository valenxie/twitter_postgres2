/*
 * Calculates the languages that commonly use the hashtag #coronavirus
 */
SELECT
    lang,
    count(*) AS count
FROM (
    SELECT
        data->>'lang' AS lang
    FROM tweets_jsonb
    WHERE data->'entities'->'hashtags'@@'$[*].text == "coronavirus"'
       OR data->'extended_tweet'->'entities'->'hashtags'@@'$[*].text == "coronavirus"'
) t
GROUP BY lang
ORDER BY count DESC,lang
;

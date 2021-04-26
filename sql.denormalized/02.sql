/*
 * Calculates the hashtags that are commonly used with the hashtag #coronavirus
 */
SELECT
    '#'|| tags AS tag,
    count(*) AS count
FROM (
    SELECT DISTINCT data->>'id' AS id_tweets,   
    jsonb_array_elements(COALESCE((data->'extended_tweet'::text -> 'entities'::text -> 'hashtags'), (data->'entities'::text -> 'hashtags' )))->>'text' AS tags   
    FROM tweets_jsonb
    WHERE (data->'entities'->'hashtags') @> '[{"text": "coronavirus"}]'
    OR (data->'extended_tweet'->'entities'->'hashtags') @> '[{"text": "coronavirus"}]'
    ) tbl
GROUP BY tag
ORDER BY count DESC,tag
LIMIT 1000;

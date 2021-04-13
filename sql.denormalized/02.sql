/*
 * Calculates the hashtags that are commonly used with the hashtag #coronavirus
 */
SELECT
    tag,
    count(*) AS count
FROM (
    SELECT
        data->>'id' AS id,
        '#' || (jsonb_array_elements(COALESCE(data->'entities'->'hashtags','[]') || COALESCE(data->'extended_tweet'->'entities'->'hashtags','[]'))->>'text') as tag
    FROM tweets_jsonb
    WHERE data->'entities'->'hashtags'@@'$[*].text == "coronavirus"'
       OR data->'extended_tweet'->'entities'->'hashtags'@@'$[*].text == "coronavirus"'
) t
GROUP BY tag
ORDER BY count DESC,tag
;


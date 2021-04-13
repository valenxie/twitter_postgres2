/*
 * Calculates the hashtags that are commonly used for English tweets containing the word "coronavirus"
 */
SELECT
    tag,
    count(*) AS count
FROM (
    SELECT
        data->>'id' AS id,
        '#' || (jsonb_array_elements(COALESCE(data->'entities'->'hashtags','[]') || COALESCE(data->'extended_tweet'->'entities'->'hashtags','[]'))->>'text') as tag
    FROM tweets_jsonb
    WHERE to_tsvector('english',COALESCE(data->'extended_tweet'->>'full_text',data->>'text'))@@to_tsquery('english','coronavirus')
      AND data->>'lang'='en'
) t
GROUP BY tag
ORDER BY count DESC,tag
;


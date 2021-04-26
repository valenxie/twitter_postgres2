/*
 * Count the number of tweets that use #coronavirus
 */
SELECT COUNT(distinct data -> 'id')
FROM tweets_jsonb
WHERE (data->'entities'->'hashtags') @> '[{"text": "coronavirus"}]'
OR (data->'extended_tweet'->'entities'->'hashtags') @> '[{"text": "coronavirus"}]';

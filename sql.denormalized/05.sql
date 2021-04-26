/*
 * Calculates the hashtags that are commonly used for English tweets containing the word "coronavirus"
 */
SELECT '#' || tags AS tag,
COUNT(distinct id_tweets) FROM
    (SELECT
	jsonb_array_elements(COALESCE((data->'extended_tweet'::text -> 'entities'::text -> 'hashtags'), (data->'entities'::text -> 'hashtags' )))->>'text'AS tags,
	data->'id' AS id_tweets
	FROM tweets_jsonb
	WHERE
	data->>'lang' = 'en' AND
	to_tsvector('english', COALESCE((data->'extended_tweet' ->> 'full_text'),(data->>'text'))) @@ to_tsquery('english', 'coronavirus')
     ) tbl
GROUP BY tag
ORDER BY count DESC, tag
limit 1000;

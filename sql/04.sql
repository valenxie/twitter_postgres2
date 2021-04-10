/*
 * Calculates how commonly the hashtag #coronavirus is used in each US state.
 */
SELECT 
    state_code,
    count(*) as count
FROM tweet_tags
INNER JOIN tweets ON tweet_tags.id_tweets = tweets.id_tweets
WHERE
    country_code = 'us' AND
    tag = '#coronavirus'
GROUP BY country_code, state_code
ORDER BY count DESC,state_code;

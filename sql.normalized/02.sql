/*
 * Calculates the hashtags that are commonly used with the hashtag #coronavirus
 */
SELECT
    t2.tag as tag,
    count(*) as count
FROM tweet_tags t1
JOIN tweet_tags t2 ON t1.id_tweets = t2.id_tweets
WHERE t1.tag='#coronavirus'
  AND t2.tag LIKE '#%'
GROUP BY (1)
ORDER BY count DESC,tag;

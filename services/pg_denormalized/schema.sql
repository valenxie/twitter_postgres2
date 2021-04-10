\set ON_ERROR_STOP on

BEGIN;

--------------------------------------------------------------------------------    
-- data tables
--------------------------------------------------------------------------------    

CREATE TABLE tweets (
    data JSONB
);

--------------------------------------------------------------------------------    
-- the materialized views below represent normalized tables
--------------------------------------------------------------------------------    

CREATE MATERIALIZED VIEW tweet_mentions AS (
    SELECT DISTINCT id_tweets, jsonb->>'id' AS id_users
    FROM (
        SELECT
            data->>'id' AS id_tweets,
            jsonb_array_elements(
                COALESCE(data->'entities'->'user_mentions','[]') ||
                COALESCE(data->'extended_tweet'->'entities'->'user_mentions','[]')
            ) AS jsonb
        FROM tweets
    ) t
);


CREATE MATERIALIZED VIEW tweet_tags AS (
    SELECT DISTINCT id_tweets, '$' || (jsonb->>'text'::TEXT) AS tag
    FROM (
        SELECT
            data->>'id' AS id_tweets,
            jsonb_array_elements(
                COALESCE(data->'entities'->'symbols','[]') ||
                COALESCE(data->'extended_tweet'->'entities'->'symbols','[]')
            ) AS jsonb
        FROM tweets
    ) t
    UNION ALL
    SELECT DISTINCT id_tweets, '#' || (jsonb->>'text'::TEXT) AS tag
    FROM (
        SELECT
            data->>'id' AS id_tweets,
            jsonb_array_elements(
                COALESCE(data->'entities'->'hashtags','[]') ||
                COALESCE(data->'extended_tweet'->'entities'->'hashtags','[]')
            ) AS jsonb
        FROM tweets
    ) t
);


CREATE MATERIALIZED VIEW tweet_media AS (
    SELECT DISTINCT
        id_tweets,
        jsonb->>'media_url' AS media_url,
        jsonb->>'type' AS type
    FROM (
        SELECT
            data->>'id' AS id_tweets,
            jsonb_array_elements(
                COALESCE(data->'extended_entities'->'media','[]') ||
                COALESCE(data->'extended_tweet'->'extended_entities'->'media','[]')
            ) AS jsonb
        FROM tweets
    ) t
);



/*
 * Precomputes the total number of occurrences for each hashtag
 */
CREATE MATERIALIZED VIEW tweet_tags_total AS (
    SELECT 
        row_number() over (order by count(*) desc) AS row,
        tag, 
        count(*) AS total
    FROM tweet_tags
    GROUP BY tag
    ORDER BY total DESC
);

/*
 * Precomputes the number of hashtags that co-occur with each other
 */
CREATE MATERIALIZED VIEW tweet_tags_cooccurrence AS (
    SELECT 
        t1.tag AS tag1,
        t2.tag AS tag2,
        count(*) AS total
    FROM tweet_tags t1
    INNER JOIN tweet_tags t2 ON t1.id_tweets = t2.id_tweets
    GROUP BY t1.tag, t2.tag
    ORDER BY total DESC
);


COMMIT;
/*
time unzip -p /data-fast/twitter2020/geoTwitter20-04-01.zip | sed 's/\\u0000//g' | psql postgres://postgres:pass@localhost:25432/ -c "COPY tweets (data) FROM STDIN csv quote e'\x01' delimiter e'\x02';"
COPY 4102603

real	14m12.189s
user	3m40.130s
sys	0m44.539s
*/


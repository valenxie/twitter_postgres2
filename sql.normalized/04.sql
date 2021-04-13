/*
 * Calculates the hashtags that are commonly used for English tweets containing the word "coronavirus"
 */
SELECT
    count(*)
FROM tweets
WHERE to_tsvector('english',text)@@to_tsquery('english','coronavirus')
  AND lang='en'
;

CREATE INDEX tweets_idx_gin ON tweets USING gin((to_tsvector('english',text))) WHERE lang='en';


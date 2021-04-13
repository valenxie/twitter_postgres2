/*
 * Calculates the hashtags that are commonly used for English tweets containing the word "coronavirus"
 */
SELECT
    count(*)
FROM tweets_jsonb
WHERE to_tsvector('english',COALESCE(data->'extended_tweet'->>'full_text',data->>'text'))@@to_tsquery('english','coronavirus')
  AND data->>'lang'='en'
;

CREATE INDEX tweets_jsonb_idx_gin ON tweets_jsonb USING gin(to_tsvector('english',COALESCE(data->'extended_tweet'->>'full_text',data->>'text'))) WHERE data->>'lang'='en';
CREATE INDEX tweets_jsonb_idx_gin ON tweets_jsonb USING gin((to_tsvector('english',data->>'text'))) WHERE data->>'lang'='en';

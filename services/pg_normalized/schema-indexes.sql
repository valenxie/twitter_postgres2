CREATE INDEX tweets_idx_txt ON tweets USING gin(to_tsvector('english', text));
CREATE INDEX tweets_idx_id ON tweets(id_tweets);
CREATE INDEX tweet_tags_idx_id ON tweet_tags(id_tweets);
CREATE INDEX tweet_tags_idx_tid ON tweet_tags(tag, id_tweets);
CREATE INDEX tweet_idx_id_lang ON tweets(id_tweets,lang);

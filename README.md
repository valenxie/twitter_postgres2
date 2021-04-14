# Twitter in Postgres 2

This is a continuation of the first [twitter in postgres assignment](https://github.com/mikeizbicki/twitter_postgres).

## Step 0: Prepare the repo/docker

1. Fork this repo, and clone your fork onto the lambda server.

1. Modify the `docker-compose.yml` file so that the ports for each of the services are distinct.

1. Remove the volumes you created in your previous assignment with the command:
   ```
   $ docker volume prune
   ```

## Step 1: Load the Data

For this assignment, we will work with just a single day of twitter data, about 4 million tweets.
This is enough data that indexes will dramatically improve query times,
but you won't have to wait hours/days to create each index and see if it works correctly.

The files in this repo are slightly modified from the previous twitter\_postgres repo:
1. `load_tweets.sh` and `load_tweets.py` are my solution to the previous assignment
1. `services/*/schema.sql` has had all indexes removed (including primary/foreign keys and unique constraints)

Load the data into docker by running the command
```
$ sh load_tweets.sh
```

The denormalized data will load in just 5-10 minutes (about how long it took your `map.py` file to process a single zip file).
The normalized data will take several hours to run because it is highly unoptimized.
Recall that to optimize the loading of normalized data,
you want to load it in "batches" rather than a single data point at a time.

## Step 2: Create indexes on the normalized database

I have provided a series of 5 sql queries for you, which you can find in the `sql.normalized` folder.
You can time the running of these queries with the command
```
$ time docker-compose exec pg_normalized ./check_answers.sh sql.normalized
```
This takes about 23 seconds for me.

You should create indexes so that the command above takes less than 2 seconds to run.
Most of this runtime is overhead of the shell script.
If you open up psql and run the queries directly,
then you should see the queries taking only milliseconds to run.

**NOTE:**
None of your indexes should be partial indexes.
This is so that you could theoretically replace any of the conditions with any other value,
and the results will still be returned quickly.

**HINT:**
My solution creates 3 btree indexes and 1 gin index.

**IMPORTANT:**
As you create your indexes, you should add them to the file `services/pg_normalized/schema-indexes.sql`.
In general, you never want to directly modify the schema of a production database.
Instead, you write your schema-modifying code in a sql file,
commit the sql file to your git repo,
then execute the sql file.
This ensures that you can always fully recreate your database schema from the project's git repo.

## Step 3: Create queries and indexes for the denormalized database

I have provided you the sql queries for the normalized database, but not for the denormalized one.
You will have to modify the files in `sql.denormalized` so that they produce the same output as the files in `sql.normalized`.
The purpose of this exercise it twofold:
1. to give you practice writing queries into a denormalized database (you've only written queries for a normalized database at this point)
2. to give you practice writing queries and indexes at the same time (the exact queries you'll write in the real world will depend on the indexes you're able to create and vice versa)
You should add all of the indexes you create into the file `services/pg_denormalized/schema-indexes.sql`,
just like you did for the normalized database.

You can check the runtime and correctness of your denormalized queries with the command
```
$ time docker-compose exec pg_denormalized ./check_answers.sh sql.denormalized
```

You will likely notice that the denormalized representation is significantly slower than the normalized representation when there are no indexes present.
My solution takes about 4 minutes without indexes, and 3 seconds with indexes.
The indexed solution is still slower than the normalized solution because there are sorts in the query plan that the indexes cannot eliminate.
In fact, no set of indexes would be able to eliminate these sorts... we'll talk later about how to eliminate them using materialized views.

**HINT:**
My solution uses 3 gin indexes, and no btree indexes.

## Submission

We will not use github actions in this assignment,
since this assignment uses too much disk space and computation.
In general, there are not great techniques for testing programs on large datasets.
The best solution is to test on small datasets (like we did for the first version of twitter\_postgres),
and carefully design those tests so that they ensure good performance on the large datasets.
We're not following this procedure, however, to ensure that you get some actual practice with these larger datasets.

To submit your assignment:

1. Run the following commands
   ```
   $ ( time docker-compose exec pg_normalized   ./check_answers.sh sql.normalized   ) > results.normalized   2>&1
   $ ( time docker-compose exec pg_denormalized ./check_answers.sh sql.denormalized ) > results.denormalized 2>&1
   ```
   This will create two files in your repo that contain the runtimes and results of your test cases.
   In the command above:
   1. `( ... )` is called a subshell in bash.
      The `time` command is an internal built-in command in bash and not a separate executable file,
      and it is necessary to wrap it in a subshell in order to redirect its output.
   1. `2>&1` redirects stderr (2) to stdout (1), and since stdout is being redirected to a file, stderr will also be redirected to that file.
      The output of the `time` command goes to stderr, and so this combined with the subshell ensure that the time command's output gets sent into the results files.

1. Add the `results.*`, `sql.denormalized`, and `services/*/schema-indexes.sql` files to your git repo, commit, and push to github.

1. Submit a link to your forked repo to sakai.

## Grading

The assignment is worth 15 points.

1. Each file in `sql.denormalized` is worth 2 points (for 10 total)

1. The timing is the remaining 5 points.

    1. You start with 5 points.
    1. If your normalized queries take longer than 2 seconds: you lose 1 point per second
    1. If your normalized queries take longer than 4 seconds: you lose 1 point per second

I will check the `results.*` files in your github repos to do the actual grading.

<!--
Before creating the indexes, I get:
```
$ cat results.normalized
sql.normalized/01.sql pass
sql.normalized/02.sql pass
sql.normalized/03.sql pass
sql.normalized/04.sql pass
sql.normalized/05.sql pass

real	0m24.023s
user	0m0.592s
sys	0m0.353s
$ cat results.denormalized
sql.denormalized/01.sql pass
sql.denormalized/02.sql pass
sql.denormalized/03.sql pass
sql.denormalized/04.sql pass
sql.denormalized/05.sql pass

real	3m17.415s
user	0m0.648s
sys	0m0.430s
```

After creating the appropriate indexes, I get
```
$ cat results.normalized
sql.normalized/01.sql pass
sql.normalized/02.sql pass
sql.normalized/03.sql pass
sql.normalized/04.sql pass
sql.normalized/05.sql pass

real	0m1.745s
user	0m0.550s
sys	0m0.374s
$ cat results.denormalized
sql.denormalized/01.sql pass
sql.denormalized/02.sql pass
sql.denormalized/03.sql pass
sql.denormalized/04.sql pass
sql.denormalized/05.sql pass

real	0m3.173s
user	0m0.684s
sys	0m0.375s
```
-->

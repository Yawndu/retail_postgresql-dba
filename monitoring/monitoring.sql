-- M1: Current sessions and what they are doing
SELECT pid, usename, application_name, state,
       now() - query_start AS running_for,
       left(query, 80)     AS query
FROM pg_stat_activity
WHERE datname = 'retail_operations'
ORDER BY query_start;

-- M2: Database-level stats: cache hit ratio, commits, rollbacks, deadlocks
SELECT datname,
       numbackends                                            AS connections,
       xact_commit, xact_rollback, deadlocks,
       round(100.0 * blks_hit / NULLIF(blks_hit + blks_read, 0), 2) AS cache_hit_pct,
       pg_size_pretty(pg_database_size(datname))              AS db_size
FROM pg_stat_database
WHERE datname = 'retail_operations';

-- M3: Table sizes (data vs indexes) and row counts
SELECT relname                                         AS table_name,
       n_live_tup                                      AS est_rows,
       pg_size_pretty(pg_table_size(relid))            AS table_size,
       pg_size_pretty(pg_indexes_size(relid))          AS index_size,
       pg_size_pretty(pg_total_relation_size(relid))   AS total_size
FROM pg_stat_user_tables
ORDER BY pg_total_relation_size(relid) DESC;

-- M4: Sequential vs index scans per table (finds tables that may need an index)
SELECT relname AS table_name, seq_scan, idx_scan,
       round(100.0 * idx_scan / NULLIF(seq_scan + idx_scan, 0), 1) AS idx_scan_pct
FROM pg_stat_user_tables
ORDER BY seq_scan DESC;

-- M5: Index usage (idx_scan = 0 means never used since stats reset)
SELECT relname AS table_name, indexrelname AS index_name,
       idx_scan, pg_size_pretty(pg_relation_size(indexrelid)) AS index_size
FROM pg_stat_user_indexes
ORDER BY idx_scan, pg_relation_size(indexrelid) DESC;

-- M6: Dead tuples and vacuum/analyze history (table bloat indicator)
SELECT relname AS table_name, n_live_tup, n_dead_tup,
       round(100.0 * n_dead_tup / NULLIF(n_live_tup + n_dead_tup, 0), 2) AS dead_pct,
       last_autovacuum, last_autoanalyze
FROM pg_stat_user_tables
ORDER BY n_dead_tup DESC;

-- M7: Blocking locks (empty result = no blocking)
SELECT blocked.pid  AS blocked_pid,  left(blocked.query, 60)  AS blocked_query,
       blocking.pid AS blocking_pid, left(blocking.query, 60) AS blocking_query
FROM pg_stat_activity blocked
JOIN LATERAL unnest(pg_blocking_pids(blocked.pid)) AS b(pid) ON true
JOIN pg_stat_activity blocking ON blocking.pid = b.pid;


ANALYZE;
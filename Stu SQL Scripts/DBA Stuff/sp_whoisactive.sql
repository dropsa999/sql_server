sp_whoisactive @get_plans = 1
/*
@get_plans = 1 – this gives you the execution plans for running queries.
@get_locks = 1 – gives you an XML snippet you can click on to see what table, row, object, etc locks each query owns. Useful when you’re trying to figure out why one query is blocking others.
@get_task_info = 1 – if a query has gone parallel and you’re troubleshooting CXPACKET waits, you can figure out what each task in the query is waiting on.
*/
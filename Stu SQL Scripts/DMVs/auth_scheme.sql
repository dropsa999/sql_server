SELECT
    dec.session_id,
    dec.auth_scheme
FROM sys.dm_exec_connections AS dec
# SVG Functions

A collection of [PostgreSQL](https://www.postgresql.org/) functions
which allow easily creating [SVG](https://developer.mozilla.org/en-US/docs/Web/SVG) graphics.
The main goal of the API is to allow converting [PostGIS](https://postgis.net/) geometries into styled SVG documents.
The functions also support simple geometry generated without PostGIS.

## Installation

```
psql < pg-svg-lib.sql
```

Sometimes function signatures can change.
The old function must be removed.
To generate `DROP FUNCTION` commands use this query:

```sql
SELECT 'DROP FUNCTION ' || oid::regprocedure
FROM   pg_proc
WHERE  proname LIKE 'svg%' AND pg_function_is_visible(oid);
```

## Usage

See the [API doc](API.md).

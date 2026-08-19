# SQL Course Practice

PostgreSQL exercises and assignment solutions from the SQL course.

The repository contains two kinds of material:

- lecture/practice notes (`1_15sql.sql`, `17_25sql.sql`, `27_39sql.sql`);
- reproducible assignment solutions for the **Library** and **Airport** tasks.

## Assignment structure

- `src/main/resources/task/16sql.adoc` — Library assignment;
- `src/main/resources/db/16sql.sql` — completed Library queries;
- `src/main/resources/task/26sql.adoc` — Airport assignment;
- `src/main/resources/db/26sql.sql` — completed Airport queries;
- `src/main/resources/db/migration/` — Flyway schema and seed migrations;
- `src/test/sql/verify.sql` — SQL assertions used by CI.

The lecture-note SQL files are intentionally kept as learning material and are **not** Flyway migrations. Some of them demonstrate destructive statements and alternative query forms, so they are not intended to be executed top-to-bottom against a production database.

## Requirements

- Java 11+
- Maven 3.8+
- PostgreSQL 14+

## Database setup

Create an empty PostgreSQL database, for example:

```sql
CREATE DATABASE sql_course;
```

Configure Flyway with environment variables. Example for PowerShell:

```powershell
$env:DB_URL = "jdbc:postgresql://localhost:5432/sql_course"
$env:DB_USER = "postgres"
$env:DB_PASSWORD = "your-password"
```

Linux/macOS:

```bash
export DB_URL='jdbc:postgresql://localhost:5432/sql_course'
export DB_USER='postgres'
export DB_PASSWORD='your-password'
```

No database password is stored in the repository.

## Apply migrations

```bash
mvn -B flyway:migrate
```

This creates and seeds both assignment schemas in the configured database.

## Run the assignments

With `psql`:

```bash
psql -d sql_course -f src/main/resources/db/16sql.sql
psql -d sql_course -f src/main/resources/db/26sql.sql
```

`16sql.sql` contains the destructive delete required by task 9, so use a fresh migrated database when you want deterministic results.

## Verify results

After applying migrations and executing both assignment files:

```bash
psql -d sql_course -v ON_ERROR_STOP=1 -f src/test/sql/verify.sql
```

The verification script checks, among other things:

- the Library delete is data-driven rather than hard-coded;
- the five-oldest-books result remains correct;
- aircraft models and flight seats are unique where required;
- flight statuses and dates are valid;
- the MN3002 free-seat result is correct;
- exactly two longest flights are selected from valid data;
- Minsk/London duration statistics are correct;
- passenger statistics group by first name.

## CI

GitHub Actions starts a PostgreSQL 14 service, applies Flyway migrations, executes both assignment solutions, and runs the SQL assertions on every push and pull request.

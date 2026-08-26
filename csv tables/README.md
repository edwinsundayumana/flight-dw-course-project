# CSV Exports

Snapshots of the fact table (and other tables, as needed) exported directly from SQL Server at key
milestones, kept here as evidence of the project's progress and as a reference distinct from the
live database.

## Files

| File | Exported after | Description |
|---|---|---|
| `FactAirticket_v1_preprocessed.csv` | Phase 1 (preprocessing) | The 600-row fact table after all preprocessing fixes were applied and verified (see `queries/06_verification_all_requirements.sql`). All requirements confirmed passing at time of export. |

## How these are generated

Each snapshot is exported directly from SSMS: run a `SELECT * FROM <table> ORDER BY <key>;`,
right-click the results grid → **Save Results As...** → save as `.csv`. This keeps the exported
file as an exact, verifiable copy of what's actually in the database at that point in time, rather
than a manually edited file.

## Why keep these at all, if the real data lives in SQL Server?

- Provides a permanent, timestamped record of what the data looked like at each phase, for the
  report and for grading evidence.
- Lets changes between phases be diffed/compared later if needed.
- Gives a fallback reference if the database ever needs to be rebuilt from scratch.

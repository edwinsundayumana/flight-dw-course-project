# CSV Exports

Snapshots of the fact table (and other tables, as needed) exported directly from SQL Server at key
milestones, kept here as evidence of the project's progress and as a reference distinct from the
live database.

## Files

| File | Exported after | Description |
|---|---|---|
| `FactAirticket_v1_preprocessed.csv` | Phase 1 (preprocessing) | The 600-row fact table after all preprocessing fixes were applied and verified (see `queries/06_verification_all_requirements.sql`). All Phase 1 requirements confirmed passing at time of export. |
| `FactAirticket_v2_star_schema.csv` | Phase 2 (star schema formalization) | Same 600 rows, now including the new `FlightFactID` surrogate primary key and direct `AirlinesID` column, with all 15 previously-orphaned `PassengerID` values corrected. Exported after all 11 foreign key constraints were verified in place. |


## Why do I keep these at all, if the real data lives in SQL Server?

- Provides a permanent, timestamped record of what the data looked like at each phase, for the
  report and for grading evidence.
- Lets changes between phases be diffed/compared later if needed.
- Gives a fallback reference if the database ever needs to be rebuilt from scratch.

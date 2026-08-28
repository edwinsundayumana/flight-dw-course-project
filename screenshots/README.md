# Screenshots

Visual evidence captured throughout the project — diagrams, query results, SSMS/SSAS screens —
kept here so they're easy to find when writing the final report, and so the repository itself
shows visual progress alongside the SQL in `queries/`.

## Naming convention

`<phase-number>_<short-description>.png`, e.g. `02_star_schema_diagram.png`. Numbered by the
phase the screenshot belongs to, so files sort in the same order the project was built.

## Contents

| File | Phase | Description |
|---|---|---|
| `star_schema_diagram.png` | 2 — Star Schema Design | SSMS Database Diagram showing `FactAirticket` at the center with all 9 dimension tables connected via their formally-declared foreign keys, including the three-way role-playing relationship into `DimAirport` (Departure / Transit / Landing). Generated after all 11 foreign key constraints were added and verified. |

More rows will be added here as later phases produce their own evidence (e.g. Phase 1
verification query results, Phase 4 SSAS cube structure, Phase 5 MDX query results).

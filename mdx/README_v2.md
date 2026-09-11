# MDX Queries (Phase 5 — OLAP Analysis)

21+ MDX queries demonstrating 7+ OLAP operation types (3 examples each), run against
`FlightAirticketCube` on `EDWIN\SSAS_EVAL`.

## Naming convention

`<operation>_<number>_<short description>.mdx`, with a matching `<same name>_result.csv`
holding that query's exported result grid.

## Progress

| # | Operation | File | Business question | Status |
|---|---|---|---|---|
| 1 | Slice | `slice_01_price_by_airline_march2021.mdx` | Total ticket revenue by airline, for March 2021 only. Helps identify which airlines were strongest in a specific period (e.g. seasonal/holiday performance). | ✅ Done |
| 2 | Slice | `slice_02_mileage_by_airport_firstclass.mdx` | Total mileage flown by departure airport, for First Class passengers only. Identifies which airports generate the most premium/long-haul traffic. | ✅ Done |
| 3 | Slice | `slice_03_flightcount_by_airport_MU.mdx` | Flight count by departure airport, for China Eastern (MU) only. Shows one airline's own route network concentration. | ✅ Done |
| 4 | Dice | `dice_01_price_by_airline_q1_business.mdx` | Total revenue by airline, for Q1 2021 (Jan-Mar) AND Business class only. Combines a time range with a class filter simultaneously. | ✅ Done |
| 5 | Dice | `dice_02_flightcount_by_airport_age50plus_premium.mdx` | Flight count by departure airport, for passengers aged 51-90 AND flying First or Business class. Targets a specific demographic + premium segment together. | ✅ Done |
| 6 | Dice | `dice_03_avgrate_by_airline_transit_specific_airport.mdx` | Average discount rate by airline, for flights with a real transit/stopover AND departing from a specific airport (漠河机场). Uses a calculated member (average) and excludes the "no transit" placeholder member. | ✅ Done |

More rows will be added as each remaining operation (Drill, Rank, Top N, Moving Average, Pivot,
etc.) is completed.

## Notes

- `(null)` in a result is not an error — it correctly means no fact rows matched that specific
  combination (e.g. an airport outside the 30-airport pool used in Phase 1, or an airline with
  no flights in the filtered period/class/demographic). Distinguished from a wrong-query
  symptom, which would show `(null)` for every single row rather than a mix of real values and
  nulls.
- Several dimension attributes had to be manually added in the cube designer after the Cube
  Wizard's quick-create path only exposed ID columns by default: `Year`/`Month`/`Date` under
  the date dimensions, `airlines`/`airlinesCode` under Dim Airlines, and `PassengerAge`/
  `PassengerGender`/`PassengerWorkplace`/`FFP_TIER`/`FLIGHT_COUNT`/`PassengerName` under Dim
  Passenger. See `cube/README.md`.
- While adding the Dim Passenger attributes, cube processing failed with an "attribute key
  cannot be found" error, traced to 735 `PassengerWorkplace` values containing a Chinese
  "ideographic space" character (`NCHAR(12288)`) inconsistently — some rows had it, some
  didn't, for what should have been the same value. A first fix attempt using `TRIM` did not
  work because the character was embedded mid-string, not at the start/end; fixed instead with
  `REPLACE(PassengerWorkplace, NCHAR(12288), '')`. See `queries/12_fix_passenger_workplace_special_space.sql`.
- Exact dimension/attribute/measure names were confirmed via the SSMS Metadata pane before
  writing each query, rather than assumed, after an early query failed due to a naming mismatch
  (`Departure Date` originally only exposed `Date Range ID`, not `Year`/`Month`).
- MDX has no direct "IS NOT NULL" filter the way SQL does. To find rows with a genuine transit
  stop (excluding the ~575 rows with none), we exclude the dimension's automatic
  `.UnknownMember` placeholder using `EXCEPT(...)` rather than a NULL check. A first attempt
  naming this exclusion as a separate `WITH SET` triggered a false "circular reference" error
  from the SSAS engine when used inside the `WHERE` slicer axis; fixed by inlining the
  `EXCEPT(...)` expression directly in the `WHERE` clause instead of naming it separately.
- Chinese text (airport/airline/city names) in exported result CSVs shows as `?` if saved via
  Excel's plain "CSV (Comma delimited)" option, since this Excel version lacks a "CSV UTF-8"
  option. Fix: Save As "Unicode Text (*.txt)" instead, then rename the file extension from
  `.txt` to `.csv` in File Explorer.

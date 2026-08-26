/*
    Phase 1 - Preprocessing
    Fix: Rate column was imported as `real` (single-precision float),
    which caused floating point display errors (e.g. 0.35 shown as
    0.349999994039536). Converts it to decimal(3,2), an exact type,
    since Rate only ever ranges from 0.29 to 1.00 in 2-decimal steps.
*/

USE FlightDW;
GO

ALTER TABLE FactAirticket
ALTER COLUMN Rate DECIMAL(3,2);
GO

-- Verify
SELECT COLUMN_NAME, DATA_TYPE, NUMERIC_PRECISION, NUMERIC_SCALE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'FactAirticket';

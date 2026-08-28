/*
    Phase 2 - Star Schema Design
    FactAirticket had no formal primary key (the 'ian' column was
    unique by coincidence, but nothing enforced it). Adds a proper
    surrogate primary key, FlightFactID, numbered 1-600.
*/

USE FlightDW;
GO

-- Step 1: add the column, nullable for now
ALTER TABLE FactAirticket
ADD FlightFactID INT NULL;
GO

-- Step 2: populate it, numbered in the same order as the original 'ian' column
WITH Numbered AS (
    SELECT ian, ROW_NUMBER() OVER (ORDER BY ian) AS RowNum
    FROM FactAirticket
)
UPDATE f
SET f.FlightFactID = n.RowNum
FROM FactAirticket f
JOIN Numbered n ON f.ian = n.ian;
GO

-- Step 3: forbid future blanks
ALTER TABLE FactAirticket
ALTER COLUMN FlightFactID INT NOT NULL;
GO

-- Step 4: declare it the primary key
ALTER TABLE FactAirticket
ADD CONSTRAINT PK_FactAirticket PRIMARY KEY (FlightFactID);
GO

-- Verify
SELECT TOP 5 FlightFactID, ian FROM FactAirticket ORDER BY FlightFactID;
SELECT COUNT(*) AS TotalRows, COUNT(DISTINCT FlightFactID) AS DistinctIDs FROM FactAirticket;

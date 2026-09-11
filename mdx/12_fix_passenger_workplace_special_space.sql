/*
    Phase 5 - OLAP Cube (discovered while adding Dim Passenger attributes)
    Fix for cube processing failure:
    "The attribute key cannot be found when processing:
    Table: 'dbo_DimPassenger', Column: 'PassengerWorkplace',
    Value: '中国河南郑州　'. The attribute is 'Passenger Workplace'."

    Cause: 735 PassengerWorkplace values contained a Chinese
    "ideographic space" character (U+3000, NCHAR(12288)) -- visually
    similar to a normal space but a distinct character. Some rows
    for what should be the same workplace had this character, some
    didn't, causing inconsistent/duplicate-looking attribute keys
    that SSAS refused to process.

    Note: a first attempt using TRIM() did not fix this, because
    TRIM only removes characters from the start/end of a string --
    in this data the character was embedded in the middle of the
    text (e.g. "HKHong KongHong Kong", position 7 of 20 characters),
    not at the edges. REPLACE() is the correct tool since it removes
    every occurrence, regardless of position.
*/

USE FlightDW;
GO

-- Diagnose: how many rows are affected
SELECT COUNT(*) AS RowsWithSpecialSpace
FROM DimPassenger
WHERE PassengerWorkplace LIKE '%' + NCHAR(12288) + '%';
GO

-- Fix: remove the character wherever it appears in the string
UPDATE DimPassenger
SET PassengerWorkplace = REPLACE(PassengerWorkplace, NCHAR(12288), '')
WHERE PassengerWorkplace IS NOT NULL;
GO

-- Verify
SELECT COUNT(*) AS StillHasSpecialSpace
FROM DimPassenger
WHERE PassengerWorkplace LIKE '%' + NCHAR(12288) + '%';

/*
    After running this, redeploy the SSAS project (Visual Studio ->
    right-click project -> Deploy) to reprocess the cube against the
    cleaned data.
*/

/*
    Phase 4 - OLAP Cube (SSAS)
    Fix for cube deployment error:
    "The datasource, 'FlightDW', contains an ImpersonationMode that
    is not supported for processing operations."

    Cause: the Data Source's impersonation setting was originally
    "Use the credentials of the current user", which works for
    interactive browsing/design but fails during actual cube
    PROCESSING, since processing runs as a background Windows
    service (no logged-in user to borrow credentials from).

    Fix (two parts):
    1. In Visual Studio, the Data Source (FlightDW.ds) impersonation
       mode was changed from "Use the credentials of the current
       user" to "Use the service account".
    2. This script grants that service account explicit, read-only
       permission on FlightDW, since it has no access by default.

    Run this against the Database Engine (not Analysis Services).
    Adjust the login name below if your SSAS instance has a
    different name than SSAS_EVAL.
*/

USE FlightDW;
GO

CREATE LOGIN [NT SERVICE\MSOLAP$SSAS_EVAL] FROM WINDOWS;
CREATE USER [NT SERVICE\MSOLAP$SSAS_EVAL] FOR LOGIN [NT SERVICE\MSOLAP$SSAS_EVAL];
ALTER ROLE db_datareader ADD MEMBER [NT SERVICE\MSOLAP$SSAS_EVAL];
GO

-- Verify
SELECT dp.name AS UserName, dp.type_desc, r.name AS RoleName
FROM sys.database_role_members drm
JOIN sys.database_principals dp ON drm.member_principal_id = dp.principal_id
JOIN sys.database_principals r ON drm.role_principal_id = r.principal_id
WHERE dp.name = 'NT SERVICE\MSOLAP$SSAS_EVAL';

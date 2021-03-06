/*
The following Errors were reported on first run of this script using the Equineplus 
database:

[11:28:36 AM]	Started executing query at Line 1678
	
	Msg 207, Level 16, State 1, Procedure vw_user_History_plus, Line 8
Invalid column name 'AgeCategoryID'. 
	
	Msg 207, Level 16, State 1, Procedure vw_user_History_plus, Line 4
Invalid column name 'Price'. 
	
	Msg 207, Level 16, State 1, Procedure vw_user_History_plus, Line 4
Invalid column name 'Note1'. 
	
	Msg 207, Level 16, State 1, Procedure vw_user_History_plus, Line 4
Invalid column name 'Note2'. 
---------------------
[11:28:38 AM]	Started executing query at Line 3302
	
	The module 'usp_user_Service_GetByID' depends on the missing object 'usp_user_Contact_GetByID'. The module will still be created; however, it cannot run successfully until the object exists. 
---------------------

*/
USE [EquinePlus]
GO
/****** Object:  StoredProcedure [dbo].[usp_user_System_GetStatementDate]    Script Date: 10/25/2020 11:13:59 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_user_System_GetStatementDate]
(
@Statement varchar(10)
)
AS
BEGIN

	--get the current period
	SELECT StatementDate FROM user_Statement WHERE Statement = @Statement

END
GO
/****** Object:  UserDefinedFunction [dbo].[udf_ComputeDaysOld]    Script Date: 10/25/2020 11:14:00 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[udf_ComputeDaysOld]
	(@DateBorn	varchar(8)
	,@OffsetMonth	int
	,@CurrentDate	datetime)
RETURNS int

AS

BEGIN

-- NOTE: The ComputedDaysOld value calculated for cases where OffsetMonth is NOT equal to ZERO is INCORRECT.
-- Must consult with farm personnel on how to do this.

DECLARE @ComputedDateBorn	datetime
DECLARE @ComputedDaysOld	int

IF @DateBorn is not NULL and LEN(@DateBorn) = 8
BEGIN

	IF @OffsetMonth = 0
		SET @ComputedDateBorn = CONVERT(DateTime, SUBSTRING(@DateBorn,5,2) + '/' + RIGHT(@DateBorn,2) + '/' + LEFT(@DateBorn,4))
	ELSE
		SET @ComputedDateBorn = CONVERT(DateTime, CONVERT(nvarchar(2),@OffsetMonth) + '/1/' + LEFT(@DateBorn,4))

	SET @ComputedDaysOld = DATEDIFF(dd,@ComputedDateBorn,@CurrentDate)

END
ELSE
	SET @ComputedDaysOld = 0

RETURN @ComputedDaysOld

END
GO
/****** Object:  StoredProcedure [dbo].[usp_user_MaintenanceBoarding_Delete]    Script Date: 10/25/2020 11:13:51 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_MaintenanceBoarding_Delete]
	@BoardingID			uniqueidentifier

AS

DELETE
FROM user_MaintenanceBoarding
WHERE BoardingID = @BoardingID
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Show_Delete]    Script Date: 10/25/2020 11:13:55 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_Show_Delete]
(
	@ShowID uniqueIdentifier 
)
AS
BEGIN
	DELETE FROM user_Show WHERE ShowID = @ShowID
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnPositive]    Script Date: 10/25/2020 11:14:00 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[fnPositive] 
(
@value numeric(18,2)
)  
RETURNS numeric(18,2)
AS  
BEGIN 
	IF (@value < 0)
	BEGIN
		SET @value = 0
	END

	RETURN (@value)
END
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Client_Update_ContactID]    Script Date: 10/25/2020 11:13:33 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
-- =============================================
-- Author:		<Sean Biefeld>
-- Create date: <09/12/2006>
-- Description:	<Update Client Contact>
-- =============================================
CREATE PROCEDURE [dbo].[usp_user_Client_Update_ContactID]
	@ClientID		uniqueidentifier,
	@ContactID		uniqueidentifier	
AS
UPDATE user_Client
SET ContactID = @ContactID
WHERE ClientID = @ClientID
GO
/****** Object:  StoredProcedure [dbo].[usp_user_History_Update]    Script Date: 10/25/2020 11:13:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_History_Update]
             @HorseID                  uniqueidentifier
            ,@SalesList                  bit
            ,@SalesPrice                numeric(18,2)
            ,@DateAcquired                      datetime
            ,@Cost                                    numeric(18,2)
            ,@SellingPrice              numeric(18,2)
            ,@SalesNote1              nvarchar(60)
            ,@SalesNote2              nvarchar(60)
            ,@Notes                      nvarchar(65)
            ,@SpecialReportCodes            nvarchar(10)
            ,@Comments               ntext
            ,@DateSold                 datetime
 ,@UpdateUser varchar(120) = null, @UpdateTimestamp DateTime = null, @NewUpdateUser varchar(120)

AS

IF NOT EXISTS ( select 1 from user_History where HorseID = @HorseID )
BEGIN

	INSERT INTO user_History (HorseID, UpdateUser, UpdateTimestamp) VALUES (@HorseID, @UpdateUser, @Updatetimestamp)

END


UPDATE user_History
SET SalesList = @SalesList, SalesPrice = @SalesPrice, DateAcquired = @DateAcquired,
            Cost = @Cost, SellingPrice = @SellingPrice, SalesNote1 = @SalesNote1, SalesNote2 = @SalesNote2,
            Notes = @Notes, SpecialReportCodes = @SpecialReportCodes, Comments = @Comments, UpdateUser = @NewUpdateUser, UpdateTimestamp = GETDATE()
WHERE HorseID = @HorseID
AND (UpdateUser = @UpdateUser AND UpdateTimestamp = @UpdateTimestamp)
 
--Check For Concurrency Error
IF (@@ROWCOUNT = 0) 
BEGIN
	RAISERROR(52025, 16, 1)
END

UPDATE user_Horse
SET DateSold = @DateSold
WHERE HorseID = @HorseID
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Maintenance_GetByID]    Script Date: 10/25/2020 11:13:49 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_Maintenance_GetByID]
(
@HorseID uniqueidentifier
)
AS

if not exists (select 1 from user_Maintenance where HorseID = @HorseID)
begin
	if exists (select 1 from user_horse where HorseID = @HorseID)
	begin
		INSERT INTO user_Maintenance (HorseID) VALUES (@HorseID)
	end
end

SELECT m.HorseID, m.Location, m.Insurance, m.InsurancePhone, m.Handler, m.Trainer, m.NextVet, m.NextFarrier,
m.Note1, m.Note2, m.BandNumber, m.Comments, h.HorseName
,m.UpdateUser, m.UpdateTimestamp
FROM user_Maintenance m
JOIN user_Horse h ON m.HorseID = h.HorseID
WHERE m.HorseID = @HorseID
GO
/****** Object:  View [dbo].[vw_user_Breeding_plus]    Script Date: 10/25/2020 11:14:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_user_Breeding_plus]
AS
SELECT     TOP 100 PERCENT b.BreedingID, horse1.HorseName AS MareName, g1.LookupDescription AS MareGender, horse2.HorseName AS StallionName, 
                      g2.LookupDescription AS StallionGender, b.DateOpened, b.DateClosed, b.Fee, b.Gestation, b.FoalingDate, b.BreedingLocation, b.Status, b.StatusDate, 
                      b.Comments
FROM         dbo.user_Breeding b INNER JOIN
                      dbo.user_Horse horse1 ON b.HorseID = horse1.HorseID INNER JOIN
                      dbo.user_Horse horse2 ON b.StallionID = horse2.HorseID INNER JOIN
                      dbo.base_Lookup g1 ON horse1.GenderID = g1.LookupID INNER JOIN
                      dbo.base_Lookup g2 ON horse2.GenderID = g2.LookupID
ORDER BY horse1.HorseName, b.DateOpened
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Breeding_GetByHorseID]    Script Date: 10/25/2020 11:13:24 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_Breeding_GetByHorseID]
            @HorseID                                 uniqueidentifier
AS


DECLARE @Gender varchar(100)
 

SELECT @Gender = g.LookupAbrv
FROM user_Horse h
INNER JOIN base_Lookup g ON h.GenderID = g.LookupID
WHERE h.HorseID = @HorseID

 
IF @Gender = 'M'
            SELECT b.BreedingID, b.HorseID, mare.HorseName AS MareName, b.StallionID,
                        stallion.HorseName AS StallionName, b.ReservationDate, b.DateOpened, b.DateClosed, b.Fee,
                        b.Gestation, b.FoalingDate, b.BreedingLocation, b.Status, b.StatusDate, b.Comments
		,b.UpdateUser, b.UpdateTimestamp
            FROM user_Breeding b
            JOIN user_Horse mare ON b.HorseID = mare.HorseID
            JOIN user_Horse stallion ON b.StallionID = stallion.HorseID
            WHERE b.HorseID = @HorseID
            ORDER BY b.ReservationDate DESC

ELSE

            BEGIN

            IF @Gender = 'S'

            SELECT b.BreedingID, b.HorseID, mare.HorseName AS MareName, b.StallionID,
                        stallion.HorseName AS StallionName, b.ReservationDate, b.DateOpened, b.DateClosed, b.Fee,
                        b.Gestation, b.FoalingDate, b.BreedingLocation, b.Status, b.StatusDate, b.Comments
		,b.UpdateUser, b.UpdateTimestamp
            FROM user_Breeding b
            JOIN user_Horse mare ON b.HorseID = mare.HorseID
            JOIN user_Horse stallion ON b.StallionID = stallion.HorseID
            WHERE b.StallionID = @HorseID
            ORDER BY mare.HorseName, b.ReservationDate DESC

            ELSE

                        SELECT * FROM user_Horse WHERE 1 = 0

            END
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Horse_GetListForReport]    Script Date: 10/25/2020 11:13:44 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_Horse_GetListForReport]
(
@LocalCodes varchar(50),
@Ages varchar(50),
@Genders varchar(50)
)
AS

DECLARE @FoalCode	varchar(1)
DECLARE @WeanlingCode	varchar(1)
DECLARE @YearlingCode	varchar(1)
DECLARE @TwoYearOldCode	varchar(1)
DECLARE @ThreeYearOldCode	varchar(1)
DECLARE @FourYearOldCode	varchar(1)
DECLARE @AdultCode	varchar(1)

IF CHARINDEX('F',@Ages) > 0
  set @FoalCode = 'F'
IF CHARINDEX('W',@Ages) > 0
  set @WeanlingCode = 'W'
IF CHARINDEX('Y',@Ages) > 0
  set @YearlingCode = 'Y'
IF CHARINDEX('2',@Ages) > 0
  set @TwoYearOldCode = '2'
IF CHARINDEX('3',@Ages) > 0
  set @ThreeYearOldCode = '3'
IF CHARINDEX('4',@Ages) > 0
  set @FourYearOldCode = '4'
IF CHARINDEX('A',@Ages) > 0
  set @AdultCode = 'A'


DECLARE @OffsetMonth	int
DECLARE @Weanling	int
DECLARE @Yearling	int
DECLARE @TwoYearOld	int
DECLARE @ThreeYearOld	int
DECLARE @FourYearOld	int
DECLARE @Adult		int

SELECT @OffsetMonth = OffsetMonth, @Weanling = Weanling, @Yearling = Yearling,
	@TwoYearOld = TwoYearOld, @ThreeYearOld = ThreeYearOld, @FourYearOld = FourYearOld,
	@Adult = Adult
FROM config_AgeCategories
WHERE ConfigID = '{91AF1A80-7994-431E-8D6C-9D9B7CDAE4C1}'

DECLARE @horseids table 
   (HorseID uniqueidentifier, DaysOld int, AgeCode varchar(1))

INSERT INTO @horseids (HorseID, DaysOld)
SELECT h.HorseID, dbo.udf_ComputeDaysOld(h.DateBorn, @OffsetMonth, GetDate()) 
FROM user_Horse h 
WHERE 
GenderID in (select LookupID from base_lookup where LookupSetID = '{454BA8D6-24D5-4723-8518-D63143194411}' and CHARINDEX(LookupAbrv,@Genders) > 0 ) and 
LocalID in (select LookupID from base_Lookup where LookupSetID = '{506C0E43-4548-46C6-9BB7-09643EE23188}' and CHARINDEX(LookupAbrv,@LocalCodes) > 0 )

--select * from @horseids

UPDATE @horseids
SET AgeCode = 
	CASE
		WHEN DaysOld >= @Adult THEN @AdultCode
		WHEN DaysOld >= @FourYearOld THEN @FourYearOldCode
		WHEN DaysOld >= @ThreeYearOld THEN @ThreeYearOldCode
		WHEN DaysOld >= @TwoYearOld THEN @TwoYearOldCode
		WHEN DaysOld >= @Yearling THEN @YearlingCode
		WHEN DaysOld >= @Weanling THEN @WeanlingCode
		ELSE @FoalCode
	END

--select * from @horseids


SELECT h.HorseID, h.HorseName, h.TrackingColorID, LUDescription.LookupDescription AS TrackingColorDescription, 
	LUDescription.LookupAbrv AS TrackingColorAbrv, h.RegistrationNumber, h.DateDeceased, h.DateBorn, h.GenderID,
	LUGender.LookupDescription AS GenderDescription, LUGender.LookupAbrv AS GenderAbrv, h.Data1, h.Data2, h.ColorID,
	LUColor.LookupDescription AS ColorDescription, LUColor.LookupAbrv AS ColorAbrv, h.Comment, h.Breeder, h.Owner, h.OwnerNumber, h.SireID, 
	h2.HorseName AS SireName, h2.RegistrationNumber AS SireRegistrationNumber, LUSireGender.LookupDescription AS SireGenderDescription,
	h.DamID, h3.HorseName AS DamName, h3.RegistrationNumber AS DamRegistrationNumber,
	LUDamGender.LookupDescription AS DamGenderDescription, h.BloodTyped, h.FreezeMarked, h.Imported, h.Title1, h.Title2, h.Breed, h.[Catalog],
	h.LastTransaction, h.LocalID, LULocal.LookupDescription AS LocalDescription, LULocal.LookupAbrv AS LocalAbrv, h.DateSold, h.Comments,
	(SELECT TOP 1 HorseID FROM dbo.user_Horse WHERE HorseName > h.HorseName ORDER BY HorseName) AS NextHorseID,
	(SELECT TOP 1 HorseID FROM dbo.user_Horse WHERE HorseName < h.HorseName ORDER BY HorseName DESC) AS PreviousHorseID
FROM dbo.user_Horse h
INNER JOIN dbo.base_Lookup LUDescription ON h.TrackingColorID = LUDescription.LookupID
INNER JOIN dbo.base_Lookup LUGender ON h.GenderID = LUGender.LookupID
INNER JOIN dbo.base_Lookup LUColor ON h.ColorID = LUColor.LookupID
LEFT OUTER JOIN dbo.user_Horse h2 ON h.SireID = h2.HorseID
LEFT OUTER JOIN dbo.user_Horse h3 ON h.DamID = h3.HorseID
LEFT OUTER JOIN dbo.base_Lookup LUSireGender ON h2.GenderID = LUSireGender.LookupID
LEFT OUTER JOIN dbo.base_Lookup LUDamGender ON h3.GenderID = LUDamGender.LookupID
INNER JOIN dbo.base_Lookup LULocal ON h.LocalID = LULocal.LookupID
INNER JOIN @horseids hi on hi.HorseID = h.HorseID and (hi.AgeCode is not null)
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Breeding_GetListForMareReport]    Script Date: 10/25/2020 11:13:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_user_Breeding_GetListForMareReport]
(
@LocalCodes varchar(50),
@BeginDate datetime,
@EndDate datetime,
@IncludeClosedBreedings bit
)
AS
 

SELECT b.BreedingID, m.HorseName MareName, s.HorseName StallionName, 
            b.StatusDate,
            b.FoalingDate, b.Status, 
            c.BreedingCalendarID as EntryID, c.[Date] as EntryDate, c.Codes as EntryCodes
,b.UpdateUser, b.UpdateTimestamp
FROM user_Breeding b
JOIN user_Horse m ON b.HorseID = m.HorseID 
            and m.LocalID in (select LookupID from base_Lookup where LookupSetID = '{506C0E43-4548-46C6-9BB7-09643EE23188}' and CHARINDEX(LookupAbrv,@LocalCodes) > 0 )
JOIN user_Horse s ON b.StallionID = s.HorseID
JOIN user_BreedingCalendar c on c.BreedingID = b.BreedingID
WHERE b.StatusDate >= @BeginDate and b.StatusDate <= @EndDate
            and (c.Codes like '%I%' or c.Codes like '%B%' or c.Codes like '%A%') 
	and (@IncludeClosedBreedings = 1 or b.DateClosed is null)
ORDER BY MareName, StallionName, EntryDate, EntryCodes
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Horse_GetCategoryCountForReport]    Script Date: 10/25/2020 11:13:41 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_Horse_GetCategoryCountForReport]

(
@BegHorse varchar(100),
@EndHorse varchar(100),
@BegDOB varchar(8),
@EndDOB varchar(8),
@Data1 varchar(100),
@Data2 varchar(100),
@Owner varchar(50),
@Breeder varchar(50),
@Breed varchar(50),
@Imported bit,
@RegPrefix varchar(10),
@CatPrefix varchar(10),
@Sex varchar(10),
@Color varchar(10)
)

AS

--

SELECT count(1)

FROM dbo.user_Horse h
LEFT OUTER JOIN dbo.base_Lookup LUGender ON h.GenderID = LUGender.LookupID
LEFT OUTER JOIN dbo.base_Lookup LUColor ON h.ColorID = LUColor.LookupID
WHERE 
	(@BegHorse is NULL or @BegHorse <= h.HorseName) and
	(@EndHorse is NULL or h.HorseName <= @EndHorse) and
	(@BegDOB is NULL or @BegDOB <= h.DateBorn) and
	(@EndDOB is NULL or h.DateBorn <= @EndDOB) and
	(@Data1 is NULL or h.Data1 like @Data1) and
	(@Data2 is NULL or h.Data2 like @Data2) and
	(@Owner is NULL or h.Owner like @Owner) and
	(@Breeder is NULL or h.Breeder like @Breeder) and
	(@Breed is NULL or h.Breed like @Breed) and
	(@Imported = 0 or h.Imported = 1) and
	(@RegPrefix is NULL or h.RegistrationNumber like @RegPrefix) and
	(@CatPrefix is NULL or h.[Catalog] like @CatPrefix) and
	(@Sex is NULL or LUGender.LookupAbrv like @Sex) and
	(@Color is NULL or LUColor.LookupAbrv like @Color)
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Horse_GetBandNumberListForReport]    Script Date: 10/25/2020 11:13:40 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_Horse_GetBandNumberListForReport] 
(
@Order varchar(1),
@LocalCodes varchar(50)
)
AS

select m.BandNumber, h.HorseName, m.Location, l.lookupabrv as LocalAbrv
from dbo.user_Horse h
inner join base_Lookup l on h.LocalID = l.LookupID and l.LookupID in (select LookupID from base_Lookup where LookupSetID = '{506C0E43-4548-46C6-9BB7-09643EE23188}' and (CHARINDEX(LookupAbrv,@LocalCodes) > 0 or (CHARINDEX('8', @LocalCodes) > 0) and CHARINDEX(LookupAbrv,'S') > 0) )
inner join dbo.user_Maintenance m on m.HorseID = h.HorseID and (m.BandNumber is not null and m.BandNumber <> '')
order by 
	case
	when @order = 'b' then Bandnumber
	when @order = 'h' then HorseName
	when @order = 'l' then Location
	end,
	case
	when @order = 'b' then HorseName
	when @order = 'h' then BandNumber
	when @order = 'l' then BandNumber
	end
GO
/****** Object:  StoredProcedure [dbo].[usp_user_HorseWithProgeny_GetDetailedListForReport]    Script Date: 10/25/2020 11:13:49 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_HorseWithProgeny_GetDetailedListForReport]

(
@BegHorse varchar(100),
@EndHorse varchar(100),
@BegDOB varchar(8),
@EndDOB varchar(8),
@Data1 varchar(100),
@Data2 varchar(100),
@Owner varchar(50),
@Breeder varchar(50),
@Breed varchar(50),
@Imported bit,
@RegPrefix varchar(10),
@CatPrefix varchar(10),
@Sex varchar(10),
@Color varchar(10)
)

AS

--

DECLARE @temp table
	(HorseID uniqueidentifier)

INSERT INTO @temp (HorseID)
SELECT h.HorseID
FROM dbo.user_Horse h
LEFT OUTER JOIN dbo.base_Lookup LUGender ON h.GenderID = LUGender.LookupID
LEFT OUTER JOIN dbo.base_Lookup LUColor ON h.ColorID = LUColor.LookupID
WHERE 
	(@BegHorse is NULL or @BegHorse <= h.HorseName) and
	(@EndHorse is NULL or h.HorseName <= @EndHorse) and
	(@BegDOB is NULL or @BegDOB <= h.DateBorn) and
	(@EndDOB is NULL or h.DateBorn <= @EndDOB) and
	(@Data1 is NULL or h.Data1 like @Data1) and
	(@Data2 is NULL or h.Data2 like @Data2) and
	(@Owner is NULL or h.Owner like @Owner) and
	(@Breeder is NULL or h.Breeder like @Breeder) and
	(@Breed is NULL or h.Breed like @Breed) and
	(@Imported = 0 or h.Imported = 1) and
	(@RegPrefix is NULL or h.RegistrationNumber like @RegPrefix) and
	(@CatPrefix is NULL or h.[Catalog] like @CatPrefix) and
	(@Sex is NULL or LUGender.LookupAbrv like @Sex) and
	(@Color is NULL or LUColor.LookupAbrv like @Color)
--and h.HorseName like 'ABEER%'


SELECT h.HorseID, h.HorseName, h.TrackingColorID, LUDescription.LookupDescription AS TrackingColorDescription, 
	LUDescription.LookupAbrv AS TrackingColorAbrv, h.RegistrationNumber, h.DateDeceased, h.DateBorn, h.GenderID,
	LUGender.LookupDescription AS GenderDescription, LUGender.LookupAbrv AS GenderAbrv, h.Data1, h.Data2, h.ColorID,
	LUColor.LookupDescription AS ColorDescription, LUColor.LookupAbrv AS ColorAbrv, h.Comment, h.Breeder, h.Breed, h.Owner, h.OwnerNumber, h.SireID, 
	h2.HorseName AS SireName, h2.RegistrationNumber AS SireRegistrationNumber, LUSireGender.LookupDescription AS SireGenderDescription,
	h.DamID, h3.HorseName AS DamName, h3.RegistrationNumber AS DamRegistrationNumber,
	LUDamGender.LookupDescription AS DamGenderDescription, h.BloodTyped, h.FreezeMarked, h.Imported, h.Title1, h.Title2, h.Breed, h.[Catalog],
	h.LastTransaction, h.LocalID, LULocal.LookupDescription AS LocalDescription, LULocal.LookupAbrv AS LocalAbrv, h.DateSold, h.Comments,
	(SELECT TOP 1 HorseID FROM dbo.user_Horse WHERE HorseName > h.HorseName ORDER BY HorseName) AS NextHorseID,
	(SELECT TOP 1 HorseID FROM dbo.user_Horse WHERE HorseName < h.HorseName ORDER BY HorseName DESC) AS PreviousHorseID


FROM dbo.user_Horse h
INNER JOIN @temp t on t.HorseID = h.HorseID
LEFT OUTER JOIN dbo.base_Lookup LUDescription ON h.TrackingColorID = LUDescription.LookupID
LEFT OUTER JOIN dbo.base_Lookup LUGender ON h.GenderID = LUGender.LookupID
LEFT OUTER JOIN dbo.base_Lookup LUColor ON h.ColorID = LUColor.LookupID
LEFT OUTER JOIN dbo.user_Horse h2 ON h.SireID = h2.HorseID
LEFT OUTER JOIN dbo.user_Horse h3 ON h.DamID = h3.HorseID
LEFT OUTER JOIN dbo.base_Lookup LUSireGender ON h2.GenderID = LUSireGender.LookupID
LEFT OUTER JOIN dbo.base_Lookup LUDamGender ON h3.GenderID = LUDamGender.LookupID
LEFT OUTER JOIN dbo.base_Lookup LULocal ON h.LocalID = LULocal.LookupID
ORDER BY h.HorseName


SELECT  h.HorseID, h.HorseName,

	p.HorseID as ProgenyID, p.HorseName as ProgenyName, 
	p.TrackingColorID as ProgenyTrackingColorID,
	LUDescription2.LookupDescription AS ProgenyTrackingColorDesc, 
	LUDescription2.LookupAbrv AS ProgenyTrackingColorAbrv, 

	p.RegistrationNumber as ProgenyRegNum, 
	p.DateDeceased as ProgenyDeceased,
	p.DateBorn as ProgenyBorn, 
	p.GenderID as ProgenyGenderID,
	LUGender2.LookupDescription AS ProgenyGenderDesc, 
	LUGender2.LookupAbrv AS ProgenyGenderAbrv, 
	p.Data1 as ProgenyData1, 
	p.Data2 as ProgenyData2, 
	p.ColorID as ProgenyColorID,
	LUColor2.LookupDescription AS ProgenyColorDesc, 
	LUColor2.LookupAbrv AS ProgenyColorAbrv, 
	--p.Comment, p.Breeder, p.Owner, p.OwnerNumber, 
	p.SireID as ProgenySireID, 
	p2.HorseName AS ProgenySireName, 
	p2.RegistrationNumber AS ProgenySireRegNum, 
	--LUSireGender2.LookupDescription AS SireGenderDescription,
	p.DamID as ProgenyDamID, 
	p3.HorseName AS ProgenyDamName, 
	p3.RegistrationNumber AS ProgenyDamRegNum
	--LUDamGender2.LookupDescription AS DamGenderDescription, 
	
	--p.BloodTyped, 
	--p.FreezeMarked, 
	--p.Imported, 
	--p.Title1, 
	--p.Title2, 
	--p.Breed, 
	--p.[Catalog],
	--p.LastTransaction, 
	--p.LocalID, 
	--LULocal2.LookupDescription AS LocalDescription, 
	--LULocal2.LookupAbrv AS LocalAbrv, 
	--p.DateSold, 
	--p.Comments

FROM dbo.user_Horse h
INNER JOIN @temp t on t.HorseID = h.HorseID
INNER JOIN dbo.user_Horse p ON p.SireID = h.HorseID or p.DamID = h.HorseID
LEFT OUTER JOIN dbo.base_Lookup LUDescription2 ON p.TrackingColorID = LUDescription2.LookupID
LEFT OUTER JOIN dbo.base_Lookup LUGender2 ON p.GenderID = LUGender2.LookupID
LEFT OUTER JOIN dbo.base_Lookup LUColor2 ON p.ColorID = LUColor2.LookupID
LEFT OUTER JOIN dbo.user_Horse p2 ON p.SireID = p2.HorseID
LEFT OUTER JOIN dbo.user_Horse p3 ON p.DamID = p3.HorseID
ORDER BY h.HorseName, p.DateBorn
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Horse_GetDetailedListForReport]    Script Date: 10/25/2020 11:13:43 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_Horse_GetDetailedListForReport]

(
@BegHorse varchar(100),
@EndHorse varchar(100),
@BegDOB varchar(8),
@EndDOB varchar(8),
@Data1 varchar(100),
@Data2 varchar(100),
@Owner varchar(50),
@Breeder varchar(50),
@Breed varchar(50),
@Imported bit,
@RegPrefix varchar(10),
@CatPrefix varchar(10),
@Sex varchar(10),
@Color varchar(10)
)

AS

--

SELECT h.HorseID, h.HorseName, h.TrackingColorID, LUDescription.LookupDescription AS TrackingColorDescription, 
	LUDescription.LookupAbrv AS TrackingColorAbrv, h.RegistrationNumber, h.DateDeceased, h.DateBorn, h.GenderID,
	LUGender.LookupDescription AS GenderDescription, LUGender.LookupAbrv AS GenderAbrv, h.Data1, h.Data2, h.ColorID,
	LUColor.LookupDescription AS ColorDescription, LUColor.LookupAbrv AS ColorAbrv, h.Comment, h.Breeder, h.Breed, h.Owner, h.OwnerNumber, h.SireID, 
	h2.HorseName AS SireName, h2.RegistrationNumber AS SireRegistrationNumber, LUSireGender.LookupDescription AS SireGenderDescription,
	h.DamID, h3.HorseName AS DamName, h3.RegistrationNumber AS DamRegistrationNumber,
	LUDamGender.LookupDescription AS DamGenderDescription, h.BloodTyped, h.FreezeMarked, h.Imported, h.Title1, h.Title2, h.Breed, h.[Catalog],
	h.LastTransaction, h.LocalID, LULocal.LookupDescription AS LocalDescription, LULocal.LookupAbrv AS LocalAbrv, h.DateSold, h.Comments,
	(SELECT TOP 1 HorseID FROM dbo.user_Horse WHERE HorseName > h.HorseName ORDER BY HorseName) AS NextHorseID,
	(SELECT TOP 1 HorseID FROM dbo.user_Horse WHERE HorseName < h.HorseName ORDER BY HorseName DESC) AS PreviousHorseID,
	h.UpdateUser, h.UpdateTimestamp

FROM dbo.user_Horse h
LEFT OUTER JOIN dbo.base_Lookup LUDescription ON h.TrackingColorID = LUDescription.LookupID
LEFT OUTER JOIN dbo.base_Lookup LUGender ON h.GenderID = LUGender.LookupID
LEFT OUTER JOIN dbo.base_Lookup LUColor ON h.ColorID = LUColor.LookupID
LEFT OUTER JOIN dbo.user_Horse h2 ON h.SireID = h2.HorseID
LEFT OUTER JOIN dbo.user_Horse h3 ON h.DamID = h3.HorseID
LEFT OUTER JOIN dbo.base_Lookup LUSireGender ON h2.GenderID = LUSireGender.LookupID
LEFT OUTER JOIN dbo.base_Lookup LUDamGender ON h3.GenderID = LUDamGender.LookupID
LEFT OUTER JOIN dbo.base_Lookup LULocal ON h.LocalID = LULocal.LookupID
WHERE 
	(@BegHorse is NULL or @BegHorse <= h.HorseName) and
	(@EndHorse is NULL or h.HorseName <= @EndHorse) and
	(@BegDOB is NULL or @BegDOB <= h.DateBorn) and
	(@EndDOB is NULL or h.DateBorn <= @EndDOB) and
	(@Data1 is NULL or h.Data1 like @Data1) and
	(@Data2 is NULL or h.Data2 like @Data2) and
	(@Owner is NULL or h.Owner like @Owner) and
	(@Breeder is NULL or h.Breeder like @Breeder) and
	(@Breed is NULL or h.Breed like @Breed) and
	(@Imported = 0 or h.Imported = 1) and
	(@RegPrefix is NULL or h.RegistrationNumber like @RegPrefix) and
	(@CatPrefix is NULL or h.[Catalog] like @CatPrefix) and
	(@Sex is NULL or LUGender.LookupAbrv like @Sex) and
	(@Color is NULL or LUColor.LookupAbrv like @Color)
--and h.HorseName like 'ABEER%'
ORDER BY h.HorseName
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Breeding_GetListForStallionReport]    Script Date: 10/25/2020 11:13:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_user_Breeding_GetListForStallionReport]
(
@LocalCodes varchar(50),
@BeginDate datetime,
@EndDate datetime,
@IncludeClosedBreedings bit
)
AS
 

SELECT b.BreedingID, m.HorseName MareName, m.RegistrationNumber MareRegistry, m.Owner MareOwner, s.HorseName StallionName, s.RegistrationNumber StallionRegistry, s.Owner StallionOwner,
            b.StatusDate,
            b.FoalingDate, b.Status, 
            c.BreedingCalendarID as EntryID, c.[Date] as EntryDate, c.Codes as EntryCodes
,b.UpdateUser, b.UpdateTimestamp
FROM user_Breeding b
JOIN user_Horse m ON b.HorseID = m.HorseID 
            and m.LocalID in (select LookupID from base_Lookup where LookupSetID = '{506C0E43-4548-46C6-9BB7-09643EE23188}' and CHARINDEX(LookupAbrv,@LocalCodes) > 0 )
JOIN user_Horse s ON b.StallionID = s.HorseID
JOIN user_BreedingCalendar c on c.BreedingID = b.BreedingID
WHERE b.StatusDate >= @BeginDate and b.StatusDate <= @EndDate
            and (c.Codes like '%I%' or c.Codes like '%B%' or c.Codes like '%A%') 
	and (@IncludeClosedBreedings = 1 or b.DateClosed is null)
ORDER BY StallionName, MareName, EntryDate, EntryCodes
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Breeding_GetListForFoalDueReport]    Script Date: 10/25/2020 11:13:24 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_Breeding_GetListForFoalDueReport]
(
@LocalCodes varchar(50),
@BeginDate datetime,
@EndDate datetime
)
AS

SELECT b.BreedingID, m.HorseName MareName, s.HorseName StallionName, 
            b.StatusDate,
            b.FoalingDate, b.Status, 
            c.BreedingCalendarID as EntryID, c.[Date] as EntryDate, c.Codes as EntryCodes
,b.UpdateUser, b.UpdateTimestamp
FROM user_Breeding b
JOIN user_Horse m ON b.HorseID = m.HorseID 
            and m.LocalID in (select LookupID from base_Lookup where LookupSetID = '{506C0E43-4548-46C6-9BB7-09643EE23188}' and CHARINDEX(LookupAbrv,@LocalCodes) > 0 )
JOIN user_Horse s ON b.StallionID = s.HorseID
JOIN user_BreedingCalendar c on c.BreedingID = b.BreedingID
WHERE b.FoalingDate >= @BeginDate and b.FoalingDate <= @EndDate
            and (c.Codes like '%I%' or c.Codes like '%B%' or c.Codes like '%A%') 
            and b.Status = 'D'
ORDER BY b.FoalingDate, MareName, StallionName, EntryDate, EntryCodes
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Horse_Breeding_Sale_GetByID]    Script Date: 10/25/2020 11:13:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_user_Horse_Breeding_Sale_GetByID]
(
@HorseID uniqueidentifier,
@SaleID uniqueidentifier
)
AS
 
SELECT s.*, h.horsename as StallionName FROM user_BreedingSale s 
INNER JOIN user_horse h on h.horseid = s.stallionid
WHERE s.HorseID = @HorseID AND s.BreedingSaleID = @SaleID

SELECT a.* FROM user_AmortizedCharge a 
INNER JOIN user_BreedingSale h on h.BreedingSaleID = a.ReferenceID 
WHERE h.HorseID = @HorseID AND h.BreedingSaleID = @SaleID 
ORDER BY ChargeDate
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Horse_GetCount]    Script Date: 10/25/2020 11:13:41 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_Horse_GetCount] AS

SELECT count(1) FROM dbo.user_Horse
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Client_GetTransactionSummary]    Script Date: 10/25/2020 11:13:30 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_Client_GetTransactionSummary]
(
@BeginDate datetime,
@EndDate datetime,
@LocalCodes varchar(50)
)
AS

select ClientMiscID as MiscID, c.ClientID, c.ClientCode, [Date] as MiscDate, Amount, Item
from user_ClientMisc
inner join user_Client c on c.ClientID = user_ClientMisc.ClientID
inner join base_LocalCodeAccountLookup lc on lc.Account = user_ClientMisc.Account
inner join base_Lookup l on l.LookupAbrv = lc.LocalCodeAbrv and l.LookupSetID = '{506C0E43-4548-46C6-9BB7-09643EE23188}' and CHARINDEX(LookupAbrv,@LocalCodes) > 0 
where @BeginDate <= [Date] and [Date] <= @EndDate
order by c.ClientCode, [Date]


select p.PaymentID, p.PaymentDate, p.Amount, p.PaymentMethod, p.PaymentOrCredit, p.Notes, c.ClientID, c.ClientCode
from user_ClientPayment p
inner join user_Client c on p.ClientID = c.ClientID
inner join base_LocalCodeAccountLookup lc on lc.Account = p.Account
inner join base_Lookup l on l.LookupAbrv = lc.LocalCodeAbrv and l.LookupSetID = '{506C0E43-4548-46C6-9BB7-09643EE23188}' and CHARINDEX(LookupAbrv,@LocalCodes) > 0 
where @BeginDate <= p.PaymentDate and p.PaymentDate <= @EndDate
order by c.ClientCode, p.PaymentDate


select BoardingID, user_MaintenanceBoarding.HorseID, h.HorseName, TimeUnit, Rate, BeginDate, EndDate, Account, Notes, user_MaintenanceBoarding.Comments
from user_MaintenanceBoarding
inner join user_Horse h on h.HorseID = user_MaintenanceBoarding.HorseID
where @BeginDate <= EndDate and BeginDate <= @EndDate
and user_MaintenanceBoarding.LocalID  in (select LookupID from base_Lookup where LookupSetID = '{506C0E43-4548-46C6-9BB7-09643EE23188}' and (CHARINDEX(LookupAbrv,@LocalCodes) > 0 or (CHARINDEX('8', @LocalCodes) > 0) and CHARINDEX(LookupAbrv,'S') > 0) )
order by h.HorseName, EndDate

select ShowID, ShowName, ShowDate, Points,
h.HorseID, h.HorseName, 
DayRate, DayRateCodes,
EntryFees, EntryFeesCodes,
Equipment, EquipmentCodes,
Grooming, GroomingCodes,
Handling, HandlingCodes,
Miscellaneous, MiscellaneousCodes,
ProRata, ProRataCodes,
Transport, TransportCodes
from user_Show
inner join user_Horse h on h.HorseID = user_Show.HorseID
where @BeginDate <= ShowDate and ShowDate <= @EndDate
and ( CHARINDEX('8',@LocalCodes) > 0 )
order by h.HorseName, ShowDate

-- Veterinary records
SELECT s.ServiceID, s.HorseID, h.HorseName, s.ServiceTypeID, lookup.LookupDescription AS ServiceTypeDescription, s.ContactID,
	contact.Name AS ContactName, s.ServiceDate, s.Cost, s.Notes, s.Account, s.Comments
FROM user_Service s
INNER JOIN base_Lookup lookup ON s.ServiceTypeID = lookup.LookupID
INNER JOIN user_Horse h on h.HorseID = s.HorseID
LEFT OUTER JOIN user_Contact contact ON s.ContactID = contact.ContactID
WHERE s.ServiceTypeID = 'D1635172-632F-4625-AD8D-E79281A78268'
and @BeginDate <= ServiceDate and ServiceDate <= @EndDate
and s.LocalID  in (select LookupID from base_Lookup where LookupSetID = '{506C0E43-4548-46C6-9BB7-09643EE23188}' and (CHARINDEX(LookupAbrv,@LocalCodes) > 0 or (CHARINDEX('8', @LocalCodes) > 0) and CHARINDEX(LookupAbrv,'S') > 0) )
ORDER BY h.HorseName, s.ServiceDate, s.Notes

-- Farrier records
SELECT s.ServiceID, s.HorseID, h.HorseName, s.ServiceTypeID, lookup.LookupDescription AS ServiceTypeDescription, s.ContactID,
	contact.Name AS ContactName, s.ServiceDate, s.Cost, s.Notes, s.Account, s.Comments
FROM user_Service s
INNER JOIN base_Lookup lookup ON s.ServiceTypeID = lookup.LookupID
INNER JOIN user_Horse h on h.HorseID = s.HorseID
LEFT OUTER JOIN user_Contact contact ON s.ContactID = contact.ContactID
WHERE s.ServiceTypeID = 'a67e4c2f-428d-4e2c-a840-a49f5a0aa982'
and @BeginDate <= ServiceDate and ServiceDate <= @EndDate
and s.LocalID  in (select LookupID from base_Lookup where LookupSetID = '{506C0E43-4548-46C6-9BB7-09643EE23188}' and (CHARINDEX(LookupAbrv,@LocalCodes) > 0 or (CHARINDEX('8', @LocalCodes) > 0) and CHARINDEX(LookupAbrv,'S') > 0) )
ORDER BY h.HorseName, s.ServiceDate, s.Notes

-- Horse Miscellaneous records
SELECT s.ServiceID, s.HorseID, h.HorseName, s.ServiceTypeID, lookup.LookupDescription AS ServiceTypeDescription, s.ContactID,
	contact.Name AS ContactName, s.ServiceDate, s.Cost, s.Notes, s.Account, s.Comments
FROM user_Service s
INNER JOIN base_Lookup lookup ON s.ServiceTypeID = lookup.LookupID
INNER JOIN user_Horse h on h.HorseID = s.HorseID
LEFT OUTER JOIN user_Contact contact ON s.ContactID = contact.ContactID
WHERE s.ServiceTypeID = 'e2461ba6-0fbb-4f8c-bf26-95ecb074cbbd'
and @BeginDate <= ServiceDate and ServiceDate <= @EndDate
and s.LocalID  in (select LookupID from base_Lookup where LookupSetID = '{506C0E43-4548-46C6-9BB7-09643EE23188}' and (CHARINDEX(LookupAbrv,@LocalCodes) > 0 or (CHARINDEX('8', @LocalCodes) > 0) and CHARINDEX(LookupAbrv,'S') > 0) )
ORDER BY h.HorseName, s.ServiceDate, s.Notes

SELECT a.AmortizedChargeID, s.HorseID, h.HorseName, a.ChargeDate, (a.Principal + a.Interest) as Amount, s.Notes
FROM user_AmortizedCharge a
INNER JOIN user_HorseSale s on a.ReferenceID = s.HorseSaleID
INNER JOIN user_Horse h on s.HorseID = h.HorseID
WHERE a.ChargeDate >= @BeginDate and a.ChargeDate <= @EndDate
and h.LocalID  in (select LookupID from base_Lookup where LookupSetID = '{506C0E43-4548-46C6-9BB7-09643EE23188}' and CHARINDEX(LookupAbrv,@LocalCodes) > 0 )
and 0 = 1
order by a.ChargeDate

SELECT a.AmortizedChargeID, s.HorseID, h.HorseName, a.ChargeDate, (a.Principal + a.Interest) as Amount, s.Notes
FROM user_AmortizedCharge a
INNER JOIN user_BreedingSale s on a.ReferenceID = s.BreedingSaleID
INNER JOIN user_Horse h on s.HorseID = h.HorseID
WHERE a.ChargeDate >= @BeginDate and a.ChargeDate <= @EndDate
and h.LocalID  in (select LookupID from base_Lookup where LookupSetID = '{506C0E43-4548-46C6-9BB7-09643EE23188}' and CHARINDEX(LookupAbrv,@LocalCodes) > 0 )
and 0 = 1
order by a.ChargeDate
GO
/****** Object:  StoredProcedure [dbo].[usp_user_BatchVetEntries]    Script Date: 10/25/2020 11:13:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_user_BatchVetEntries]
(
@LocalCodes varchar(50),
@Ages varchar(50),
@Genders varchar(50),
@ServiceDate datetime,
@Cost numeric(18,2),
@Notes nvarchar(50),
@Account nvarchar(8),
@Comments ntext,
@UpdateUser nvarchar(120),
@UpdateTimestamp datetime
)
AS

DECLARE @LocalID uniqueidentifier
DECLARE @FoalCode	varchar(1)
DECLARE @WeanlingCode	varchar(1)
DECLARE @YearlingCode	varchar(1)
DECLARE @TwoYearOldCode	varchar(1)
DECLARE @ThreeYearOldCode	varchar(1)
DECLARE @FourYearOldCode	varchar(1)
DECLARE @AdultCode	varchar(1)

IF CHARINDEX('F',@Ages) > 0
  set @FoalCode = 'F'
IF CHARINDEX('W',@Ages) > 0
  set @WeanlingCode = 'W'
IF CHARINDEX('Y',@Ages) > 0
  set @YearlingCode = 'Y'
IF CHARINDEX('2',@Ages) > 0
  set @TwoYearOldCode = '2'
IF CHARINDEX('3',@Ages) > 0
  set @ThreeYearOldCode = '3'
IF CHARINDEX('4',@Ages) > 0
  set @FourYearOldCode = '4'
IF CHARINDEX('A',@Ages) > 0
  set @AdultCode = 'A'


DECLARE @OffsetMonth	int
DECLARE @Weanling	int
DECLARE @Yearling	int
DECLARE @TwoYearOld	int
DECLARE @ThreeYearOld	int
DECLARE @FourYearOld	int
DECLARE @Adult		int

SELECT @OffsetMonth = OffsetMonth, @Weanling = Weanling, @Yearling = Yearling,
	@TwoYearOld = TwoYearOld, @ThreeYearOld = ThreeYearOld, @FourYearOld = FourYearOld,
	@Adult = Adult
FROM config_AgeCategories
WHERE ConfigID = '{91AF1A80-7994-431E-8D6C-9D9B7CDAE4C1}'

DECLARE @horseids table 
   (HorseID uniqueidentifier, DaysOld int, AgeCode varchar(1))

INSERT INTO @horseids (HorseID, DaysOld)
SELECT h.HorseID, dbo.udf_ComputeDaysOld(h.DateBorn, @OffsetMonth, GetDate()) 
FROM user_Horse h 
WHERE 
GenderID in (select LookupID from base_lookup where LookupSetID = '{454BA8D6-24D5-4723-8518-D63143194411}' and CHARINDEX(LookupAbrv,@Genders) > 0 ) and 
LocalID in (select LookupID from base_Lookup where LookupSetID = '{506C0E43-4548-46C6-9BB7-09643EE23188}' and CHARINDEX(LookupAbrv,@LocalCodes) > 0 )

--select * from @horseids

UPDATE @horseids
SET AgeCode = 
	CASE
		WHEN DaysOld >= @Adult THEN @AdultCode
		WHEN DaysOld >= @FourYearOld THEN @FourYearOldCode
		WHEN DaysOld >= @ThreeYearOld THEN @ThreeYearOldCode
		WHEN DaysOld >= @TwoYearOld THEN @TwoYearOldCode
		WHEN DaysOld >= @Yearling THEN @YearlingCode
		WHEN DaysOld >= @Weanling THEN @WeanlingCode
		ELSE @FoalCode
	END

--select * from @horseids

DECLARE @HorseID uniqueidentifier

DECLARE  horse_cursor CURSOR LOCAL FAST_FORWARD
FOR 
SELECT hi.HorseID
FROM @horseids hi WHERE (hi.AgeCode is not null)
FOR READ ONLY

OPEN horse_cursor

FETCH NEXT FROM horse_cursor 
INTO @HorseID

WHILE @@FETCH_STATUS = 0
BEGIN

	IF NOT EXISTS(SELECT 1 FROM user_Maintenance WHERE HorseID = @HorseID)
	BEGIN
		INSERT INTO user_Maintenance(HorseID) VALUES (@HorseID)
	END

	SELECT @LocalID = LocalID from user_Horse WHERE horseid = @HorseID

	INSERT INTO user_Service(ServiceID, HorseID, ServiceTypeID, ServiceDate, Cost, Notes, Account, UpdateUser, UpdateTimestamp, LocalID)
	VALUES(newid(), @HorseID, 'd1635172-632f-4625-ad8d-e79281a78268', @ServiceDate, @Cost, @Notes, @Account, @UpdateUser, @UpdateTimestamp, @LocalID)

	FETCH NEXT FROM horse_cursor 
	INTO @HorseID

END
CLOSE horse_cursor
DEALLOCATE horse_cursor
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Horse_GetSalesListForReport]    Script Date: 10/25/2020 11:13:45 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_user_Horse_GetSalesListForReport]
(
@LocalCodes varchar(50),
@Ages varchar(50),
@Genders varchar(50)
)
AS

DECLARE @FoalCode	varchar(1)
DECLARE @WeanlingCode	varchar(1)
DECLARE @YearlingCode	varchar(1)
DECLARE @TwoYearOldCode	varchar(1)
DECLARE @ThreeYearOldCode	varchar(1)
DECLARE @FourYearOldCode	varchar(1)
DECLARE @AdultCode	varchar(1)

IF CHARINDEX('F',@Ages) > 0
  set @FoalCode = 'F'
IF CHARINDEX('W',@Ages) > 0
  set @WeanlingCode = 'W'
IF CHARINDEX('Y',@Ages) > 0
  set @YearlingCode = 'Y'
IF CHARINDEX('2',@Ages) > 0
  set @TwoYearOldCode = '2'
IF CHARINDEX('3',@Ages) > 0
  set @ThreeYearOldCode = '3'
IF CHARINDEX('4',@Ages) > 0
  set @FourYearOldCode = '4'
IF CHARINDEX('A',@Ages) > 0
  set @AdultCode = 'A'


DECLARE @OffsetMonth	int
DECLARE @Weanling	int
DECLARE @Yearling	int
DECLARE @TwoYearOld	int
DECLARE @ThreeYearOld	int
DECLARE @FourYearOld	int
DECLARE @Adult		int

SELECT @OffsetMonth = OffsetMonth, @Weanling = Weanling, @Yearling = Yearling,
	@TwoYearOld = TwoYearOld, @ThreeYearOld = ThreeYearOld, @FourYearOld = FourYearOld,
	@Adult = Adult
FROM config_AgeCategories
WHERE ConfigID = '{91AF1A80-7994-431E-8D6C-9D9B7CDAE4C1}'

DECLARE @horseids table 
   (HorseID uniqueidentifier, DaysOld int, AgeCode varchar(1))

INSERT INTO @horseids (HorseID, DaysOld)
SELECT h.HorseID, dbo.udf_ComputeDaysOld(h.DateBorn, @OffsetMonth, GetDate()) 
FROM user_Horse h 
WHERE 
GenderID in (select LookupID from base_lookup where LookupSetID = '{454BA8D6-24D5-4723-8518-D63143194411}' and CHARINDEX(LookupAbrv,@Genders) > 0 ) and 
LocalID in (select LookupID from base_Lookup where LookupSetID = '{506C0E43-4548-46C6-9BB7-09643EE23188}' and CHARINDEX(LookupAbrv,@LocalCodes) > 0 )

--select * from @horseids

UPDATE @horseids
SET AgeCode = 
	CASE
		WHEN DaysOld >= @Adult THEN @AdultCode
		WHEN DaysOld >= @FourYearOld THEN @FourYearOldCode
		WHEN DaysOld >= @ThreeYearOld THEN @ThreeYearOldCode
		WHEN DaysOld >= @TwoYearOld THEN @TwoYearOldCode
		WHEN DaysOld >= @Yearling THEN @YearlingCode
		WHEN DaysOld >= @Weanling THEN @WeanlingCode
		ELSE @FoalCode
	END

--select * from @horseids


SELECT h.HorseID, h.HorseName, h.TrackingColorID, LUDescription.LookupDescription AS TrackingColorDescription, 
	LUDescription.LookupAbrv AS TrackingColorAbrv, h.RegistrationNumber, h.DateDeceased, h.DateBorn, h.GenderID,
	LUGender.LookupDescription AS GenderDescription, LUGender.LookupAbrv AS GenderAbrv, h.Data1, h.Data2, h.ColorID,
	LUColor.LookupDescription AS ColorDescription, LUColor.LookupAbrv AS ColorAbrv, h.Comment, h.Breeder, h.Owner, h.OwnerNumber, h.SireID, 
	h2.HorseName AS SireName, h2.RegistrationNumber AS SireRegistrationNumber, LUSireGender.LookupDescription AS SireGenderDescription,
	h.DamID, h3.HorseName AS DamName, h3.RegistrationNumber AS DamRegistrationNumber,
	LUDamGender.LookupDescription AS DamGenderDescription, h.BloodTyped, h.FreezeMarked, h.Imported, h.Title1, h.Title2, h.Breed, h.[Catalog],
	h.LastTransaction, h.LocalID, LULocal.LookupDescription AS LocalDescription, LULocal.LookupAbrv AS LocalAbrv, h.DateSold, h.Comments,
	his.SalesPrice, his.SalesNote1, his.SalesNote2
FROM dbo.user_Horse h
INNER JOIN dbo.base_Lookup LUDescription ON h.TrackingColorID = LUDescription.LookupID
INNER JOIN dbo.base_Lookup LUGender ON h.GenderID = LUGender.LookupID
INNER JOIN dbo.base_Lookup LUColor ON h.ColorID = LUColor.LookupID
LEFT OUTER JOIN dbo.user_Horse h2 ON h.SireID = h2.HorseID
LEFT OUTER JOIN dbo.user_Horse h3 ON h.DamID = h3.HorseID
LEFT OUTER JOIN dbo.base_Lookup LUSireGender ON h2.GenderID = LUSireGender.LookupID
LEFT OUTER JOIN dbo.base_Lookup LUDamGender ON h3.GenderID = LUDamGender.LookupID
INNER JOIN dbo.base_Lookup LULocal ON h.LocalID = LULocal.LookupID
INNER JOIN dbo.user_History his on his.HorseID = h.HorseID and his.SalesList = 1
INNER JOIN @horseids hi on hi.HorseID = h.HorseID and (hi.AgeCode is not null)
ORDER BY h.HorseName
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Horse_Breeding_Sales]    Script Date: 10/25/2020 11:13:39 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_Horse_Breeding_Sales]
(
@HorseID uniqueidentifier
)
AS

SELECT s.*, h.horsename as StallionName FROM user_BreedingSale s 
INNER JOIN user_horse h on h.horseid = s.stallionid
WHERE s.HorseID = @HorseID
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Horse_GetSoldListForReport]    Script Date: 10/25/2020 11:13:45 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_Horse_GetSoldListForReport]
(
@LocalCodes varchar(50),
@Ages varchar(50),
@Genders varchar(50),
@BeginDate datetime,
@EndDate datetime
)
AS

DECLARE @FoalCode	varchar(1)
DECLARE @WeanlingCode	varchar(1)
DECLARE @YearlingCode	varchar(1)
DECLARE @TwoYearOldCode	varchar(1)
DECLARE @ThreeYearOldCode	varchar(1)
DECLARE @FourYearOldCode	varchar(1)
DECLARE @AdultCode	varchar(1)

IF CHARINDEX('F',@Ages) > 0
  set @FoalCode = 'F'
IF CHARINDEX('W',@Ages) > 0
  set @WeanlingCode = 'W'
IF CHARINDEX('Y',@Ages) > 0
  set @YearlingCode = 'Y'
IF CHARINDEX('2',@Ages) > 0
  set @TwoYearOldCode = '2'
IF CHARINDEX('3',@Ages) > 0
  set @ThreeYearOldCode = '3'
IF CHARINDEX('4',@Ages) > 0
  set @FourYearOldCode = '4'
IF CHARINDEX('A',@Ages) > 0
  set @AdultCode = 'A'


DECLARE @OffsetMonth	int
DECLARE @Weanling	int
DECLARE @Yearling	int
DECLARE @TwoYearOld	int
DECLARE @ThreeYearOld	int
DECLARE @FourYearOld	int
DECLARE @Adult		int

SELECT @OffsetMonth = OffsetMonth, @Weanling = Weanling, @Yearling = Yearling,
	@TwoYearOld = TwoYearOld, @ThreeYearOld = ThreeYearOld, @FourYearOld = FourYearOld,
	@Adult = Adult
FROM config_AgeCategories
WHERE ConfigID = '{91AF1A80-7994-431E-8D6C-9D9B7CDAE4C1}'

DECLARE @horseids table 
   (HorseID uniqueidentifier, DaysOld int, AgeCode varchar(1))

INSERT INTO @horseids (HorseID, DaysOld)
SELECT h.HorseID, dbo.udf_ComputeDaysOld(h.DateBorn, @OffsetMonth, GetDate()) 
FROM user_Horse h 
WHERE 
GenderID in (select LookupID from base_lookup where LookupSetID = '{454BA8D6-24D5-4723-8518-D63143194411}' and CHARINDEX(LookupAbrv,@Genders) > 0 ) and 
LocalID in (select LookupID from base_Lookup where LookupSetID = '{506C0E43-4548-46C6-9BB7-09643EE23188}' and CHARINDEX(LookupAbrv,@LocalCodes) > 0 ) and
DateSold >= @BeginDate and DateSold <= @EndDate

--select * from @horseids

UPDATE @horseids
SET AgeCode = 
	CASE
		WHEN DaysOld >= @Adult THEN @AdultCode
		WHEN DaysOld >= @FourYearOld THEN @FourYearOldCode
		WHEN DaysOld >= @ThreeYearOld THEN @ThreeYearOldCode
		WHEN DaysOld >= @TwoYearOld THEN @TwoYearOldCode
		WHEN DaysOld >= @Yearling THEN @YearlingCode
		WHEN DaysOld >= @Weanling THEN @WeanlingCode
		ELSE @FoalCode
	END

--select * from @horseids


SELECT h.HorseID, h.HorseName, h.TrackingColorID, LUDescription.LookupDescription AS TrackingColorDescription, 
	LUDescription.LookupAbrv AS TrackingColorAbrv, h.RegistrationNumber, h.DateDeceased, h.DateBorn, h.GenderID,
	LUGender.LookupDescription AS GenderDescription, LUGender.LookupAbrv AS GenderAbrv, h.Data1, h.Data2, h.ColorID,
	LUColor.LookupDescription AS ColorDescription, LUColor.LookupAbrv AS ColorAbrv, h.Comment, h.Breeder, h.Owner, h.OwnerNumber, h.SireID, 
	h2.HorseName AS SireName, h2.RegistrationNumber AS SireRegistrationNumber, LUSireGender.LookupDescription AS SireGenderDescription,
	h.DamID, h3.HorseName AS DamName, h3.RegistrationNumber AS DamRegistrationNumber,
	LUDamGender.LookupDescription AS DamGenderDescription, h.BloodTyped, h.FreezeMarked, h.Imported, h.Title1, h.Title2, h.Breed, h.[Catalog],
	h.LastTransaction, h.LocalID, LULocal.LookupDescription AS LocalDescription, LULocal.LookupAbrv AS LocalAbrv, h.DateSold, h.Comments,
	his.SalesPrice, his.SellingPrice, his.SalesNote1, his.SalesNote2
FROM dbo.user_Horse h
INNER JOIN dbo.base_Lookup LUDescription ON h.TrackingColorID = LUDescription.LookupID
INNER JOIN dbo.base_Lookup LUGender ON h.GenderID = LUGender.LookupID
INNER JOIN dbo.base_Lookup LUColor ON h.ColorID = LUColor.LookupID
LEFT OUTER JOIN dbo.user_Horse h2 ON h.SireID = h2.HorseID
LEFT OUTER JOIN dbo.user_Horse h3 ON h.DamID = h3.HorseID
LEFT OUTER JOIN dbo.base_Lookup LUSireGender ON h2.GenderID = LUSireGender.LookupID
LEFT OUTER JOIN dbo.base_Lookup LUDamGender ON h3.GenderID = LUDamGender.LookupID
INNER JOIN dbo.base_Lookup LULocal ON h.LocalID = LULocal.LookupID
INNER JOIN dbo.user_History his on his.HorseID = h.HorseID
INNER JOIN @horseids hi on hi.HorseID = h.HorseID and (hi.AgeCode is not null)
ORDER BY h.HorseName
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Client_GetHorseOwnershipList]    Script Date: 10/25/2020 11:13:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_user_Client_GetHorseOwnershipList] 
(
@ClientID uniqueidentifier
)
AS

SELECT
	l.*,
	c.Name, c.FirstName, c.Company, c.Address1, c.Address2, c.City, c.StateID, LUState.LookupAbrv AS StateAbrv,
	LUState.LookupDescription AS StateDescription, c.Zip, c.CountryID, LUCountry.LookupAbrv AS CountryAbrv,
	LUCountry.LookupDescription AS CountryDescription, c.Phone1, c.Phone2, c.Fax, c.HorseNotes
FROM
	user_Client l
LEFT OUTER JOIN 
	user_Contact c ON l.ContactID = c.ContactID
LEFT OUTER JOIN 
	base_Lookup LUState ON c.StateID = LUState.LookupID
LEFT OUTER JOIN 
	base_Lookup LUCountry ON c.CountryID = LUCountry.LookupID
WHERE (@ClientID is NULL or l.ClientID = @ClientID)
ORDER BY l.ClientCode


SELECT h.HorseID, h.HorseName, h.TrackingColorID, LUDescription.LookupDescription AS TrackingColorDescription, 
	LUDescription.LookupAbrv AS TrackingColorAbrv, h.RegistrationNumber, h.DateDeceased, h.DateBorn, h.GenderID,
	LUGender.LookupDescription AS GenderDescription, LUGender.LookupAbrv AS GenderAbrv, h.Data1, h.Data2, h.ColorID,
	LUColor.LookupDescription AS ColorDescription, LUColor.LookupAbrv AS ColorAbrv, h.Comment, h.Breeder, h.Owner, h.OwnerNumber, h.SireID, 
	h2.HorseName AS SireName, h2.RegistrationNumber AS SireRegistrationNumber, LUSireGender.LookupDescription AS SireGenderDescription,
	h.DamID, h3.HorseName AS DamName, h3.RegistrationNumber AS DamRegistrationNumber,
	LUDamGender.LookupDescription AS DamGenderDescription, h.BloodTyped, h.FreezeMarked, h.Imported, h.Title1, h.Title2, h.Breed, h.[Catalog],
	h.LastTransaction, h.LocalID, LULocal.LookupDescription AS LocalDescription, LULocal.LookupAbrv AS LocalAbrv, h.DateSold, h.Comments,
	o.ClientID
FROM dbo.user_Horse h
INNER JOIN dbo.base_Lookup LUDescription ON h.TrackingColorID = LUDescription.LookupID
INNER JOIN dbo.base_Lookup LUGender ON h.GenderID = LUGender.LookupID
INNER JOIN dbo.base_Lookup LUColor ON h.ColorID = LUColor.LookupID
LEFT OUTER JOIN dbo.user_Horse h2 ON h.SireID = h2.HorseID
LEFT OUTER JOIN dbo.user_Horse h3 ON h.DamID = h3.HorseID
LEFT OUTER JOIN dbo.base_Lookup LUSireGender ON h2.GenderID = LUSireGender.LookupID
LEFT OUTER JOIN dbo.base_Lookup LUDamGender ON h3.GenderID = LUDamGender.LookupID
INNER JOIN dbo.base_Lookup LULocal ON h.LocalID = LULocal.LookupID
INNER JOIN dbo.user_Ownership o ON o.HorseID = h.HorseID
WHERE (@ClientID is NULL or o.ClientID = @ClientID)
ORDER BY h.HorseName


SELECT o.OwnershipID AS OwnershipID, o.HorseID AS HorseID, o.ClientID AS ClientID, o.Percentage AS Percentage,  
       o.LastStatementDate AS LastStatementDate, o.Comments AS Comments, c.ClientCode AS ClientCode, c.ContactID AS ContactID 
FROM   user_Ownership o 
INNER JOIN user_Client c ON o.ClientID = c.ClientID
WHERE (@ClientID is NULL or o.ClientID = @ClientID)
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Client_GetListAndCharges]    Script Date: 10/25/2020 11:13:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_user_Client_GetListAndCharges]
(
@ClientID uniqueidentifier,
@EndDate datetime,
@StartDate datetime
)
AS

--
-- CLIENTS
--
SELECT
	l.*,
	c.Name, c.FirstName, c.Company, c.Address1, c.Address2, c.City, c.StateID, LUState.LookupAbrv AS StateAbrv,
	LUState.LookupDescription AS StateDescription, c.Zip, c.CountryID, LUCountry.LookupAbrv AS CountryAbrv,
	LUCountry.LookupDescription AS CountryDescription, c.Phone1, c.Phone2, c.Fax, c.HorseNotes
FROM
	user_Client l
LEFT OUTER JOIN 
	user_Contact c ON l.ContactID = c.ContactID
LEFT OUTER JOIN 
	base_Lookup LUState ON c.StateID = LUState.LookupID
LEFT OUTER JOIN 
	base_Lookup LUCountry ON c.CountryID = LUCountry.LookupID
WHERE
	(@ClientID is null or l.ClientID = @ClientID)
ORDER BY l.ClientCode




--
-- HORSES - list of horses involved in current charges for selected clients
--

SELECT DISTINCT base.ClientID, base.Percentage, h.HorseID, h.horsename, h.RegistrationNumber, h.DateBorn, LULocal.LookupAbrv AS LocalAbrv,
	LUGender.LookupDescription AS GenderDescription, LUGender.LookupAbrv AS GenderAbrv,
	LUDescription.LookupAbrv AS TrackingColorAbrv,
	(SELECT COUNT(1) FROM user_Horse WHERE SireID = h.HorseID OR DamID = h.HorseID) as ProgenyCount
FROM
(
--
--BREEDING
--
select c.ClientID as ClientID, o.HorseID, o.percentage as Percentage, f.Cost as Amount from user_breedingfee f
inner join user_breeding b on b.breedingid = f.breedingid
inner join user_ownership o on o.horseid = b.horseid
inner join user_client c on c.clientid = o.clientid
where f.DueDate <= @EndDate and f.DueDate > @StartDate and (@ClientID is null or c.ClientID = @ClientID)

union

--
--BOARDING
--
SELECT c.ClientID, o.HorseID, o.percentage, 
CASE WHEN base.TimeUnit = 'D' THEN
	CAST((base.RelativeEndDate - base.RelativeBeginDate)+1 as INT)*base.Rate
     WHEN base.TimeUnit = 'M' THEN
	CASE WHEN Month(base.RelativeEndDate) <> Month(base.RelativeBeginDate) THEN
	   base.Rate
	ELSE
	   CAST((base.RelativeEndDate - base.RelativeBeginDate)+1 as INT)*base.Rate/30
	END
END AS Amount
FROM
(SELECT b.HorseID, b.TimeUnit, b.Rate,
   CASE WHEN b.enddate <= @EndDate THEN b.enddate ELSE @EndDate END as RelativeEndDate,
   CASE WHEN b.begindate > @StartDate THEN b.begindate ELSE @StartDate END as RelativeBeginDate,
   b.begindate,
   b.enddate
FROM user_maintenanceboarding b
WHERE b.begindate <= @EndDate and b.endDate > @StartDate) base
INNER JOIN user_ownership o ON o.horseid = base.horseid
INNER JOIN user_client c on c.clientid = o.clientid
WHERE (@ClientID is null or c.ClientID = @ClientID)

union

--
--SERVICES
--
SELECT c.ClientID, o.HorseID, o.percentage, s.Cost as Amount
FROM user_service s
INNER JOIN base_Lookup l on l.LookupID = s.ServiceTypeID
INNER JOIN user_ownership o on o.horseid = s.horseid
INNER JOIN user_client c on c.clientid = o.clientid
WHERE s.ServiceDate <= @EndDate and s.ServiceDate > @StartDate and not s.Cost is NULL and (@ClientID is null or c.ClientID = @ClientID)

union

--
--SHOW
--
SELECT c.ClientID, o.HorseID, o.percentage, isnull(DayRate,0)+isnull(Transport,0)+isnull(Equipment,0)+isnull(Handling,0)+isnull(ProRata,0)+isnull(Grooming,0)+isnull(EntryFees,0)+isnull(Miscellaneous,0) as Amount FROM user_show s
INNER JOIN user_ownership o on o.horseid = s.horseid
INNER JOIN user_client c on c.clientid = o.clientid
WHERE s.ShowDate <= @EndDate and s.ShowDate > @StartDate and (@ClientID is null or c.ClientID = @ClientID)

union

--
--BREEDING SALE
--
SELECT c.ClientID, o.HorseID, o.percentage, (a.Principal + a.Interest) as Amount
FROM user_AmortizedCharge a
INNER JOIN user_breedingSale b on a.ReferenceID = b.breedingsaleid
INNER JOIN user_ownership o ON o.horseid = b.horseid
INNER JOIN user_client c on c.clientid = o.clientid
WHERE (@ClientID is null or c.ClientID = @ClientID) and (a.ChargeDate > @StartDate and a.ChargeDate <= @EndDate)

union

--
--HORSE SALE
--
SELECT c.ClientID, o.HorseID, o.percentage, (a.Principal + a.Interest) as Amount
FROM user_AmortizedCharge a
INNER JOIN user_horseSale h on a.ReferenceID = h.horsesaleid
INNER JOIN user_ownership o ON o.horseid = h.horseid
INNER JOIN user_client c on c.clientid = o.clientid
WHERE (@ClientID is null or c.ClientID = @ClientID) and (a.ChargeDate > @StartDate and a.ChargeDate <= @EndDate)


) base
INNER JOIN user_horse h on h.horseID = base.HorseID
INNER JOIN dbo.base_Lookup LULocal ON h.LocalID = LULocal.LookupID
INNER JOIN dbo.base_Lookup LUGender ON h.GenderID = LUGender.LookupID
INNER JOIN dbo.base_Lookup LUDescription ON h.TrackingColorID = LUDescription.LookupID
GROUP BY base.ClientID, base.Percentage, h.HorseID, h.horseName, h.RegistrationNumber, h.DateBorn, LULocal.LookupAbrv,
	LUGender.LookupDescription, LUGender.LookupAbrv,
	LUDescription.LookupAbrv


--
-- PAYMENTS
--

select c.ClientID, c.ClientCode, p.PaymentID, p.PaymentMethod, p.PaymentOrCredit, p.PaymentDate, p.Notes, p.Amount, p.Notes, p.Account from user_clientpayment p
inner join user_client c on c.clientid = p.clientid
where not p.amount is null and p.PaymentDate <= @EndDate and p.PaymentDate > @StartDate and (@ClientID is null or c.ClientID = @ClientID)
ORDER BY p.PaymentDate

--
-- CHARGES
--

SELECT base.ClientID, base.HorseID, 'BredSale' as Account, 'Breeding' as ServiceType, SUM( CAST((base.Amount * base.Percentage + 0.5) as INT) ) / 100.0 AS Charges
FROM
(
--
--BREEDING
--
select c.ClientID as ClientID, o.HorseID, o.percentage as Percentage, f.Cost as Amount, f.DueDate as [Date] from user_breedingfee f
inner join user_breeding b on b.breedingid = f.breedingid
inner join user_ownership o on o.horseid = b.horseid
inner join user_client c on c.clientid = o.clientid
where f.DueDate <= @EndDate and f.DueDate > @StartDate and (@ClientID is null or c.ClientID = @ClientID)

) base
GROUP BY base.ClientID, base.HorseID

union

SELECT base.ClientID, base.HorseID, '' as Account, 'Boarding' as ServiceType, SUM( CAST((base.Amount * base.Percentage + 0.5) as INT) ) / 100.0 AS Charges
FROM
(
--
--BOARDING
--
SELECT c.ClientID, o.HorseID, o.percentage, 
	CASE WHEN base.TimeUnit = 'D' THEN
		CAST((base.RelativeEndDate - base.RelativeBeginDate)+1 as INT)*base.Rate
	     WHEN base.TimeUnit = 'M' THEN
				base.Rate * Months + CAST(((base.Rate * DaysBefore * 100 / DaysInMonthBefore) +
						(base.Rate * DaysAfter * 100 / DaysInMonthAfter) +
						(base.Rate * DaysDuring * 100 / DaysInMonth) +
						0.5) as INT) / 100.0
				END AS Amount, 
	base.RelativeEndDate as [Date]
FROM
(SELECT b3.HorseID, b3.TimeUnit, b3.Rate,
	CASE WHEN DateDiff(m, b3.BeginFirstFullMonth, b3.DayAfterLastFullMonth) > 0 THEN DateDiff(m, b3.BeginFirstFullMonth, b3.DayAfterLastFullMonth) ELSE 0 END as Months,
	CASE WHEN DateDiff(m, b3.BeginFirstFullMonth, b3.DayAfterLastFullMonth) > 0 THEN DateDiff(d, b3.RelativeBeginDate, b3.BeginFirstFullMonth) ELSE 0 END as DaysBefore,
	CASE WHEN DateDiff(m, b3.BeginFirstFullMonth, b3.DayAfterLastFullMonth) > 0 THEN DateDiff(d, b3.DayAfterLastFullMonth, b3.RelativeEndDate)+1 ELSE 0 END as DaysAfter,
	CASE WHEN DateDiff(m, b3.BeginFirstFullMonth, b3.DayAfterLastFullMonth) <= 0 THEN DateDiff(d, b3.RelativeBeginDate, b3.RelativeEndDate)+1 ELSE 0 END as DaysDuring,
	day(DateAdd(d, -1, b3.BeginFirstFullMonth)) as DaysInMonthBefore,
	day(DateAdd(d, -1, DateAdd(m, 1, b3.DayAfterLastFullMonth))) as DaysInMonthAfter,
	CASE WHEN DateDiff(m, b3.BeginFirstFullMonth, b3.DayAfterLastFullMonth) > 0 THEN day(DateAdd(d, -1, b3.DayAfterLastFullMonth)) WHEN b3.BeginFirstFullMonth > b3.RelativeEndDate THEN day(DateAdd(d, -1, b3.BeginFirstFullMonth)) ELSE day(DateAdd(d, -1, DateAdd(m, 1, b3.DayAfterLastFullMonth))) END as DaysInMonth,
	b3.RelativeBeginDate, 
	b3.RelativeEndDate
FROM
(SELECT b2.HorseID, b2.TimeUnit, b2.Rate,
	b2.RelativeBeginDate, 
	b2.RelativeEndDate, 
	CASE WHEN day(b2.RelativeBeginDate) = 1 THEN
		cast(cast(month(b2.RelativeBeginDate) as varchar(2)) + '/01/' + cast(year(b2.RelativeBeginDate) as varchar(4)) + ' 0:00:000' as datetime)
	     ELSE
		cast(cast(month(DateAdd(m,1,b2.RelativeBeginDate)) as varchar(2)) + '/01/' + cast(year(DateAdd(m,1,b2.RelativeBeginDate)) as varchar(4)) + ' 0:00:000' as datetime)
	END as BeginFirstFullMonth, 
	CASE WHEN month(b2.RelativeEndDate) = month(DateAdd(d,1,b2.RelativeEndDate)) THEN
		cast(cast(month(b2.RelativeEndDate) as varchar(2)) + '/01/' + cast(year(b2.RelativeEndDate) as varchar(4)) + ' 0:00:00' as datetime)
	ELSE
		cast(cast(month(DateAdd(d,1,b2.RelativeEndDate)) as varchar(2)) + '/01/' + cast(year(DateAdd(d,1,b2.RelativeEndDate)) as varchar(4)) + ' 0:00:000' as datetime)
	END as DayAfterLastFullMonth
FROM
(SELECT b.HorseID, b.TimeUnit, b.Rate,
   CASE WHEN b.enddate <= @EndDate THEN b.enddate ELSE @EndDate END as RelativeEndDate,
   CASE WHEN b.begindate >= @StartDate THEN b.begindate ELSE @StartDate END as RelativeBeginDate,
   b.begindate,
   b.enddate
FROM user_maintenanceboarding b
WHERE b.begindate <= @EndDate and b.endDate >= @StartDate) b2) b3) base
INNER JOIN user_ownership o ON o.horseid = base.horseid
INNER JOIN user_client c on c.clientid = o.clientid
WHERE (@ClientID is null or c.ClientID = @ClientID)
) base
GROUP BY base.ClientID, base.HorseID

union

SELECT base.ClientID, base.HorseID, '' as Account, base.ServiceType, SUM( CAST((base.Amount * base.Percentage + 0.5) as INT) ) / 100.0 AS Charges
FROM
(
--
--SERVICES
--
SELECT c.ClientID, o.HorseID, o.percentage, l.LookupDescription as ServiceType, s.Cost as Amount, s.ServiceDate as [Date] 
FROM user_service s
INNER JOIN base_Lookup l on l.LookupID = s.ServiceTypeID
INNER JOIN user_ownership o on o.horseid = s.horseid
INNER JOIN user_client c on c.clientid = o.clientid
WHERE s.ServiceDate <= @EndDate and s.ServiceDate > @StartDate and not s.Cost is NULL and (@ClientID is null or c.ClientID = @ClientID)

) base
GROUP BY base.ClientID, base.HorseID, base.ServiceType

union

SELECT base.ClientID, base.HorseID, '' as Account, 'Show' as ServiceType, SUM( CAST((base.Amount * base.Percentage + 0.5) as INT) ) / 100.0 AS Charges
FROM
(
--
--SHOW
--
SELECT c.ClientID, o.HorseID, o.percentage, isnull(DayRate,0)+isnull(Transport,0)+isnull(Equipment,0)+isnull(Handling,0)+isnull(ProRata,0)+isnull(Grooming,0)+isnull(EntryFees,0)+isnull(Miscellaneous,0) as Amount, s.ShowDate as [Date] FROM user_show s
INNER JOIN user_ownership o on o.horseid = s.horseid
INNER JOIN user_client c on c.clientid = o.clientid
WHERE s.ShowDate <= @EndDate and s.ShowDate > @StartDate and (@ClientID is null or c.ClientID = @ClientID)

) base
GROUP BY base.ClientID, base.HorseID

union

SELECT base.ClientID, base.HorseID, 'BredSale' as Account, 'BreedSale' as ServiceType, SUM( CAST((base.Amount * base.Percentage + 0.5) as INT) ) / 100.0 AS Charges
FROM
(
--
--BREEDING SALE
--
SELECT c.ClientID, o.HorseID, o.percentage,
	(a.Principal + a.Interest) as Amount,
	a.chargedate as [Date]
FROM user_AmortizedCharge a
INNER JOIN user_breedingSale b on a.ReferenceID = b.breedingsaleid
INNER JOIN user_ownership o ON o.horseid = b.horseid
INNER JOIN user_client c on c.clientid = o.clientid
WHERE (@ClientID is null or c.ClientID = @ClientID) and (a.ChargeDate > @StartDate and a.ChargeDate <= @EndDate)
) base
GROUP BY base.ClientID, base.HorseID

union

SELECT base.ClientID, base.HorseID, 'HorsSale' as Account, 'HorseSale' as ServiceType, SUM( CAST((base.Amount * base.Percentage + 0.5) as INT) ) / 100.0 AS Charges
FROM
(
--
--HORSE SALE
--
SELECT c.ClientID, o.HorseID, o.percentage,
	(a.Principal + a.Interest) as Amount,
	a.chargedate as [Date]
FROM user_AmortizedCharge a
INNER JOIN user_horseSale h on a.ReferenceID = h.horsesaleid
INNER JOIN user_ownership o ON o.horseid = h.horseid
INNER JOIN user_client c on c.clientid = o.clientid
WHERE (@ClientID is null or c.ClientID = @ClientID) and (a.ChargeDate > @StartDate and a.ChargeDate <= @EndDate)
) base
GROUP BY base.ClientID, base.HorseID



--
--MISC
--
select c.ClientID, c.ClientCode, m.ClientMiscID as MiscID, m.Amount, m.Date as MiscDate, m.Item, m.Account from user_clientmisc m
inner join user_client c on c.clientid = m.clientid
where m.Date <= @EndDate and m.Date > @StartDate and not m.Amount is null and (@ClientID is null or c.ClientID = @ClientID)
ORDER BY m.Date
GO
/****** Object:  View [dbo].[vw_user_Service_plus]    Script Date: 10/25/2020 11:14:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_user_Service_plus]
AS
SELECT     TOP 100 PERCENT s.ServiceID, s.HorseID, horse.HorseName, s.ServiceTypeID, lookup.LookupDescription AS ServiceDescription, s.ContactID, 
                      contact.Name, s.ServiceDate, s.Cost, s.Notes, s.Account, s.Comments
FROM         dbo.user_Service s INNER JOIN
                      dbo.user_Horse horse ON s.HorseID = horse.HorseID INNER JOIN
                      dbo.base_Lookup lookup ON s.ServiceTypeID = lookup.LookupID LEFT OUTER JOIN
                      dbo.user_Contact contact ON s.ContactID = contact.ContactID
ORDER BY lookup.LookupDescription, horse.HorseName, s.ServiceDate
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Client_GetTransactionSummary_Sales]    Script Date: 10/25/2020 11:13:30 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_Client_GetTransactionSummary_Sales]
(
@BeginDate datetime,
@EndDate datetime,
@SalesAccount varchar(50)
)
AS

select ClientMiscID as MiscID, c.ClientID, c.ClientCode, [Date] as MiscDate, Amount, Item
from user_ClientMisc
inner join user_Client c on c.ClientID = user_ClientMisc.ClientID
where @BeginDate <= [Date] and [Date] <= @EndDate and user_ClientMisc.Account = @SalesAccount
order by c.ClientCode, [Date]


select p.PaymentID, p.PaymentDate, p.Amount, p.PaymentMethod, p.PaymentOrCredit, p.Notes, c.ClientID, c.ClientCode
from user_ClientPayment p
inner join user_Client c on p.ClientID = c.ClientID
where @BeginDate <= p.PaymentDate and p.PaymentDate <= @EndDate and p.Account = @SalesAccount
order by c.ClientCode, p.PaymentDate


select BoardingID, user_MaintenanceBoarding.HorseID, h.HorseName, TimeUnit, Rate, BeginDate, EndDate, Account, Notes, user_MaintenanceBoarding.Comments
from user_MaintenanceBoarding
inner join user_Horse h on h.HorseID = user_MaintenanceBoarding.HorseID
where 0 = 1
order by h.HorseName, EndDate

select ShowID, ShowName, ShowDate, Points,
h.HorseID, h.HorseName, 
DayRate, DayRateCodes,
EntryFees, EntryFeesCodes,
Equipment, EquipmentCodes,
Grooming, GroomingCodes,
Handling, HandlingCodes,
Miscellaneous, MiscellaneousCodes,
ProRata, ProRataCodes,
Transport, TransportCodes
from user_Show
inner join user_Horse h on h.HorseID = user_Show.HorseID
where 0 = 1
order by h.HorseName, ShowDate

-- Veterinary records
SELECT s.ServiceID, s.HorseID, h.HorseName, s.ServiceTypeID, lookup.LookupDescription AS ServiceTypeDescription, s.ContactID,
	contact.Name AS ContactName, s.ServiceDate, s.Cost, s.Notes, s.Account, s.Comments
FROM user_Service s
INNER JOIN base_Lookup lookup ON s.ServiceTypeID = lookup.LookupID
INNER JOIN user_Horse h on h.HorseID = s.HorseID
LEFT OUTER JOIN user_Contact contact ON s.ContactID = contact.ContactID
WHERE 0 = 1
ORDER BY h.HorseName, s.ServiceDate, s.Notes

-- Farrier records
SELECT s.ServiceID, s.HorseID, h.HorseName, s.ServiceTypeID, lookup.LookupDescription AS ServiceTypeDescription, s.ContactID,
	contact.Name AS ContactName, s.ServiceDate, s.Cost, s.Notes, s.Account, s.Comments
FROM user_Service s
INNER JOIN base_Lookup lookup ON s.ServiceTypeID = lookup.LookupID
INNER JOIN user_Horse h on h.HorseID = s.HorseID
LEFT OUTER JOIN user_Contact contact ON s.ContactID = contact.ContactID
WHERE 0 = 1
ORDER BY h.HorseName, s.ServiceDate, s.Notes

-- Horse Miscellaneous records
SELECT s.ServiceID, s.HorseID, h.HorseName, s.ServiceTypeID, lookup.LookupDescription AS ServiceTypeDescription, s.ContactID,
	contact.Name AS ContactName, s.ServiceDate, s.Cost, s.Notes, s.Account, s.Comments
FROM user_Service s
INNER JOIN base_Lookup lookup ON s.ServiceTypeID = lookup.LookupID
INNER JOIN user_Horse h on h.HorseID = s.HorseID
LEFT OUTER JOIN user_Contact contact ON s.ContactID = contact.ContactID
WHERE 0 = 1
ORDER BY h.HorseName, s.ServiceDate, s.Notes

SELECT a.AmortizedChargeID, s.HorseID, h.HorseName, a.ChargeDate, (a.Principal + a.Interest) as Amount, s.Notes
FROM user_AmortizedCharge a
INNER JOIN user_HorseSale s on a.ReferenceID = s.HorseSaleID
INNER JOIN user_Horse h on s.HorseID = h.HorseID
WHERE 0 = 1
order by a.ChargeDate

SELECT a.AmortizedChargeID, s.HorseID, h.HorseName, a.ChargeDate, (a.Principal + a.Interest) as Amount, s.Notes
FROM user_AmortizedCharge a
INNER JOIN user_BreedingSale s on a.ReferenceID = s.BreedingSaleID
INNER JOIN user_Horse h on s.HorseID = h.HorseID
WHERE 0 = 1
order by a.ChargeDate
GO
/****** Object:  View [dbo].[vw_user_History_plus]    Script Date: 10/25/2020 11:14:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_user_History_plus]
AS
SELECT     TOP 100 PERCENT h.HorseID, horse.HorseName, LUAgeCategory.LookupDescription AS AgeCategoryDescription, 
                      LUAgeCategory.LookupAbrv AS AgeCategoryAbrv, h.SalesList, h.Price, h.DateAcquired, h.Cost, h.SellingPrice, h.ContactID, h.Note1, h.Note2, 
                      h.SpecialReportCodes, h.Comments
FROM         dbo.user_History h INNER JOIN
                      dbo.user_Horse horse ON h.HorseID = horse.HorseID INNER JOIN
                      dbo.base_Lookup LUAgeCategory ON h.AgeCategoryID = LUAgeCategory.LookupID
ORDER BY horse.HorseName
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Breeding_GetByBreedingID]    Script Date: 10/25/2020 11:13:24 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_Breeding_GetByBreedingID]
(
	@BreedingID uniqueidentifier,
	@SortBy varchar(50) = NULL,
	@SortDirection varchar(3) = NULL
)
AS
BEGIN

	--get the breeding info
	SELECT 
		b.BreedingID, 
		b.HorseID, 
		mare.HorseName AS MareName, 
		b.StallionID,
		stallion.HorseName AS StallionName, 
		b.DateOpened, 
		b.DateClosed, 
		b.Fee,
		b.Gestation, 
		b.FoalingDate, 
		b.BreedingLocation, 
		b.Status, 
		b.StatusDate, 
		b.Comments,
		b.ReservationDate
		,b.UpdateUser, b.UpdateTimestamp
	FROM 
		user_Breeding b
			INNER JOIN user_Horse mare ON 
				b.HorseID = mare.HorseID
			INNER JOIN user_Horse stallion ON 
				b.StallionID = stallion.HorseID
	WHERE 
		b.BreedingID = @BreedingID

	--get the calendar entries for the breeding
	SELECT
		BreedingCalendarID AS "EntryID", 
		BreedingID, 
		Date AS "EntryDate", 
		Codes AS "EntryCodes", 
		Note1 AS "EntryNote1", 
		Note2 AS "EntryNote2", 
		Note3 AS "EntryNote3", 
		Note4 AS "EntryNote4", 
		Note5 AS "EntryNote5", 
		Comments AS "EntryComments",
		UpdateUser, UpdateTimestamp
	FROM
		user_BreedingCalendar
	WHERE
		BreedingID = @BreedingID
	ORDER BY
		CASE @SortBy + @SortDirection
			WHEN 'EntryDateASC' THEN [Date]
		END ASC,
		CASE @SortBy + @SortDirection
			WHEN 'EntryDateDESC' THEN [Date]
		END DESC,
		[Date] DESC

END
GO
/****** Object:  View [dbo].[vw_user_Maintenance_plus]    Script Date: 10/25/2020 11:14:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_user_Maintenance_plus]
AS
SELECT     TOP 100 PERCENT m.HorseID, horse.HorseName, m.Location, m.Insurance, m.InsurancePhone, m.Handler, m.Trainer, m.NextVet, m.NextFarrier, 
                      m.Note1, m.Note2, m.BandNumber, m.Comments
FROM         dbo.user_Maintenance m INNER JOIN
                      dbo.user_Horse horse ON m.HorseID = horse.HorseID
ORDER BY horse.HorseName
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Horse_GetBreedablStallions]    Script Date: 10/25/2020 11:13:40 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_Horse_GetBreedablStallions]
AS
BEGIN

	SELECT
		h.horseid,
		h.HorseName,
		g.LookupDescription AS Gender,
		l.LookupDescription AS Location
		,h.UpdateUser, h.UpdateTimestamp
	FROM
		user_Horse h 
			INNER JOIN base_Lookup g ON 
				h.GenderID = g.LookupID 
			INNER JOIN base_Lookup l ON 
				h.LocalID = l.LookupID
	WHERE
		(g.LookupDescription = 'Stallion') 
		AND (l.LookupAbrv <> '0') 
		AND (l.LookupAbrv <> '6') 
		AND (l.LookupAbrv <> '9')
	ORDER BY
		h.HorseName

END
GO
/****** Object:  StoredProcedure [dbo].[usp_user_horse_sale_insert]    Script Date: 10/25/2020 11:13:48 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_user_horse_sale_insert]
(
@RecordID uniqueidentifier,
@HorseID uniqueidentifier,
@ClientID uniqueidentifier,
@SaleDate datetime,
@Amount numeric(18,2),
@DownPayment numeric(18,2),
@Interest numeric(18,2),
@Notes nvarchar(50),
@Comments ntext,
@UpdateUser nvarchar(120),
@UpdateTimestamp datetime,
@NewUpdateUser nvarchar(120)
)
AS

BEGIN TRANSACTION

INSERT INTO user_HorseSale (HorseSaleID, HorseID, SaleDate, Amount, DownPayment, Interest, Notes, Comments, UpdateUser, UpdateTimestamp)
VALUES (@RecordID, @HorseID, @SaleDate, @Amount, @DownPayment, @Interest, @Notes, @Comments, @UpdateUser, @UpdateTimestamp)

UPDATE user_history 
SET SalesList = 0, SellingPrice = @Amount
WHERE HorseID = @HorseID

UPDATE user_horse
SET DateSold = @SaleDate
WHERE HorseID = @HorseID

DELETE FROM user_Ownership WHERE HorseID = @HorseID

INSERT INTO user_Ownership (ClientID, HorseID, Percentage, UpdateUser, UpdateTimestamp)
VALUES (@ClientID, @HorseID, 100.0, @UpdateUser, @UpdateTimestamp)

COMMIT
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Horse_Get_Pedigree_5gen]    Script Date: 10/25/2020 11:13:39 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_Horse_Get_Pedigree_5gen]
	@HorseID			uniqueidentifier

AS

SELECT @HorseID AS HorseID, g1.SireID AS S1, g1.DamID D1,

	g2a.SireID AS S2, g2a.DamID AS D2, g2b.SireID AS S3, g2b.DamID AS D3,

	g3a.SireID AS S4, g3a.DamID AS D4, g3b.SireID AS S5, g3b.DamID AS D5,
	g3c.SireID AS S6, g3c.DamID AS D6, g3d.SireID AS S7, g3d.DamID AS D7,

	g4a.SireID AS S8, g4a.DamID AS D8, g4b.SireID AS S9, g4b.DamID AS D9,
	g4c.SireID AS S10, g4c.DamID AS D10, g4d.SireID AS S11, g4d.DamID AS D11,
	g4e.SireID AS S12, g4e.DamID AS D12, g4f.SireID AS S13, g4f.DamID AS D13,
	g4g.SireID AS S14, g4g.DamID AS D14, g4h.SireID AS S15, g4h.DamID AS D15

FROM user_Horse g1

LEFT OUTER JOIN user_Horse g2a ON g1.SireID = g2a.HorseID
LEFT OUTER JOIN user_Horse g2b ON g1.DamID = g2b.HorseID

LEFT OUTER JOIN user_Horse g3a ON g2a.SireID = g3a.HorseID
LEFT OUTER JOIN user_Horse g3b ON g2a.DamID = g3b.HorseID
LEFT OUTER JOIN user_Horse g3c ON g2b.SireID = g3c.HorseID
LEFT OUTER JOIN user_Horse g3d ON g2b.DamID = g3d.HorseID

LEFT OUTER JOIN user_Horse g4a ON g3a.SireID = g4a.HorseID
LEFT OUTER JOIN user_Horse g4b ON g3a.DamID = g4b.HorseID
LEFT OUTER JOIN user_Horse g4c ON g3b.SireID = g4c.HorseID
LEFT OUTER JOIN user_Horse g4d ON g3b.DamID = g4d.HorseID
LEFT OUTER JOIN user_Horse g4e ON g3c.SireID = g4e.HorseID
LEFT OUTER JOIN user_Horse g4f ON g3c.DamID = g4f.HorseID
LEFT OUTER JOIN user_Horse g4g ON g3d.SireID = g4g.HorseID
LEFT OUTER JOIN user_Horse g4h ON g3d.DamID = g4h.HorseID

WHERE g1.HorseID = @HorseID
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Horse_GetID_Or_Insert]    Script Date: 10/25/2020 11:13:43 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_Horse_GetID_Or_Insert]
	 @HorseName			nvarchar(50)
	,@HorseID			uniqueidentifier		OUTPUT

AS

DECLARE @LocalID		uniqueidentifier
DECLARE @ColorID		uniqueidentifier
DECLARE @GenderID		uniqueidentifier
DECLARE @TrackingColorID	uniqueidentifier

SET @LocalID = '{36DE1595-2451-4349-B16B-4E0507513D89}'
SET @ColorID = '{A9BC4E5E-FDC3-4266-B339-32C3FAE54930}'
SET @GenderID = '{3C13EE2E-EA12-4F80-AE2F-147B5798F719}'
SET @TrackingColorID = '{58CC7B2C-F005-44A4-BDE6-772F74EC14BE}'

SELECT @HorseID = HorseID
FROM user_Horse
WHERE HorseName = @HorseName

IF @HorseID IS NULL
	BEGIN
		SELECT @HorseID = newid()
		INSERT INTO user_Horse(HorseID, HorseName, LocalID, ColorID, GenderID, TrackingColorID)
		VALUES(@HorseID, UPPER(@HorseName), @LocalID, @ColorID, @GenderID, @TrackingColorID)
	END
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Horse_GetHorseListByGender]    Script Date: 10/25/2020 11:13:43 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_Horse_GetHorseListByGender]
	 @Gender			varchar(10)
	,@SearchChars			varchar(50)

AS

IF @Gender = 'stallion'
	BEGIN
		SELECT TOP 25 h.HorseID, h.HorseName, h.RegistrationNumber, h.DateBorn, LULocal.LookupAbrv AS LocalAbrv,
			LUGender.LookupDescription AS GenderDescription, LUGender.LookupAbrv AS GenderAbrv,
			LUTrackingColor.LookupAbrv AS TrackingColorAbrv,
			COUNT(h2.HorseName) + COUNT(h3.HorseName) AS ProgenyCount
		FROM user_Horse h
		INNER JOIN base_Lookup LULocal ON h.LocalID = LULocal.LookupID
		INNER JOIN dbo.base_Lookup LUGender ON h.GenderID = LUGender.LookupID
		INNER JOIN dbo.base_Lookup LUColor ON h.ColorID = LUColor.LookupID
		INNER JOIN dbo.base_Lookup LUTrackingColor ON h.TrackingColorID = LUTrackingColor.LookupID
		LEFT OUTER JOIN user_Horse h2 ON h.HorseID = h2.SireID AND h.GenderID <> '{3C13EE2E-EA12-4F80-AE2F-147B5798F719}'
		LEFT OUTER JOIN user_Horse h3 ON h.HorseID = h3.DamID AND h.GenderID <> '{3C13EE2E-EA12-4F80-AE2F-147B5798F719}'
		WHERE h.HorseName like @SearchChars + '%' AND (LUGender.LookupDescription = 'Unknown, Both Sexes' OR  LUGender.LookupDescription = 'Gelding' OR LUGender.LookupDescription = 'Colt' OR LUGender.LookupDescription = 'Stallion')
		GROUP BY h.HorseID, h.HorseName, h.RegistrationNumber, h.DateBorn, LULocal.LookupAbrv,
			LUGender.LookupDescription, LUGender.LookupAbrv, LUTrackingColor.LookupAbrv
		ORDER BY h.HorseName
	END
ELSE IF @Gender = 'mare'
	BEGIN
		SELECT TOP 25 h.HorseID, h.HorseName, h.RegistrationNumber, h.DateBorn, LULocal.LookupAbrv AS LocalAbrv,
			LUGender.LookupDescription AS GenderDescription, LUGender.LookupAbrv AS GenderAbrv,
			LUTrackingColor.LookupAbrv AS TrackingColorAbrv,
			COUNT(h2.HorseName) + COUNT(h3.HorseName) AS ProgenyCount
		FROM user_Horse h
		INNER JOIN base_Lookup LULocal ON h.LocalID = LULocal.LookupID
		INNER JOIN dbo.base_Lookup LUGender ON h.GenderID = LUGender.LookupID
		INNER JOIN dbo.base_Lookup LUColor ON h.ColorID = LUColor.LookupID
		INNER JOIN dbo.base_Lookup LUTrackingColor ON h.TrackingColorID = LUTrackingColor.LookupID
		LEFT OUTER JOIN user_Horse h2 ON h.HorseID = h2.SireID AND h.GenderID <> '{3C13EE2E-EA12-4F80-AE2F-147B5798F719}'
		LEFT OUTER JOIN user_Horse h3 ON h.HorseID = h3.DamID AND h.GenderID <> '{3C13EE2E-EA12-4F80-AE2F-147B5798F719}'
		WHERE h.HorseName like @SearchChars + '%' AND (LUGender.LookupDescription = 'Unknown, Both Sexes' OR  LUGender.LookupDescription = 'Spayed Mare' OR LUGender.LookupDescription = 'Filly' OR LUGender.LookupDescription = 'Mare')
		GROUP BY h.HorseID, h.HorseName, h.RegistrationNumber, h.DateBorn, LULocal.LookupAbrv,
			LUGender.LookupDescription, LUGender.LookupAbrv, LUTrackingColor.LookupAbrv
		ORDER BY h.HorseName
	END
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Horse_Delete]    Script Date: 10/25/2020 11:13:39 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_Horse_Delete]
	 @HorseID			uniqueidentifier
	,@Success			bit		OUTPUT

AS

-- This sproc will delete a horse only if it DOES NOT have child records in the following tables:
-- user_Breeding, user_Ownership, user_Service, user_Show

DECLARE @Breeding		decimal
DECLARE @Ownership		decimal
DECLARE @Service		decimal
DECLARE @Show		decimal

SELECT @Breeding = Count(*)
FROM user_Breeding
WHERE HorseID = @HorseID

SELECT @Ownership = Count(*)
FROM user_Ownership
WHERE HorseID = @HorseID

SELECT @Service = Count(*)
FROM user_Service
WHERE HorseID = @HorseID

SELECT @Show = Count(*)
FROM user_Show
WHERE HorseID = @HorseID

IF @Breeding > 0 OR @Ownership > 0 OR @Service > 0 OR @Show > 0
	SET @Success = 0

ELSE
	BEGIN

	-- 1) Get rid of HorseID as Sire or Dam IDs for other records

	-- Set SireIDs to null
	UPDATE user_Horse
	SET SireID = NULL
	WHERE SireID = @HorseID

	-- Set DamIDs to null
	UPDATE user_Horse
	Set DamID = NULL
	WHERE DamID = @HorseID

	-- 2) Delete Child Records

	-- Delete History Record
	DELETE
	FROM user_History
	WHERE HorseID = @HorseID

	-- Delete MaintenanceBoarding records
	DELETE
	FROM user_MaintenanceBoarding
	WHERE HorseID = @HorseID

	-- Delete MaintenanceFeeding records
	DELETE
	FROM user_MaintenanceFeeding
	WHERE HorseID = @HorseID

	-- Delete Maintenance record
	DELETE
	FROM user_Maintenance
	WHERE HorseID = @HorseID

	-- 3) Delete main horse record

	-- Delete the horse record
	DELETE
	FROM user_Horse
	WHERE HorseID = @HorseID

	SET @Success = 1

	END
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Horse_GetByID]    Script Date: 10/25/2020 11:13:40 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_user_Horse_GetByID]

            @ID                uniqueidentifier

 

AS

 

SELECT h.HorseID, h.HorseName, h.TrackingColorID, LUDescription.LookupDescription AS TrackingColorDescription, 

            LUDescription.LookupAbrv AS TrackingColorAbrv, h.RegistrationNumber, h.DateDeceased, h.DateBorn, h.GenderID,

            LUGender.LookupDescription AS GenderDescription, LUGender.LookupAbrv AS GenderAbrv, h.Data1, h.Data2, h.ColorID,

            LUColor.LookupDescription AS ColorDescription, LUColor.LookupAbrv AS ColorAbrv, h.Comment, h.Breeder, h.Owner, h.OwnerNumber, h.SireID, 

            h2.HorseName AS SireName, h2.RegistrationNumber AS SireRegistrationNumber, LUSireGender.LookupDescription AS SireGenderDescription,

            h.DamID, h3.HorseName AS DamName, h3.RegistrationNumber AS DamRegistrationNumber,

            LUDamGender.LookupDescription AS DamGenderDescription, h.BloodTyped, h.FreezeMarked, h.Imported, h.Title1, h.Title2, h.Breed, h.[Catalog],

            h.LastTransaction, h.LocalID, LULocal.LookupDescription AS LocalDescription, LULocal.LookupAbrv AS LocalAbrv, h.DateSold, h.Comments,

            (SELECT TOP 1 HorseID FROM dbo.user_Horse WHERE HorseName > h.HorseName ORDER BY HorseName) AS NextHorseID,

            (SELECT TOP 1 HorseID FROM dbo.user_Horse WHERE HorseName < h.HorseName ORDER BY HorseName DESC) AS PreviousHorseID
,h.UpdateUser, h.UpdateTimestamp
FROM dbo.user_Horse h

INNER JOIN dbo.base_Lookup LUDescription ON h.TrackingColorID = LUDescription.LookupID

INNER JOIN dbo.base_Lookup LUGender ON h.GenderID = LUGender.LookupID

INNER JOIN dbo.base_Lookup LUColor ON h.ColorID = LUColor.LookupID

LEFT OUTER JOIN dbo.user_Horse h2 ON h.SireID = h2.HorseID

LEFT OUTER JOIN dbo.user_Horse h3 ON h.DamID = h3.HorseID

LEFT OUTER JOIN dbo.base_Lookup LUSireGender ON h2.GenderID = LUSireGender.LookupID

LEFT OUTER JOIN dbo.base_Lookup LUDamGender ON h3.GenderID = LUDamGender.LookupID

INNER JOIN dbo.base_Lookup LULocal ON h.LocalID = LULocal.LookupID

WHERE h.HorseID = @ID
GO
/****** Object:  View [dbo].[vw_user_Horse_plus]    Script Date: 10/25/2020 11:14:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_user_Horse_plus]
AS
SELECT     TOP 100 PERCENT h.HorseID, h.HorseName, h.TrackingColorID, LUDescription.LookupDescription AS TrackingColorDescription, 
                      LUDescription.LookupAbrv AS TrackingColorAbrv, h.RegistrationNumber, h.DateDeceased, h.DateBorn, h.GenderID, 
                      LUGender.LookupDescription AS GenderDescription, LUGender.LookupAbrv AS GenderAbrv, h.Data1, h.Data2, h.ColorID, 
                      LUColor.LookupDescription AS ColorDescription, LUColor.LookupAbrv AS ColorAbrv, h.Comment, h.Breeder, h.Owner,
                      h.OwnerNumber, h.SireID, h2.HorseName AS SireName, h2.RegistrationNumber AS SireRegistrationNumber, h.DamID,
                      h3.HorseName AS DamName, h3.RegistrationNumber AS DamRegistrationNumber, h.BloodTyped, h.FreezeMarked, h.Imported,
                      h.Title1, h.Title2, h.Breed, h.[Catalog], h.LastTransaction, h.LocalID, LULocal.LookupDescription AS LocalDescription, 
                      LULocal.LookupAbrv AS LocalAbrv, h.DateSold, h.Comments
FROM         dbo.user_Horse h INNER JOIN
                      dbo.base_Lookup LUDescription ON h.TrackingColorID = LUDescription.LookupID INNER JOIN
                      dbo.base_Lookup LUGender ON h.GenderID = LUGender.LookupID INNER JOIN
                      dbo.base_Lookup LUColor ON h.ColorID = LUColor.LookupID LEFT OUTER JOIN
                      dbo.user_Horse h2 ON h.SireID = h2.HorseID LEFT OUTER JOIN
                      dbo.user_Horse h3 ON h.DamID = h3.HorseID INNER JOIN
                      dbo.base_Lookup LULocal ON h.LocalID = LULocal.LookupID
ORDER BY h.HorseName
GO
/****** Object:  View [dbo].[vw_user_Ownership_plus]    Script Date: 10/25/2020 11:14:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_user_Ownership_plus]
AS
SELECT     TOP 100 PERCENT o.OwnershipID, o.HorseID, h.HorseName, o.ClientID, c.ClientCode, o.Percentage, o.LastStatementDate, o.Comments
FROM         dbo.user_Ownership o INNER JOIN
                      dbo.user_Horse h ON o.HorseID = h.HorseID INNER JOIN
                      dbo.user_Client c ON o.ClientID = c.ClientID
ORDER BY c.ClientCode, h.HorseName
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Horse_GetListBySearch]    Script Date: 10/25/2020 11:13:44 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_user_Horse_GetListBySearch]
	 @SearchName			nvarchar(50)
              ,@BandNumber                           nvarchar(10)
	,@LocalID			uniqueidentifier
	,@TrackingColorID		uniqueidentifier
	,@GenderID			uniqueidentifier
             ,@IncludeNonLocal                      bit
             ,@IncludeDeparted                       bit
	,@SortBy			varchar(50)
	,@SortDirection			varchar(10)

AS

SELECT h.HorseID, h.HorseName, h.Registrationnumber, h.DateBorn, LULocal.LookupAbrv AS LocalAbrv,
	LUGender.LookupDescription AS GenderDescription, LUGender.LookupAbrv AS GenderAbrv,
	LUTrack.LookupAbrv AS TrackingColorAbrv, h.UpdateUser, h.UpdateTimestamp, COUNT(h2.HorseName) + COUNT(h3.HorseName) AS ProgenyCount	
FROM user_Horse h
JOIN base_Lookup LULocal ON h.LocalID = LULocal.LookupID AND (@IncludeNonLocal = 1 or LULocal.LookupAbrv <> '0') AND (@IncludeDeparted = 1 or LULocal.LookupAbrv <> '6')
JOIN base_Lookup LUGender ON h.GenderID = LUGender.LookupID
LEFT JOIN base_Lookup LUTrack ON h.TrackingColorID = LUTrack.LookupID
LEFT OUTER JOIN user_Horse h2 ON h.HorseID = h2.SireID AND h.GenderID <> '{3C13EE2E-EA12-4F80-AE2F-147B5798F719}'
LEFT OUTER JOIN user_Horse h3 ON h.HorseID = h3.DamID AND h.GenderID <> '{3C13EE2E-EA12-4F80-AE2F-147B5798F719}'
LEFT JOIN user_Maintenance m on h.HorseID = m.HorseID
WHERE (@SearchName = '' or h.HorseName LIKE @SearchName + '%') AND (@BandNumber = '' or m.BandNumber like '%' + @BandNumber + '%')
	AND (@LocalID IS NULL OR h.LocalID = @LocalID)
	AND (@TrackingColorID IS NULL OR h.TrackingColorID = @TrackingColorID)
	AND (@GenderID IS NULL OR h.GenderID = @GenderID)
GROUP BY  h.HorseID, h.HorseName, h.Registrationnumber, h.DateBorn, LULocal.LookupAbrv,
	LUGender.LookupDescription, LUGender.LookupAbrv, LUTrack.LookupAbrv, h.UpdateUser, h.UpdateTimestamp
ORDER BY
	CASE @SortBy + @SortDirection
		WHEN 'HorseNameASC' THEN h.HorseName
		WHEN 'DateBornASC' THEN h.DateBorn + h.HorseName
		WHEN 'LocalAbrvASC' THEN LULocal.LookupAbrv + h.HorseName
		WHEN 'GenderAbrvASC' THEN LUGender.LookupAbrv + h.HorseName
	END ASC,
	CASE @SortBy + @SortDirection
		WHEN 'HorseNameDESC' THEN h.HorseName
		WHEN 'DateBornDESC' THEN h.DateBorn + h.HorseName
		WHEN 'LocalAbrvDESC' THEN LULocal.LookupAbrv + h.HorseName
		WHEN 'GenderAbrvDESC' THEN LUGender.LookupAbrv + h.HorseName
	END DESC
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Horse_GetProgenyByParentID]    Script Date: 10/25/2020 11:13:44 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_user_Horse_GetProgenyByParentID]
	 @HorseID			uniqueidentifier
	,@SortBy			varchar(50)
	,@SortDirection			varchar(10)

AS

SELECT h.HorseID, h.HorseName, h.RegistrationNumber, h.DateBorn, LULocal.LookupAbrv AS LocalAbrv,
	LUGender.LookupDescription AS GenderDescription, LUGender.LookupAbrv AS GenderAbrv,
	h.Data1, h.Data2, LUColor.LookupDescription AS ColorDescription, h.SireID, h4.HorseName AS SireName,
	h.DamID, h5.HorseName AS DamName, LUTrackingColor.LookupAbrv AS TrackingColorAbrv, h.UpdateUser, h.UpdateTimestamp, 
	COUNT(h2.HorseName) + COUNT(h3.HorseName) AS ProgenyCount
FROM user_Horse h
INNER JOIN base_Lookup LULocal ON h.LocalID = LULocal.LookupID
INNER JOIN dbo.base_Lookup LUGender ON h.GenderID = LUGender.LookupID
INNER JOIN dbo.base_Lookup LUColor ON h.ColorID = LUColor.LookupID
INNER JOIN dbo.base_Lookup LUTrackingColor ON h.TrackingColorID = LUTrackingColor.LookupID
LEFT OUTER JOIN user_Horse h2 ON h.HorseID = h2.SireID AND h.GenderID <> '{3C13EE2E-EA12-4F80-AE2F-147B5798F719}'
LEFT OUTER JOIN user_Horse h3 ON h.HorseID = h3.DamID AND h.GenderID <> '{3C13EE2E-EA12-4F80-AE2F-147B5798F719}'
LEFT OUTER JOIN dbo.user_Horse h4 ON h.SireID = h4.HorseID
LEFT OUTER JOIN dbo.user_Horse h5 ON h.DamID = h5.HorseID
WHERE h.SireID = @HorseID OR h.DamID = @HorseID
GROUP BY h.HorseID, h.HorseName, h.RegistrationNumber, h.DateBorn, LULocal.LookupAbrv,
	h.Data1, h.Data2, LUColor.LookupDescription, h.SireID, h4.HorseName, h.DamID, h5.HorseName,
	LUGender.LookupDescription, LUGender.LookupAbrv, LUTrackingColor.LookupAbrv, h.UpdateUser, h.UpdateTimestamp
ORDER BY
	CASE @SortBy + @SortDirection
		WHEN 'HorseNameASC' THEN h.HorseName
		WHEN 'DateBornASC' THEN h.DateBorn + h.HorseName
		WHEN 'LocalAbrvASC' THEN LULocal.LookupAbrv + h.HorseName
		WHEN 'GenderAbrvASC' THEN LUGender.LookupAbrv + h.HorseName
	END ASC,
	CASE @SortBy + @SortDirection
		WHEN 'HorseNameDESC' THEN h.HorseName
		WHEN 'DateBornDESC' THEN h.DateBorn + h.HorseName
		WHEN 'LocalAbrvDESC' THEN LULocal.LookupAbrv + h.HorseName
		WHEN 'GenderAbrvDESC' THEN LUGender.LookupAbrv + h.HorseName
	END DESC
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Client_GetListAndDetailedCharges]    Script Date: 10/25/2020 11:13:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_user_Client_GetListAndDetailedCharges]
(
@ClientID uniqueidentifier,
@BeginDate datetime,
@EndDate datetime
)
AS

--
-- CLIENTS
--
SELECT
	l.*,
	c.Name, c.FirstName, c.Company, c.Address1, c.Address2, c.City, c.StateID, LUState.LookupAbrv AS StateAbrv,
	LUState.LookupDescription AS StateDescription, c.Zip, c.CountryID, LUCountry.LookupAbrv AS CountryAbrv,
	LUCountry.LookupDescription AS CountryDescription, c.Phone1, c.Phone2, c.Fax, c.HorseNotes
FROM
	user_Client l
LEFT OUTER JOIN 
	user_Contact c ON l.ContactID = c.ContactID
LEFT OUTER JOIN 
	base_Lookup LUState ON c.StateID = LUState.LookupID
LEFT OUTER JOIN 
	base_Lookup LUCountry ON c.CountryID = LUCountry.LookupID
WHERE
	(@ClientID is null or l.ClientID = @ClientID)
ORDER BY l.ClientCode


--
-- HORSES - list of horses involved in current charges for selected clients
--

SELECT DISTINCT base.ClientID, base.Percentage, h.HorseID, h.horsename, h.RegistrationNumber, h.DateBorn, LULocal.LookupAbrv AS LocalAbrv,
	LUGender.LookupDescription AS GenderDescription, LUGender.LookupAbrv AS GenderAbrv,
	LUDescription.LookupAbrv AS TrackingColorAbrv,
	(SELECT COUNT(1) FROM user_Horse WHERE SireID = h.HorseID OR DamID = h.HorseID) as ProgenyCount
FROM
(
select c.ClientID as ClientID, o.HorseID, o.percentage as Percentage
from user_client c
inner join user_ownership o on o.clientid = c.clientid
where (@ClientID is null or c.ClientID = @ClientID)
) base
INNER JOIN user_horse h on h.horseID = base.HorseID
INNER JOIN dbo.base_Lookup LULocal ON h.LocalID = LULocal.LookupID
INNER JOIN dbo.base_Lookup LUGender ON h.GenderID = LUGender.LookupID
INNER JOIN dbo.base_Lookup LUDescription ON h.TrackingColorID = LUDescription.LookupID
GROUP BY base.ClientID, base.Percentage, h.HorseID, h.horseName, h.RegistrationNumber, h.DateBorn, LULocal.LookupAbrv,
	LUGender.LookupDescription, LUGender.LookupAbrv,
	LUDescription.LookupAbrv
order by h.HorseName

--
-- PAYMENTS
--
select c.ClientID, c.ClientCode, p.PaymentID, p.PaymentOrCredit, p.PaymentDate, p.Notes, p.Amount, p.Notes, p.PaymentMethod, p.Account from user_clientpayment p
inner join user_client c on c.clientid = p.clientid
where not p.amount is null and p.PaymentDate <= @EndDate and p.PaymentDate >= @BeginDate and (@ClientID is null or c.ClientID = @ClientID)
ORDER BY p.PaymentDate, c.ClientCode

--
-- CHARGES
--

SELECT base.ClientID, base.HorseID, base.ServiceType, base.ServiceDate, (CAST((base.Amount * base.Percentage + 0.5) as INT) ) / 100.0 AS Charges, base.Notes, base.Account
FROM
(
--
--BREEDING
--
select 
	c.ClientID, o.HorseID, o.percentage, 'Breeding' as ServiceType, 
	f.Cost as Amount, f.DueDate as ServiceDate, 'Breeding with ' + s.HorseName as Notes, 'BredSale' as Account
from user_breedingfee f
inner join user_breeding b on b.breedingid = f.breedingid
inner join user_ownership o on o.horseid = b.horseid
inner join user_client c on c.clientid = o.clientid
inner join user_horse s on s.HorseID = b.StallionID
where f.DueDate <= @EndDate and f.DueDate >= @BeginDate and (@ClientID is null or c.ClientID = @ClientID)

union

--
--BOARDING
--
SELECT c.ClientID, o.HorseID, o.percentage, 'Boarding' as ServiceType, 
	CASE WHEN base.TimeUnit = 'D' THEN
		CAST((base.RelativeEndDate - base.RelativeBeginDate)+1 as INT)*base.Rate
	     WHEN base.TimeUnit = 'M' THEN
		base.Rate * Months + CAST(((base.Rate * DaysBefore * 100 / DaysInMonthBefore) +
						(base.Rate * DaysAfter * 100 / DaysInMonthAfter) +
						(base.Rate * DaysDuring * 100 / DaysInMonth) +
						0.5) as INT) / 100.0
	END AS Amount, 
	base.RelativeEndDate as ServiceDate,
	CASE WHEN base.TimeUnit = 'D' THEN
		Cast(DateDiff(d,base.RelativeBeginDate,base.RelativeEndDate)+1 as VARCHAR(10)) + ' Days @ ' + CAST(base.Rate as varchar(10))
	     WHEN base.TimeUnit = 'M' THEN
		CASE WHEN Months > 0 THEN Cast(Months as varchar(10)) + ' Months' ELSE '' END +
		CASE WHEN Months > 0 AND (DaysBefore+DaysAfter+DaysDuring) > 0 THEN ' and ' ELSE '' END +
		CASE WHEN (DaysBefore+DaysAfter+DaysDuring) > 0 THEN Cast((DaysBefore+DaysAfter+DaysDuring) as varchar(8)) + ' Days' ELSE '' END +
		' @ ' + CAST(base.Rate as varchar(10)) + '/month'
	END AS Notes, '' as Account
FROM
(SELECT b3.HorseID, b3.TimeUnit, b3.Rate, 
	CASE WHEN DateDiff(m, b3.BeginFirstFullMonth, b3.DayAfterLastFullMonth) > 0 THEN DateDiff(m, b3.BeginFirstFullMonth, b3.DayAfterLastFullMonth) ELSE 0 END as Months,
	CASE WHEN DateDiff(m, b3.BeginFirstFullMonth, b3.DayAfterLastFullMonth) > 0 THEN DateDiff(d, b3.RelativeBeginDate, b3.BeginFirstFullMonth) ELSE 0 END as DaysBefore,
	CASE WHEN DateDiff(m, b3.BeginFirstFullMonth, b3.DayAfterLastFullMonth) > 0 THEN DateDiff(d, b3.DayAfterLastFullMonth, b3.RelativeEndDate)+1 ELSE 0 END as DaysAfter,
	CASE WHEN DateDiff(m, b3.BeginFirstFullMonth, b3.DayAfterLastFullMonth) <= 0 THEN DateDiff(d, b3.RelativeBeginDate, b3.RelativeEndDate)+1 ELSE 0 END as DaysDuring,
	day(DateAdd(d, -1, b3.BeginFirstFullMonth)) as DaysInMonthBefore,
	day(DateAdd(d, -1, DateAdd(m, 1, b3.DayAfterLastFullMonth))) as DaysInMonthAfter,
	CASE WHEN DateDiff(m, b3.BeginFirstFullMonth, b3.DayAfterLastFullMonth) > 0 THEN day(DateAdd(d, -1, b3.DayAfterLastFullMonth)) WHEN b3.BeginFirstFullMonth > b3.RelativeEndDate THEN day(DateAdd(d, -1, b3.BeginFirstFullMonth)) ELSE day(DateAdd(d, -1, DateAdd(m, 1, b3.DayAfterLastFullMonth))) END as DaysInMonth,
	b3.RelativeBeginDate, 
	b3.RelativeEndDate
FROM
(SELECT b2.HorseID, b2.TimeUnit, b2.Rate,
	b2.RelativeBeginDate, 
	b2.RelativeEndDate, 
	CASE WHEN day(b2.RelativeBeginDate) = 1 THEN
		cast(cast(month(b2.RelativeBeginDate) as varchar(2)) + '/01/' + cast(year(b2.RelativeBeginDate) as varchar(4)) + ' 0:00:000' as datetime)
	     ELSE
		cast(cast(month(DateAdd(m,1,b2.RelativeBeginDate)) as varchar(2)) + '/01/' + cast(year(DateAdd(m,1,b2.RelativeBeginDate)) as varchar(4)) + ' 0:00:000' as datetime)
	END as BeginFirstFullMonth, 
	CASE WHEN month(b2.RelativeEndDate) = month(DateAdd(d,1,b2.RelativeEndDate)) THEN
		cast(cast(month(b2.RelativeEndDate) as varchar(2)) + '/01/' + cast(year(b2.RelativeEndDate) as varchar(4)) + ' 0:00:00' as datetime)
	ELSE
		cast(cast(month(DateAdd(d,1,b2.RelativeEndDate)) as varchar(2)) + '/01/' + cast(year(DateAdd(d,1,b2.RelativeEndDate)) as varchar(4)) + ' 0:00:000' as datetime)
	END as DayAfterLastFullMonth
FROM
(SELECT b.HorseID, b.TimeUnit, b.Rate,
   CASE WHEN b.enddate <= @EndDate THEN b.enddate ELSE @EndDate END as RelativeEndDate,
   CASE WHEN b.begindate >= @BeginDate THEN b.begindate ELSE @BeginDate END as RelativeBeginDate,
   b.begindate,
   b.enddate
FROM user_maintenanceboarding b
WHERE b.begindate <= @EndDate and b.endDate >= @BeginDate
) b2) b3) base
INNER JOIN user_ownership o ON o.horseid = base.horseid
INNER JOIN user_client c on c.clientid = o.clientid
WHERE (@ClientID is null or c.ClientID = @ClientID)

union

--
--SERVICES
--
SELECT 
	c.ClientID, o.HorseID, o.percentage, l.LookupDescription as ServiceType, 
	s.Cost as Amount, s.ServiceDate as ServiceDate, s.Notes, '' as Account
FROM user_service s
INNER JOIN base_Lookup l on l.LookupID = s.ServiceTypeID
INNER JOIN user_ownership o on o.horseid = s.horseid
INNER JOIN user_client c on c.clientid = o.clientid
WHERE s.ServiceDate <= @EndDate and s.ServiceDate >= @BeginDate and not s.Cost is NULL and (@ClientID is null or c.ClientID = @ClientID)

union

--
--SHOW
--
SELECT 
	c.ClientID, o.HorseID, o.percentage, 'Show' as ServiceType, 
	isnull(DayRate,0)+isnull(Transport,0)+isnull(Equipment,0)+isnull(Handling,0)+isnull(ProRata,0)+isnull(Grooming,0)+isnull(EntryFees,0)+isnull(Miscellaneous,0) as Amount, 
	s.ShowDate as ServiceDate, s.ShowName as Notes, '' as Account
FROM user_show s
INNER JOIN user_ownership o on o.horseid = s.horseid
INNER JOIN user_client c on c.clientid = o.clientid
WHERE s.ShowDate <= @EndDate and s.ShowDate >= @BeginDate and (@ClientID is null or c.ClientID = @ClientID)

union

--
--BREEDING SALE
--
SELECT c.ClientID, o.HorseID, o.percentage, 'BreedSale' as ServiceType, 
	(a.Principal + a.Interest) as Amount,
	a.chargedate as ServiceDate, b.Notes, 'BredSale' as Account
FROM user_AmortizedCharge a
INNER JOIN user_breedingSale b on a.ReferenceID = b.breedingsaleid
INNER JOIN user_ownership o ON o.horseid = b.horseid
INNER JOIN user_client c on c.clientid = o.clientid
WHERE (@ClientID is null or c.ClientID = @ClientID) and (a.ChargeDate >= @BeginDate and a.ChargeDate <= @EndDate)

union

--
--HORSE SALE
--
SELECT c.ClientID, o.HorseID, o.percentage, 'HorseSale' as ServiceType, 
	(a.Principal + a.Interest) as Amount,
	a.chargedate as ServiceDate, h.Notes, 'HorsSale' as Account
FROM user_AmortizedCharge a
INNER JOIN user_horseSale h on a.ReferenceID = h.horsesaleid
INNER JOIN user_ownership o ON o.horseid = h.horseid
INNER JOIN user_client c on c.clientid = o.clientid
WHERE (@ClientID is null or c.ClientID = @ClientID) and (a.ChargeDate >= @BeginDate and a.ChargeDate <= @EndDate)


) base
ORDER BY base.ServiceDate



--
--MISC
--
select c.ClientID, c.ClientCode, m.ClientMiscID as MiscID, m.Amount, m.Date as MiscDate, m.Item, m.Account from user_clientmisc m
inner join user_client c on c.clientid = m.clientid
where m.Date <= @EndDate and m.Date >= @BeginDate and not m.Amount is null and (@ClientID is null or c.ClientID = @ClientID)
ORDER BY m.Date
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Client_GetReceivables]    Script Date: 10/25/2020 11:13:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_user_Client_GetReceivables]
(
@EndDate datetime
)
AS

DECLARE @lastStatementDate datetime
set @lastStatementDate = (select StatementDate from user_Statement where Statement = 'LAST')

SELECT
	c.ClientID, c.ClientCode, c.ContactID, c.LastTransaction, c.LastBill, c.StatementType, c.ServiceCharge,
	c.Terms, c.Statement,
	CASE WHEN @EndDate > @lastStatementDate THEN
		(isnull(new.Charges,0) - dbo.fnPositive(isnull(new.Payments,0) - isnull(c.Period2,0) - isnull(c.Period3,0) - isnull(c.Period1,0) - isnull(c.[Current],0))) 
	ELSE
		c.[Current]
	END as [Current],
	CASE WHEN @EndDate > @lastStatementDate THEN
		dbo.fnPositive(isnull(c.[Current],0) - dbo.fnPositive(isnull(new.Payments,0) - isnull(c.Period2,0) - isnull(c.Period3,0) - isnull(c.Period1,0)))
	ELSE
		c.Period1
	END as [Period1],
	CASE WHEN @EndDate > @lastStatementDate THEN
		dbo.fnPositive(isnull(c.Period1,0) - dbo.fnPositive(isnull(new.Payments,0) - isnull(c.Period2,0) - isnull(c.Period3,0))) 
	ELSE
		c.Period2
	END as [Period2],
	CASE WHEN @EndDate > @lastStatementDate THEN
		dbo.fnPositive(isnull(c.Period2,0) + isnull(c.Period3,0) - isnull(new.Payments,0))
	ELSE
		c.Period3
	END as [Period3],
	CASE WHEN @EndDate > @lastStatementDate THEN
		c.[Current]
	ELSE
		c.LastCurrent
	END as LastCurrent, 
	CASE WHEN @EndDate > @lastStatementDate THEN
		c.Period1
	ELSE
		c.LastPeriod1
	END as LastPeriod1, 
	CASE WHEN @EndDate > @lastStatementDate THEN
		c.Period2
	ELSE
		c.LastPeriod2
	END as LastPeriod2, 
	CASE WHEN @EndDate > @lastStatementDate THEN
		c.Period3
	ELSE
		c.LastPeriod3
	END as LastPeriod3, 

	CASE WHEN @EndDate > @lastStatementDate THEN
		(isnull(new.BreedCharges,0) - dbo.fnPositive(isnull(new.BreedPayments,0) - isnull(c.BreedPeriod2,0) - isnull(c.BreedPeriod3,0) - isnull(c.BreedPeriod1,0) - isnull(c.[BreedCurrent],0))) 
	ELSE
		c.[BreedCurrent]
	END as [BreedCurrent],
	CASE WHEN @EndDate > @lastStatementDate THEN
		dbo.fnPositive(isnull(c.[BreedCurrent],0) - dbo.fnPositive(isnull(new.BreedPayments,0) - isnull(c.BreedPeriod2,0) - isnull(c.BreedPeriod3,0) - isnull(c.BreedPeriod1,0)))
	ELSE
		c.BreedPeriod1
	END as [BreedPeriod1],
	CASE WHEN @EndDate > @lastStatementDate THEN
		dbo.fnPositive(isnull(c.BreedPeriod1,0) - dbo.fnPositive(isnull(new.BreedPayments,0) - isnull(c.BreedPeriod2,0) - isnull(c.BreedPeriod3,0))) 
	ELSE
		c.BreedPeriod2
	END as [BreedPeriod2],
	CASE WHEN @EndDate > @lastStatementDate THEN
		dbo.fnPositive(isnull(c.BreedPeriod2,0) + isnull(c.BreedPeriod3,0) - isnull(new.BreedPayments,0))
	ELSE
		c.BreedPeriod3
	END as [BreedPeriod3],
	CASE WHEN @EndDate > @lastStatementDate THEN
		c.[BreedCurrent]
	ELSE
		c.LastBreedCurrent
	END as LastBreedCurrent, 
	CASE WHEN @EndDate > @lastStatementDate THEN
		c.BreedPeriod1
	ELSE
		c.LastBreedPeriod1
	END as LastBreedPeriod1, 
	CASE WHEN @EndDate > @lastStatementDate THEN
		c.BreedPeriod2
	ELSE
		c.LastBreedPeriod2
	END as LastBreedPeriod2, 
	CASE WHEN @EndDate > @lastStatementDate THEN
		c.BreedPeriod3
	ELSE
		c.LastBreedPeriod3
	END as LastBreedPeriod3, 

	CASE WHEN @EndDate > @lastStatementDate THEN
		(isnull(new.SaleCharges,0) - dbo.fnPositive(isnull(new.SalePayments,0) - isnull(c.SalePeriod2,0) - isnull(c.SalePeriod3,0) - isnull(c.SalePeriod1,0) - isnull(c.[SaleCurrent],0))) 
	ELSE
		c.[SaleCurrent]
	END as [SaleCurrent],
	CASE WHEN @EndDate > @lastStatementDate THEN
		dbo.fnPositive(isnull(c.[SaleCurrent],0) - dbo.fnPositive(isnull(new.SalePayments,0) - isnull(c.SalePeriod2,0) - isnull(c.SalePeriod3,0) - isnull(c.SalePeriod1,0)))
	ELSE
		c.SalePeriod1
	END as [SalePeriod1],
	CASE WHEN @EndDate > @lastStatementDate THEN
		dbo.fnPositive(isnull(c.SalePeriod1,0) - dbo.fnPositive(isnull(new.SalePayments,0) - isnull(c.SalePeriod2,0) - isnull(c.SalePeriod3,0))) 
	ELSE
		c.SalePeriod2
	END as [SalePeriod2],
	CASE WHEN @EndDate > @lastStatementDate THEN
		dbo.fnPositive(isnull(c.SalePeriod2,0) + isnull(c.SalePeriod3,0) - isnull(new.SalePayments,0))
	ELSE
		c.SalePeriod3
	END as [SalePeriod3],
	CASE WHEN @EndDate > @lastStatementDate THEN
		c.[SaleCurrent]
	ELSE
		c.LastSaleCurrent
	END as LastSaleCurrent, 
	CASE WHEN @EndDate > @lastStatementDate THEN
		c.SalePeriod1
	ELSE
		c.LastSalePeriod1
	END as LastSalePeriod1, 
	CASE WHEN @EndDate > @lastStatementDate THEN
		c.SalePeriod2
	ELSE
		c.LastSalePeriod2
	END as LastSalePeriod2, 
	CASE WHEN @EndDate > @lastStatementDate THEN
		c.SalePeriod3
	ELSE
		c.LastSalePeriod3
	END as LastSalePeriod3, 

	CASE WHEN @EndDate > @lastStatementDate THEN
		(isnull(new.TransCharges,0) - dbo.fnPositive(isnull(new.TransPayments,0) - isnull(c.TransPeriod2,0) - isnull(c.TransPeriod3,0) - isnull(c.TransPeriod1,0) - isnull(c.[TransCurrent],0))) 
	ELSE
		c.[TransCurrent]
	END as [TransCurrent],
	CASE WHEN @EndDate > @lastStatementDate THEN
		dbo.fnPositive(isnull(c.[TransCurrent],0) - dbo.fnPositive(isnull(new.TransPayments,0) - isnull(c.TransPeriod2,0) - isnull(c.TransPeriod3,0) - isnull(c.TransPeriod1,0)))
	ELSE
		c.TransPeriod1
	END as [TransPeriod1],
	CASE WHEN @EndDate > @lastStatementDate THEN
		dbo.fnPositive(isnull(c.TransPeriod1,0) - dbo.fnPositive(isnull(new.TransPayments,0) - isnull(c.TransPeriod2,0) - isnull(c.TransPeriod3,0))) 
	ELSE
		c.TransPeriod2
	END as [TransPeriod2],
	CASE WHEN @EndDate > @lastStatementDate THEN
		dbo.fnPositive(isnull(c.TransPeriod2,0) + isnull(c.TransPeriod3,0) - isnull(new.TransPayments,0))
	ELSE
		c.TransPeriod3
	END as [TransPeriod3],
	CASE WHEN @EndDate > @lastStatementDate THEN
		c.[TransCurrent]
	ELSE
		c.LastTransCurrent
	END as LastTransCurrent, 
	CASE WHEN @EndDate > @lastStatementDate THEN
		c.TransPeriod1
	ELSE
		c.LastTransPeriod1
	END as LastTransPeriod1, 
	CASE WHEN @EndDate > @lastStatementDate THEN
		c.TransPeriod2
	ELSE
		c.LastTransPeriod2
	END as LastTransPeriod2, 
	CASE WHEN @EndDate > @lastStatementDate THEN
		c.TransPeriod3
	ELSE
		c.LastTransPeriod3
	END as LastTransPeriod3, 

	c.SeparatePeriods,
	c.Notes, c.Comments,
	co.Name, co.FirstName, co.Company, co.Address1, co.Address2, co.City, co.StateID, LUState.LookupAbrv AS StateAbrv,
	LUState.LookupDescription AS StateDescription, co.Zip, co.CountryID, LUCountry.LookupAbrv AS CountryAbrv,
	LUCountry.LookupDescription AS CountryDescription, co.Phone1, co.Phone2, co.Fax, co.HorseNotes
FROM
	user_Client c
LEFT JOIN 
	(

SELECT 
		base.ClientID, 
		SUM( CAST((base.Amount * base.Percentage + 0.5) as INT) ) / 100.0 AS Charges, 
		SUM( CAST((base.BreedAmount * base.Percentage + 0.5) as INT) ) / 100.0 AS BreedCharges, 
		SUM( CAST((base.SaleAmount * base.Percentage + 0.5) as INT) ) / 100.0 AS SaleCharges, 
		SUM( CAST((base.TransAmount * base.Percentage + 0.5) as INT) ) / 100.0 AS TransCharges, 
		SUM(Payment) AS Payments,
		SUM(BreedPayment) AS BreedPayments,
		SUM(SalePayment) AS SalePayments,
		SUM(TransPayment) AS TransPayments
		FROM
		(
			--
			-- PAYMENTS
			--
			select paymentid as uniqueid, c.ClientID, 100.00 as percentage, 0.00 as Amount, 0.00 as BreedAmount, 0.00 as SaleAmount, 0.00 as TransAmount, 
				p.PaymentDate as [Date], p.Amount as Payment, 0.00 as BreedPayment, 0.00 as SalePayment, 0.00 as TransPayment
			from user_clientpayment p
			inner join user_client c on c.clientid = p.clientid
			where not p.amount is null and p.PaymentDate <= @endDate and p.PaymentDate > @lastStatementDate
				and (c.SeparatePeriods=0 or not p.Account in ('BredSale', 'HorsSale', 'Trnsprt'))
			
			union
			
			select paymentid as uniqueid, c.ClientID, 100.00 as percentage, 0.00 as Amount, 0.00 as BreedAmount, 0.00 as SaleAmount, 0.00 as TransAmount, 
				p.PaymentDate as [Date], 0.00 as Payment, p.Amount as BreedPayment, 0.00 as SalePayment, 0.00 as TransPayment
			from user_clientpayment p
			inner join user_client c on c.clientid = p.clientid
			where not p.amount is null and p.PaymentDate <= @endDate and p.PaymentDate > @lastStatementDate
				and c.SeparatePeriods=1 and p.Account = 'BredSale'
			
			union

			select paymentid as uniqueid, c.ClientID, 100.00 as percentage, 0.00 as Amount, 0.00 as BreedAmount, 0.00 as SaleAmount, 0.00 as TransAmount, 
				p.PaymentDate as [Date], 0.00 as Payment, 0.00 as BreedPayment, p.Amount as SalePayment, 0.00 as TransPayment
			from user_clientpayment p
			inner join user_client c on c.clientid = p.clientid
			where not p.amount is null and p.PaymentDate <= @endDate and p.PaymentDate > @lastStatementDate
				and c.SeparatePeriods=1 and p.Account = 'HorsSale'
			
			union

			select paymentid as uniqueid, c.ClientID, 100.00 as percentage, 0.00 as Amount, 0.00 as BreedAmount, 0.00 as SaleAmount, 0.00 as TransAmount, 
				p.PaymentDate as [Date], 0.00 as Payment, 0.00 as BreedPayment, 0.00 as SalePayment, p.Amount as TransPayment
			from user_clientpayment p
			inner join user_client c on c.clientid = p.clientid
			where not p.amount is null and p.PaymentDate <= @endDate and p.PaymentDate > @lastStatementDate
				and c.SeparatePeriods=1 and p.Account = 'Trnsprt'
			
			union

			--
			-- CHARGES
			--
			
			--
			--BREEDING
			--
			select b.breedingid as uniqueid, c.ClientID as ClientID, o.percentage as Percentage, f.Cost as Amount, 0.00 as BreedAmount, 0.00 as SaleAmount, 0.00 as TransAmount, 
				f.DueDate as [Date], 0.00 as Payment, 0.00 as BreedPayment, 0.00 as SalePayment, 0.00 as TransPayment
			from user_breedingfee f
			inner join user_breeding b on b.breedingid = f.breedingid
			inner join user_ownership o on o.horseid = b.horseid
			inner join user_client c on c.clientid = o.clientid
			where f.DueDate <= @endDate and f.DueDate > @lastStatementDate
				and c.SeparatePeriods=0
			
			union
			
			select b.breedingid as uniqueid, c.ClientID as ClientID, o.percentage as Percentage, 0.00 as Amount, f.Cost as BreedAmount, 0.00 as SaleAmount, 0.00 as TransAmount, 
				f.DueDate as [Date], 0.00 as Payment, 0.00 as BreedPayment, 0.00 as SalePayment, 0.00 as TransPayment
			from user_breedingfee f
			inner join user_breeding b on b.breedingid = f.breedingid
			inner join user_ownership o on o.horseid = b.horseid
			inner join user_client c on c.clientid = o.clientid
			where f.DueDate <= @endDate and f.DueDate > @lastStatementDate
				and c.SeparatePeriods=1
			
			union
			
			--
			--MISC
			--
			select clientmiscid as uniqueid, c.ClientID, 100.00 as percentage, m.Amount, 0.00 as BreedAmount, 0.00 as SaleAmount, 0.00 as TransAmount, 
				m.Date, 0.00 as Payment, 0.00 as BreedPayment, 0.00 as SalePayment, 0.00 as TransPayment
			from user_clientmisc m
			inner join user_client c on c.clientid = m.clientid
			where m.Date <= @endDate and m.Date > @lastStatementDate and not m.Amount is null
				and (c.SeparatePeriods=0 or not m.Account in ('BredSale', 'HorsSale', 'Trnsprt'))
			
			union
			
			select clientmiscid as uniqueid, c.ClientID, 100.00 as percentage, 0.00 as Amount, m.Amount as BreedAmount, 0.00 as SaleAmount, 0.00 as TransAmount, 
				m.Date, 0.00 as Payment, 0.00 as BreedPayment, 0.00 as SalePayment, 0.00 as TransPayment
			from user_clientmisc m
			inner join user_client c on c.clientid = m.clientid
			where m.Date <= @endDate and m.Date > @lastStatementDate and not m.Amount is null
				and c.SeparatePeriods=1 and m.Account = 'BredSale'
			
			union
			
			select clientmiscid as uniqueid, c.ClientID, 100.00 as percentage, 0.00 as Amount, 0.00 as BreedAmount, m.Amount as SaleAmount, 0.00 as TransAmount, 
				m.Date, 0.00 as Payment, 0.00 as BreedPayment, 0.00 as SalePayment, 0.00 as TransPayment
			from user_clientmisc m
			inner join user_client c on c.clientid = m.clientid
			where m.Date <= @endDate and m.Date > @lastStatementDate and not m.Amount is null
				and c.SeparatePeriods=1 and m.Account = 'HorsSale'
			
			union
			
			select clientmiscid as uniqueid, c.ClientID, 100.00 as percentage, 0.00 as Amount, 0.00 as BreedAmount, 0.00 as SaleAmount, m.Amount as TransAmount, 
				m.Date, 0.00 as Payment, 0.00 as BreedPayment, 0.00 as SalePayment, 0.00 as TransPayment
			from user_clientmisc m
			inner join user_client c on c.clientid = m.clientid
			where m.Date <= @endDate and m.Date > @lastStatementDate and not m.Amount is null
				and c.SeparatePeriods=1 and m.Account = 'Trnsprt'
			
			union
			
			--
			--BOARDING
			--
			SELECT base.boardingid as uniqueid, c.ClientID, o.percentage, 
				CASE WHEN base.TimeUnit = 'D' THEN
					CAST((base.RelativeEndDate - base.RelativeBeginDate)+1 as INT)*base.Rate
				     WHEN base.TimeUnit = 'M' THEN
		base.Rate * Months + CAST(((base.Rate * DaysBefore * 100 / DaysInMonthBefore) +
						(base.Rate * DaysAfter * 100 / DaysInMonthAfter) +
						(base.Rate * DaysDuring * 100 / DaysInMonth) +
						0.5) as INT) / 100.0
				END AS Amount, 0.00 as BreedAmount, 0.00 as SaleAmount, 0.00 as TransAmount, 
				base.RelativeEndDate as [Date], 0.00 as Payment, 0.00 as BreedPayment, 0.00 as SalePayment, 0.00 as TransPayment
			FROM
(SELECT b3.boardingid, b3.HorseID, b3.TimeUnit, b3.Rate, 
	CASE WHEN DateDiff(m, b3.BeginFirstFullMonth, b3.DayAfterLastFullMonth) > 0 THEN DateDiff(m, b3.BeginFirstFullMonth, b3.DayAfterLastFullMonth) ELSE 0 END as Months,
	CASE WHEN DateDiff(m, b3.BeginFirstFullMonth, b3.DayAfterLastFullMonth) > 0 THEN DateDiff(d, b3.RelativeBeginDate, b3.BeginFirstFullMonth) ELSE 0 END as DaysBefore,
	CASE WHEN DateDiff(m, b3.BeginFirstFullMonth, b3.DayAfterLastFullMonth) > 0 THEN DateDiff(d, b3.DayAfterLastFullMonth, b3.RelativeEndDate)+1 ELSE 0 END as DaysAfter,
	CASE WHEN DateDiff(m, b3.BeginFirstFullMonth, b3.DayAfterLastFullMonth) <= 0 THEN DateDiff(d, b3.RelativeBeginDate, b3.RelativeEndDate)+1 ELSE 0 END as DaysDuring,
	day(DateAdd(d, -1, b3.BeginFirstFullMonth)) as DaysInMonthBefore,
	day(DateAdd(d, -1, DateAdd(m, 1, b3.DayAfterLastFullMonth))) as DaysInMonthAfter,
	CASE WHEN DateDiff(m, b3.BeginFirstFullMonth, b3.DayAfterLastFullMonth) > 0 THEN day(DateAdd(d, -1, b3.DayAfterLastFullMonth)) WHEN b3.BeginFirstFullMonth > b3.RelativeEndDate THEN day(DateAdd(d, -1, b3.BeginFirstFullMonth)) ELSE day(DateAdd(d, -1, DateAdd(m, 1, b3.DayAfterLastFullMonth))) END as DaysInMonth,
				b3.RelativeBeginDate, 
				b3.RelativeEndDate
			FROM
(SELECT b2.boardingid, b2.HorseID, b2.TimeUnit, b2.Rate,
				b2.RelativeBeginDate, 
				b2.RelativeEndDate, 
				CASE WHEN day(b2.RelativeBeginDate) = 1 THEN
					cast(cast(month(b2.RelativeBeginDate) as varchar(2)) + '/01/' + cast(year(b2.RelativeBeginDate) as varchar(4)) + ' 0:00:000' as datetime)
				     ELSE
					cast(cast(month(DateAdd(m,1,b2.RelativeBeginDate)) as varchar(2)) + '/01/' + cast(year(DateAdd(m,1,b2.RelativeBeginDate)) as varchar(4)) + ' 0:00:000' as datetime)
				END as BeginFirstFullMonth, 
	CASE WHEN month(b2.RelativeEndDate) = month(DateAdd(d,1,b2.RelativeEndDate)) THEN
		cast(cast(month(b2.RelativeEndDate) as varchar(2)) + '/01/' + cast(year(b2.RelativeEndDate) as varchar(4)) + ' 0:00:00' as datetime)
	ELSE
		cast(cast(month(DateAdd(d,1,b2.RelativeEndDate)) as varchar(2)) + '/01/' + cast(year(DateAdd(d,1,b2.RelativeEndDate)) as varchar(4)) + ' 0:00:000' as datetime)
	END as DayAfterLastFullMonth
			FROM
(SELECT b.boardingid, b.HorseID, b.TimeUnit, b.Rate,
			   CASE WHEN b.enddate <= @EndDate THEN b.enddate ELSE @EndDate END as RelativeEndDate,
   CASE WHEN b.begindate > @lastStatementDate THEN b.begindate ELSE dateadd(d,1,@lastStatementDate) END as RelativeBeginDate,
			   b.begindate,
			   b.enddate
			FROM user_maintenanceboarding b
WHERE b.begindate <= @EndDate and b.endDate > @lastStatementDate
) b2) b3) base
			INNER JOIN user_ownership o ON o.horseid = base.horseid
			INNER JOIN user_client c on c.clientid = o.clientid
			
			union
			
			--
			--SERVICES
			--
			SELECT serviceid as uniqueid, c.ClientID, o.percentage, s.Cost as Amount, 0.00 as BreedAmount, 0.00 as SaleAmount, 0.00 as TransAmount, 
				s.ServiceDate as [Date], 0.00 as Payment, 0.00 as BreedPayment, 0.00 as SalePayment, 0.00 as TransPayment
			FROM user_service s
			INNER JOIN user_ownership o on o.horseid = s.horseid
			INNER JOIN user_client c on c.clientid = o.clientid
			WHERE s.ServiceDate <= @endDate and s.ServiceDate > @lastStatementDate and not s.Cost is NULL
			
			union
			
			--
			--SHOW
			--
			SELECT showid as uniqueid, c.ClientID, o.percentage, isnull(DayRate,0)+isnull(Transport,0)+isnull(Equipment,0)+isnull(Handling,0)+isnull(ProRata,0)+isnull(Grooming,0)+isnull(EntryFees,0)+isnull(Miscellaneous,0) as Amount, 
				0.00 as BreedAmount, 0.00 as SaleAmount, 0.00 as TransAmount, 
				s.ShowDate as [Date], 0.00 as Payment, 0.00 as BreedPayment, 0.00 as SalePayment, 0.00 as TransPayment
			FROM user_show s
			INNER JOIN user_ownership o on o.horseid = s.horseid
			INNER JOIN user_client c on c.clientid = o.clientid
			WHERE s.ShowDate <= @endDate and s.ShowDate > @lastStatementDate
		) base
		GROUP BY base.ClientID
	) new ON new.ClientID = c.ClientID
INNER JOIN user_Contact co ON c.ContactID = co.ContactID
LEFT OUTER JOIN base_Lookup LUState ON co.StateID = LUState.LookupID
LEFT OUTER JOIN base_Lookup LUCountry ON co.CountryID = LUCountry.LookupID
ORDER BY c.ClientCode
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Client_GetList]    Script Date: 10/25/2020 11:13:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_user_Client_GetList]
AS

SELECT
	l.*,
	c.Name, c.FirstName, c.Company, c.Address1, c.Address2, c.City, c.StateID, LUState.LookupAbrv AS StateAbrv,
	LUState.LookupDescription AS StateDescription, c.Zip, c.CountryID, LUCountry.LookupAbrv AS CountryAbrv,
	LUCountry.LookupDescription AS CountryDescription, c.Phone1, c.Phone2, c.Fax, c.HorseNotes
FROM
	user_Client l
INNER JOIN
(

select distinct x2.clientcode
from
(

select clientcode from user_client
where ([current]+Period1+Period2+Period3+BreedCurrent+BreedPeriod1+BreedPeriod2+BreedPeriod3+SaleCurrent+SalePeriod1+SalePeriod2+SalePeriod3+TransCurrent+TransPeriod1+TransPeriod2+TransPeriod3) > 0

union

select distinct x.clientcode
from
(
select c.clientcode, max(b.statusdate) as LastDate
from user_breeding b
inner join user_ownership o on o.horseid = b.horseid
inner join user_client c on o.clientid = c.clientid
group by c.clientcode

union

select c.clientcode, max(b.foalingdate)
from user_breeding b
inner join user_ownership o on o.horseid = b.horseid
inner join user_client c on o.clientid = c.clientid
group by c.clientcode

union

select c.clientcode, max(b.statusdate)
from user_breeding b
inner join user_ownership o on o.horseid = b.stallionid
inner join user_client c on o.clientid = c.clientid
group by c.clientcode

union

select c.clientcode, max(b.foalingdate)
from user_breeding b
inner join user_ownership o on o.horseid = b.stallionid
inner join user_client c on o.clientid = c.clientid
group by c.clientcode

union

select c.clientcode, max(s.showdate)
from user_show s
inner join user_ownership o on o.horseid = s.horseid
inner join user_client c on o.clientid = c.clientid
group by c.clientcode

union

select clientcode, max(date)
from user_clientmisc m
inner join user_client c on c.clientid = m.clientid
group by c.clientcode

union

select clientcode, max(paymentdate)
from user_clientpayment p
inner join user_client c on c.clientid = p.clientid
group by c.clientcode

union

select c.clientcode, max(serviceDate)
from user_service s
inner join user_ownership o on o.horseid = s.horseid
inner join user_client c on c.clientid = o.clientid
group by c.clientcode

union

select c.clientcode, max(m.enddate)
from user_maintenanceboarding m
inner join user_ownership o on o.horseid = m.horseid
inner join user_client c on c.clientid = o.clientid
group by c.clientcode

) x
where x.LastDate > dateadd(yy,-1,getdate())

) x2

) r ON r.clientcode = l.clientcode
LEFT OUTER JOIN 
	user_Contact c ON l.ContactID = c.ContactID
LEFT OUTER JOIN 
	base_Lookup LUState ON c.StateID = LUState.LookupID
LEFT OUTER JOIN 
	base_Lookup LUCountry ON c.CountryID = LUCountry.LookupID
ORDER BY l.ClientCode
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Client_UpdateCurrentPeriod]    Script Date: 10/25/2020 11:13:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_user_Client_UpdateCurrentPeriod]
(
@endDate datetime
)
AS

DECLARE @lastStatementDate datetime
set @lastStatementDate = (Select [StatementDate] from [user_Statement] WHERE [Statement] = 'LAST')


UPDATE user_client
SET
	LastCurrent = c.[Current],
	LastPeriod1 = c.[Period1],
	LastPeriod2 = c.[Period2],
	LastPeriod3 = c.[Period3],
	[Current] = (isnull(new.Charges,0) - dbo.fnPositive(isnull(new.Payments,0) - isnull(c.Period2,0) - isnull(c.Period3,0) - isnull(c.Period1,0) - isnull(c.[Current],0))),
	[Period1] = dbo.fnPositive(isnull(c.[Current],0) - dbo.fnPositive(isnull(new.Payments,0) - isnull(c.Period2,0) - isnull(c.Period3,0) - isnull(c.Period1,0))),
	[Period2] = dbo.fnPositive(isnull(c.Period1,0) - dbo.fnPositive(isnull(new.Payments,0) - isnull(c.Period2,0) - isnull(c.Period3,0))),
	[Period3] = dbo.fnPositive(isnull(c.Period2,0) + isnull(c.Period3,0) - isnull(new.Payments,0)),
	LastBreedCurrent = c.[BreedCurrent],
	LastBreedPeriod1 = c.[BreedPeriod1],
	LastBreedPeriod2 = c.[BreedPeriod2],
	LastBreedPeriod3 = c.[BreedPeriod3],
	[BreedCurrent] = (isnull(new.BreedCharges,0) - dbo.fnPositive(isnull(new.BreedPayments,0) - isnull(c.BreedPeriod2,0) - isnull(c.BreedPeriod3,0) - isnull(c.BreedPeriod1,0) - isnull(c.[BreedCurrent],0))),
	[BreedPeriod1] = dbo.fnPositive(isnull(c.[BreedCurrent],0) - dbo.fnPositive(isnull(new.BreedPayments,0) - isnull(c.BreedPeriod2,0) - isnull(c.BreedPeriod3,0) - isnull(c.BreedPeriod1,0))),
	[BreedPeriod2] = dbo.fnPositive(isnull(c.BreedPeriod1,0) - dbo.fnPositive(isnull(new.BreedPayments,0) - isnull(c.BreedPeriod2,0) - isnull(c.BreedPeriod3,0))),
	[BreedPeriod3] = dbo.fnPositive(isnull(c.BreedPeriod2,0) + isnull(c.BreedPeriod3,0) - isnull(new.BreedPayments,0)),
	LastSaleCurrent = c.[SaleCurrent],
	LastSalePeriod1 = c.[SalePeriod1],
	LastSalePeriod2 = c.[SalePeriod2],
	LastSalePeriod3 = c.[SalePeriod3],
	[SaleCurrent] = (isnull(new.SaleCharges,0) - dbo.fnPositive(isnull(new.SalePayments,0) - isnull(c.SalePeriod2,0) - isnull(c.SalePeriod3,0) - isnull(c.SalePeriod1,0) - isnull(c.[SaleCurrent],0))),
	[SalePeriod1] = dbo.fnPositive(isnull(c.[SaleCurrent],0) - dbo.fnPositive(isnull(new.SalePayments,0) - isnull(c.SalePeriod2,0) - isnull(c.SalePeriod3,0) - isnull(c.SalePeriod1,0))),
	[SalePeriod2] = dbo.fnPositive(isnull(c.SalePeriod1,0) - dbo.fnPositive(isnull(new.SalePayments,0) - isnull(c.SalePeriod2,0) - isnull(c.SalePeriod3,0))),
	[SalePeriod3] = dbo.fnPositive(isnull(c.SalePeriod2,0) + isnull(c.SalePeriod3,0) - isnull(new.SalePayments,0)),
	LastTransCurrent = c.[TransCurrent],
	LastTransPeriod1 = c.[TransPeriod1],
	LastTransPeriod2 = c.[TransPeriod2],
	LastTransPeriod3 = c.[TransPeriod3],
	[TransCurrent] = (isnull(new.TransCharges,0) - dbo.fnPositive(isnull(new.TransPayments,0) - isnull(c.TransPeriod2,0) - isnull(c.TransPeriod3,0) - isnull(c.TransPeriod1,0) - isnull(c.[TransCurrent],0))),
	[TransPeriod1] = dbo.fnPositive(isnull(c.[TransCurrent],0) - dbo.fnPositive(isnull(new.TransPayments,0) - isnull(c.TransPeriod2,0) - isnull(c.TransPeriod3,0) - isnull(c.TransPeriod1,0))),
	[TransPeriod2] = dbo.fnPositive(isnull(c.TransPeriod1,0) - dbo.fnPositive(isnull(new.TransPayments,0) - isnull(c.TransPeriod2,0) - isnull(c.TransPeriod3,0))),
	[TransPeriod3] = dbo.fnPositive(isnull(c.TransPeriod2,0) + isnull(c.TransPeriod3,0) - isnull(new.TransPayments,0))
FROM user_client c
LEFT JOIN 
(

SELECT 
		base.ClientID, 
		SUM( CAST((base.Amount * base.Percentage + 0.5) as INT) ) / 100.0 AS Charges, 
		SUM( CAST((base.BreedAmount * base.Percentage + 0.5) as INT) ) / 100.0 AS BreedCharges, 
		SUM( CAST((base.SaleAmount * base.Percentage + 0.5) as INT) ) / 100.0 AS SaleCharges, 
		SUM( CAST((base.TransAmount * base.Percentage + 0.5) as INT) ) / 100.0 AS TransCharges, 
		SUM(Payment) AS Payments,
		SUM(BreedPayment) AS BreedPayments,
		SUM(SalePayment) AS SalePayments,
		SUM(TransPayment) AS TransPayments
		FROM
		(
			--
			-- PAYMENTS
			--
			select paymentid as uniqueid, c.ClientID, 100.00 as percentage, 0.00 as Amount, 0.00 as BreedAmount, 0.00 as SaleAmount, 0.00 as TransAmount, 
				p.PaymentDate as [Date], p.Amount as Payment, 0.00 as BreedPayment, 0.00 as SalePayment, 0.00 as TransPayment
			from user_clientpayment p
			inner join user_client c on c.clientid = p.clientid
			where not p.amount is null and p.PaymentDate <= @endDate and p.PaymentDate > @lastStatementDate
				and (c.SeparatePeriods=0 or not p.Account in ('BredSale', 'HorsSale', 'Trnsprt'))
			
			union
			
			select paymentid as uniqueid, c.ClientID, 100.00 as percentage, 0.00 as Amount, 0.00 as BreedAmount, 0.00 as SaleAmount, 0.00 as TransAmount, 
				p.PaymentDate as [Date], 0.00 as Payment, p.Amount as BreedPayment, 0.00 as SalePayment, 0.00 as TransPayment
			from user_clientpayment p
			inner join user_client c on c.clientid = p.clientid
			where not p.amount is null and p.PaymentDate <= @endDate and p.PaymentDate > @lastStatementDate
				and c.SeparatePeriods=1 and p.Account = 'BredSale'
			
			union

			select paymentid as uniqueid, c.ClientID, 100.00 as percentage, 0.00 as Amount, 0.00 as BreedAmount, 0.00 as SaleAmount, 0.00 as TransAmount, 
				p.PaymentDate as [Date], 0.00 as Payment, 0.00 as BreedPayment, p.Amount as SalePayment, 0.00 as TransPayment
			from user_clientpayment p
			inner join user_client c on c.clientid = p.clientid
			where not p.amount is null and p.PaymentDate <= @endDate and p.PaymentDate > @lastStatementDate
				and c.SeparatePeriods=1 and p.Account = 'HorsSale'
			
			union

			select paymentid as uniqueid, c.ClientID, 100.00 as percentage, 0.00 as Amount, 0.00 as BreedAmount, 0.00 as SaleAmount, 0.00 as TransAmount, 
				p.PaymentDate as [Date], 0.00 as Payment, 0.00 as BreedPayment, 0.00 as SalePayment, p.Amount as TransPayment
			from user_clientpayment p
			inner join user_client c on c.clientid = p.clientid
			where not p.amount is null and p.PaymentDate <= @endDate and p.PaymentDate > @lastStatementDate
				and c.SeparatePeriods=1 and p.Account = 'Trnsprt'
			
			union

			--
			-- CHARGES
			--
			
			--
			--BREEDING
			--
			select b.breedingid as uniqueid, c.ClientID as ClientID, o.percentage as Percentage, f.Cost as Amount, 0.00 as BreedAmount, 0.00 as SaleAmount, 0.00 as TransAmount, 
				f.DueDate as [Date], 0.00 as Payment, 0.00 as BreedPayment, 0.00 as SalePayment, 0.00 as TransPayment
			from user_breedingfee f
			inner join user_breeding b on b.breedingid = f.breedingid
			inner join user_ownership o on o.horseid = b.horseid
			inner join user_client c on c.clientid = o.clientid
			where f.DueDate <= @endDate and f.DueDate > @lastStatementDate
				and c.SeparatePeriods=0
			
			union
			
			select b.breedingid as uniqueid, c.ClientID as ClientID, o.percentage as Percentage, 0.00 as Amount, f.Cost as BreedAmount, 0.00 as SaleAmount, 0.00 as TransAmount, 
				f.DueDate as [Date], 0.00 as Payment, 0.00 as BreedPayment, 0.00 as SalePayment, 0.00 as TransPayment
			from user_breedingfee f
			inner join user_breeding b on b.breedingid = f.breedingid
			inner join user_ownership o on o.horseid = b.horseid
			inner join user_client c on c.clientid = o.clientid
			where f.DueDate <= @endDate and f.DueDate > @lastStatementDate
				and c.SeparatePeriods=1
			
			union
			
			--
			--MISC
			--
			select clientmiscid as uniqueid, c.ClientID, 100.00 as percentage, m.Amount, 0.00 as BreedAmount, 0.00 as SaleAmount, 0.00 as TransAmount, 
				m.Date, 0.00 as Payment, 0.00 as BreedPayment, 0.00 as SalePayment, 0.00 as TransPayment
			from user_clientmisc m
			inner join user_client c on c.clientid = m.clientid
			where m.Date <= @endDate and m.Date > @lastStatementDate and not m.Amount is null
				and (c.SeparatePeriods=0 or not m.Account in ('BredSale', 'HorsSale', 'Trnsprt'))
			
			union
			
			select clientmiscid as uniqueid, c.ClientID, 100.00 as percentage, 0.00 as Amount, m.Amount as BreedAmount, 0.00 as SaleAmount, 0.00 as TransAmount, 
				m.Date, 0.00 as Payment, 0.00 as BreedPayment, 0.00 as SalePayment, 0.00 as TransPayment
			from user_clientmisc m
			inner join user_client c on c.clientid = m.clientid
			where m.Date <= @endDate and m.Date > @lastStatementDate and not m.Amount is null
				and c.SeparatePeriods=1 and m.Account = 'BredSale'
			
			union
			
			select clientmiscid as uniqueid, c.ClientID, 100.00 as percentage, 0.00 as Amount, 0.00 as BreedAmount, m.Amount as SaleAmount, 0.00 as TransAmount, 
				m.Date, 0.00 as Payment, 0.00 as BreedPayment, 0.00 as SalePayment, 0.00 as TransPayment
			from user_clientmisc m
			inner join user_client c on c.clientid = m.clientid
			where m.Date <= @endDate and m.Date > @lastStatementDate and not m.Amount is null
				and c.SeparatePeriods=1 and m.Account = 'HorsSale'
			
			union
			
			select clientmiscid as uniqueid, c.ClientID, 100.00 as percentage, 0.00 as Amount, 0.00 as BreedAmount, 0.00 as SaleAmount, m.Amount as TransAmount, 
				m.Date, 0.00 as Payment, 0.00 as BreedPayment, 0.00 as SalePayment, 0.00 as TransPayment
			from user_clientmisc m
			inner join user_client c on c.clientid = m.clientid
			where m.Date <= @endDate and m.Date > @lastStatementDate and not m.Amount is null
				and c.SeparatePeriods=1 and m.Account = 'Trnsprt'
			
			union
			
			--
			--BOARDING
			--
			SELECT base.boardingid as uniqueid, c.ClientID, o.percentage, 
				CASE WHEN base.TimeUnit = 'D' THEN
					CAST((base.RelativeEndDate - base.RelativeBeginDate)+1 as INT)*base.Rate
				     WHEN base.TimeUnit = 'M' THEN
		base.Rate * Months + CAST(((base.Rate * DaysBefore * 100 / DaysInMonthBefore) +
						(base.Rate * DaysAfter * 100 / DaysInMonthAfter) +
						(base.Rate * DaysDuring * 100 / DaysInMonth) +
						0.5) as INT) / 100.0
				END AS Amount, 0.00 as BreedAmount, 0.00 as SaleAmount, 0.00 as TransAmount, 
				base.RelativeEndDate as [Date], 0.00 as Payment, 0.00 as BreedPayment, 0.00 as SalePayment, 0.00 as TransPayment
			FROM
(SELECT b3.boardingid, b3.HorseID, b3.TimeUnit, b3.Rate, 
	CASE WHEN DateDiff(m, b3.BeginFirstFullMonth, b3.DayAfterLastFullMonth) > 0 THEN DateDiff(m, b3.BeginFirstFullMonth, b3.DayAfterLastFullMonth) ELSE 0 END as Months,
	CASE WHEN DateDiff(m, b3.BeginFirstFullMonth, b3.DayAfterLastFullMonth) > 0 THEN DateDiff(d, b3.RelativeBeginDate, b3.BeginFirstFullMonth) ELSE 0 END as DaysBefore,
	CASE WHEN DateDiff(m, b3.BeginFirstFullMonth, b3.DayAfterLastFullMonth) > 0 THEN DateDiff(d, b3.DayAfterLastFullMonth, b3.RelativeEndDate)+1 ELSE 0 END as DaysAfter,
	CASE WHEN DateDiff(m, b3.BeginFirstFullMonth, b3.DayAfterLastFullMonth) <= 0 THEN DateDiff(d, b3.RelativeBeginDate, b3.RelativeEndDate)+1 ELSE 0 END as DaysDuring,
	day(DateAdd(d, -1, b3.BeginFirstFullMonth)) as DaysInMonthBefore,
	day(DateAdd(d, -1, DateAdd(m, 1, b3.DayAfterLastFullMonth))) as DaysInMonthAfter,
	CASE WHEN DateDiff(m, b3.BeginFirstFullMonth, b3.DayAfterLastFullMonth) > 0 THEN day(DateAdd(d, -1, b3.DayAfterLastFullMonth)) WHEN b3.BeginFirstFullMonth > b3.RelativeEndDate THEN day(DateAdd(d, -1, b3.BeginFirstFullMonth)) ELSE day(DateAdd(d, -1, DateAdd(m, 1, b3.DayAfterLastFullMonth))) END as DaysInMonth,
				b3.RelativeBeginDate, 
				b3.RelativeEndDate
			FROM
(SELECT b2.boardingid, b2.HorseID, b2.TimeUnit, b2.Rate,
				b2.RelativeBeginDate, 
				b2.RelativeEndDate, 
				CASE WHEN day(b2.RelativeBeginDate) = 1 THEN
					cast(cast(month(b2.RelativeBeginDate) as varchar(2)) + '/01/' + cast(year(b2.RelativeBeginDate) as varchar(4)) + ' 0:00:000' as datetime)
				     ELSE
					cast(cast(month(DateAdd(m,1,b2.RelativeBeginDate)) as varchar(2)) + '/01/' + cast(year(DateAdd(m,1,b2.RelativeBeginDate)) as varchar(4)) + ' 0:00:000' as datetime)
				END as BeginFirstFullMonth, 
	CASE WHEN month(b2.RelativeEndDate) = month(DateAdd(d,1,b2.RelativeEndDate)) THEN
		cast(cast(month(b2.RelativeEndDate) as varchar(2)) + '/01/' + cast(year(b2.RelativeEndDate) as varchar(4)) + ' 0:00:00' as datetime)
	ELSE
		cast(cast(month(DateAdd(d,1,b2.RelativeEndDate)) as varchar(2)) + '/01/' + cast(year(DateAdd(d,1,b2.RelativeEndDate)) as varchar(4)) + ' 0:00:000' as datetime)
	END as DayAfterLastFullMonth
			FROM
(SELECT b.boardingid, b.HorseID, b.TimeUnit, b.Rate,
			   CASE WHEN b.enddate <= @EndDate THEN b.enddate ELSE @EndDate END as RelativeEndDate,
   CASE WHEN b.begindate > @lastStatementDate THEN b.begindate ELSE dateadd(d,1,@lastStatementDate) END as RelativeBeginDate,
			   b.begindate,
			   b.enddate
			FROM user_maintenanceboarding b
WHERE b.begindate <= @EndDate and b.endDate > @lastStatementDate
) b2) b3) base
			INNER JOIN user_ownership o ON o.horseid = base.horseid
			INNER JOIN user_client c on c.clientid = o.clientid
			
			union
			
			--
			--SERVICES
			--
			SELECT serviceid as uniqueid, c.ClientID, o.percentage, s.Cost as Amount, 0.00 as BreedAmount, 0.00 as SaleAmount, 0.00 as TransAmount, 
				s.ServiceDate as [Date], 0.00 as Payment, 0.00 as BreedPayment, 0.00 as SalePayment, 0.00 as TransPayment
			FROM user_service s
			INNER JOIN user_ownership o on o.horseid = s.horseid
			INNER JOIN user_client c on c.clientid = o.clientid
			WHERE s.ServiceDate <= @endDate and s.ServiceDate > @lastStatementDate and not s.Cost is NULL
			
			union
			
			--
			--SHOW
			--
			SELECT showid as uniqueid, c.ClientID, o.percentage, isnull(DayRate,0)+isnull(Transport,0)+isnull(Equipment,0)+isnull(Handling,0)+isnull(ProRata,0)+isnull(Grooming,0)+isnull(EntryFees,0)+isnull(Miscellaneous,0) as Amount, 
				0.00 as BreedAmount, 0.00 as SaleAmount, 0.00 as TransAmount, 
				s.ShowDate as [Date], 0.00 as Payment, 0.00 as BreedPayment, 0.00 as SalePayment, 0.00 as TransPayment
			FROM user_show s
			INNER JOIN user_ownership o on o.horseid = s.horseid
			INNER JOIN user_client c on c.clientid = o.clientid
			WHERE s.ShowDate <= @endDate and s.ShowDate > @lastStatementDate
		) base
		GROUP BY base.ClientID
) new ON new.ClientID = c.ClientID

-- Move the Last Statement Date into the Prior
UPDATE user_Statement
SET StatementDate = @lastStatementDate, UpdateTimestamp = getdate()
WHERE Statement = 'PRIOR'

-- Set the New Last Statement Date
UPDATE user_Statement
SET StatementDate = @EndDate, UpdateTimestamp = getdate()
WHERE Statement = 'LAST'
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Service_Delete]    Script Date: 10/25/2020 11:13:54 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_Service_Delete]
	@ServiceID			uniqueidentifier

AS

DELETE
FROM user_Service
WHERE ServiceID = @ServiceID
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Service_Insert_Or_Update]    Script Date: 10/25/2020 11:13:55 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_user_Service_Insert_Or_Update]
             @ServiceID                            uniqueidentifier
            ,@HorseID                              uniqueidentifier
            ,@ServiceTypeID                    uniqueidentifier
            ,@ServiceDate                       datetime
            ,@Cost                                    numeric(18,2)
            ,@Notes                                  nvarchar(50)
            ,@Account                               nvarchar(8)
            ,@Comments                           ntext
            ,@LocalID                               uniqueidentifier
            ,@NewServiceID                     uniqueidentifier              OUTPUT

 ,@UpdateUser varchar(120) = null, @UpdateTimestamp DateTime = null, @NewUpdateUser varchar(120)

AS

IF @ServiceID IS NULL
BEGIN

            SELECT @NewServiceID = newid()


            INSERT INTO user_Service(ServiceID, HorseID, ServiceTypeID, ServiceDate, Cost, Notes, Account, Comments, LocalID, UpdateUser, UpdateTimestamp)
            VALUES(@NewServiceID, @HorseID, @ServiceTypeID, @ServiceDate, @Cost, @Notes, @Account, @Comments, @LocalID, @UpdateUser, @UpdateTimestamp)

END
ELSE
BEGIN

            UPDATE user_Service
            SET ServiceDate = @ServiceDate, Cost = @Cost, Notes = @Notes, Account = @Account,
                     Comments = @Comments, LocalID = @LocalID,
                     UpdateUser = @NewUpdateUser, UpdateTimestamp = GETDATE()
            WHERE ServiceID = @ServiceID
			AND (UpdateUser = @UpdateUser AND UpdateTimestamp = @UpdateTimestamp)
 
	--Check For Concurrency Error
	IF (@@ROWCOUNT = 0) 
	BEGIN
		RAISERROR(52025, 16, 1)
	END

            SET @NewServiceID = @ServiceID

END
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Service_Update_ContactID]    Script Date: 10/25/2020 11:13:55 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_Service_Update_ContactID]
	 @ServiceID		uniqueidentifier
	,@ContactID		uniqueidentifier

AS

UPDATE user_Service
SET ContactID = @ContactID
WHERE ServiceID = @ServiceID
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Service_GetByID]    Script Date: 10/25/2020 11:13:54 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_Service_GetByID]

            @ServiceID                             uniqueidentifier

 

AS

 

DECLARE @ContactID uniqueidentifier

 

SELECT @ContactID = s.ContactID

FROM user_Service s

WHERE ServiceID = @ServiceID

 

SELECT s.ServiceID, s.HorseID, s.ServiceTypeID, LookupDescription.LookupDescription AS ServiceTypeDescription, 

            s.ContactID, s.ServiceDate, s.Cost, s.Notes, s.Account, s.Comments
,s.UpdateUser, s.UpdateTimestamp
FROM user_Service s

JOIN base_Lookup LookupDescription ON s.ServiceTypeID = LookupDescription.LookupID

WHERE ServiceID = @ServiceID

 

EXEC usp_user_Contact_GetByID @ContactID
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Service_GetListForHorse]    Script Date: 10/25/2020 11:13:54 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_user_Service_GetListForHorse]

             @ServiceTypeID                                uniqueidentifier
            ,@HorseID                                          uniqueidentifier

AS

SELECT s.ServiceID, s.HorseID, s.ServiceTypeID, lookup.LookupDescription AS ServiceTypeDescription, s.ContactID,
            contact.Name AS ContactName, s.ServiceDate, s.Cost, s.Notes, s.Account, s.Comments, s.LocalID, l.LookupAbrv as LocalAbrv,
            s.UpdateUser, s.UpdateTimestamp
FROM user_Service s
INNER JOIN base_Lookup lookup ON s.ServiceTypeID = lookup.LookupID
LEFT OUTER JOIN base_Lookup l on s.LocalID = l.LookupID
LEFT OUTER JOIN user_Contact contact ON s.ContactID = contact.ContactID
WHERE s.ServiceTypeID = @ServiceTypeID AND s.HorseID = @HorseID
ORDER BY s.ServiceDate DESC, s.Notes
GO
/****** Object:  StoredProcedure [dbo].[usp_user_HasPagePermission]    Script Date: 10/25/2020 11:13:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_user_HasPagePermission]
(
	@Username nvarchar(120),
	@Pagename nvarchar(80)
)
AS
BEGIN

	DECLARE 
		@UserLevel int, 
		@PageLevel int

	SELECT
		@UserLevel = ISNULL(AdminLevel, 0)
	FROM
		user_Users
	WHERE
		Username = @Username

	SELECT
		@PageLevel = ISNULL(AdminLevel, @UserLevel - 10)
	FROM
		user_Security
	WHERE
		PageName = @Pagename

	SELECT
		"HasPermission" = CASE
			WHEN (@UserLevel <= @PageLevel) THEN 1
			ELSE 0
		END

END
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Users_GetUserByID]    Script Date: 10/25/2020 11:13:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_user_Users_GetUserByID]
(
	@UserID uniqueidentifier
)
AS
BEGIN

	SELECT
		u.UserID, 
		u.AdminLevel, 
		u.Username,
		ISNULL(a.AdminName, '') as "AdminLevelName",
		u.UpdateUser,
		u.UpdateTimestamp
	FROM
		user_Users u 
			LEFT JOIN user_Admin a ON
				u.AdminLevel = a.AdminLevel
	WHERE
		UserID = @UserID

END
GO
/****** Object:  StoredProcedure [dbo].[usp_user_GetUsers]    Script Date: 10/25/2020 11:13:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_user_GetUsers]
AS
BEGIN

	SELECT
		u.UserID, 
		u.AdminLevel, 
		u.Username,
		ISNULL(a.AdminName, '') as "AdminLevelName"
		,u.UpdateUser, u.UpdateTimestamp
	FROM
		user_Users u 
			LEFT JOIN user_Admin a ON
				u.AdminLevel = a.AdminLevel

END
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Admin_GetAll]    Script Date: 10/25/2020 11:13:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_user_Admin_GetAll]
AS
BEGIN

	SELECT
		AdminID, 
		AdminLevel, 
		AdminName, 
		AdminDescription
		,UpdateUser, UpdateTimestamp
	FROM
		user_Admin
	ORDER BY
		AdminLevel DESC

END
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Maintenance_Update]    Script Date: 10/25/2020 11:13:50 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_Maintenance_Update]
             @HorseID                              uniqueidentifier
            ,@Location                              nvarchar(50)
            ,@Insurance                             nvarchar(50)
            ,@InsurancePhone                   nvarchar(25)
            ,@Handler                               nvarchar(25)
            ,@Trainer                                 nvarchar(25)
            ,@NextVet                              datetime
            ,@NextFarrier                          datetime
            ,@Note1                                  nvarchar(60)
            ,@Note2                                  nvarchar(60)
            ,@BandNumber                                   nvarchar(10)
            ,@Comments                           ntext
,@UpdateUser varchar(120) = null, @UpdateTimestamp DateTime = null, @NewUpdateUser varchar(120)

AS

IF NOT EXISTS ( select 1 from user_maintenance where horseid = @horseid )
BEGIN
	INSERT INTO user_Maintenance (HorseID, UpdateUser, UpdateTimestamp) VALUES (@HorseID, @UpdateUser, @UpdateTimestamp)
END 

UPDATE user_Maintenance
SET Location = @Location, Insurance = @Insurance, InsurancePhone = @InsurancePhone,
            Handler = @Handler, Trainer = @Trainer, NextVet = @NextVet, NextFarrier = @NextFarrier,
            Note1 = @Note1, Note2 = @Note2, BandNumber = @BandNumber, Comments = @Comments, UpdateUser = @NewUpdateUser, UpdateTimestamp = GETDATE()
WHERE HorseID = @HorseID
AND (UpdateUser = @UpdateUser AND UpdateTimestamp = @UpdateTimestamp)

--Check For Concurrency Error
IF (@@ROWCOUNT = 0) 
BEGIN
	RAISERROR(52025, 16, 1)
END
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Users_InsertOrUpdate]    Script Date: 10/25/2020 11:14:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_user_Users_InsertOrUpdate]
(
	@UserID uniqueidentifier, 
	@AdminLevel int, 
	@Username varchar(120),
	@NewUserID uniqueidentifier output
	,@UpdateUser varchar(120) = null, @UpdateTimestamp DateTime = null, @NewUpdateUser varchar(120)
)
AS
BEGIN

	IF @UserID IS NULL
	BEGIN

		SET @NewUserID = newid()

		INSERT INTO user_Users(
			UserID, 
			AdminLevel, 
			Username,
			UpdateUser,
			UpdateTimestamp
		)
		VALUES(
			@NewUserID, 
			@AdminLevel, 
			@Username,
			@UpdateUser,
			@UpdateTimestamp
		)

	END
	ELSE
	BEGIN

		UPDATE user_Users SET 
			AdminLevel = @AdminLevel,
			Username = @Username
			, UpdateUser = @NewUpdateUser, UpdateTimestamp = GETDATE()
		WHERE 
			UserID = @UserID
			AND (UpdateUser = @UpdateUser AND UpdateTimestamp = @UpdateTimestamp)

		--Check For Concurrency Error
		IF (@@ROWCOUNT = 0) 
		BEGIN
			RAISERROR(52025, 16, 1)
		END

		SET @NewUserID = @UserID

	END
	

END
GO
/****** Object:  StoredProcedure [dbo].[user_Users_Delete]    Script Date: 10/25/2020 11:13:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[user_Users_Delete]
(
	@UserID uniqueidentifier
)
AS
BEGIN

	DELETE FROM user_Users WHERE UserID = @UserID

END
GO
/****** Object:  StoredProcedure [dbo].[usp_user_MaintenanceFeeding_Add_Or_Update]    Script Date: 10/25/2020 11:13:52 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_user_MaintenanceFeeding_Add_Or_Update]

             @FeedingID                           uniqueidentifier

            ,@HorseID                              uniqueidentifier

            ,@FeedTime                            nvarchar(8)

            ,@Feed                                                nvarchar(15)

            ,@FeedQuantity                                   numeric(18,1)

            ,@Hay                                     nvarchar(10)

            ,@HayQuantity                                    numeric(18,1)

            ,@Notes                                  nvarchar(25)

 ,@UpdateUser varchar(120) = null, @UpdateTimestamp DateTime = null, @NewUpdateUser varchar(120)

AS

 

IF @FeedingID IS NULL

            INSERT INTO user_MaintenanceFeeding(HorseID, FeedTime, Feed, FeedQuantity, Hay, HayQuantity, Notes, UpdateUser, UpdateTimestamp)

            VALUES(@HorseID, @FeedTime, @Feed, @FeedQuantity, @Hay, @HayQuantity, @Notes, @UpdateUser, @UpdateTimestamp)

ELSE

            UPDATE user_MaintenanceFeeding

            SET FeedTime = @FeedTime, Feed = @Feed, FeedQuantity = @FeedQuantity, Hay = @Hay,

                        HayQuantity = @HayQuantity, Notes = @Notes, UpdateUser = @NewUpdateUser, UpdateTimestamp = GETDATE()

            WHERE FeedingID = @FeedingID
			AND (UpdateUser = @UpdateUser AND UpdateTimestamp = @UpdateTimestamp)

			--Check For Concurrency Error
			IF (@@ROWCOUNT = 0) 
			BEGIN
				RAISERROR(52025, 16, 1)
			END
GO
/****** Object:  StoredProcedure [dbo].[usp_user_MaintenanceFeeding_GetByHorseID]    Script Date: 10/25/2020 11:13:52 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_user_MaintenanceFeeding_GetByHorseID]

            @HorseID                               uniqueidentifier

 

AS

 

SELECT FeedingID, HorseID, FeedTime, Feed, FeedQuantity, Hay, HayQuantity, Notes
,UpdateUser, UpdateTimestamp
FROM user_MaintenanceFeeding

WHERE HorseID = @HorseID

ORDER BY FeedTime, Feed
GO
/****** Object:  StoredProcedure [dbo].[usp_user_MaintenanceFeeding_GetByFeedingID]    Script Date: 10/25/2020 11:13:52 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_user_MaintenanceFeeding_GetByFeedingID]

            @FeedingID                            uniqueidentifier

 

AS

 

SELECT FeedingID, HorseID, FeedTime, Feed, FeedQuantity, Hay, HayQuantity, Notes
,UpdateUser, UpdateTimestamp
FROM user_MaintenanceFeeding

WHERE FeedingID = @FeedingID
GO
/****** Object:  StoredProcedure [dbo].[usp_user_MaintenanceFeeding_Delete]    Script Date: 10/25/2020 11:13:52 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_MaintenanceFeeding_Delete]
	@FeedingID			uniqueidentifier

AS

DELETE
FROM user_MaintenanceFeeding
WHERE FeedingID = @FeedingID
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Breeding_Delete]    Script Date: 10/25/2020 11:13:24 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_Breeding_Delete]
(
	@BreedingID uniqueidentifier 
)
AS
BEGIN

	DELETE FROM user_BreedingCalendar WHERE BreedingID = @BreedingID
	DELETE FROM user_Breeding WHERE BreedingID = @BreedingID

END
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Breeding_InsertOrUpdate]    Script Date: 10/25/2020 11:13:26 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_Breeding_InsertOrUpdate]
(
	@BreedingID uniqueidentifier = null, 
	@HorseID uniqueidentifier, 
	@StallionID uniqueidentifier, 
	@DateOpened datetime, 
	@DateClosed datetime, 
	@Fee numeric(18,2), 
	@Gestation numeric(18,0), 
	@FoalingDate datetime, 
	@BreedingLocation nvarchar(50), 
	@Status char(1), 
	@StatusDate datetime, 
	@Comments ntext, 
	@ReservationDate datetime,
	@NewBreedingID uniqueidentifier output
,@UpdateUser varchar(120) = null, @UpdateTimestamp DateTime = null, @NewUpdateUser varchar(120)
)
AS
BEGIN

	if (@BreedingID IS NULL)
	BEGIN

		Set @NewBreedingID = NewID()

		INSERT INTO user_Breeding 
		(
			BreedingID, 
			HorseID, 
			StallionID, 
			DateOpened, 
			DateClosed, 
			Fee, 
			Gestation, 
			FoalingDate, 
			BreedingLocation, 
			Status, 
			StatusDate, 
			Comments, 
			ReservationDate
			, UpdateUser, UpdateTimestamp
		)
		VALUES 
		(
			@NewBreedingID, 
			@HorseID, 
			@StallionID, 
			@DateOpened, 
			@DateClosed, 
			@Fee, 
			@Gestation, 
			@FoalingDate, 
			@BreedingLocation, 
			@Status, 
			@StatusDate, 
			@Comments, 
			@ReservationDate
			, @UpdateUser, @UpdateTimestamp
		)

	END
	ELSE
	BEGIN

		UPDATE user_Breeding SET
			HorseID = @HorseID, 
			StallionID = @StallionID, 
			DateOpened = @DateOpened, 
			DateClosed = @DateClosed, 
			Fee = @Fee, 
			Gestation = @Gestation, 
			FoalingDate = @FoalingDate, 
			BreedingLocation = @BreedingLocation, 
			Status = @Status, 
			StatusDate = @StatusDate, 
			Comments = @Comments, 
			ReservationDate = @ReservationDate
			, UpdateUser = @NewUpdateUser, UpdateTimestamp = GETDATE()
		WHERE
			BreedingID = @BreedingID
			AND (UpdateUser = @UpdateUser AND UpdateTimestamp = @UpdateTimestamp)

		--Check For Concurrency Error
		IF (@@ROWCOUNT = 0) 
		BEGIN
			RAISERROR(52025, 16, 1)
		END


		SET @NewBreedingID = @BreedingID

		IF (@DateClosed IS NOT NULL)
		BEGIN
			
			-- Now testing + or *
			DECLARE @HasPlusOrF bit
			SET @HasPlusOrF = 0

			SELECT TOP 1
				@HasPlusOrF = 1
			FROM
				user_breedingcalendar
			WHERE
				BreedingID = @BreedingID
				AND (
					(CHARINDEX("+", Codes) > 0)
					OR (CHARINDEX("*", Codes) > 0)
				)

			IF EXISTS(SELECT 1 FROM user_breedingcalendar WHERE
				BreedingID = @BreedingID AND (CHARINDEX("F", Codes) > 0)
				)
			BEGIN
				SET @HasPlusOrF = 0
			END

			IF (@HasPlusOrF = 1)
			BEGIN
				UPDATE user_Breeding SET
					Status = "*",
					StatusDate = @DateClosed
				WHERE
					BreedingID = @BreedingID
			END

		END

	END

END
GO
/****** Object:  StoredProcedure [dbo].[usp_user_BreedingEntry_Delete]    Script Date: 10/25/2020 11:13:26 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_BreedingEntry_Delete]
(
	@EntryID uniqueidentifier
)
AS
BEGIN

	DELETE
	FROM 
		user_BreedingCalendar
	WHERE 
		BreedingCalendarID = @EntryID

END
GO
/****** Object:  StoredProcedure [dbo].[usp_user_BreedingEntry_GetByID]    Script Date: 10/25/2020 11:13:26 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_BreedingEntry_GetByID]
(
	@EntryID uniqueidentifier
)
AS
BEGIN

	--get the breeding entry
	SELECT 
		BreedingCalendarID AS "EntryID", 
		BreedingID, 
		Date AS "EntryDate", 
		Codes AS "EntryCodes", 
		Note1 AS "EntryNote1", 
		Note2 AS "EntryNote2", 
		Note3 AS "EntryNote3", 
		Note4 AS "EntryNote4", 
		Note5 AS "EntryNote5", 
		Comments AS "EntryComments"
		,UpdateUser, UpdateTimestamp
	FROM 
		user_BreedingCalendar
	WHERE 
		BreedingCalendarID = @EntryID

END
GO
/****** Object:  StoredProcedure [dbo].[usp_user_BreedingEntry_UpdateBreedingStatus]    Script Date: 10/25/2020 11:13:27 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_BreedingEntry_UpdateBreedingStatus]
(
	@BreedingID uniqueidentifier,
	@EntryCodes char(5),
	@EntryDate DateTime
)
AS
BEGIN

	DECLARE 
		@CurDate DateTime,
		@PrevDate DateTime,
		@Processed bit

	--check for "F" for Foaled
	IF (CHARINDEX("F", @EntryCodes) > 0)
	BEGIN
		--foaled... update breeding record
		UPDATE user_Breeding SET
			Status = "F",
			FoalingDate = @EntryDate,
			StatusDate = @EntryDate
		WHERE
			BreedingID = @BreedingID
	END

	--check for "+" for positive pregnancy test
	IF (CHARINDEX("+", @EntryCodes) > 0)
	BEGIN
		--get foaling date
		SELECT TOP 1
			@PrevDate = ISNULL(Date, @EntryDate)
		FROM
			user_BreedingCalendar
		WHERE
			((CHARINDEX("I", Codes) > 0)
			OR (CHARINDEX("N", Codes) > 0))
			AND BreedingID = @BreedingID
		ORDER BY 
			Date DESC

		--add gestation to get foaling date
		SELECT 
			@CurDate = DATEADD(day, Gestation, @PrevDate)
		FROM
			user_Breeding
		WHERE
			BreedingID = @BreedingID

		--update the breeding entry
		UPDATE user_Breeding SET
			Status = "D",
			StatusDate = @EntryDate,
			FoalingDate = @CurDate
		WHERE
			BreedingID = @BreedingID
	END

	--check for negative pregnancy check
	IF (CHARINDEX("-", @EntryCodes) > 0)
	BEGIN
		UPDATE user_Breeding SET
			Status = "-",
			FoalingDate = NULL,
			StatusDate = @EntryDate
		WHERE
			BreedingID = @BreedingID
	END

	--check for mare not pregnant
	IF (CHARINDEX("*", @EntryCodes) > 0)
	BEGIN
		UPDATE user_Breeding SET
			Status = "*",
			FoalingDate = NULL,
			StatusDate = @EntryDate
		WHERE
			BreedingID = @BreedingID
	END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Horse_AmortizedCharge_Insert]    Script Date: 10/25/2020 11:13:38 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_user_Horse_AmortizedCharge_Insert]
(
@RecordID uniqueidentifier,
@ChargeDate datetime,
@Principal numeric(18,2),
@Interest numeric(18,2),
@UpdateUser nvarchar(120),
@UpdateTimestamp datetime,
@NewUpdateUser nvarchar(120)
)
AS

INSERT INTO user_AmortizedCharge (ReferenceID, ChargeDate, Principal, Interest, UpdateUser, UpdateTimestamp)
VALUES (@RecordID, @ChargeDate, @Principal, @Interest, @UpdateUser, @UpdateTimestamp)
GO
/****** Object:  StoredProcedure [dbo].[usp_user_horse_sale_update]    Script Date: 10/25/2020 11:13:48 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_horse_sale_update]
(
@RecordID uniqueidentifier,
@Notes nvarchar(50),
@Comments ntext,
@CancelRemaining bit,
@UpdateUser nvarchar(120),
@UpdateTimestamp datetime, @NewUpdateUser varchar(120)
)
AS

DECLARE @LastStatementDate datetime

BEGIN TRANSACTION

UPDATE user_HorseSale 
SET Notes = @Notes, Comments = @Comments, UpdateUser = @NewUpdateUser, UpdateTimestamp = GETDATE()
WHERE HorseSaleID = @RecordID
AND (UpdateUser = @UpdateUser AND UpdateTimestamp = @UpdateTimestamp)

--Check For Concurrency Error
IF (@@ROWCOUNT = 0) 
BEGIN
	RAISERROR(52025, 16, 1)
END

IF (@CancelRemaining = 1)
BEGIN

	SELECT @LastStatementDate = StatementDate from user_Statement where Statement = 'LAST'

	DELETE FROM user_AmortizedCharge WHERE ReferenceID = @RecordID and ChargeDate > @LastStatementDate

END

COMMIT
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Horse_Sale_GetByID]    Script Date: 10/25/2020 11:13:47 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_user_Horse_Sale_GetByID]
            @HorseID                               uniqueidentifier,
            @SaleID uniqueidentifier
AS
 
SELECT * FROM user_HorseSale WHERE HorseID = @HorseID AND HorseSaleID = @SaleID

SELECT a.* FROM user_AmortizedCharge a INNER JOIN user_HorseSale h on h.HorseSaleID = a.ReferenceID WHERE h.HorseID = @HorseID AND h.HorseSaleID = @SaleID ORDER BY ChargeDate
GO
/****** Object:  StoredProcedure [dbo].[usp_user_horse_breeding_sale_update]    Script Date: 10/25/2020 11:13:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_user_horse_breeding_sale_update]
(
@RecordID uniqueidentifier,
@StallionID uniqueidentifier,
@Notes nvarchar(50),
@Comments ntext,
@CancelRemaining bit,
@UpdateUser nvarchar(120),
@UpdateTimestamp datetime, @NewUpdateUser varchar(120)
)
AS

DECLARE @LastStatementDate datetime

BEGIN TRANSACTION

UPDATE user_BreedingSale 
SET StallionID = @StallionID, Notes = @Notes, Comments = @Comments, UpdateUser = @NewUpdateUser, UpdateTimestamp = GETDATE()
WHERE BreedingSaleID = @RecordID
AND (UpdateUser = @UpdateUser AND UpdateTimestamp = @UpdateTimestamp)

--Check For Concurrency Error
IF (@@ROWCOUNT = 0) 
BEGIN
	RAISERROR(52025, 16, 1)
END

IF (@CancelRemaining = 1)
BEGIN

	SELECT @LastStatementDate = StatementDate from user_Statement where Statement = 'LAST'

	DELETE FROM user_AmortizedCharge WHERE ReferenceID = @RecordID and ChargeDate > @LastStatementDate

END

COMMIT
GO
/****** Object:  StoredProcedure [dbo].[usp_user_horse_breeding_sale_delete]    Script Date: 10/25/2020 11:13:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_user_horse_breeding_sale_delete]
(
@RecordID uniqueidentifier
)
AS

DELETE FROM user_AmortizedCharge WHERE ReferenceID = @RecordID

DELETE FROM user_BreedingSale WHERE BreedingSaleID = @RecordID
GO
/****** Object:  StoredProcedure [dbo].[usp_user_horse_sale_delete]    Script Date: 10/25/2020 11:13:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_user_horse_sale_delete]
(
@RecordID uniqueidentifier
)
AS

DELETE FROM user_AmortizedCharge WHERE ReferenceID = @RecordID

DELETE FROM user_HorseSale WHERE HorseSaleID = @RecordID
GO
/****** Object:  StoredProcedure [dbo].[usp_calc_HorseAgeCategory]    Script Date: 10/25/2020 11:13:21 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_calc_HorseAgeCategory]
	 @DateBorn		varchar(10)
	,@AgeCategory		varchar(50)	OUTPUT
AS

DECLARE @OffsetMonth	int
DECLARE @Weanling		int
DECLARE @Yearling		int
DECLARE @TwoYearOld	int
DECLARE @ThreeYearOld	int
DECLARE @FourYearOld	int
DECLARE @Adult		int

DECLARE @DaysOld		numeric

SELECT @OffsetMonth = OffsetMonth, @Weanling = Weanling, @Yearling = Yearling,
	@TwoYearOld = TwoYearOld, @ThreeYearOld = ThreeYearOld, @FourYearOld = FourYearOld,
	@Adult = Adult
FROM config_AgeCategories
WHERE ConfigID = '{91AF1A80-7994-431E-8D6C-9D9B7CDAE4C1}'

SET @DaysOld = dbo.udf_ComputeDaysOld(@DateBorn, @OffsetMonth, GetDate())

SELECT @AgeCategory =
	CASE
		WHEN @DaysOld >= @Adult THEN 'Adult'
		WHEN @DaysOld >= @FourYearOld THEN 'Four year old'
		WHEN @DaysOld >= @ThreeYearOld THEN 'Three year old'
		WHEN @DaysOld >= @TwoYearOld THEN 'Two year old'
		WHEN @DaysOld >= @Yearling THEN 'Yearling'
		WHEN @DaysOld >= @Weanling THEN 'Weanling'
		ELSE 'Foal'
	END
GO
/****** Object:  StoredProcedure [dbo].[usp_config_UpdateAgeCategories]    Script Date: 10/25/2020 11:13:23 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_config_UpdateAgeCategories]
	 @OffsetMonth			int
	,@Weanling			int
	,@Yearling			int
	,@TwoYearOld			int
	,@ThreeYearOld		int
	,@FourYearOld			int
	,@Adult				int
	,@UpdateUser varchar(120) = null, @UpdateTimestamp DateTime = null, @NewUpdateUser varchar(120)
AS

UPDATE config_AgeCategories
SET OffsetMonth = @OffsetMonth, Weanling = @Weanling, Yearling = @Yearling,
	TwoYearOld = @TwoYearOld, ThreeYearOld = @ThreeYearOld,
	FourYearOld = @FourYearOld, Adult = @Adult
	, UpdateUser = @NewUpdateUser, UpdateTimestamp = GETDATE()
WHERE ConfigID = '{91AF1A80-7994-431E-8D6C-9D9B7CDAE4C1}'
AND (UpdateUser = @UpdateUser AND UpdateTimestamp = @UpdateTimestamp)

		--Check For Concurrency Error
		IF (@@ROWCOUNT = 0) 
		BEGIN
			RAISERROR(52025, 16, 1)
		END
GO
/****** Object:  StoredProcedure [dbo].[usp_config_GetAgeCategories]    Script Date: 10/25/2020 11:13:22 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_config_GetAgeCategories]

 

AS

 

SELECT TOP 1 OffsetMonth, Weanling, Yearling, TwoYearOld, ThreeYearOld, FourYearOld, Adult
,UpdateUser, UpdateTimestamp
FROM config_AgeCategories
GO
/****** Object:  StoredProcedure [dbo].[usp_user_History_Update_ContactID]    Script Date: 10/25/2020 11:13:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_History_Update_ContactID]
	 @HorseID		uniqueidentifier
	,@ContactID		uniqueidentifier

AS

UPDATE user_History
SET ContactID = @ContactID
WHERE HorseID = @HorseID
GO
/****** Object:  StoredProcedure [dbo].[usp_user_ShowClass_RoleUpPoints]    Script Date: 10/25/2020 11:13:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_user_ShowClass_RoleUpPoints]
(
	@ShowClassID UniqueIdentifier
)
AS
BEGIN

	DECLARE 
		@ShowID uniqueidentifier,
		@ShowClassTotal numeric(18,2)

	--get the show that this class belongs to
	SELECT
		@ShowID = ShowID
	FROM
		user_ShowClass
	WHERE
		ClassID = @ShowClassID

	--get the total points for all classes in this show
	SELECT
		@ShowClassTotal = ISNULL(SUM(Points), 0)
	FROM
		user_ShowClass
	WHERE
		ShowID = @ShowID

	--store the total points in the show
	UPDATE 
		user_Show 
	SET
		Points = @ShowClassTotal
	WHERE
		ShowID = @ShowID

END
GO
/****** Object:  StoredProcedure [dbo].[usp_user_ShowClass_Delete]    Script Date: 10/25/2020 11:13:58 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_ShowClass_Delete]
(
	@ShowClassID uniqueIdentifier 
)
AS
BEGIN
	DELETE FROM user_ShowClass WHERE ClassID = @ShowClassID
END
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Show_GetByHorseID]    Script Date: 10/25/2020 11:13:55 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_Show_GetByHorseID] 
( 
@HorseID UniqueIdentifier 
) 
AS 

BEGIN 

         SELECT 
                 ShowID,  
                 HorseID,  
                 ShowName,  
                 ShowDate,  
                 DayRate,  
                 DayRateCodes,  
                 Transport,  
                 TransportCodes,  
                 Equipment,  
                 EquipmentCodes,  
                 Handling,  
                 HandlingCodes,  
                 ProRata,  
                 ProRataCodes,  
                 Grooming,  
                 GroomingCodes,  
                 EntryFees,  
                 EntryFeesCodes,  
                 Miscellaneous,  
                 MiscellaneousCodes,  
                 Points,  
                 Account,  
                 Comments
	,UpdateUser, UpdateTimestamp

         FROM 
                 user_Show 

         WHERE 
                 HorseID = @HorseID 

         ORDER BY ShowDate DESC
 

         SELECT 
                 c.ClassID,  
                 c.ShowID,  
                 c.Class,  
                 c.Awards,  
                 c.Judge,  
                 c.Points,  
                 c.Score,  
                 c.[Percent],  
                 c.Comments 

         FROM 
                 user_ShowClass c

         INNER JOIN
                 user_Show s ON s.ShowID = c.ShowID

         WHERE 
                 s.HorseID = @HorseID

         ORDER BY c.Class
  

END
GO
/****** Object:  StoredProcedure [dbo].[usp_user_ShowClass_GetByShowID]    Script Date: 10/25/2020 11:13:58 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_ShowClass_GetByShowID] 

( 

        @ShowID UniqueIdentifier 

) 

AS 

BEGIN 

  

         SELECT 

                 ClassID,  

                 ShowID,  

                 Class,  

                 Awards,  

                 Judge,  

                 Points,  

                 Score,  

                 [Percent],  

                 Comments,

				 UpdateUser, UpdateTimestamp

         FROM 

                 user_ShowClass 

         WHERE 

                 ShowID = @ShowID 

  

END
GO
/****** Object:  StoredProcedure [dbo].[usp_user_ShowClass_GetByID]    Script Date: 10/25/2020 11:13:58 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_ShowClass_GetByID] 

( 

        @ShowClassID UniqueIdentifier 

) 

AS 

BEGIN 

  

         SELECT 

                 ClassID,  

                 ShowID,  

                 Class,  

                 Awards,  

                 Judge,  

                 Points,  

                 Score,  

                 [Percent],  

                 Comments, 
				UpdateUser, UpdateTimestamp

         FROM 

                 user_ShowClass 

         WHERE 

                 ClassID = @ShowClassID 

  

END
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Client_Delete]    Script Date: 10/25/2020 11:13:28 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Client_Delete]    Script Date: 09/13/2006 10:32:21 ******/
CREATE PROCEDURE [dbo].[usp_user_Client_Delete]
(
	@ClientID uniqueIdentifier 
)
AS
BEGIN
	DELETE FROM user_ClientMisc WHERE ClientID = @ClientID
	DELETE FROM user_ClientPayment WHERE ClientID = @ClientID
	DELETE FROM user_Ownership WHERE ClientID = @ClientID
	DELETE FROM user_Client WHERE ClientID = @ClientID
END
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Client_AddCreditEntry]    Script Date: 10/25/2020 11:13:28 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_Client_AddCreditEntry]

(

@ClientID uniqueidentifier,

@CreditAmount numeric(18,2),

@CreditDate datetime,

@Notes nvarchar(50)
,@UpdateUser varchar(120) = null, @UpdateTimestamp DateTime = null
)

AS

 

INSERT INTO dbo.user_ClientPayment

(ClientID, PaymentDate, Amount, Notes, PaymentOrCredit)

VALUES

(@ClientID, @CreditDate, @CreditAmount, @Notes, 'C')
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Client_AddPaymentEntry]    Script Date: 10/25/2020 11:13:28 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_Client_AddPaymentEntry]

(

@ClientID uniqueidentifier,

@PaymentAmount numeric(18,2),

@PaymentDate datetime,

@Notes nvarchar(50)
,@UpdateUser varchar(120) = null, @UpdateTimestamp DateTime = null
)

AS

 

INSERT INTO dbo.user_ClientPayment

(ClientID, PaymentDate, Amount, Notes, PaymentOrCredit)

VALUES

(@ClientID, @PaymentDate, @PaymentAmount, @Notes, 'P')
GO
/****** Object:  StoredProcedure [dbo].[usp_user_ClientPayment_InsertOrUpdate]    Script Date: 10/25/2020 11:13:35 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_ClientPayment_InsertOrUpdate]

(

            @PaymentID uniqueidentifier = null, 

            @ClientID uniqueidentifier, 

            @PaymentDate datetime, 

            @Amount numeric(18,2), 

            @PaymentMethod nvarchar(15), 

            @Notes nvarchar(50), 

            @PaymentOrCredit char(1), 

            @Account nvarchar(8), 

            @Comments ntext,

            @NewPaymentID uniqueidentifier output
,@UpdateUser varchar(120) = null, @UpdateTimestamp DateTime = null, @NewUpdateUser varchar(120)
)

AS

BEGIN

            IF @PaymentID IS NULL

            BEGIN

 

                        SET @NewPaymentID = newid()

 

                        INSERT INTO user_ClientPayment(

                                    PaymentID, 

                                    ClientID, 

                                    PaymentDate, 

                                    Amount, 

                                    PaymentMethod, 

                                    Notes, 

                                    PaymentOrCredit, 

                                    Account, 

                                    Comments        
									, UpdateUser, UpdateTimestamp
                        )

                        VALUES(

                                    @NewPaymentID, 

                                    @ClientID, 

                                    @PaymentDate, 

                                    @Amount, 

                                    @PaymentMethod, 

                                    @Notes, 

                                    @PaymentOrCredit, 

                                    @Account, 

                                    @Comments    
									, @UpdateUser, @UpdateTimestamp
                        )

 

            END

            ELSE

            BEGIN

 

                        UPDATE user_ClientPayment SET 

                                    ClientID = @ClientID, 

                                    PaymentDate = @PaymentDate, 

                                    Amount = @Amount, 

                                    PaymentMethod = @PaymentMethod, 

                                    Notes = @Notes, 

                                    PaymentOrCredit = @PaymentOrCredit, 

                                    Account = @Account, 

                                    Comments = @Comments        
									, UpdateUser = @NewUpdateUser, UpdateTimestamp = GETDATE()
                        WHERE 

                                    PaymentID = @PaymentID
									AND (UpdateUser = @UpdateUser AND UpdateTimestamp = @UpdateTimestamp)
 
						--Check For Concurrency Error
						IF (@@ROWCOUNT = 0) 
						BEGIN
							RAISERROR(52025, 16, 1)
						END

                        SET @NewPaymentID = @PaymentID

 

            END

END
GO
/****** Object:  StoredProcedure [dbo].[usp_user_ClientPayment_GetByID]    Script Date: 10/25/2020 11:13:34 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_ClientPayment_GetByID]

(

            @PaymentID uniqueidentifier

)

AS

BEGIN

 

            SELECT

                        c.ClientCode,

                        p.PaymentID, 

                        p.ClientID, 

                        p.PaymentDate, 

                        p.Amount, 

                        p.PaymentMethod, 

                        p.Notes, 

                        p.PaymentOrCredit, 

                        p.Account, 

                        p.Comments
,p.UpdateUser, p.UpdateTimestamp
            FROM 

                        user_ClientPayment p

                                    INNER JOIN user_Client c ON

                                                p.ClientID = c.ClientID

            WHERE

                        PaymentID = @PaymentID

 

END
GO
/****** Object:  StoredProcedure [dbo].[usp_user_ClientPayment_GetAllClientPayments]    Script Date: 10/25/2020 11:13:34 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_ClientPayment_GetAllClientPayments]

(

            @ClientID uniqueidentifier

)

AS

BEGIN

 

            --get all the payments for the current period, for the client

            SELECT

                        c.ClientCode,

                        p.PaymentID, 

                        p.ClientID, 

                        p.PaymentDate, 

                        p.Amount, 

                        p.PaymentMethod, 

                        p.Notes, 

                        p.PaymentOrCredit, 

                        p.Account, 

                        p.Comments
,p.UpdateUser, p.UpdateTimestamp
            FROM

                        user_ClientPayment p

                                    INNER JOIN user_Client c ON

                                                p.ClientID = c.ClientID

            WHERE

                        p.ClientID = @ClientID 

                        AND PaymentOrCredit='P'

            ORDER BY

                        p.PaymentDate DESC

 

END
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Client_GetPayments]    Script Date: 10/25/2020 11:13:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_user_Client_GetPayments]
(
@BeginDate datetime,
@EndDate datetime
)
AS

select c.ClientID, c.ContactID, c.ClientCode, isNull(p.Account,'') as Account,
c.LastTransaction, c.LastBill, c.StatementType, c.ServiceCharge, c.Terms, 
c.Statement, 
	c.[Current], c.Period1, c.Period2, c.Period3, 
	c.LastCurrent, c.LastPeriod1, c.LastPeriod2, c.LastPeriod3, 
	c.BreedCurrent, c.BreedPeriod1, c.BreedPeriod2, c.BreedPeriod3, 
	c.LastBreedCurrent, c.LastBreedPeriod1, c.LastBreedPeriod2, c.LastBreedPeriod3, 
	c.SaleCurrent, c.SalePeriod1, c.SalePeriod2, c.SalePeriod3, 
	c.LastSaleCurrent, c.LastSalePeriod1, c.LastSalePeriod2, c.LastSalePeriod3, 
	c.TransCurrent, c.TransPeriod1, c.TransPeriod2, c.TransPeriod3, 
	c.LastTransCurrent, c.LastTransPeriod1, c.LastTransPeriod2, c.LastTransPeriod3, 
	c.SeparatePeriods,
	cast(c.Notes as nvarchar(4000)) as Notes, cast(c.Comments as nvarchar(4000)) as Comments,
	co.Name, co.FirstName, co.Company, co.Address1, co.Address2, co.City, co.StateID, LUState.LookupAbrv AS StateAbrv,
	LUState.LookupDescription AS StateDescription, co.Zip, co.CountryID, LUCountry.LookupAbrv AS CountryAbrv,
	LUCountry.LookupDescription AS CountryDescription, co.Phone1, co.Phone2, co.Fax, co.HorseNotes, sum(p.Amount) as Amount

from user_ClientPayment p
inner join user_Client c on p.ClientID = c.ClientID
INNER JOIN user_Contact co ON c.ContactID = co.ContactID
LEFT OUTER JOIN base_Lookup LUState ON co.StateID = LUState.LookupID
LEFT OUTER JOIN base_Lookup LUCountry ON co.CountryID = LUCountry.LookupID
where @BeginDate <= p.PaymentDate and p.PaymentDate <= @EndDate and p.PaymentOrCredit = 'P'
group by c.ClientID, c.ContactID, c.ClientCode, isnull(p.Account,''),
c.LastTransaction, c.LastBill, c.StatementType, c.ServiceCharge, c.Terms, 
c.Statement, c.[Current], c.Period1, c.Period2, c.Period3, c.LastCurrent, 
c.LastPeriod1, c.LastPeriod2, c.LastPeriod3, 
c.BreedCurrent, c.BreedPeriod1, c.BreedPeriod2, c.BreedPeriod3, 
c.LastBreedCurrent, c.LastBreedPeriod1, c.LastBreedPeriod2, c.LastBreedPeriod3, 
c.SaleCurrent, c.SalePeriod1, c.SalePeriod2, c.SalePeriod3, 
c.LastSaleCurrent, c.LastSalePeriod1, c.LastSalePeriod2, c.LastSalePeriod3, 
c.TransCurrent, c.TransPeriod1, c.TransPeriod2, c.TransPeriod3, 
c.LastTransCurrent, c.LastTransPeriod1, c.LastTransPeriod2, c.LastTransPeriod3, 
c.SeparatePeriods,
cast(c.Notes as nvarchar(4000)), cast(c.Comments as nvarchar(4000)),
co.Name, co.FirstName, co.Company, co.Address1, co.Address2, co.City, co.StateID, LUState.LookupAbrv,
	LUState.LookupDescription, co.Zip, co.CountryID, LUCountry.LookupAbrv,
	LUCountry.LookupDescription, co.Phone1, co.Phone2, co.Fax, co.HorseNotes
order by c.ClientCode
GO
/****** Object:  StoredProcedure [dbo].[usp_user_ClientPayment_Delete]    Script Date: 10/25/2020 11:13:34 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_ClientPayment_Delete]
(
	@PaymentID uniqueidentifier
)
AS
BEGIN

	DELETE FROM 
		user_ClientPayment
	WHERE
		PaymentID = @PaymentID

END
GO
/****** Object:  StoredProcedure [dbo].[usp_user_ClientCredit_GetAllClientCredits]    Script Date: 10/25/2020 11:13:33 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_ClientCredit_GetAllClientCredits]

(

            @ClientID uniqueidentifier

)

AS

BEGIN

 

            --get all the payments for the current period, for the client

            SELECT

                        c.ClientCode,

                        p.PaymentID, 

                        p.ClientID, 

                        p.PaymentDate, 

                        p.Amount, 

                        p.PaymentMethod, 

                        p.Notes, 

                        p.PaymentOrCredit, 

                        p.Account, 

                        p.Comments
,p.UpdateUser, p.UpdateTimestamp
            FROM

                        user_ClientPayment p

                                    INNER JOIN user_Client c ON

                                                p.ClientID = c.ClientID

            WHERE

                        p.ClientID = @ClientID 

                        AND PaymentOrCredit='C'

            ORDER BY

                        p.PaymentDate DESC

 

END
GO
/****** Object:  View [dbo].[vw_user_ClientPayment_plus]    Script Date: 10/25/2020 11:14:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_user_ClientPayment_plus]
AS
SELECT     TOP 100 PERCENT cp.PaymentID, cp.ClientID, c.ClientCode, cp.PaymentDate, cp.Amount, cp.PaymentMethod, cp.Notes, cp.PaymentOrCredit, 
                      cp.Account, cp.Comments
FROM         dbo.user_ClientPayment cp INNER JOIN
                      dbo.user_Client c ON cp.ClientID = c.ClientID
ORDER BY c.ClientCode, cp.PaymentOrCredit, cp.PaymentDate, cp.Amount
GO
/****** Object:  StoredProcedure [dbo].[usp_user_ClientMisc_GetById]    Script Date: 10/25/2020 11:13:33 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_ClientMisc_GetById]

(

            @MiscID uniqueidentifier

)

AS

BEGIN

 

            --get the misc entry by id

            SELECT

                        m.ClientMiscID as "MiscID", 

                        m.ClientID, 

                        m.Date as "MiscDate", 

                        m.Amount, 

                        m.Item, 

                        m.Account, 

                        m.Comments,

                        c.ClientCode
,m.UpdateUser, m.UpdateTimestamp
            FROM

                        user_ClientMisc m

                                    INNER JOIN user_Client c ON

                                                m.ClientID = c.ClientID

            WHERE

                        m.ClientMiscID = @MiscID 

            ORDER BY

                        m.Date DESC

 

END
GO
/****** Object:  StoredProcedure [dbo].[usp_user_ClientMisc_GetListForClient]    Script Date: 10/25/2020 11:13:33 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_ClientMisc_GetListForClient]

(

            @ClientID uniqueidentifier

)

AS

BEGIN

 

            --get all the misc entries for the client

            SELECT

                        m.ClientMiscID as MiscID, 

                        m.ClientID, 

                        c.ClientCode,

                        m.Date as MiscDate, 

                        m.Amount, 

                        m.Item, 

                        m.Account, 

                        m.Comments
,m.UpdateUser, m.UpdateTimestamp
            FROM

                        user_ClientMisc m

                                    INNER JOIN user_Client c ON

                                                m.ClientID = c.ClientID

            WHERE

                        m.ClientID = @ClientID 

            ORDER BY

                        m.Date DESC

 

END
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Client_RestorePriorPeriod]    Script Date: 10/25/2020 11:13:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_user_Client_RestorePriorPeriod] AS

UPDATE user_client
SET
	[Current] = LastCurrent,
	[Period1] = LastPeriod1,
	[Period2] = LastPeriod2,
	[Period3] = LastPeriod3,
	[BreedCurrent] = LastBreedCurrent,
	[BreedPeriod1] = LastBreedPeriod1,
	[BreedPeriod2] = LastBreedPeriod2,
	[BreedPeriod3] = LastBreedPeriod3,
	[SaleCurrent] = LastSaleCurrent,
	[SalePeriod1] = LastSalePeriod1,
	[SalePeriod2] = LastSalePeriod2,
	[SalePeriod3] = LastSalePeriod3,
	[TransCurrent] = LastTransCurrent,
	[TransPeriod1] = LastTransPeriod1,
	[TransPeriod2] = LastTransPeriod2,
	[TransPeriod3] = LastTransPeriod3

-- Set the New Last Statement Date
UPDATE user_Statement
SET StatementDate = (Select [StatementDate] from [user_Statement] WHERE [Statement] = 'PRIOR')
WHERE Statement = 'LAST'
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Client_GetByID]    Script Date: 10/25/2020 11:13:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_user_Client_GetByID]
(
	@ClientID uniqueidentifier
)
AS
BEGIN

	SELECT
		l.*,
		c.Name, c.FirstName, c.Company, c.Address1, c.Address2, c.City, c.StateID, LUState.LookupAbrv AS StateAbrv,
		LUState.LookupDescription AS StateDescription, c.Zip, c.CountryID, LUCountry.LookupAbrv AS CountryAbrv,
		LUCountry.LookupDescription AS CountryDescription, c.Phone1, c.Phone2, c.Fax, c.HorseNotes
	FROM
		user_Client l
	LEFT OUTER JOIN 
		user_Contact c ON l.ContactID = c.ContactID
	LEFT OUTER JOIN 
		base_Lookup LUState ON c.StateID = LUState.LookupID
	LEFT OUTER JOIN 
		base_Lookup LUCountry ON c.CountryID = LUCountry.LookupID
	WHERE
		l.ClientID = @ClientID

END
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Ownership_GetByOwnershipID]    Script Date: 10/25/2020 11:13:53 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
-- =============================================

-- Author:                     <Sean Biefeld>

-- Create date: <09/08/2006>

-- Description:  <Get Ownership Records by Ownership Id>

-- =============================================

CREATE PROCEDURE [dbo].[usp_user_Ownership_GetByOwnershipID]

            @OwnershipID                                    uniqueidentifier

 

AS

 

SELECT  o.OwnershipID AS OwnershipID, o.HorseID AS HorseID, o.ClientID AS ClientID, o.Percentage AS Percentage, 

          o.LastStatementDate AS LastStatementDate, o.Comments AS Comments, c.ClientCode AS ClientCode, c.ContactID AS ContactID
,o.UpdateUser, o.UpdateTimestamp
FROM    user_Ownership o, user_Client c 

WHERE   o.OwnershipID = @OwnershipID AND o.ClientID = c.ClientID
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Ownership_GetByHorseID]    Script Date: 10/25/2020 11:13:53 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
-- ============================================= 

-- Author:              <Sean, Biefeld> 

-- Create date: <09/07/2006> 

-- Description: <Get Ownership Records by Horse Id> 

-- ============================================= 

CREATE PROCEDURE [dbo].[usp_user_Ownership_GetByHorseID] 

        @HorseID                        uniqueidentifier 

 

AS 

 

SELECT     o.OwnershipID AS OwnershipID, o.HorseID AS HorseID, o.ClientID AS ClientID, o.Percentage AS Percentage,  

                      o.LastStatementDate AS LastStatementDate, o.Comments AS Comments, c.ClientCode AS ClientCode, c.ContactID AS ContactID, con.Company AS Company, 

                      con.Name AS Name 
,o.UpdateUser, o.UpdateTimestamp
FROM         user_Ownership o INNER JOIN 

                      user_Client c ON o.ClientID = c.ClientID INNER JOIN 

                      user_Contact con ON con.ContactID = c.ContactID 

WHERE o.HorseID = @HorseID
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Client_Insert_Or_Update]    Script Date: 10/25/2020 11:13:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_user_Client_Insert_Or_Update]
(
	@ClientID Uniqueidentifier = null, 
	@ClientCode nvarchar(6), 
	@ContactID uniqueidentifier, 
	@LastTransaction datetime, 
	@LastBill datetime, 
	@StatementType char(1), 
	@ServiceCharge numeric(18,1), 
	@Terms nvarchar(15), 
	@Statement bit, 
	@Current numeric(18,2), 
	@Period1 numeric(18,2), 
	@Period2 numeric(18,2), 
	@Period3 numeric(18,2), 
	@LastCurrent numeric(18,2), 
	@LastPeriod1 numeric(18,2), 
	@LastPeriod2 numeric(18,2), 
	@LastPeriod3 numeric(18,2), 
	@BreedCurrent numeric(18,2), 
	@BreedPeriod1 numeric(18,2), 
	@BreedPeriod2 numeric(18,2), 
	@BreedPeriod3 numeric(18,2), 
	@LastBreedCurrent numeric(18,2), 
	@LastBreedPeriod1 numeric(18,2), 
	@LastBreedPeriod2 numeric(18,2), 
	@LastBreedPeriod3 numeric(18,2), 
	@SaleCurrent numeric(18,2), 
	@SalePeriod1 numeric(18,2), 
	@SalePeriod2 numeric(18,2), 
	@SalePeriod3 numeric(18,2), 
	@LastSaleCurrent numeric(18,2), 
	@LastSalePeriod1 numeric(18,2), 
	@LastSalePeriod2 numeric(18,2), 
	@LastSalePeriod3 numeric(18,2), 
	@TransCurrent numeric(18,2), 
	@TransPeriod1 numeric(18,2), 
	@TransPeriod2 numeric(18,2), 
	@TransPeriod3 numeric(18,2), 
	@LastTransCurrent numeric(18,2), 
	@LastTransPeriod1 numeric(18,2), 
	@LastTransPeriod2 numeric(18,2), 
	@LastTransPeriod3 numeric(18,2), 
	@SeparatePeriods bit,
	@Notes ntext, 
	@Comments ntext,
	@RefNum numeric(18,0),
	@NewClientID uniqueidentifier OUTPUT
,@UpdateUser varchar(120) = null, @UpdateTimestamp DateTime = null, @NewUpdateUser varchar(120)
)
AS
BEGIN
	IF @ClientID IS NULL
	BEGIN
		SET @NewClientID = newid()

		INSERT INTO user_Client(
			ClientID, 
			ClientCode, 
			ContactID, 
			LastTransaction, 
			LastBill, 
			StatementType, 
			ServiceCharge, 
			Terms, 
			Statement, 
			[Current], 
			Period1, 
			Period2, 
			Period3, 
			LastCurrent, 
			LastPeriod1, 
			LastPeriod2, 
			LastPeriod3, 
			BreedCurrent, 
			BreedPeriod1, 
			BreedPeriod2, 
			BreedPeriod3, 
			LastBreedCurrent, 
			LastBreedPeriod1, 
			LastBreedPeriod2, 
			LastBreedPeriod3, 
			SaleCurrent, 
			SalePeriod1, 
			SalePeriod2, 
			SalePeriod3, 
			LastSaleCurrent, 
			LastSalePeriod1, 
			LastSalePeriod2, 
			LastSalePeriod3, 
			TransCurrent, 
			TransPeriod1, 
			TransPeriod2, 
			TransPeriod3, 
			LastTransCurrent, 
			LastTransPeriod1, 
			LastTransPeriod2, 
			LastTransPeriod3, 
			SeparatePeriods,
			Notes, 
			Comments,
			RefNum
			, UpdateUser, UpdateTimestamp
		)
		VALUES(
			@NewClientID, 
			@ClientCode, 
			@ContactID, 
			@LastTransaction, 
			@LastBill, 
			@StatementType, 
			@ServiceCharge, 
			@Terms, 
			@Statement, 
			@Current, 
			@Period1, 
			@Period2, 
			@Period3, 
			@LastCurrent, 
			@LastPeriod1, 
			@LastPeriod2, 
			@LastPeriod3, 
			@BreedCurrent, 
			@BreedPeriod1, 
			@BreedPeriod2, 
			@BreedPeriod3, 
			@LastBreedCurrent, 
			@LastBreedPeriod1, 
			@LastBreedPeriod2, 
			@LastBreedPeriod3, 
			@SaleCurrent, 
			@SalePeriod1, 
			@SalePeriod2, 
			@SalePeriod3, 
			@LastSaleCurrent, 
			@LastSalePeriod1, 
			@LastSalePeriod2, 
			@LastSalePeriod3, 
			@TransCurrent, 
			@TransPeriod1, 
			@TransPeriod2, 
			@TransPeriod3, 
			@LastTransCurrent, 
			@LastTransPeriod1, 
			@LastTransPeriod2, 
			@LastTransPeriod3, 
			@SeparatePeriods,
			@Notes, 
			@Comments,
			@RefNum
			, @UpdateUser, @UpdateTimestamp
		)
	END
	ELSE
	BEGIN
		UPDATE user_Client SET 
			ClientCode = @ClientCode, 
			ContactID = @ContactID, 
			LastTransaction = @LastTransaction, 
			LastBill = @LastBill, 
			StatementType = @StatementType, 
			ServiceCharge = @ServiceCharge, 
			Terms = @Terms, 
			Statement = @Statement, 
			[Current] = @Current, 
			Period1 = @Period1, 
			Period2 = @Period2, 
			Period3 = @Period3, 
			LastCurrent = @LastCurrent, 
			LastPeriod1 = @LastPeriod1, 
			LastPeriod2 = @LastPeriod2, 
			LastPeriod3 = @LastPeriod3, 
			BreedCurrent = @BreedCurrent, 
			BreedPeriod1 = @BreedPeriod1, 
			BreedPeriod2 = @BreedPeriod2, 
			BreedPeriod3 = @BreedPeriod3, 
			LastBreedCurrent = @LastBreedCurrent, 
			LastBreedPeriod1 = @LastBreedPeriod1, 
			LastBreedPeriod2 = @LastBreedPeriod2, 
			LastBreedPeriod3 = @LastBreedPeriod3, 
			SaleCurrent = @SaleCurrent, 
			SalePeriod1 = @SalePeriod1, 
			SalePeriod2 = @SalePeriod2, 
			SalePeriod3 = @SalePeriod3, 
			LastSaleCurrent = @LastSaleCurrent, 
			LastSalePeriod1 = @LastSalePeriod1, 
			LastSalePeriod2 = @LastSalePeriod2, 
			LastSalePeriod3 = @LastSalePeriod3, 
			TransCurrent = @TransCurrent, 
			TransPeriod1 = @TransPeriod1, 
			TransPeriod2 = @TransPeriod2, 
			TransPeriod3 = @TransPeriod3, 
			LastTransCurrent = @LastTransCurrent, 
			LastTransPeriod1 = @LastTransPeriod1, 
			LastTransPeriod2 = @LastTransPeriod2, 
			LastTransPeriod3 = @LastTransPeriod3, 
			SeparatePeriods = @SeparatePeriods,
			Notes = @Notes, 
			Comments = @Comments,
			RefNum = @RefNum
			, UpdateUser = @NewUpdateUser, UpdateTimestamp = GETDATE()
		WHERE 
			ClientID = @ClientID
			AND (UpdateUser = @UpdateUser AND UpdateTimestamp = @UpdateTimestamp)

		--Check For Concurrency Error
		IF (@@ROWCOUNT = 0) 
		BEGIN
			RAISERROR(52025, 16, 1)
		END

		SET @NewClientID = @ClientID
	END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Client_GetListBySearch]    Script Date: 10/25/2020 11:13:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_user_Client_GetListBySearch]
(
@Name nvarchar(200) = NULL,
@FarmName nvarchar(50) = NULL,
@HorseNotes nvarchar(50) = NULL,
@Address1 nvarchar(35) = NULL,
@Address2 nvarchar(35) = NULL,
@City nvarchar(35) = NULL,
@State nvarchar(35) = NULL,
@Zipcode nvarchar(20) = NULL,
@Country nvarchar(35) = NULL
)
AS
BEGIN
	IF (@Name IS NOT NULL)
        	Set @Name = '%' + @Name + '%'

	IF (@FarmName IS NOT NULL)
        	Set @FarmName = '%' + @FarmName + '%'

	IF (@HorseNotes IS NOT NULL)
        	Set @HorseNotes = '%' + @HorseNotes + '%'

	IF (@Address1 IS NOT NULL)
        	Set @Address1 = '%' + @Address1 + '%'

	IF (@Address2 IS NOT NULL)
        	Set @Address2 = '%' + @Address2 + '%'

	IF (@City IS NOT NULL)
        	Set @City = '%' + @City + '%'

	IF (@State IS NOT NULL)
        	Set @State = '%' + @State + '%'

	IF (@Zipcode IS NOT NULL)
        	Set @Zipcode = '%' + @Zipcode + '%'

	IF (@Country IS NOT NULL)
		Set @Country = '%' + @Country + '%'

	SELECT
		l.*,
                c.Name, c.FirstName, c.Company, c.Address1, c.Address2, c.City, c.StateID, 
		LUState.LookupAbrv AS StateAbrv, LUState.LookupDescription AS StateDescription, 
		c.Zip, c.CountryID, LUCountry.LookupAbrv AS CountryAbrv,
		LUCountry.LookupDescription AS CountryDescription, 
                c.Phone1, c.Phone2, c.Fax, c.HorseNotes, 
		l.UpdateUser, l.UpdateTimestamp
        FROM user_Client l
	INNER JOIN user_Contact c ON l.ContactID = c.ContactID
	LEFT OUTER JOIN base_Lookup LUState ON c.StateID = LUState.LookupID
	LEFT OUTER JOIN base_Lookup LUCountry ON c.CountryID = LUCountry.LookupID
	WHERE
		((c.Name LIKE @Name) OR (c.FirstName LIKE @Name) OR (@Name IS NULL)) AND
		((c.Company LIKE @FarmName) OR (@FarmName IS NULL)) AND
		((c.HorseNotes LIKE @HorseNotes) OR (@HorseNotes IS NULL)) AND
                ((c.Address1 LIKE @Address1) OR (@Address1 IS NULL)) AND
                ((c.Address2 LIKE @Address2) OR (@Address2 IS NULL)) AND
                ((c.City LIKE @City) OR (@City Is Null)) AND
                ((LUState.LookupAbrv LIKE @State) OR (LUState.LookupDescription LIKE @State) OR (@State IS NULL)) AND
                ((LUCountry.LookupAbrv LIKE @Country) OR (LUCountry.LookupDescription LIKE @Country) OR (@Country IS NULL))
	ORDER BY 
		l.ClientCode
END
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Client_AddMiscEntry]    Script Date: 10/25/2020 11:13:28 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_Client_AddMiscEntry]
(
@ClientID uniqueidentifier,
@ChargeAmount numeric(18,2),
@ChargeDate datetime,
@Item nvarchar(50)
,@UpdateUser varchar(120) = null, @UpdateTimestamp DateTime = null
)
AS

INSERT INTO user_ClientMisc
(ClientID, Amount, Date, Item)
VALUES 
(@ClientID, @ChargeAmount, @ChargeDate, @Item)
GO
/****** Object:  StoredProcedure [dbo].[usp_user_ClientMisc_Delete]    Script Date: 10/25/2020 11:13:33 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_ClientMisc_Delete]
(
	@MiscID uniqueIdentifier 
)
AS
BEGIN
	DELETE FROM user_ClientMisc WHERE ClientMiscID = @MiscID
END
GO
/****** Object:  StoredProcedure [dbo].[usp_user_ClientMisc_InsertOrUpdate]    Script Date: 10/25/2020 11:13:34 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_ClientMisc_InsertOrUpdate]

(

            @MiscID uniqueidentifier = null, 

            @ClientID uniqueidentifier, 

            @MiscDate datetime, 

            @Amount decimal(18,2), 

            @Item nvarchar(50), 

            @Account nvarchar(8) = null, 

            @Comments ntext = null,

            @NewMiscID uniqueidentifier Output
,@UpdateUser varchar(120) = null, @UpdateTimestamp DateTime = null, @NewUpdateUser varchar(120)
)

AS

BEGIN

 

            IF (@MiscID IS NULL)

            BEGIN

 

                        SET @NewMiscID = newid()

 

                        INSERT INTO user_ClientMisc(

                                    ClientMiscID, ClientID, Date, Amount, Item, Account, Comments, UpdateUser, UpdateTimestamp

                        )

                        VALUES(

                                    @NewMiscID, @ClientID, @MiscDate, @Amount, @Item, @Account, @Comments, @UpdateUser, @UpdateTimestamp

                        )

 

            END

            ELSE

            BEGIN

 

                        UPDATE user_ClientMisc SET 

                                    ClientID = @ClientID, 

                                    Date = @MiscDate, 

                                    Amount = @Amount, 

                                    Item = @Item, 

                                    Account = @Account, 

                                    Comments = @Comments
									, UpdateUser = @NewUpdateUser, UpdateTimestamp = GETDATE()

                        WHERE 

                                    ClientMiscID = @MiscID
									AND (UpdateUser = @UpdateUser AND UpdateTimestamp = @UpdateTimestamp)
 

						--Check For Concurrency Error
						IF (@@ROWCOUNT = 0) 
						BEGIN
							RAISERROR(52025, 16, 1)
						END

                        SET @NewMiscID = @MiscID

 

            END

 

END
GO
/****** Object:  StoredProcedure [dbo].[usp_base_LookupSet_GetByName]    Script Date: 10/25/2020 11:13:21 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_base_LookupSet_GetByName]
	@Name			varchar(50)

AS

SELECT l.LookupID, l.LookupSetID, l.LookupDescription, l.LookupAbrv, l.LookupSequence
FROM base_LookupSet ls
JOIN base_Lookup l ON ls.LookupSetID = l.LookupSetID
WHERE ls.LookupSetDescription = @Name
ORDER BY l.LookupSequence
GO
/****** Object:  StoredProcedure [dbo].[usp_base_LookupSetDescription_GetByID]    Script Date: 10/25/2020 11:13:21 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_base_LookupSetDescription_GetByID]
	@LookupSetID	uniqueidentifier

AS

SELECT ls.*
FROM base_LookupSet ls
WHERE ls.LookupSetID = @LookupSetID
GO
/****** Object:  View [dbo].[vw_base_Lookup_plus]    Script Date: 10/25/2020 11:14:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_base_Lookup_plus]
AS
SELECT     TOP 100 PERCENT l.LookupID, ls.LookupSetDescription, l.LookupDescription, l.LookupAbrv, l.LookupSequence, l.DateAdded, l.DateUpdated
FROM         dbo.base_Lookup l INNER JOIN
                      dbo.base_LookupSet ls ON l.LookupSetID = ls.LookupSetID
ORDER BY ls.LookupSetDescription, l.LookupSequence
GO
/****** Object:  StoredProcedure [dbo].[usp_base_Lookup_Insert_or_Update]    Script Date: 10/25/2020 11:13:21 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_base_Lookup_Insert_or_Update]
(
@LookupID			uniqueidentifier,
@LookupSetID			uniqueidentifier,
@LookupAbrv			varchar(10),
@LookupDescription		varchar(50),
@LookupSequence			int
)
AS

IF @LookupID IS NULL
BEGIN
	SET @LookupID = newid()

	INSERT INTO base_Lookup(LookupID, LookupSetID, LookupAbrv, LookupDescription, LookupSequence)
	VALUES(@LookupID, @LookupSetID, @LookupAbrv, @LookupDescription, @LookupSequence)
END
ELSE
BEGIN
	UPDATE base_Lookup
	SET 
		LookupAbrv = @LookupAbrv, 
		LookupDescription = @LookupDescription,
		LookupSequence = @LookupSequence
	WHERE LookupID = @LookupID
END

SELECT @LookupID
GO
/****** Object:  StoredProcedure [dbo].[usp_base_Lookup_Delete]    Script Date: 10/25/2020 11:13:20 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_base_Lookup_Delete]
(
@LookupID			uniqueidentifier,
@LookupSetID			uniqueidentifier
)
AS

DELETE FROM base_Lookup
WHERE LookupID = @LookupID and LookupSetID = @LookupSetID
GO
/****** Object:  View [dbo].[vw_user_Contact_plus]    Script Date: 10/25/2020 11:14:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_user_Contact_plus]
AS
SELECT     TOP 100 PERCENT c.ContactID, c.Name, c.Company, c.Address1, c.Address2, c.City, LUState.LookupDescription AS StateDescription, 
                      LUState.LookupAbrv AS StateAbrv, c.Zip, LUCountry.LookupDescription AS CountryDescription, LUCountry.LookupAbrv AS CountryAbrv, c.Phone1, 
                      c.Phone2, c.Fax
FROM         dbo.user_Contact c LEFT OUTER JOIN
                      dbo.base_Lookup LUState ON c.StateID = LUState.LookupID LEFT OUTER JOIN
                      dbo.base_Lookup LUCountry ON c.CountryID = LUCountry.LookupID
ORDER BY c.Name, c.Company
GO
/****** Object:  StoredProcedure [dbo].[usp_user_MaintenanceBoarding_GetByHorseID]    Script Date: 10/25/2020 11:13:51 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_user_MaintenanceBoarding_GetByHorseID]
           @HorseID                               uniqueidentifier
AS

SELECT BoardingID, HorseID, TimeUnit, Rate, BeginDate, EndDate, Account, Notes, Comments, LocalID, l.LookupAbrv as LocalAbrv,
               UpdateUser, UpdateTimestamp
FROM user_MaintenanceBoarding
LEFT JOIN base_Lookup l on LocalID = l.LookupID
WHERE HorseID = @HorseID
ORDER BY BeginDate desc
GO
/****** Object:  StoredProcedure [dbo].[usp_base_Lookup_GetByID]    Script Date: 10/25/2020 11:13:20 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_base_Lookup_GetByID]
	@LookupID			uniqueidentifier

AS

SELECT LookupID, LookupSetID, LookupDescription, LookupAbrv, LookupSequence
FROM base_Lookup
WHERE LookupID = @LookupID
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Contact_GetList]    Script Date: 10/25/2020 11:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_user_Contact_GetList]
AS

SELECT c.ContactID, c.Name, c.FirstName, c.Company, c.Address1, c.Address2, c.City, c.StateID, LUState.LookupAbrv AS StateAbrv,
            LUState.LookupDescription AS StateDescription, c.Zip, c.CountryID, LUCountry.LookupAbrv AS CountryAbrv,
            LUCountry.LookupDescription AS CountryDescription, c.Phone1, c.Phone2, c.Fax, c.HorseNotes
,c.UpdateUser, c.UpdateTimestamp
FROM user_Contact c
LEFT OUTER JOIN base_Lookup LUState ON c.StateID = LUState.LookupID
LEFT OUTER JOIN base_Lookup LUCountry ON c.CountryID = LUCountry.LookupID
ORDER BY Name, City
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Contact_GetByID]    Script Date: 10/25/2020 11:13:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_user_Contact_GetByID]
(
@ContactID uniqueidentifier
)
AS

SELECT c.ContactID, c.Name, c.FirstName, c.Company, c.Address1, c.Address2, c.City, c.StateID, LUState.LookupAbrv AS StateAbrv,
            LUState.LookupDescription AS StateDescription, c.Zip, c.CountryID, LUCountry.LookupAbrv AS CountryAbrv,
            LUCountry.LookupDescription AS CountryDescription, c.Phone1, c.Phone2, c.Fax, c.HorseNotes
,c.UpdateUser, c.UpdateTimestamp
FROM user_Contact c
LEFT OUTER JOIN base_Lookup LUState ON c.StateID = LUState.LookupID
LEFT OUTER JOIN base_Lookup LUCountry ON c.CountryID = LUCountry.LookupID
WHERE c.ContactID = @ContactID
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Ownership_Delete]    Script Date: 10/25/2020 11:13:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_user_Ownership_Delete]
(
@OwnershipID uniqueidentifier
)
AS

DELETE FROM user_ownership WHERE OwnershipID = @OwnershipID
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Ownership_Insert_Or_Update]    Script Date: 10/25/2020 11:13:54 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_Ownership_Insert_Or_Update]

(

            @OwnershipID uniqueidentifier = null, 

            @HorseID uniqueidentifier, 

            @ClientID uniqueidentifier, 

            @Percentage numeric(18,2), 

            @LastStatementDate datetime, 

            @Comments ntext,

            @NewOwnershipID uniqueidentifier output
,@UpdateUser varchar(120) = null, @UpdateTimestamp DateTime = null, @NewUpdateUser varchar(120)
)

AS

BEGIN

            IF @OwnershipID IS NULL

            BEGIN

 

                        SET @NewOwnershipID = newid()

 

                        INSERT INTO user_Ownership(

                                    OwnershipID, HorseID, ClientID, Percentage, LastStatementDate, Comments, UpdateUser, UpdateTimestamp

                        )

                        VALUES(

                                    @NewOwnershipID, @HorseID, @ClientID, @Percentage, @LastStatementDate, @Comments, @UpdateUser, @UpdateTimestamp

                        )

 

            END

            ELSE

            BEGIN

 

                        UPDATE user_Ownership SET 

                                    HorseID = @HorseID, 

                                    ClientID = @ClientID, 

                                    Percentage = @Percentage, 

                                    LastStatementDate = @LastStatementDate, 

                                    Comments = @Comments

									, UpdateUser = @NewUpdateUser, UpdateTimestamp = GETDATE()

                        WHERE 

                                    OwnershipID = @OwnershipID
									AND (UpdateUser = @UpdateUser AND UpdateTimestamp = @UpdateTimestamp)
 
						--Check For Concurrency Error
						IF (@@ROWCOUNT = 0) 
						BEGIN
							RAISERROR(52025, 16, 1)
						END

                        SET @NewOwnershipID = @OwnershipID

 

            END

END
GO
/****** Object:  StoredProcedure [dbo].[usp_user_MaintenanceBoarding_Add_Or_Update]    Script Date: 10/25/2020 11:13:51 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_user_MaintenanceBoarding_Add_Or_Update]
             @BoardingID                                      uniqueidentifier
            ,@HorseID                                          uniqueidentifier
            ,@TimeUnit                                          char(1)
            ,@Rate                                                numeric(18,2)
            ,@BeginDate                                        datetime
            ,@EndDate                                          datetime
            ,@Account                                           nvarchar(8)
            ,@Notes                                              nvarchar(30)
            ,@Comments                                       ntext
            ,@LocalID                                           uniqueidentifier
,@UpdateUser varchar(120) = null, @UpdateTimestamp DateTime = null, @NewUpdateUser varchar(120)
 

AS

IF @BoardingID IS NULL

            INSERT INTO user_MaintenanceBoarding(HorseID, TimeUnit, Rate, BeginDate, EndDate, Account,
                        Notes, Comments, LocalID, UpdateUser, UpdateTimestamp)
            VALUES (@HorseID, @TimeUnit, @Rate, @BeginDate, @EndDate, @Account,
                        @Notes, @Comments, @LocalID, @UpdateUser, @UpdateTimestamp)

ELSE

            UPDATE user_MaintenanceBoarding
            SET TimeUnit = @TimeUnit, Rate = @Rate, BeginDate = @BeginDate, EndDate = @EndDate,
                     Account = @Account, Notes = @Notes, Comments = @Comments, LocalID = @LocalID,
                     UpdateUser = @NewUpdateUser, UpdateTimestamp = GETDATE()

            WHERE BoardingID = @BoardingID
			AND (UpdateUser = @UpdateUser AND UpdateTimestamp = @UpdateTimestamp)

	--Check For Concurrency Error
	IF (@@ROWCOUNT = 0) 
	BEGIN
		RAISERROR(52025, 16, 1)
	END
GO
/****** Object:  StoredProcedure [dbo].[usp_user_MaintenanceBoarding_GetByBoardingID]    Script Date: 10/25/2020 11:13:51 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_MaintenanceBoarding_GetByBoardingID]

            @BoardingID                           uniqueidentifier

 

AS

 

SELECT BoardingID, HorseID, TimeUnit, Rate, BeginDate, EndDate, Account, Notes, Comments
,UpdateUser, UpdateTimestamp
FROM user_MaintenanceBoarding

WHERE BoardingID = @BoardingID
GO
/****** Object:  StoredProcedure [dbo].[usp_user_horse_breeding_sale_insert]    Script Date: 10/25/2020 11:13:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_user_horse_breeding_sale_insert]
(
@RecordID uniqueidentifier,
@HorseID uniqueidentifier,
@StallionID uniqueidentifier,
@SaleDate datetime,
@Amount numeric(18,2),
@DownPayment numeric(18,2),
@Interest numeric(18,2),
@Notes nvarchar(50),
@Comments ntext,
@UpdateUser nvarchar(120),
@UpdateTimestamp datetime,
@NewUpdateUser nvarchar(120)
)
AS

INSERT INTO user_BreedingSale (BreedingSaleID, HorseID, StallionID, SaleDate, Amount, DownPayment, Interest, Notes, Comments, UpdateUser, UpdateTimestamp)
VALUES (@RecordID, @HorseID, @StallionID, @SaleDate, @Amount, @DownPayment, @Interest, @Notes, @Comments, @UpdateUser, @UpdateTimestamp)
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Show_Insert_Or_Update]    Script Date: 10/25/2020 11:13:57 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_Show_Insert_Or_Update]

(

            @ShowID uniqueIdentifier = null, 

            @HorseID uniqueidentifier, 

            @ShowName nvarchar(50), 

            @ShowDate datetime, 

            @DayRate numeric(18,2) = null, 

            @DayRateCodes char(8) = null,

            @Transport numeric(18,2) = null, 

            @TransportCodes char(8) = null,

            @Equipment numeric(18,2) = null, 

            @EquipmentCodes char(8) = null,

            @Handling numeric(18,2) = null, 

            @HandlingCodes char(8) = null,

            @ProRata numeric(18,2) = null, 

            @ProRataCodes char(8) = null,

            @Grooming numeric(18,2) = null, 

            @GroomingCodes char(8) = null,

            @EntryFees numeric(18,2) = null, 

            @EntryFeesCodes char(8) = null,

            @Miscellaneous numeric(18,2) = null, 

            @MiscellaneousCodes char(8) = null,

            @Account nvarchar(8) = null,

            @Comments ntext = null,

            @NewShowID                        uniqueidentifier              OUTPUT
,@UpdateUser varchar(120) = null, @UpdateTimestamp DateTime = null, @NewUpdateUser varchar(120)
)

AS

BEGIN

            IF @ShowID IS NULL

            BEGIN

 

                        SET @NewShowID = newid()

 

                        INSERT INTO user_Show(

                                    ShowID, HorseID, ShowName, ShowDate, DayRate, DayRateCodes, Transport, TransportCodes, Equipment, EquipmentCodes, Handling, HandlingCodes, ProRata, ProRataCodes, Grooming, GroomingCodes, EntryFees, EntryFeesCodes, Miscellaneous, MiscellaneousCodes, Account, Comments, UpdateUser, UpdateTimestamp

                        )

                        VALUES(

                                    @NewShowID, @HorseID, @ShowName, @ShowDate, @DayRate, @DayRateCodes, @Transport, @TransportCodes, @Equipment, @EquipmentCodes, @Handling, @HandlingCodes, @ProRata, @ProRataCodes, @Grooming, @GroomingCodes, @EntryFees, @EntryFeesCodes, @Miscellaneous, @MiscellaneousCodes, @Account, @Comments, @UpdateUser, @UpdateTimestamp

                        )

 

            END

            ELSE

            BEGIN

 

                        UPDATE user_Show SET 

                                    HorseID = @HorseID, 

                                    ShowName = @ShowName, 

                                    ShowDate = @ShowDate, 

                                    DayRate = @DayRate, 

                                    DayRateCodes = @DayRateCodes, 

                                    Transport = @Transport, 

                                    TransportCodes = @TransportCodes, 

                                    Equipment = @Equipment, 

                                    EquipmentCodes = @EquipmentCodes, 

                                    Handling = @Handling, 

                                    HandlingCodes = @HandlingCodes, 

                                    ProRata = @ProRata, 

                                    ProRataCodes = @ProRataCodes, 

                                    Grooming = @Grooming, 

                                    GroomingCodes = @GroomingCodes, 

                                    EntryFees = @EntryFees, 

                                    EntryFeesCodes = @EntryFeesCodes, 

                                    Miscellaneous = @Miscellaneous, 

                                    MiscellaneousCodes = @MiscellaneousCodes, 

                                    Account = @Account, 

                                    Comments = @Comments

									, UpdateUser = @NewUpdateUser, UpdateTimestamp = GETDATE()

                        WHERE 

                                    ShowID = @ShowID
									AND (UpdateUser = @UpdateUser AND UpdateTimestamp = @UpdateTimestamp)

						--Check For Concurrency Error
						IF (@@ROWCOUNT = 0) 
						BEGIN
							RAISERROR(52025, 16, 1)
						END

 

                        SET @NewShowID = @ShowID

 

            END

END
GO
/****** Object:  StoredProcedure [dbo].[usp_config_GetProcCodes]    Script Date: 10/25/2020 11:13:22 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_config_GetProcCodes]
(
@Order varchar(1)
)

AS

IF (@Order = 't')
BEGIN

	SELECT * FROM user_proc ORDER BY procType, procCode

END
ELSE
BEGIN

	IF (@Order = 'c')
	BEGIN

		SELECT * FROM user_proc ORDER BY procCode

	END
	ELSE
	BEGIN

		SELECT * FROM user_proc ORDER BY procDesc

	END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_config_UpdateProcCode]    Script Date: 10/25/2020 11:13:23 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_config_UpdateProcCode]
(
@Code varchar(4),
@Type varchar(1),
@Desc varchar(50),
@Cost numeric(18,2)
,@UpdateUser varchar(120) = null, @UpdateTimestamp DateTime = null, @NewUpdateUser varchar(120)
)

AS

IF EXISTS (SELECT 1 FROM user_proc WHERE ProcCode = @Code)
BEGIN

	UPDATE user_proc
	SET
		ProcType = @Type,
		ProcDesc = @Desc,
		Cost = @Cost
		, UpdateUser = @NewUpdateUser, UpdateTimestamp = GETDATE()
	WHERE
		ProcCode = @Code
		AND (UpdateUser = @UpdateUser AND UpdateTimestamp = @UpdateTimestamp)

		--Check For Concurrency Error
		IF (@@ROWCOUNT = 0) 
		BEGIN
			RAISERROR(52025, 16, 1)
		END


END
ELSE
BEGIN

	INSERT INTO user_proc (ProcCode, ProcType, ProcDesc, Cost, UpdateUser, UpdateTimestamp)
	VALUES (@Code, @Type, @Desc, @Cost, @NewUpdateUser, @UpdateTimestamp)

END
GO
/****** Object:  StoredProcedure [dbo].[usp_config_GetProcCode]    Script Date: 10/25/2020 11:13:22 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_config_GetProcCode]
(
@Code varchar(4)
)

AS

SELECT * FROM user_proc WHERE ProcCode = @Code
GO
/****** Object:  StoredProcedure [dbo].[usp_config_DeleteProcCode]    Script Date: 10/25/2020 11:13:22 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_config_DeleteProcCode]
(
@Code nvarchar(4)
)
AS

DELETE FROM user_proc WHERE ProcCode = @Code
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Contact_Insert_Or_Update]    Script Date: 10/25/2020 11:13:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_user_Contact_Insert_Or_Update]
(
@ContactID uniqueidentifier,
@Name        nvarchar(200),
@FirstName   nvarchar(100),
@Company   nvarchar(50),
@Address1   nvarchar(35),
@Address2   nvarchar(35),
@City           nvarchar(35),
@StateID      uniqueidentifier,
@Zip            nvarchar(20),
@CountryID uniqueidentifier,
@Phone1      nvarchar(25),
@Phone2      nvarchar(25),
@Fax            nvarchar(25),
@HorseNotes	nvarchar(50),
@UpdateUser varchar(120) = null, 
@UpdateTimestamp DateTime = null, 
@NewUpdateUser varchar(120)
)
AS

IF @ContactID IS NULL
    INSERT INTO user_Contact(ContactID, Name, FirstName, Company, Address1, Address2, City,
                   StateID, Zip, CountryID, Phone1, Phone2, Fax, HorseNotes, UpdateUser, UpdateTimestamp)
    VALUES(NewID(), @Name, @FirstName, @Company, @Address1, @Address2, @City,
                   @StateID, @Zip, @CountryID, @Phone1, @Phone2, @Fax, @HorseNotes, @UpdateUser, @UpdateTimestamp)
ELSE
    UPDATE user_Contact
    SET Name = @Name, FirstName = @FirstName, Company = @Company, Address1 = @Address1, Address2 = @Address2,
        City = @City, StateID = @StateID, Zip = @Zip, CountryID = @CountryID,
        Phone1 = @Phone1, Phone2 = @Phone2, Fax = @Fax, HorseNotes = @HorseNotes,
	UpdateUser = @NewUpdateUser, UpdateTimestamp = GETDATE()
    WHERE ContactID = @ContactID
	AND (UpdateUser = @UpdateUser AND UpdateTimestamp = @UpdateTimestamp)

    --Check For Concurrency Error
    IF (@@ROWCOUNT = 0) 
    BEGIN
	RAISERROR(52025, 16, 1)
    END
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Horse_Insert_Or_Update]    Script Date: 10/25/2020 11:13:46 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_Horse_Insert_Or_Update]

             @HorseID                              uniqueidentifier

            ,@HorseName                         nvarchar(50)

            ,@OldHorseName                   nvarchar(50)

            ,@RegistrationNumber             nvarchar(22)

            ,@LocalID                               uniqueidentifier

            ,@Title1                                   nvarchar(50)

            ,@Title2                                   nvarchar(50)

            ,@ColorID                               uniqueidentifier

            ,@GenderID                            uniqueidentifier

            ,@SireID                                 uniqueidentifier

            ,@SireName                            nvarchar(50)

            ,@DamID                                uniqueidentifier

            ,@DamName                           nvarchar(50)

            ,@Data1                                  nvarchar(50)

            ,@Data2                                  nvarchar(50)

            ,@DateBorn                             varchar(8)

            ,@DateDeceased                     varchar(8)

            ,@Comment                             nvarchar(70)

            ,@Breeder                               nvarchar(50)

            ,@Owner                                 nvarchar(50)

            ,@OwnerNumber                    nvarchar(8)

            ,@Breed                                  nvarchar(20)

            ,@Catalog                                nvarchar(20)

            ,@BloodTyped                                    bit

            ,@FreezeMarked                     bit

            ,@TrackingColorID                 uniqueidentifier

            ,@Success                               bit                                OUTPUT

            ,@NewHorseID                                   uniqueidentifier              OUTPUT

 ,@UpdateUser varchar(120) = null, @UpdateTimestamp DateTime = null, @NewUpdateUser varchar(120)

AS

 

DECLARE @Mode                 varchar(10)

DECLARE @ExistingHorseID uniqueidentifier

DECLARE @DoUpdate                      bit

DECLARE @LocalLookupAbrv          varchar(50)

 

SET @Success = 0

 

IF @HorseID IS NULL

            SET @Mode = 'add'

ELSE

            SET @Mode = 'update'

 

IF @Mode = 'add'

            BEGIN

            SELECT @HorseID = HorseID

            FROM user_Horse

            WHERE HorseName = @HorseName

            IF @HorseID IS NOT NULL

                        -- The horse name exists, can't do insert

                        SET @Success = 0

            ELSE

                        BEGIN

                        -- Get Local Code for this horse

                        SELECT @LocalLookupAbrv = LookupAbrv

                        FROM base_Lookup

                        WHERE LookupID = @LocalID

                        -- Get SireID as needed

                        IF @SireName IS NULL

                                    SET @SireID = NULL

                        ELSE

                                    EXEC usp_user_Horse_GetID_Or_Insert @SireName, @SireID OUTPUT

                        -- Get DamID as needed

                        IF @DamName IS NULL

                                    SET @DamID = NULL

                        ELSE

                                    EXEC usp_user_Horse_GetID_Or_Insert @DamName, @DamID OUTPUT

                        SET @NewHorseID = newid()

                        INSERT INTO user_Horse(HorseID, HorseName, TrackingColorID, RegistrationNumber, DateDeceased,

                                    DateBorn, GenderID, Data1, Data2, ColorID, Comment, Breeder, Owner, OwnerNumber, SireID,

                                    DamID, BloodTyped, FreezeMarked, Title1, Title2, Breed, Catalog, LocalID, UpdateUser, UpdateTimestamp)


                        VALUES(@NewHorseID, @HorseName, @TrackingColorID, @RegistrationNumber, @DateDeceased,

                                    @DateBorn, @GenderID, @Data1, @Data2, @ColorID, @Comment, @Breeder, @Owner, @OwnerNumber, @SireID,

                                    @DamID, @BloodTyped, @FreezeMarked, @Title1, @Title2, @Breed, @Catalog, @LocalID, @UpdateUser, @UpdateTimestamp)

                        SET @Success = 1

                        -- If we have a local horse, add Maintenance and History records

                        IF @LocalLookupAbrv <> '0'

                                    BEGIN

                                    INSERT INTO user_Maintenance(HorseID) VALUES(@NewHorseID)

                                    INSERT INTO user_History(HorseID) VALUES(@NewHorseID)

                                    END                

                        END

            END

 

IF @Mode = 'update'

            BEGIN

            IF UPPER(@OldHorseName) <> UPPER(@HorseName)

                        BEGIN

                        SELECT @ExistingHorseID = HorseID

                        FROM user_Horse

                        WHERE HorseName = @HorseName

                        IF @ExistingHorseID IS NOT NULL

                                    BEGIN

                                    SET @DoUpdate = 0

                                    SET @Success = 0

                                    END

                        ELSE

                                    SET @DoUpdate = 1

                        END

            ELSE

                        SET @DoUpdate = 1

            IF @DoUpdate = 1

                        BEGIN

                        IF @SireID IS NULL AND @SireName IS NOT NULL

                                    EXEC usp_user_Horse_GetID_Or_Insert @SireName, @SireID OUTPUT

                        IF @DamID IS NULL AND @DamName IS NOT NULL

                                    EXEC usp_user_Horse_GetID_Or_Insert @DamName, @DamID OUTPUT

                        UPDATE user_Horse

                        SET HorseName = UPPER(@HorseName), TrackingColorID = @TrackingColorID,

                                    RegistrationNumber = @RegistrationNumber, DateDeceased = @DateDeceased,

                                    DateBorn = @DateBorn, GenderID = @GenderID, Data1 = @Data1, Data2 = @Data2,

                                    ColorID = @ColorID, Comment = @Comment, Breeder = @Breeder, Owner = @Owner,

                                    OwnerNumber = @OwnerNumber, SireID = @SireID, DamID = @DamID,

                                    BloodTyped = @BloodTyped, FreezeMarked = @FreezeMarked, Title1 = @Title1,

                                    Title2 = @Title2, Breed = @Breed, Catalog = @Catalog, LocalID = @LocalID, UpdateUser = @NewUpdateUser, UpdateTimestamp = GETDATE()

                        WHERE HorseID = @HorseID
							AND (UpdateUser = @UpdateUser AND UpdateTimestamp = @UpdateTimestamp)

						--Check For Concurrency Error
						IF (@@ROWCOUNT = 0) 
						BEGIN
							RAISERROR(52025, 16, 1)
						END

                        SET @NewHorseID = @HorseID

                        SET @Success = 1

                        END

            END
GO
/****** Object:  StoredProcedure [dbo].[usp_user_History_GetByID]    Script Date: 10/25/2020 11:13:36 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_user_History_GetByID]
            @HorseID                               uniqueidentifier
AS
 
if not exists (select 1 from user_History where HorseID = @HorseID)
begin
	if exists (select 1 from user_horse where HorseID = @HorseID)
	begin
		INSERT INTO user_History (HorseID) VALUES (@HorseID)
	end
end

DECLARE @DateBorn varchar(10)
DECLARE @AgeCategory varchar(50)
DECLARE @OffsetMonth int


-- 1. Get @AgeCategory
SELECT @DateBorn = DateBorn
FROM user_Horse
WHERE HorseID = @HorseID

EXEC usp_calc_HorseAgeCategory @DateBorn, @AgeCategory OUTPUT

-- 2. Get @AgeOffset setting
SELECT @OffsetMonth = OffsetMonth
FROM config_AgeCategories
WHERE ConfigID = '{91AF1A80-7994-431E-8D6C-9D9B7CDAE4C1}'

DECLARE @ContactID uniqueidentifier

SELECT @ContactID = h.ContactID
FROM user_History h
WHERE HorseID = @HorseID

SELECT h.HorseID, h.SalesList, h.SalesPrice, h.DateAcquired, h.Cost, h.SellingPrice, h.ContactID,
            h.SalesNote1, h.SalesNote2, h.SpecialReportCodes, h.Notes, h.Comments, hh.HorseName, hh.DateSold,
            @AgeCategory AS AgeCategory, @OffsetMonth AS OffsetMonth
,h.UpdateUser, h.UpdateTimestamp
FROM user_History h
LEFT OUTER JOIN user_Horse hh ON h.HorseID = hh.HorseID
WHERE h.HorseID = @HorseID

EXEC usp_user_Contact_GetByID @ContactID

SELECT * FROM user_HorseSale WHERE HorseID = @HorseID ORDER BY SaleDate DESC
GO
/****** Object:  StoredProcedure [dbo].[usp_user_BreedingEntry_InsertOrUpdate]    Script Date: 10/25/2020 11:13:27 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_BreedingEntry_InsertOrUpdate]
(
	@EntryID uniqueidentifier = null, 
	@BreedingID uniqueidentifier = null, 
	@EntryDate DateTime, 
	@Codes char(5), 
	@Note1 nvarchar(50), 
	@Note2 nvarchar(50), 
	@Note3 nvarchar(50), 
	@Note4 nvarchar(50), 
	@Note5 nvarchar(50), 
	@Comments ntext,
	@NewEntryID uniqueidentifier OUTPUT
,@UpdateUser varchar(120) = null, @UpdateTimestamp DateTime = null, @NewUpdateUser varchar(120)
)
AS
BEGIN

	if (@EntryID IS NULL)
	BEGIN

		Set @NewEntryID = NewID()

		INSERT INTO user_BreedingCalendar
		(
			BreedingCalendarID, 
			BreedingID, 
			Date, 
			Codes, 
			Note1, 
			Note2, 
			Note3, 
			Note4, 
			Note5, 
			Comments
			, UpdateUser, UpdateTimestamp
		)
		VALUES 
		(
			@NewEntryID, 
			@BreedingID, 
			@EntryDate, 
			@Codes, 
			@Note1, 
			@Note2, 
			@Note3, 
			@Note4, 
			@Note5, 
			@Comments
			, @UpdateUser, @UpdateTimestamp
		)

		EXEC [dbo].[usp_user_BreedingEntry_UpdateBreedingStatus] @BreedingID = @BreedingID, @EntryCodes = @Codes, @EntryDate = @EntryDate
	END
	ELSE
	BEGIN

		UPDATE user_BreedingCalendar SET
			BreedingID = @BreedingID, 
			Date = @EntryDate, 
			Codes = @Codes, 
			Note1 = @Note1, 
			Note2 = @Note2, 
			Note3 = @Note3, 
			Note4 = @Note4, 
			Note5 = @Note5, 
			Comments = @Comments
			, UpdateUser = @NewUpdateUser, UpdateTimestamp = GETDATE()
		WHERE
			BreedingCalendarID = @EntryID
			AND (UpdateUser = @UpdateUser AND UpdateTimestamp = @UpdateTimestamp)

		--Check For Concurrency Error
		IF (@@ROWCOUNT = 0) 
		BEGIN
			RAISERROR(52025, 16, 1)
		END


		SET @NewEntryID = @EntryID

		EXEC [dbo].[usp_user_BreedingEntry_UpdateBreedingStatus] @BreedingID = @BreedingID, @EntryCodes = @Codes, @EntryDate = @EntryDate

	END

END
GO
/****** Object:  StoredProcedure [dbo].[usp_user_ShowClass_Insert_Or_Update]    Script Date: 10/25/2020 11:13:59 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_ShowClass_Insert_Or_Update]

(

            @ClassID uniqueidentifier = NULL, 

            @ShowID uniqueidentifier, 

            @Class nvarchar(50), 

            @Awards nvarchar(30), 

            @Judge nvarchar(30), 

            @Points numeric(18,3), 

            @Score numeric(18,4), 

            @Percent numeric(18,5), 

            @Comments ntext,

            @NewClassID uniqueidentifier OUTPUT
,@UpdateUser varchar(120) = null, @UpdateTimestamp DateTime = null, @NewUpdateUser varchar(120)
)

AS

BEGIN

            IF @ClassID IS NULL

            BEGIN

 

                        SET @NewClassID = newid()

 

                        INSERT INTO user_ShowClass(

                                    ClassID, ShowID, Class, Awards, Judge, Points, Score, [Percent], Comments, UpdateUser, UpdateTimestamp

                        )

                        VALUES(

                                    @NewClassID, @ShowID, @Class, @Awards, @Judge, @Points, @Score, @Percent, @Comments, @UpdateUser, @UpdateTimestamp

                        )

 

            END

            ELSE

            BEGIN

 

                        UPDATE user_ShowClass SET 

                                    ShowID = @ShowID, 

                                    Class = @Class,

                                    Awards = @Awards, 

                                    Judge = @Judge, 

                                    Points = @Points, 

                                    Score = @Score, 

                                    [Percent] = @Percent, 

                                    Comments = @Comments
									, UpdateUser = @NewUpdateUser, UpdateTimestamp = GETDATE()

                        WHERE 

                                    ClassID = @ClassID
									AND (UpdateUser = @UpdateUser AND UpdateTimestamp = @UpdateTimestamp)
 

						--Check For Concurrency Error
						IF (@@ROWCOUNT = 0) 
						BEGIN
							RAISERROR(52025, 16, 1)
						END


                        SET @NewClassID = @ClassID

 

            END

 

            --update total points

            EXEC usp_user_ShowClass_RoleUpPoints @ShowClassID=@NewClassID

 

END
GO
/****** Object:  StoredProcedure [dbo].[usp_user_Show_GetByID]    Script Date: 10/25/2020 11:13:56 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[usp_user_Show_GetByID] 

( 

        @ShowID UniqueIdentifier 

) 

AS 

BEGIN 

  

         SELECT 

                 ShowID,  

                 HorseID,  

                 ShowName,  

                 ShowDate,  

                 DayRate,  

                 DayRateCodes,  

                 Transport,  

                 TransportCodes,  

                 Equipment,  

                 EquipmentCodes,  

                 Handling,  

                 HandlingCodes,  

                 ProRata,  

                 ProRataCodes,  

                 Grooming,  

                 GroomingCodes,  

                 EntryFees,  

                 EntryFeesCodes,  

                 Miscellaneous,  

                 MiscellaneousCodes,  

                 Points,  

                 Account,  

                 Comments,
				UpdateUser, UpdateTimestamp

         FROM 

                 user_Show 

         WHERE 

                 ShowID = @ShowID 

  

         EXEC usp_user_ShowClass_GetByShowID @ShowID = @ShowID 

  

END
GO

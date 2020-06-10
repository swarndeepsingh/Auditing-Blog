
CREATE proc [DBLog].[usp_AddNewLocation] @locationID int, @locationPath varchar(4000), @isMapped bit, @mapName varchar(50)=null, @uName varchar(500)=null, @pword varchar(8000)=null
as
set nocount on
insert into dblog.location_details 
select @locationID, @locationPath, @isMapped, @mapName, @uName, @pword
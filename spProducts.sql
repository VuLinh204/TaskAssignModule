USE Paradise_Beta_Tai2
GO
if object_id('[dbo].[spProducts]') is null
	EXEC ('CREATE PROCEDURE [dbo].[spProducts] as select 1')
GO
ALTER PROCEDURE [dbo].[spProducts]--
    @LoginID int           =3, @LanguageID varchar(5) ='VN', --
    @zxc123  nVarchar(150) ='', @TempTableAPIName nVarchar(150) =''
as
declare @sql varchar(max) =N'select * from Products'
if len(@TempTableAPIName)>0
    set @sql=N'select * into '+@TempTableAPIName+N' from Products'
exec(@sql)
GO
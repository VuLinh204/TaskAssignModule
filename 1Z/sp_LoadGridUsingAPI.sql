USE Paradise_Beta_Tai2
GO
if object_id('[dbo].[sp_LoadGridUsingAPI]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_LoadGridUsingAPI] as select 1')
GO
--exec sp_LoadGridUsingAPI @ProcName='spDailyAttendanceData', @ProcParam = '@FromDate=N''2025-12-01 00:00:00'',@ToDate=N''2025-12-30 23:59:59'',@LoginID=3,@EmployeeID_Pram=N''-1'',@Normal=0,@NoIn=0,@NoOut=0,@NoInNoOut=0,@WorkOnHolidayJM=0,@Leave=0,@Holiday=0,@Abnormal=0'
--exec sp_LoadGridUsingAPI @ProcName='spDailyAttendanceData', @ProcParam = '@FromDate=N''2025-12-01 00:00:00'',@ToDate=N''2025-12-30 23:59:59'',@LoginID=3,@EmployeeID_Pram=N''-1'',@Normal=0,@NoIn=0,@NoOut=0,@NoInNoOut=0,@WorkOnHolidayJM=0,@Leave=0,@Holiday=0,@Abnormal=0', @Sort = 'ORDER BY In_0 ASC,STT ASC', @RequireTotalCount = 1, @TotalSummary = 'count(EmployeeID) as EmployeeID_COUNT, count(FullName) as FullName_COUNT, count(STT) as STT_COUNT, count(CASE WHEN Approved = 1 THEN 1 END) as Approved_COUNT, sum(WorkingTime_0) as WorkingTime_0_SUM, sum(WorkingTimeTotal) as WorkingTimeTotal_SUM, sum(WorkingDay) as WorkingDay_SUM, sum(LvAmount) as LvAmount_SUM', @Take = 25, @Skip = 0

ALTER PROCEDURE [dbo].[sp_LoadGridUsingAPI]--
    @LoginID           int           =3, --
    @LanguageID        varchar(5)    ='VN', --
    @ProcName          nVarchar(200) ='', --
    @ProcParam         nVarchar(max) ='', --
    @Take              int           =0, --
    @Skip              int           =0, --
    @RequireTotalCount bit           =0, --
    @TotalSummary      nVarchar(max) ='', --
    @Sort              nVarchar(500) ='', --
    @SearchValue       nVarchar(150) ='', --
    @ColumnSearch      nVarchar(max) ='', --
    @Filters           nVarchar(max) ='', --
    @SelectGroup       nVarchar(max) ='', --
    @GroupBy           nVarchar(max) ='', --
    @value           sql_Variant = null
as begin
    set noCount on
    if not exists (select * from dbo.tblLanguage where LanguageID=@LanguageID)
        set @LanguageID='VN'
    declare @TableDataName varchar(max) =@ProcName+cast(@LoginID as nVarchar)+@LanguageID
    declare @ProcQuery nVarchar(max), @sql nVarchar(max), @Condition nVarchar(max) =N' WHERE ';
	declare @object_id int = object_id(@TableDataName)
	declare @int int = 0

	if @value is not null and @object_id is null
	begin
		set @int = 1
		goto getData
	end
	paradise:
	if @value is not null
	begin
		if(isNull(@ColumnSearch,'') = '')
		begin
			select top 1 @ColumnSearch+=(','+[name])
			from sys.columns c
			where c.object_id=@object_id
			if len(@ColumnSearch) > 1
				set @ColumnSearch = right(@ColumnSearch,len(@ColumnSearch)-1)
		end
			
		set @sql = N'select * from '+@TableDataName+' where '+@ColumnSearch +' = @value '
		exec sp_executesql @sql, N'@value sql_Variant', @value = @value;
		return
	end

	getData:
    if object_Id(@TableDataName) is null
       or(@RequireTotalCount=1 and @Filters='')begin
        set @ProcQuery=N'
		if object_id('''+@TableDataName+N''') is not null Drop Table '+@TableDataName+N'
		EXEC '+@ProcName
		if len(@ProcParam) > 0
			set @ProcQuery+=N' '+@ProcParam+N','
		set @ProcQuery+=N' @TempTableAPIName = '''+@TableDataName+N''';'
        print(@ProcQuery)
        exec(@ProcQuery)
		if @int = 1
		begin
			set @int = 2
			set @object_id = object_id(@TableDataName)
			goto paradise
		end
    end
    if(isNull(@ColumnSearch,'') = '')
	begin
		select @ColumnSearch+=(','+[name])
		from sys.columns c
		where c.object_id=@object_id
		if len(@ColumnSearch) > 1
			set @ColumnSearch = right(@ColumnSearch,len(@ColumnSearch)-1)
	end
    if(@SearchValue<>'' and @ColumnSearch<>'')
        goto ConditionSearch
    if(@Filters<>'')
        goto ConditionFilters
    goto ConditionEnd
    ConditionSearch:
    if object_Id('tempdb..#temptable2') is not null
        drop table #temptable2
    select *
      into #temptable2
      from SplitString(@ColumnSearch, ',')
    declare @StuffCondition nVarchar(max) =N'';
    if(@SearchValue like '%;%')begin
        if object_Id('tempdb..#temp') is not null
            drop table #temp
        select *
          into #temp
          from SplitString(@SearchValue, ';')
         where Items<>''
        update #temp
           set Items=N'%'+TRIM(Items)+N'%'
        declare @AllStuffCondition nVarchar(max) =N''
        set @StuffCondition=(select stuff((select ' OR cast('+Items+' as nvarchar(max)) COLLATE Latin1_General_CI_AI like N''[REPLACE_VALUE_STRING]'' ' from #temptable2 for xml path('')), 1, 3, ''))
        set @AllStuffCondition=(select stuff((select ' OR ('+replace(@StuffCondition, '[REPLACE_VALUE_STRING]', Items)+')' from #temp for xml path('')), 1, 3, ''))
        set @Condition += @AllStuffCondition
        goto ConditionEnd
    end
    set @SearchValue=N'%'+@SearchValue+N'%'
    set @StuffCondition=(select stuff((select ' OR cast('+Items+' as nvarchar(max)) COLLATE Latin1_General_CI_AI like N'''+@SearchValue+''' ' from #temptable2 for xml path('')), 1, 3, ''))
    set @Condition += @StuffCondition
    goto ConditionEnd
    ConditionFilters:
    set @Condition += @Filters
    ConditionEnd:
    if(@TotalSummary<>'')begin
        if object_Id('tempdb..#temptable') is not null
            drop table #temptable;
        with CTE as (select value, charIndex('(', value) as open_bracket, charIndex(')', value) as close_bracket from string_Split(@TotalSummary, ','))
        select lTrim(rTrim(substring(value, open_bracket+1, close_bracket-open_bracket-1))) as ColumnName, value
          into #temptable
          from CTE
         where open_bracket>0
               and close_bracket>0
        set @TotalSummary=
        (
        select stuff(
               (
               select ','+value
                 from #temptable
                where ColumnName in(select COLUMN_NAME from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME=N''+@TableDataName+N'')
               for xml path('')
               ),   1, 1, ''
                    )
        )
    end
    select @Condition=N''
     where @Condition like ' WHERE '
    if(@GroupBy<>'')begin
        set @sql=N'SELECT	'+@SelectGroup+N' FROM '+@TableDataName+N' '+@Condition+N' '+@GroupBy+N' ORDER BY ' --
                 +replace(@GroupBy, 'GROUP BY ', '')+N' '+case when @Take>0 then 'OFFSET '+cast(@Skip as nVarchar)+' ROWS FETCH NEXT '+cast(@Take as nVarchar)+' ROWS ONLY;'
                                                          else ''
                                                               end+N''
        goto runSQL
    end
	else
		if isNull(@Sort,'') = ''
		set @Sort = 'ORDER by 1'
    set @sql=N'
	SELECT * FROM '+@TableDataName+N' '+@Condition+N' '+@Sort+N' '+case when @Take>0 then 'OFFSET ' --
                                                                                          +cast(@Skip as nVarchar)+' ROWS FETCH NEXT '+cast(@Take as nVarchar)+' ROWS ONLY'
                                                                   else ''
                                                                        end+N';

	'+case when @RequireTotalCount=1 then 'SELECT COUNT(1) as TotalCount FROM '+@TableDataName+N' '+@Condition+' '
      else ''
           end+N';

	'+case when @TotalSummary<>'' then 'SELECT '+@TotalSummary+N' FROM '+@TableDataName+N''
      else ''
           end+N'
	'
    runSQL:
    print(@sql)
    exec(@sql)
end
GO
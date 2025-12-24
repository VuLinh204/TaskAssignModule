USE Paradise_Beta_Tai2
GO
if object_id('[dbo].[sptblCommonControlType_Signed]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sptblCommonControlType_Signed] as select 1')
GO
ALTER PROCEDURE [dbo].[sptblCommonControlType_Signed]@TableName varchar(256) = ''
as
if object_Id('tempdb..#temptable') is not null drop table #temptable
select t.*,cast('' as nVarchar(max)) html,cast('' as nVarchar(max)) loadUI,cast('' as nVarchar(max)) loadData
,cast(c.column_id as nVarchar(64)) columnId
into #temptable
from dbo.tblCommonControlType_Signed t
left join sys.columns c on c.name = t.[ColumnName] and c.object_id = object_Id(t.TableEditor)
where TableName=@TableName

update #temptable set loadUI = N'
let %columnName% = $("#%columnName%").dxTextBox({
}).dxTextBox("instance")
' where [Type] = 'hpaControlText'
update #temptable set loadUI = N'
let %columnName%TimeOut
let %columnName%Key
async function %columnName%onValueChanged() {
    const dataJSON = JSON.stringify([%tableId%, %columnId%, %columnName%.option("value")])
    const json = await saveFunction(dataJSON, JSON.stringify(%columnName%Key))
    const results = (json.data && json.data[0]) || []
    const dtError = json.data[json.data.length - 1]
    if (dtError.length > 0) {
        uiManager.showAlert({ type: "error", message: dtError.Message || "Lưu thất bại" })
        return
    }
    uiManager.showAlert({ type: "success", message: "%status%" })
    //%columnName%Key     = { %columnId%: "NV02" }
}
let %columnName% = $("#%columnName%").dxTextBox({
    onValueChanged: async (e) => {
        if (%columnName%TimeOut)
            clearTimeout(%columnName%TimeOut)
        %columnName%onValueChanged()
    },
    onKeyUp(e) {
        if (%columnName%TimeOut)
            clearTimeout(%columnName%TimeOut)
        %columnName%TimeOut = setTimeout(async () => %columnName%onValueChanged(), 100);
    },
}).dxTextBox("instance")
' where [Type] = 'hpaControlText' and AutoSave = 1
update #temptable set loadUI = N'
let %columnName% = $("#%columnName%").dxTextBox({
    readOnly: true,
}).dxTextBox("instance")
' where [Type] = 'hpaControlText' and readOnly=1
update #temptable set loadData =N'
%columnName%._suppressValueChangeAction()
%columnName%.option("value", obj.%columnName%)
%columnName%._resumeValueChangeAction()
%columnName%Key = { %columnIdKey%: obj.%columnNameKey% }' where [Type] = 'hpaControlText'
update #temptable set loadData =N'
%columnName%._suppressValueChangeAction()
%columnName%.option("value", obj.%columnName%)
%columnName%._resumeValueChangeAction()
%columnName%Key = { 1: obj.EmployeeID }' where [Type] = 'hpaControlText'
--xử lý key
update #temptable set html =N'
<div id="%columnName%"></div>' where [Type] = 'hpaControlText'

declare @object_Id varchar(max) = cast(object_Id(@TableName) as nVarchar(64))
update #temptable set loadUI =replace(loadUI,'%columnName%',[ColumnName]) where [Type] = 'hpaControlText'
update #temptable set loadUI =replace(loadUI,'%tableId%',@object_Id) where [Type] = 'hpaControlText'
update #temptable set loadUI =replace(loadUI,'%columnId%',columnId) where [Type] = 'hpaControlText'
update #temptable set loadData =replace(loadData,'%columnName%',[ColumnName]) where [Type] = 'hpaControlText'
update #temptable set loadData =replace(loadData,'%columnId%',columnId) where [Type] = 'hpaControlText'
update #temptable set html =replace(html,'%columnName%',[ColumnName]) where [Type] = 'hpaControlText'
--

declare @html nVarchar(max) = N''
declare @loadUI nVarchar(max) = N''
declare @loadData nVarchar(max) = N''
select @html+=html,@loadUI+=loadUI,@loadData+=loadData from #temptable
declare @nsql nVarchar(max) = N'
'+@html+'
<script>
    (() => {
        '+@loadUI+N'
        function loadData() {
            AjaxHPAParadise({
                data: {
                    name: "%tableName%",
                    param: []
                },
                success: function (res) {
                    const json = typeof res === "string" ? JSON.parse(res) : res
                    const results = (json.data && json.data[0]) || []
                    const obj = results[0]
                    '+@loadData+N'
                }
            });
        }
		loadData()
    })();
</script>'
set @nsql =replace(@nsql,'%tableName%',@TableName)
select @nsql htmlProc
GO
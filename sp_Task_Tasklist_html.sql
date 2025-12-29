USE Paradise_Beta_Tai2
GO

-- ========================================================================
-- CONTROL 1: SELECTBOX (Single Select with Add New)
-- ========================================================================

if object_id('[dbo].[sp_Task_Tasklist_html]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_Task_Tasklist_html] as select 1')
GO

ALTER PROCEDURE [dbo].[sp_Task_Tasklist_html]
    @LoginID    INT = 3,
    @LanguageID VARCHAR(2) = 'VN',
    @isWeb      INT = 1
AS
BEGIN
SET NOCOUNT ON;
DECLARE @html NVARCHAR(MAX);
SET @html = N'
    
    <div id="gridMyTasks" style="height: 100%;"></div>
    <script>
        (() => {
            var currentRecordID;
            let DataSource = [];
                if ($("#gridMyTasks").length === 0) {
                    $("<div>", { id: "gridMyTasks" }).appendTo("body");
                }
                let gridMyTasksInstance;
                let gridMyTasksDataSource = [];
                function loadUIgridMyTasks() {
                    const $container = $("#gridMyTasks");
                    const store = new DevExpress.data.ArrayStore({ data: gridMyTasksDataSource, key: "TaskID" });
                    /*BEGIN_DX*/
                    gridMyTasksInstance = $("<div>").appendTo($container).dxDataGrid({
                        dataSource: store,
                        keyExpr: "TaskID",
                        height: "100%",
                        showBorders: true,
                        showRowLines: true,
                        rowAlternationEnabled: true,
                        hoverStateEnabled: true,
                        columnAutoWidth: true,
                        allowColumnReordering: true,
                        allowColumnResizing: true,
                        wordWrapEnabled: true,
                        paging: { enabled: true, pageSize: 20 },
                        pager: { visible: true, allowedPageSizes: [10, 20, 50], showPageSizeSelector: true, showInfo: true },
                        filterRow: { visible: true, applyFilter: "auto" },
                        searchPanel: { visible: true, width: 200, placeholder: "Tìm kiếm..." },
                        headerFilter: { visible: true },
                        columnChooser: { enabled: true, mode: "select" },
                        columns: [
    { dataField: "TaskName", caption: "Tên công việc", width: 150, allowEditing: true },
    { dataField: "Status", caption: "Trạng thái", width: 150, allowEditing: true },
    { dataField: "AssignPriority", caption: "Ưu tiên", width: 150, allowEditing: true },
    { dataField: "StartDate", caption: "Ngày giao", width: 150, allowEditing: true },
    { dataField: "EndDate", caption: "Hạn hoàn thành", width: 150, allowEditing: true },
    { dataField: "Progress", caption: "Tiến độ (%)", width: 150, allowEditing: true },
    { dataField: "TaskID", caption: "Mã CV", width: 150, allowEditing: true },
    { dataField: "EmployeeID", caption: "Người thực hiện", width: 150, allowEditing: true }
],
                        summary: {
                            totalItems: [{
                                column: "gridMyTasks",
                                summaryType: "count",
                                displayFormat: "Tổng: {0} bản ghi"
                            }],
                            groupItems: [{
                                column: "gridMyTasks",
                                summaryType: "count",
                                displayFormat: "{0}"
                            }]
                        },
                        onRowUpdating: async function(e) {
                            const col = Object.keys(e.newData)[0];
                            let newVal = e.newData[col];
                            try {
                                const dataJSON = JSON.stringify(["%tableId%", [col], [newVal]]);
                                const idValuesJSON = JSON.stringify([[e.key], "gridMyTasks"]);
                                const json = await saveFunction(dataJSON, idValuesJSON);
                                const dtError = json.data[json.data.length - 1] || [];
                                if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                                    uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "Lưu thất bại" });
                                    e.cancel = true;
                                    return;
                                }
                                const rowIdx = gridMyTasksInstance.getRowIndexByKey(e.key);
                                gridMyTasksInstance.cellValue(rowIdx, col, newVal);
                                uiManager.showAlert({ type: "success", message: "Lưu thành công" });
                            } catch (err) {
                                e.cancel = true;
                                console.error("Grid save error:", err);
                                uiManager.showAlert({ type: "error", message: "Lỗi lưu dữ liệu" });
                            }
                        }
                    }).dxDataGrid("instance");
                    /*END_DX*/
                    return {
                        setValue: val => {
                            gridMyTasksDataSource = val || [];
                            if (gridMyTasksInstance) {
                                gridMyTasksInstance.option("dataSource", gridMyTasksDataSource);
                                gridMyTasksInstance.refresh();
                            }
                        },
                        getValue: () => gridMyTasksDataSource,
                        getInstance: () => gridMyTasksInstance
                    };
                }

            //Hàm tải dữ liệu
            function loadData() {
                AjaxHPAParadise({
                    data: {
                        name: "sp_Task_GetMyTasks",
                        param: []
                    },
                    success: function (res) {
                        const json = typeof res === "string" ? JSON.parse(res) : res
                        const results = (json.data && json.data[0]) || []

                        if (0=== 1) {
                          Instance.option("dataSource", results);
                        } else {
                            const obj = results[0]
                            currentRecordID = obj.gridMyTasks || currentRecordID;
                            DataSource = results;
                            console.log("DataSource", DataSource);
                            let gridMyTasksControl
                            gridMyTasksControl = loadUIgridMyTasks();
                            gridMyTasksControl.setValue(obj.gridMyTasks);
                            currentRecordID = obj.gridMyTasks
                        }
                    }
                });
            }
            loadData()
        })();
    </script>
';
    SELECT @html AS html;
END
GO

EXEC sp_GenerateHTMLScript 'sp_Task_Tasklist_html'
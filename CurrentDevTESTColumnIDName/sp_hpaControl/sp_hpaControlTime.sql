USE Paradise_Dev
GO
if object_id('[dbo].[sp_hpaControlTime]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_hpaControlTime] as select 1')
GO

ALTER PROCEDURE [dbo].[sp_hpaControlTime]
    @TableName VARCHAR(256) = ''
AS
BEGIN
    -- =========================================================================
    -- hpaControlTime - AutoSave Mode
    -- =========================================================================
    UPDATE #temptable SET loadUI = N'
        let Instance%ColumnName%%UID% = null; 
        let %ColumnName%TimeOut;

        async function TimeBoxSaveLogic() {
            let val = Instance%ColumnName%%UID%.option("value");
            const timeString = val ? DevExpress.localization.formatDate(val, "HH:mm") : "";
            const dataJSON = JSON.stringify(["%tableId%", ["%ColumnName%"], [timeString]]);
            
            // Context-aware record IDs (giống TextBox)
            let id1 = currentRecordID_%ColumnIDName%;
            if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
                id1 = cellInfo.data["%ColumnIDName%"] || id1;
            }
            let currentRecordIDValue = [id1];
            let currentRecordID = ["%ColumnIDName%"];

            // Xử lý multiple IDs nếu ColumnIDName chứa dấu phẩy
            if ("%ColumnIDName%".includes(",")) {
                const ids = "%ColumnIDName%".split(",").map(id => id.trim());
                ids.forEach(id => {
                    let idVal = window["currentRecordID_" + id];
                    if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data && cellInfo.data[id] !== undefined) {
                        idVal = cellInfo.data[id] || idVal;
                    }
                    currentRecordIDValue.push(idVal);
                });
                currentRecordID = "%ColumnIDName%".split(",").map(id => id.trim());
            }

            const idValsJSON = JSON.stringify([currentRecordIDValue, currentRecordID]);
            const json = await saveFunction(dataJSON, idValsJSON);
            const dtError = json.data[json.data.length - 1] || [];
            
            if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "Lưu thất bại" });
            }
            
            if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                try {
                    const grid = cellInfo.component;
                    grid.cellValue(cellInfo.rowIndex, "%ColumnName%", val);
                    grid.repaint();
                } catch (syncErr) {
                    console.warn("[Grid Sync] TimeBox %ColumnName%%UID%: Không thể sync grid:", syncErr);
                }
            }
        }

        Instance%ColumnName%%UID% = $("#%UID%").dxDateBox({
            type: "time",
            displayFormat: "HH:mm",
            pickerType: "rollers",
            useMaskBehavior: true,
            showClearButton: false,
            width: "100%",
            elementAttr: { class: "hpa-dx-timebox-inline" },
            onValueChanged: async (e) => {
                clearTimeout(%ColumnName%TimeOut);
                e.event && await TimeBoxSaveLogic();
            },
            onKeyUp: (e) => {
                clearTimeout(%ColumnName%TimeOut);
                %ColumnName%TimeOut = setTimeout(async () => TimeBoxSaveLogic(), 1000);
            }
        }).dxDateBox("instance");
    '
    WHERE [Type] = 'hpaControlTime' AND AutoSave = 1

    -- =========================================================================
    -- hpaControlTime - ReadOnly Mode
    -- =========================================================================
    UPDATE #temptable SET loadUI = N'
        let Instance%ColumnName%%UID% = null;
        Instance%ColumnName%%UID% = $("#%UID%").dxDateBox({
            type: "time",
            displayFormat: "HH:mm",
            pickerType: "rollers",
            useMaskBehavior: true,
            showClearButton: true,
            width: "100%",
            elementAttr: { class: "hpa-dx-timebox-inline" },
            readOnly: true
        }).dxDateBox("instance");
    '
    WHERE [Type] = 'hpaControlTime' AND ReadOnly = 1

    -- =========================================================================
    -- hpaControlTime - Non-AutoSave Mode (configurable)
    -- =========================================================================
    UPDATE #temptable SET loadUI = N'
        let Instance%ColumnName%%UID% = null; 
        let %ColumnName%TimeOut;
        let _autoSave%ColumnName%%UID% = false;
        let _readOnly%ColumnName%%UID% = false;

        async function TimeBoxSaveLogic%ColumnName%() {
            let val = Instance%ColumnName%%UID%.option("value");
            const timeString = val ? DevExpress.localization.formatDate(val, "HH:mm") : "";
            const dataJSON = JSON.stringify(["%tableId%", ["%ColumnName%"], [timeString]]);
            
            // Context-aware record IDs (giống TextBox)
            let id1 = currentRecordID_%ColumnIDName%;
            if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
                id1 = cellInfo.data["%ColumnIDName%"] || id1;
            }
            let currentRecordIDValue = [id1];
            let currentRecordID = ["%ColumnIDName%"];

            // Xử lý multiple IDs nếu ColumnIDName chứa dấu phẩy
            if ("%ColumnIDName%".includes(",")) {
                const ids = "%ColumnIDName%".split(",").map(id => id.trim());
                ids.forEach(id => {
                    let idVal = window["currentRecordID_" + id];
                    if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data && cellInfo.data[id] !== undefined) {
                        idVal = cellInfo.data[id] || idVal;
                    }
                    currentRecordIDValue.push(idVal);
                });
                currentRecordID = "%ColumnIDName%".split(",").map(id => id.trim());
            }

            const idValsJSON = JSON.stringify([currentRecordIDValue, currentRecordID]);

            try {
                const json = await saveFunction(dataJSON, idValsJSON);
                const dtError = json.data[json.data.length - 1] || [];
                
                if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                    if ("%IsAlert%" === "1") {
                        uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "Lưu thất bại" });
                    }
                } else {
                    if ("%IsAlert%" === "1") {
                        uiManager.showAlert({ type: "success", message: "Lưu thành công" });
                    }
                }

                if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                    try {
                        const grid = cellInfo.component;
                        grid.cellValue(cellInfo.rowIndex, "%ColumnName%", val);
                        grid.repaint();
                    } catch (syncErr) {
                        console.warn("[Grid Sync] TimeBox %ColumnName%%UID%: Error", syncErr);
                    }
                }
            } catch (err) {
                console.error("TimeBox Save Error:", err);
            }
        }

        Instance%ColumnName%%UID% = $("#%UID%").dxDateBox({
            type: "time",
            displayFormat: "HH:mm",
            pickerType: "rollers",
            useMaskBehavior: true,
            showClearButton: true,
            width: "100%",
            elementAttr: { class: "hpa-dx-timebox-inline" },
            readOnly: _readOnly%ColumnName%%UID%,
            onValueChanged: async (e) => {
                if (_autoSave%ColumnName%%UID%) {
                    clearTimeout(%ColumnName%TimeOut);
                    e.event && await TimeBoxSaveLogic%ColumnName%();
                } else {
                    if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                        const grid = cellInfo.component;
                        grid.cellValue(cellInfo.rowIndex, "%ColumnName%", e.value);
                    }
                }
            },
            onKeyUp: (e) => {
                if (_autoSave%ColumnName%%UID%) {
                    clearTimeout(%ColumnName%TimeOut);
                    %ColumnName%TimeOut = setTimeout(async () => TimeBoxSaveLogic%ColumnName%(), 1000);
                }
            }
        }).dxDateBox("instance");
    '
    WHERE [Type] = 'hpaControlTime' AND (AutoSave = 0 OR AutoSave IS NULL) AND (ReadOnly = 0 OR ReadOnly IS NULL)
END
GO
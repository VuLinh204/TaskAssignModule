USE Paradise_Dev
GO
if object_id('[dbo].[sp_hpaControlNumber]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_hpaControlNumber] as select 1')
GO

ALTER PROCEDURE [dbo].[sp_hpaControlNumber]
    @TableName VARCHAR(256) = ''
AS
BEGIN
    -- =========================================================================
    -- hpaControlNumber - AUTOSAVE MODE
    -- =========================================================================
    UPDATE #temptable SET loadUI = N'
        let Instance%ColumnName%%UID% = null; 
        let %ColumnName%TimeOut;

        async function NumberBoxSaveLogic() {
            let val = Instance%ColumnName%%UID%.option("value");
            const dataJSON = JSON.stringify(["%tableId%", ["%ColumnName%"], [val]]);
            
            // Context-aware record IDs
            let id1 = currentRecordID_%ColumnIDName%;
            if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
                id1 = cellInfo.data["%ColumnIDName%"] || id1;
            }
            let currentRecordIDValue = [id1];
            let currentRecordID = ["%ColumnIDName%"];

            if ("%ColumnIDName2%" && "%ColumnIDName2%".trim() !== "") {
                let id2 = currentRecordID_%ColumnIDName2%;
                if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
                    id2 = cellInfo.data["%ColumnIDName2%"] || id2;
                }
                currentRecordIDValue.push(id2);
                currentRecordID.push("%ColumnIDName2%");
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
                    console.warn("[Grid Sync] NumberBox %ColumnName%%UID%: Không thể sync grid:", syncErr);
                }
            }
        }

        Instance%ColumnName%%UID% = $("#%UID%").dxNumberBox({
            format: "#,##0",
            showSpinButtons: false,
            showClearButton: false,
            width: "100%",
            elementAttr: { class: "hpa-dx-numberbox-inline" },
            onValueChanged: async (e) => {
                clearTimeout(%ColumnName%TimeOut);
                e.event && await NumberBoxSaveLogic();
            },
            onKeyUp: (e) => {
                clearTimeout(%ColumnName%TimeOut);
                %ColumnName%TimeOut = setTimeout(async () => NumberBoxSaveLogic(), 1000);
            }
        }).dxNumberBox("instance");
    '
    WHERE [Type] = 'hpaControlNumber' AND AutoSave = 1;

    -- =========================================================================
    -- hpaControlNumber - READONLY MODE
    -- =========================================================================
    UPDATE #temptable SET loadUI = N'
        Instance%ColumnName%%UID% = $("#%UID%").dxNumberBox({
            format: "#,##0",
            showSpinButtons: false,
            showClearButton: false,
            width: "100%",
            elementAttr: { class: "hpa-dx-numberbox-inline" },
            readOnly: true
        }).dxNumberBox("instance");
    '
    WHERE [Type] = 'hpaControlNumber' AND ReadOnly = 1;

    -- =========================================================================
    -- hpaControlNumber - NON-AUTOSAVE MODE
    -- =========================================================================
    UPDATE #temptable SET loadUI = N'
        let Instance%ColumnName%%UID% = null; 
        let %ColumnName%TimeOut;
        let _autoSave%ColumnName%%UID% = false;
        let _readOnly%ColumnName%%UID% = false;

        async function NumberBoxSaveLogic%ColumnName%() {
            let val = Instance%ColumnName%%UID%.option("value");
            const dataJSON = JSON.stringify(["%tableId%", ["%ColumnName%"], [val]]);
            
            // Context-aware record IDs
            let id1 = currentRecordID_%ColumnIDName%;
            if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
                id1 = cellInfo.data["%ColumnIDName%"] || id1;
            }
            let currentRecordIDValue = [id1];
            let currentRecordID = ["%ColumnIDName%"];

            if ("%ColumnIDName2%" && "%ColumnIDName2%".trim() !== "") {
                let id2 = currentRecordID_%ColumnIDName2%;
                if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.data) {
                    id2 = cellInfo.data["%ColumnIDName2%"] || id2;
                }
                currentRecordIDValue.push(id2);
                currentRecordID.push("%ColumnIDName2%");
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
                        console.warn("[Grid Sync] NumberBox %ColumnName%%UID%: Error", syncErr);
                    }
                }
            } catch (err) {
                console.error("NumberBox Save Error:", err);
            }
        }

        Instance%ColumnName%%UID% = $("#%UID%").dxNumberBox({
            format: "#,##0",
            showSpinButtons: false,
            showClearButton: false,
            width: "100%",
            elementAttr: { class: "hpa-dx-numberbox-inline" },
            readOnly: _readOnly%ColumnName%%UID%,
            onValueChanged: async (e) => {
                if (_autoSave%ColumnName%%UID%) {
                    clearTimeout(%ColumnName%TimeOut);
                    e.event && await NumberBoxSaveLogic%ColumnName%();
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
                    %ColumnName%TimeOut = setTimeout(async () => NumberBoxSaveLogic%ColumnName%(), 1000);
                }
            }
        }).dxNumberBox("instance");
    '
    WHERE [Type] = 'hpaControlNumber' AND (AutoSave = 0 OR AutoSave IS NULL) AND (ReadOnly = 0 OR ReadOnly IS NULL);
END
GO
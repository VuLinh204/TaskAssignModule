USE Paradise_Dev
GO
if object_id('[dbo].[sp_hpaControlMoney]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_hpaControlMoney] as select 1')
GO

ALTER PROCEDURE [dbo].[sp_hpaControlMoney]
    @TableName VARCHAR(256) = ''
AS
BEGIN
    -- =========================================================================
    -- hpaControlMoney - AUTOSAVE MODE
    -- =========================================================================
    UPDATE #temptable SET loadUI = N'
        let Instance%ColumnName%%UID% = null;
        let %ColumnName%TimeOut;

        async function MoneyBoxSaveLogic() {
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
                    console.warn("[Grid Sync] MoneyBox %ColumnName%%UID%: Không thể sync grid:", syncErr);
                }
            }
        }

        Instance%ColumnName%%UID% = $("#%UID%").dxNumberBox({
            format: "#,##0 ₫",
            showSpinButtons: false,
            showClearButton: false,
            width: "100%",
            elementAttr: { class: "hpa-dx-numberbox-inline" },
            onValueChanged: async (e) => {
                clearTimeout(%ColumnName%TimeOut);
                e.event && await MoneyBoxSaveLogic();
            },
            onKeyUp: (e) => {
                clearTimeout(%ColumnName%TimeOut);
                %ColumnName%TimeOut = setTimeout(async () => MoneyBoxSaveLogic(), 1000);
            }
        }).dxNumberBox("instance");
    '
    WHERE [Type] = 'hpaControlMoney' AND AutoSave = 1 AND Layout IS NULL;

    -- =========================================================================
    -- hpaControlMoney - READONLY MODE
    -- =========================================================================
    UPDATE #temptable SET loadUI = N'
        Instance%ColumnName%%UID% = $("#%UID%").dxNumberBox({
            format: "#,##0 ₫",
            showSpinButtons: false,
            showClearButton: false,
            width: "100%",
            elementAttr: { class: "hpa-dx-numberbox-inline" },
            readOnly: true
        }).dxNumberBox("instance");
    '
    WHERE [Type] = 'hpaControlMoney' AND ReadOnly = 1 AND Layout IS NULL;

    -- =========================================================================
    -- hpaControlMoney - NON-AUTOSAVE MODE
    -- =========================================================================
    UPDATE #temptable SET loadUI = N'
        let Instance%ColumnName%%UID% = null;
        let %ColumnName%TimeOut;
        let _autoSave%ColumnName%%UID% = false;
        let _readOnly%ColumnName%%UID% = false;

        async function MoneyBoxSaveLogic%ColumnName%() {
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
                        console.warn("[Grid Sync] MoneyBox %ColumnName%%UID%: Error", syncErr);
                    }
                }
            } catch (err) {
                console.error("MoneyBox Save Error:", err);
            }
        }

        Instance%ColumnName%%UID% = $("#%UID%").dxNumberBox({
            format: "#,##0 ₫",
            showSpinButtons: false,
            showClearButton: false,
            width: "100%",
            elementAttr: { class: "hpa-dx-numberbox-inline" },
            readOnly: _readOnly%ColumnName%%UID%,
            onValueChanged: async (e) => {
                if (_autoSave%ColumnName%%UID%) {
                    clearTimeout(%ColumnName%TimeOut);
                    e.event && await MoneyBoxSaveLogic%ColumnName%();
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
                    %ColumnName%TimeOut = setTimeout(async () => MoneyBoxSaveLogic%ColumnName%(), 1000);
                }
            }
        }).dxNumberBox("instance");
    '
    WHERE [Type] = 'hpaControlMoney' AND (AutoSave = 0 OR AutoSave IS NULL) AND (ReadOnly = 0 OR ReadOnly IS NULL) AND Layout IS NULL;
END
GO
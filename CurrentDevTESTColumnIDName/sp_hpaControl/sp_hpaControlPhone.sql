USE Paradise_Dev
GO
if object_id('[dbo].[sp_hpaControlPhone]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_hpaControlPhone] as select 1')
GO

ALTER PROCEDURE [dbo].[sp_hpaControlPhone]
    @TableName VARCHAR(256) = ''
AS
BEGIN
UPDATE #temptable SET loadUI = N'
        let Instance%ColumnName%%UID% = null; let %ColumnName%TimeOut;

        async function PhoneBoxSaveLogic() {
            let currentVal = Instance%ColumnName%%UID%.option("value") || "";
            let cleanVal = currentVal.replace(/[^0-9+]/g, "");
            const dataJSON = JSON.stringify(["%tableId%", ["%ColumnName%%UID%"], [cleanVal]]);
            const idValuesJSON = JSON.stringify([[currentRecordID], "%ColumnIDName%"]);
            const json = await saveFunction(dataJSON, idValuesJSON);
            const dtError = json.data[json.data.length - 1] || [];
            if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "Lưu thất bại" });
            }
            if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                try {
                    const grid = cellInfo.component;
                    const rowKey = cellInfo.key || cellInfo.data["%ColumnIDName%"];
                    grid.cellValue(cellInfo.rowIndex, "%ColumnName%", val);
                    grid.repaint();
                } catch (syncErr) {
                    console.warn("[Grid Sync] PhoneBox %ColumnName%%UID%: Không thể sync grid:", syncErr);
                }
            }
        }

       Instance%ColumnName%%UID% = $("#%UID%").dxTextBox({
            mode: "tel",
            showClearButton: false,
            width: "100%",
            elementAttr: { class: "hpa-dx-textbox-inline" },
            onKeyDown: function(e) {
                const regex = /^[0-9+]$|^Backspace$|^Delete$|^Tab$|^Enter$|^Arrow|^Home$|^End$/;
                regex.test(e.event.key) ? null : e.event.preventDefault();
            },
            onValueChanged: async (e) => {
                clearTimeout(%ColumnName%TimeOut);
                e.event && await PhoneBoxSaveLogic();
            },
            onKeyUp: (e) => {
                clearTimeout(%ColumnName%TimeOut);
                %ColumnName%TimeOut = setTimeout(async () => PhoneBoxSaveLogic(), 1000);
            }
        }).dxTextBox("instance");
    '
    WHERE [Type] = 'hpaControlPhone' AND AutoSave = 1 AND Layout IS NULL

    -- ControlPhoneBox ReadOnly
    UPDATE #temptable SET loadUI = N'
        let Instance%ColumnName%%UID% = $("#%UID%").dxTextBox({
            mode: "tel",
            showClearButton: false,
            width: "100%",
            elementAttr: { class: "hpa-dx-textbox-inline" },
            readOnly: true
        }).dxTextBox("instance");
    '
    WHERE [Type] = 'hpaControlPhone' AND ReadOnly = 1 AND Layout IS NULL

    -- ControlPhoneBox Non-AutoSave
    UPDATE #temptable SET loadUI = N'
        let Instance%ColumnName%%UID% = null; let %ColumnName%TimeOut;
        let _autoSave%ColumnName%%UID% = false;
        let _readOnly%ColumnName%%UID% = false;

        async function PhoneBoxSaveLogic%ColumnName%() {
            let currentVal = Instance%ColumnName%%UID%.option("value") || "";
            let cleanVal = currentVal.replace(/[^0-9+]/g, ""); // Keep only numbers and +

            const dataJSON = JSON.stringify(["%tableId%", ["%ColumnName%%UID%"], [cleanVal]]);
            
            let currentRecordIDValue = [currentRecordID_%ColumnIDName%];
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
                        grid.cellValue(cellInfo.rowIndex, "%ColumnName%", cleanVal);
                        grid.repaint();
                    } catch (syncErr) {
                        console.warn("[Grid Sync] PhoneBox %ColumnName%%UID%: Error", syncErr);
                    }
                }
            } catch (err) {
                console.error("PhoneBox Save Error:", err);
            }
        }

        Instance%ColumnName%%UID% = $("#%UID%").dxTextBox({
            mode: "tel",
            showClearButton: false,
            width: "100%",
            elementAttr: { class: "hpa-dx-textbox-inline" },
            readOnly: _readOnly%ColumnName%%UID%,
            onKeyDown: function(e) {
                const regex = /^[0-9+]$|^Backspace$|^Delete$|^Tab$|^Enter$|^Arrow|^Home$|^End$/;
                regex.test(e.event.key) ? null : e.event.preventDefault();
            },
            onValueChanged: async (e) => {
                if (_autoSave%ColumnName%%UID%) {
                     clearTimeout(%ColumnName%TimeOut);
                     e.event && await PhoneBoxSaveLogic%ColumnName%();
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
                    %ColumnName%TimeOut = setTimeout(async () => PhoneBoxSaveLogic%ColumnName%(), 1000);
                 }
            }
        }).dxTextBox("instance");
    '
    WHERE [Type] = 'hpaControlPhone' AND (AutoSave = 0 OR AutoSave IS NULL) AND (ReadOnly = 0 OR ReadOnly IS NULL) AND Layout IS NULL
END
GO
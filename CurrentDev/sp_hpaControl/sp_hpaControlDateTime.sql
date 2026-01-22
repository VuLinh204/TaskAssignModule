USE Paradise_Dev
GO
if object_id('[dbo].[sp_hpaControlDateTime]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_hpaControlDateTime] as select 1')
GO

ALTER PROCEDURE [dbo].[sp_hpaControlDateTime]
    @TableName VARCHAR(256) = ''
AS
BEGIN
    -- =========================================================================
    -- hpaControlDateTime - AUTOSAVE MODE
    -- =========================================================================
    UPDATE #temptable SET loadUI = N'
        let Instance%ColumnName%%UID% = null; 
        let %ColumnName%TimeOut;

        async function DateTimeSaveLogic() {
            let val = Instance%ColumnName%%UID%.option("value");
            // Format lưu thành yyyy/MM/dd HH:mm để lấy cả giờ
            let valToSave = val ? DevExpress.localization.formatDate(new Date(val), "yyyy/MM/dd HH:mm") : null;

            const dataJSON = JSON.stringify(["%tableId%", ["%ColumnName%"], [valToSave]]);
            
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

            // SYNC GRID: Cập nhật lại giá trị trong Grid sau khi save thành công
            if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                try {
                    const grid = cellInfo.component;
                    grid.cellValue(cellInfo.rowIndex, "%ColumnName%", val);
                    grid.repaint();
                } catch (syncErr) {
                    console.warn("[Grid Sync] DateTimeBox %ColumnName%%UID%: Không thể sync grid:", syncErr);
                }
            }
        }

        Instance%ColumnName%%UID% = $("#%UID%").dxDateBox({
            type: "datetime",
            displayFormat: "dd/MM/yyyy HH:mm",
            useMaskBehavior: true,
            openOnFieldClick: true,
            showClearButton: false,
            dateSerializationFormat: "yyyy-MM-ddTHH:mm:ss",
            width: "100%",
            elementAttr: { class: "hpa-dx-datebox-inline" },
            onValueChanged: async (e) => {
                clearTimeout(%ColumnName%TimeOut);
                e.event && await DateTimeSaveLogic();
            },
            onKeyUp: (e) => {
                clearTimeout(%ColumnName%TimeOut);
                %ColumnName%TimeOut = setTimeout(async () => DateTimeSaveLogic(), 1000);
            }
        }).dxDateBox("instance");
    '
    WHERE [Type] = 'hpaControlDateTime' AND AutoSave = 1;

    -- =========================================================================
    -- hpaControlDateTime - READONLY MODE
    -- =========================================================================
    UPDATE #temptable SET loadUI = N'
        let Instance%ColumnName%%UID% = null;
        Instance%ColumnName%%UID% = $("#%UID%").dxDateBox({
            type: "datetime",
            displayFormat: "dd/MM/yyyy HH:mm",
            useMaskBehavior: true,
            openOnFieldClick: true,
            showClearButton: false,
            dateSerializationFormat: "yyyy-MM-ddTHH:mm:ss",
            width: "100%",
            elementAttr: { class: "hpa-dx-datebox-inline" },
            readOnly: true
        }).dxDateBox("instance");
    '
    WHERE [Type] = 'hpaControlDateTime' AND ReadOnly = 1;

    -- =========================================================================
    -- hpaControlDateTime - NON-AUTOSAVE MODE
    -- =========================================================================
    UPDATE #temptable SET loadUI = N'
        let Instance%ColumnName%%UID% = null; 
        let %ColumnName%TimeOut;
        let _autoSave%ColumnName%%UID% = (typeof window["AutoSave_%ColumnName%"] !== "undefined" ? window["AutoSave_%ColumnName%"] : false);
        let _readOnly%ColumnName%%UID% = (typeof window["ReadOnly_%ColumnName%"] !== "undefined" ? window["ReadOnly_%ColumnName%"] : false);

        async function DateTimeBoxSaveLogic%ColumnName%() {
            let val = Instance%ColumnName%%UID%.option("value");
            let valToSave = val ? DevExpress.localization.formatDate(new Date(val), "yyyy/MM/dd HH:mm") : null;
            const dataJSON = JSON.stringify(["%tableId%", ["%ColumnName%"], [valToSave]]);

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
                        console.warn("[Grid Sync] DateTimeBox %ColumnName%%UID%: Error", syncErr);
                    }
                }
            } catch (err) {
                console.error("DateTimeBox Save Error:", err);
            }
        }

        Instance%ColumnName%%UID% = $("#%UID%").dxDateBox({
            type: "datetime",
            displayFormat: "dd/MM/yyyy HH:mm",
            useMaskBehavior: true,
            openOnFieldClick: true,
            showClearButton: false,
            dateSerializationFormat: "yyyy-MM-ddTHH:mm:ss",
            width: "100%",
            elementAttr: { class: "hpa-dx-datebox-inline" },
            readOnly: _readOnly%ColumnName%%UID%,
            onValueChanged: async (e) => {
                if (_autoSave%ColumnName%%UID%) {
                    clearTimeout(%ColumnName%TimeOut);
                    e.event && await DateTimeBoxSaveLogic%ColumnName%();
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
                    %ColumnName%TimeOut = setTimeout(async () => DateTimeBoxSaveLogic%ColumnName%(), 1000);
                }
            }
        }).dxDateBox("instance");
    '
    WHERE [Type] = 'hpaControlDateTime' AND (AutoSave = 0 OR AutoSave IS NULL) AND (ReadOnly = 0 OR ReadOnly IS NULL);
END
GO
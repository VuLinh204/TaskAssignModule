USE Paradise_Dev
GO
if object_id('[dbo].[sp_hpaControlPhone]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_hpaControlPhone] as select 1')
GO

ALTER PROCEDURE [dbo].[sp_hpaControlPhone]
    @TableName VARCHAR(256) = ''
AS
BEGIN
    -- =========================================================================
    -- hpaControlPhone - AUTOSAVE MODE
    -- =========================================================================
    UPDATE #temptable SET loadUI = N'
        let Instance%ColumnName%%UID% = null;
        let %ColumnName%TimeOut;
        let %ColumnName%%UID%ValidationMsg = null;
        let $container%ColumnName%%UID% = $("#%UID%");

        function showValidationError%ColumnName%%UID%(message) {
            %ColumnName%%UID%ValidationMsg.text(message).show();
            $container%ColumnName%%UID%.find("input").css({
                "border": "1px solid #d9534f",
                "box-shadow": "0 0 0 0.2rem rgba(217, 83, 79, 0.25)"
            });
        }

        function hideValidationError%ColumnName%%UID%() {
            %ColumnName%%UID%ValidationMsg.hide();
            $container%ColumnName%%UID%.find("input").css({
                "border-color": "",
                "box-shadow": ""
            });
        }

        async function PhoneBoxSaveLogic() {
            let currentVal = Instance%ColumnName%%UID%.option("value") || "";
            let cleanVal = currentVal.replace(/[^0-9+]/g, "");

            // Manual validation check
            if (%IsRequired% === 1) {
                if (!cleanVal || cleanVal.trim() === "") {
                    const errorMsg = window.ValidationEngine && window.ValidationEngine.getRequiredMessage 
                        ? window.ValidationEngine.getRequiredMessage("%DisplayName%")
                        : "%DisplayName% là bắt buộc";
                    
                    showValidationError%ColumnName%%UID%(errorMsg);
                    setTimeout(() => {
                        $container%ColumnName%%UID%.find("input").focus();
                    }, 50);
                    return;
                }
            }

            hideValidationError%ColumnName%%UID%();

            const dataJSON = JSON.stringify(["%tableId%", ["%ColumnName%"], [cleanVal]]);

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
                    console.warn("[Grid Sync] PhoneBox %ColumnName%%UID%: Không thể sync grid:", syncErr);
                }
            }
        }

        %ColumnName%%UID%ValidationMsg = $("<div>").css({
            "color": "#d9534f",
            "font-size": "0.875rem",
            "padding": "4px 8px",
            "display": "none",
            "margin-top": "2px"
        }).appendTo($container%ColumnName%%UID%);

        Instance%ColumnName%%UID% = $container%ColumnName%%UID%.find("#%UID%").dxTextBox({
            mode: "tel",
            showClearButton: false,
            width: "100%",
            elementAttr: { class: "hpa-dx-textbox-inline" },
            onKeyDown: function(e) {
                const regex = /^[0-9+]$|^Backspace$|^Delete$|^Tab$|^Enter$|^Arrow|^Home$|^End$/;
                regex.test(e.event.key) ? null : e.event.preventDefault();
                
                if (e.event.key === "Enter") {
                    e.event.preventDefault();
                    PhoneBoxSaveLogic();
                }
            },
            onValueChanged: async (e) => {
                if (e.value && e.value.trim() !== "") {
                    hideValidationError%ColumnName%%UID%();
                }
                clearTimeout(%ColumnName%TimeOut);
                e.event && await PhoneBoxSaveLogic();
            },
            onKeyUp: (e) => {
                clearTimeout(%ColumnName%TimeOut);
                %ColumnName%TimeOut = setTimeout(async () => PhoneBoxSaveLogic(), 1000);
            },
            onFocusOut: function(e) {
                const currentValue = Instance%ColumnName%%UID%.option("value") || "";
                const cleanVal = currentValue.replace(/[^0-9+]/g, "");
                
                if (%IsRequired% === 1) {
                    if (!cleanVal || cleanVal.trim() === "") {
                        const errorMsg = window.ValidationEngine && window.ValidationEngine.getRequiredMessage 
                            ? window.ValidationEngine.getRequiredMessage("%DisplayName%")
                            : "%DisplayName% là bắt buộc";
                        
                        showValidationError%ColumnName%%UID%(errorMsg);
                        return;
                    }
                }
                
                hideValidationError%ColumnName%%UID%();
            }
        }).dxTextBox("instance");
    '
    WHERE [Type] = 'hpaControlPhone' AND AutoSave = 1 AND Layout IS NULL;

    -- =========================================================================
    -- hpaControlPhone - READONLY MODE
    -- =========================================================================
    UPDATE #temptable SET loadUI = N'
        let Instance%ColumnName%%UID% = $("#%UID%").dxTextBox({
            mode: "tel",
            showClearButton: false,
            width: "100%",
            elementAttr: { class: "hpa-dx-textbox-inline" },
            readOnly: true
        }).dxTextBox("instance");
    '
    WHERE [Type] = 'hpaControlPhone' AND ReadOnly = 1 AND Layout IS NULL;

    -- =========================================================================
    -- hpaControlPhone - NON-AUTOSAVE MODE
    -- =========================================================================
    UPDATE #temptable SET loadUI = N'
        let Instance%ColumnName%%UID% = null;
        let %ColumnName%TimeOut;
        let _autoSave%ColumnName%%UID% = false;
        let _readOnly%ColumnName%%UID% = false;
        let %ColumnName%%UID%ValidationMsg = null;
        let $container%ColumnName%%UID% = $("#%UID%");

        function showValidationError%ColumnName%%UID%(message) {
            %ColumnName%%UID%ValidationMsg.text(message).show();
            $container%ColumnName%%UID%.find("input").css({
                "border": "1px solid #d9534f",
                "box-shadow": "0 0 0 0.2rem rgba(217, 83, 79, 0.25)"
            });
        }

        function hideValidationError%ColumnName%%UID%() {
            %ColumnName%%UID%ValidationMsg.hide();
            $container%ColumnName%%UID%.find("input").css({
                "border-color": "",
                "box-shadow": ""
            });
        }

        async function PhoneBoxSaveLogic%ColumnName%() {
            let currentVal = Instance%ColumnName%%UID%.option("value") || "";
            let cleanVal = currentVal.replace(/[^0-9+]/g, "");

            // Manual validation check
            if (%IsRequired% === 1) {
                if (!cleanVal || cleanVal.trim() === "") {
                    const errorMsg = window.ValidationEngine && window.ValidationEngine.getRequiredMessage 
                        ? window.ValidationEngine.getRequiredMessage("%DisplayName%")
                        : "%DisplayName% là bắt buộc";
                    
                    showValidationError%ColumnName%%UID%(errorMsg);
                    setTimeout(() => {
                        $container%ColumnName%%UID%.find("input").focus();
                    }, 50);
                    return;
                }
            }

            hideValidationError%ColumnName%%UID%();

            const dataJSON = JSON.stringify(["%tableId%", ["%ColumnName%"], [cleanVal]]);

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

        %ColumnName%%UID%ValidationMsg = $("<div>").css({
            "color": "#d9534f",
            "font-size": "0.875rem",
            "padding": "4px 8px",
            "display": "none",
            "margin-top": "2px"
        }).appendTo($container%ColumnName%%UID%);

        Instance%ColumnName%%UID% = $container%ColumnName%%UID%.find("#%UID%").dxTextBox({
            mode: "tel",
            showClearButton: false,
            width: "100%",
            elementAttr: { class: "hpa-dx-textbox-inline" },
            readOnly: _readOnly%ColumnName%%UID%,
            onKeyDown: function(e) {
                const regex = /^[0-9+]$|^Backspace$|^Delete$|^Tab$|^Enter$|^Arrow|^Home$|^End$/;
                regex.test(e.event.key) ? null : e.event.preventDefault();
                
                if (e.event.key === "Enter") {
                    e.event.preventDefault();
                    if (_autoSave%ColumnName%%UID%) {
                        PhoneBoxSaveLogic%ColumnName%();
                    }
                }
            },
            onValueChanged: async (e) => {
                if (e.value && e.value.trim() !== "") {
                    hideValidationError%ColumnName%%UID%();
                }
                
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
            },
            onFocusOut: function(e) {
                const currentValue = Instance%ColumnName%%UID%.option("value") || "";
                const cleanVal = currentValue.replace(/[^0-9+]/g, "");
                
                if (%IsRequired% === 1) {
                    if (!cleanVal || cleanVal.trim() === "") {
                        const errorMsg = window.ValidationEngine && window.ValidationEngine.getRequiredMessage 
                            ? window.ValidationEngine.getRequiredMessage("%DisplayName%")
                            : "%DisplayName% là bắt buộc";
                        
                        showValidationError%ColumnName%%UID%(errorMsg);
                        return;
                    }
                }
                
                hideValidationError%ColumnName%%UID%();
            }
        }).dxTextBox("instance");
    '
    WHERE [Type] = 'hpaControlPhone' AND (AutoSave = 0 OR AutoSave IS NULL) AND (ReadOnly = 0 OR ReadOnly IS NULL) AND Layout IS NULL;
END
GO
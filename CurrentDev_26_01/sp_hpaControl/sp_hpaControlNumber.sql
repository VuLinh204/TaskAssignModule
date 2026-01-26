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

        async function NumberBoxSaveLogic() {
            let val = Instance%ColumnName%%UID%.option("value");

            // Manual validation check
            if (%IsRequired% === 1) {
                if (val == null || val === "") {
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
                    console.warn("[Grid Sync] NumberBox %ColumnName%%UID%: Không thể sync grid:", syncErr);
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

        let %ColumnName%%UID%RealInstance = $("#%UID%").dxNumberBox({
            format: "#,##0",
            showSpinButtons: false,
            showClearButton: false,
            width: "100%",
            elementAttr: { class: "hpa-dx-numberbox-inline" },
            onKeyDown: function(e) {
                if (e.event.key === "Enter") {
                    e.event.preventDefault();
                    NumberBoxSaveLogic();
                }
            },
            onValueChanged: async (e) => {
                if (e.value != null && e.value !== "") {
                    hideValidationError%ColumnName%%UID%();
                }
                clearTimeout(%ColumnName%TimeOut);
                e.event && await NumberBoxSaveLogic();
            },
            onKeyUp: (e) => {
                clearTimeout(%ColumnName%TimeOut);
                %ColumnName%TimeOut = setTimeout(async () => NumberBoxSaveLogic(), 1000);
            },
            onFocusOut: function(e) {
                const currentValue = %ColumnName%%UID%RealInstance.option("value");
                
                if (%IsRequired% === 1) {
                    if (currentValue == null || currentValue === "") {
                        const errorMsg = window.ValidationEngine && window.ValidationEngine.getRequiredMessage 
                            ? window.ValidationEngine.getRequiredMessage("%DisplayName%")
                            : "%DisplayName% là bắt buộc";
                        
                        showValidationError%ColumnName%%UID%(errorMsg);
                        return;
                    }
                }
                
                hideValidationError%ColumnName%%UID%();
            }
        }).dxNumberBox("instance");

        /* =============== Public API =============== */
        Instance%ColumnName%%UID% = {
            option: function(name, value) {
                if (value !== undefined) {
                    return %ColumnName%%UID%RealInstance.option(name, value);
                } else {
                    return %ColumnName%%UID%RealInstance.option(name);
                }
            },
            repaint: function() {
                %ColumnName%%UID%RealInstance.repaint();
            },
            focus: function() {
                %ColumnName%%UID%RealInstance.focus();
            },
            // Empty methods để tránh lỗi khi code bên ngoài gọi
            _suppressValueChangeAction: function() {
                // NumberBox không hỗ trợ method này
            },
            _resumeValueChangeAction: function() {
                // NumberBox không hỗ trợ method này
            }
        };
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

        async function NumberBoxSaveLogic%ColumnName%() {
            let val = Instance%ColumnName%%UID%.option("value");

            // Manual validation check
            if (%IsRequired% === 1) {
                if (val == null || val === "") {
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

        %ColumnName%%UID%ValidationMsg = $("<div>").css({
            "color": "#d9534f",
            "font-size": "0.875rem",
            "padding": "4px 8px",
            "display": "none",
            "margin-top": "2px"
        }).appendTo($container%ColumnName%%UID%);

        let %ColumnName%%UID%RealInstance = $("#%UID%").dxNumberBox({
            format: "#,##0",
            showSpinButtons: false,
            showClearButton: false,
            width: "100%",
            elementAttr: { class: "hpa-dx-numberbox-inline" },
            readOnly: _readOnly%ColumnName%%UID%,
            onKeyDown: function(e) {
                if (e.event.key === "Enter") {
                    e.event.preventDefault();
                    if (_autoSave%ColumnName%%UID%) {
                        NumberBoxSaveLogic%ColumnName%();
                    }
                }
            },
            onValueChanged: async (e) => {
                if (e.value != null && e.value !== "") {
                    hideValidationError%ColumnName%%UID%();
                }
                
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
            },
            onFocusOut: function(e) {
                const currentValue = %ColumnName%%UID%RealInstance.option("value");
                
                if (%IsRequired% === 1) {
                    if (currentValue == null || currentValue === "") {
                        const errorMsg = window.ValidationEngine && window.ValidationEngine.getRequiredMessage 
                            ? window.ValidationEngine.getRequiredMessage("%DisplayName%")
                            : "%DisplayName% là bắt buộc";
                        
                        showValidationError%ColumnName%%UID%(errorMsg);
                        return;
                    }
                }
                
                hideValidationError%ColumnName%%UID%();
            }
        }).dxNumberBox("instance");

        /* =============== Public API =============== */
        Instance%ColumnName%%UID% = {
            option: function(name, value) {
                if (value !== undefined) {
                    return %ColumnName%%UID%RealInstance.option(name, value);
                } else {
                    return %ColumnName%%UID%RealInstance.option(name);
                }
            },
            repaint: function() {
                %ColumnName%%UID%RealInstance.repaint();
            },
            focus: function() {
                %ColumnName%%UID%RealInstance.focus();
            },
            // Empty methods để tránh lỗi khi code bên ngoài gọi
            _suppressValueChangeAction: function() {
                // NumberBox không hỗ trợ method này
            },
            _resumeValueChangeAction: function() {
                // NumberBox không hỗ trợ method này
            }
        };
    '
    WHERE [Type] = 'hpaControlNumber' AND (AutoSave = 0 OR AutoSave IS NULL) AND (ReadOnly = 0 OR ReadOnly IS NULL);
END
GO
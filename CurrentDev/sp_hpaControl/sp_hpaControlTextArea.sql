USE Paradise_Dev
GO
if object_id('[dbo].[sp_hpaControlTextArea]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_hpaControlTextArea] as select 1')
GO

ALTER PROCEDURE [dbo].[sp_hpaControlTextArea]
    @TableName VARCHAR(256) = ''
AS
BEGIN
    -- =========================================================================
    -- READONLY MODE
    -- =========================================================================
    UPDATE #temptable SET
        loadUI = N'
            /* Thêm CSS cho textarea height 100% */
            if (!$("head").find("#hpa-textarea-height-style").length) {
                $("head").append("<style id=\"hpa-textarea-height-style\">textarea.dx-texteditor-input { height: 100% !important; }</style>");
            }

            let Instance%ColumnName%%UID% = null;
            Instance%ColumnName%%UID% = $("#%UID%").dxTextArea({
                value: "",
                width: "100%",
                height: 80,
                readOnly: true,
                stylingMode: "underlined",
                inputAttr: { style: "font-size: 14px; padding: 6px 0px;" }
            }).dxTextArea("instance");
        '
    WHERE [Type] = 'hpaControlTextArea' AND [ReadOnly] = 1;

    -- =========================================================================
    -- EDIT MODE (INLINE + POPUP + AUTOSAVE)
    -- =========================================================================
    UPDATE #temptable SET
        loadUI = N'
            /* Thêm CSS cho textarea height 100% */
            if (!$("head").find("#hpa-textarea-height-style").length) {
                $("head").append("<style id=\"hpa-textarea-height-style\">textarea.dx-texteditor-input { height: 100% !important; }</style>");
            }

            let $container%ColumnName%%UID% = $("#%UID%");
            let Instance%ColumnName%%UID% = null;

            let %ColumnName%%UID%OriginalValue = "";
            let _saving%ColumnName%%UID% = false;

            /* =============== Helper Function =============== */
            function showValidationError%ColumnName%%UID%(message) {
                $container%ColumnName%%UID%.find("textarea").css({
                    "background-color": "#ffe6e6"
                });
                uiManager.showAlert({ type: "error", message: message });
            }

            function hideValidationError%ColumnName%%UID%() {
                $container%ColumnName%%UID%.find("textarea").css({
                    "background-color": ""
                });
            }

            async function saveValue%ColumnName%%UID%() {
                if (_saving%ColumnName%%UID%) return;

                const newVal = (Instance%ColumnName%%UID%.option("value") || "").trim();

                if (newVal === %ColumnName%%UID%OriginalValue) {
                    return;
                }

                try {
                    _saving%ColumnName%%UID% = true;

                    if (%IsRequired% === 1) {
                        if (!newVal || newVal.trim() === "") {
                            const errorMsg = window.ValidationEngine && window.ValidationEngine.getRequiredMessage
                                ? window.ValidationEngine.getRequiredMessage("%DisplayName%")
                                : "%DisplayName% là bắt buộc";

                            showValidationError%ColumnName%%UID%(errorMsg);
                            _saving%ColumnName%%UID% = false;

                            return;
                        }
                    }

                    hideValidationError%ColumnName%%UID%();

                    const dataJSON = JSON.stringify(["%tableId%", ["%ColumnName%"], [newVal || ""]]);

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

                    const dtError = json.data[json.data.length-1] ?? [];
                    if (dtError.length && dtError[0].Status === "ERROR") {
                        uiManager.showAlert({ type: "error", message: dtError[0].Message || "%SaveErrorMessage%" });
                        _saving%ColumnName%%UID% = false;
                        return;
                    }

                    if(%GridColumnName% != 0 && %GridColumnName% != null && %GridColumnName% != "" && window.hpaSharedGridDataSources["%GridColumnName%"])
                    {
                        try {
                            var updateData = {};
                            updateData["%ColumnIDName%"] = currentRecordIDValue[0];
                            updateData["%ColumnName%"] = Instance%ColumnName%%UID%.option("value");

                            var id2FieldName = "%ColumnIDName2%";
                            var hasKey2 = id2FieldName && id2FieldName !== "" && id2FieldName.indexOf("%") === -1;

                            if (hasKey2) {
                                if (currentRecordIDValue.length > 1 && currentRecordIDValue[1] !== undefined) {
                                    updateData[id2FieldName] = currentRecordIDValue[1];
                                }
                            }

                            window.updateSharedGridRow("%GridColumnName%", updateData);

                            if (typeof DataSource !== "undefined" && Array.isArray(DataSource)) {
                                var ds;
                                if (!hasKey2) {
                                    ds = DataSource.filter(item => item["%ColumnIDName%"] === updateData["%ColumnIDName%"]);
                                } else {
                                    ds = DataSource.filter(item =>
                                        item["%ColumnIDName%"] === updateData["%ColumnIDName%"] &&
                                        item[id2FieldName] === updateData[id2FieldName]
                                    );
                                }

                                if (ds && ds.length > 0) {
                                    ds[0]["%ColumnName%"] = updateData["%ColumnName%"];
                                }
                            }
                        } catch (dsErr) {
                            console.warn("[Grid Sync] TextArea %ColumnName%%UID%: ", dsErr);
                        }
                    }

                    %ColumnName%%UID%OriginalValue = newVal;
                    if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                        try {
                            const grid = cellInfo.component;
                            grid.cellValue(cellInfo.rowIndex, "%ColumnName%", newVal);
                            grid.repaint();
                        } catch (syncErr) { }
                    }

                } catch (e) {
                    uiManager.showAlert({ type: "error", message: "%SaveErrorMessage%" });
                } finally {
                    setTimeout(function(){
                        _saving%ColumnName%%UID% = false;
                    }, 100);
                }
            }

            /* ================= CREATE UI ================= */
            Instance%ColumnName%%UID% = $("<div>").appendTo($container%ColumnName%%UID%).dxTextArea({
                value: "",
                width: "100%",
                height: 80,
                stylingMode: "underlined",
                inputAttr: {
                    style: "padding-left: 0; padding-right: 0; font-size: 14px;"
                },
                onValueChanged: function(e) {
                    if (e.value && e.value.trim() !== "") {
                        hideValidationError%ColumnName%%UID%();
                    }
                },
                onFocusOut: function(e) {
                    if (_saving%ColumnName%%UID%) return;
                    saveValue%ColumnName%%UID%();
                },
                onKeyDown: function(e) {
                    if (e.event.key === "Enter" && e.event.ctrlKey) {
                        e.event.preventDefault();
                        saveValue%ColumnName%%UID%();
                    }
                },
                onInitialized: function(e) {
                    // Cấu trúc placeholder hoặc value khởi tạo nếu cần
                }
            }).dxTextArea("instance");

            %ColumnName%%UID%OriginalValue = Instance%ColumnName%%UID%.option("value") || "";
        '
    WHERE [Type] = 'hpaControlTextArea' AND [AutoSave] = 1 AND [ReadOnly] = 0;

    -- =========================================================================
    -- MANUAL MODE (NO AUTOSAVE)
    -- =========================================================================
    UPDATE #temptable SET
        loadUI = N'
            /* Thêm CSS cho textarea height 100% */
            if (!$("head").find("#hpa-textarea-height-style").length) {
                $("head").append("<style id=\"hpa-textarea-height-style\">textarea.dx-texteditor-input { height: 100% !important; }</style>");
            }

            let $container%ColumnName%%UID% = $("#%UID%");
            let Instance%ColumnName%%UID% = null;

            /* =============== Helper Function =============== */
            function showValidationError%ColumnName%%UID%(message) {
                $container%ColumnName%%UID%.find("textarea").css({
                    "background-color": "#ffe6e6"
                });
                uiManager.showAlert({ type: "error", message: message });
            }

            function hideValidationError%ColumnName%%UID%() {
                $container%ColumnName%%UID%.find("textarea").css({
                    "background-color": ""
                });
            }

            /* ================= CREATE UI ================= */
            Instance%ColumnName%%UID% = $("<div>").appendTo($container%ColumnName%%UID%).dxTextArea({
                value: "",
                width: "100%",
                height: 80,
                stylingMode: "underlined",
                inputAttr: {
                    style: "padding-left: 0; padding-right: 0; font-size: 14px;"
                },
                onValueChanged: function(e) {
                    if (e.value && e.value.trim() !== "") {
                        hideValidationError%ColumnName%%UID%();
                    }
                }
            }).dxTextArea("instance");
        '
    WHERE [Type] = 'hpaControlTextArea' AND [AutoSave] = 0 AND [ReadOnly] = 0;
END
GO
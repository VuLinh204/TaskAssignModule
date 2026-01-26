USE Paradise_Dev
GO
if object_id('[dbo].[sp_hpaControlText]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_hpaControlText] as select 1')
GO

ALTER PROCEDURE [dbo].[sp_hpaControlText]
    @TableName VARCHAR(256) = ''
AS
BEGIN
    -- =========================================================================
    -- hpaControlText - READONLY MODE
    -- =========================================================================
    UPDATE #temptable SET
        loadUI = N'
            let Instance%ColumnName%%UID% = null;
            if (!$("head").find("#hpa-inherit-font-style").length) $("head").append("<style id=\"hpa-inherit-font-style\">.dx-widget{font-size:inherit!important;font-weight:inherit!important;line-height:inherit!important;border-radius:inherit!important}.dx-texteditor, .dx-texteditor-input{font-size:inherit!important;font-weight:inherit!important;line-height:inherit!important;box-sizing:border-box!important;}</style>");
            Instance%ColumnName%%UID% = $("#%UID%").dxTextBox({
                value: "",
                width: "100%",
                readOnly: true,
                elementAttr: {
                    style: "border: none !important; box-shadow: none !important; background: transparent !important; padding: 2px 8px;"
                },
                inputAttr: {
                    style: "max-height: 100%; border: none !important; background: transparent; box-shadow: none; padding: inherit; font-size: inherit; font-weight: inherit;"
                }
            }).dxTextBox("instance");
        '
    WHERE [Type] = 'hpaControlText' AND [ReadOnly] = 1;

    -- =========================================================================
    -- hpaControlText - AUTOSAVE MODE (Chỉ dùng input, không có TextDisplay)
    -- =========================================================================
    UPDATE #temptable SET
        loadUI = N'
            let Instance%ColumnName%%UID% = null;
            if (!$("head").find("#hpa-inherit-font-style").length) $("head").append("<style id=\"hpa-inherit-font-style\">.dx-widget{font-size:inherit!important;font-weight:inherit!important;line-height:inherit!important;border-radius:inherit!important}.dx-texteditor, .dx-texteditor-input{font-size:inherit!important;font-weight:inherit!important;line-height:inherit!important;box-sizing:border-box!important;}</style>");
            let $container%ColumnName%%UID% = $("#%UID%");

            let %ColumnName%%UID%OriginalValue = "";
            let %ColumnName%%UID%ValidationMsg = null;
            let _saving%ColumnName%%UID% = false;
            let %ColumnName%%UID%RealInstance = null;

            /* =============== Helper Functions =============== */

            function showValidationError%ColumnName%%UID%(message) {
                %ColumnName%%UID%ValidationMsg.text(message).show();
                $container%ColumnName%%UID%.find("input").css({
                    "border": "2px solid #d9534f",
                    "box-shadow": "0 0 0 0.2rem rgba(217, 83, 79, 0.25)"
                });
            }

            function hideValidationError%ColumnName%%UID%() {
                %ColumnName%%UID%ValidationMsg.hide();
                $container%ColumnName%%UID%.find("input").css({
                    "border": "",
                    "box-shadow": "none"
                });
            }

            async function saveValue%ColumnName%%UID%() {
                if (_saving%ColumnName%%UID%) return;

                const newVal = %ColumnName%%UID%RealInstance.option("value");

                if (newVal === %ColumnName%%UID%OriginalValue) {
                    _saving%ColumnName%%UID% = false;
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

                            setTimeout(() => {
                                $container%ColumnName%%UID%.find("input").focus();
                            }, 50);
                            return;
                        }
                    }

                    hideValidationError%ColumnName%%UID%();

                    const dataJSON = JSON.stringify(["%tableId%", ["%ColumnName%"], [newVal]]);

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

                                    // Thực hiện update shared grid
                                    window.updateSharedGridRow("%GridColumnName%", updateData);

                                    // Kiểm tra và cập nhật biến DataSource cục bộ
                                    if (typeof DataSource !== "undefined" && Array.isArray(DataSource)) {
                                        var ds;
                                        if (!hasKey2) {
                                            // Trường hợp 1 khóa
                                            ds = DataSource.filter(item => item["%ColumnIDName%"] === updateData["%ColumnIDName%"]);
                                        } else {
                                            // Trường hợp 2 khóa
                                            ds = DataSource.filter(item =>
                                               item["%ColumnIDName%"] === updateData["%ColumnIDName%"] &&
                                                item[id2FieldName] === updateData[id2FieldName]
                                            );
                                        }

                                        if (ds && ds.length > 0) {
                                            ds[0]["%ColumnName%"] = updateData["%ColumnName%"];
                                        }
                                    } // <-- Bạn thiếu dấu này
                                } catch (dsErr) {
                                    console.warn("[Grid Sync] TextBox %ColumnName%%UID%: Không thể sync shared grid data source:", dsErr);
                                }
                            }


                    %ColumnName%%UID%OriginalValue = newVal;
                    if ("%IsAlert%" === "1") {
                        uiManager.showAlert({ type: "success", message: "Lưu thành công" });
                    }

                    if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                        try {
                            const grid = cellInfo.component;
                            grid.cellValue(cellInfo.rowIndex, "%ColumnName%", newVal);
                            grid.repaint();
                        } catch (syncErr) {
                            console.warn("[Grid Sync] Không thể sync grid:", syncErr);
                        }
                    }
                } catch (err) {
                    console.error(err);
                    uiManager.showAlert({ type: "error", message: "Có lỗi xảy ra khi lưu" });
                } finally {
                    setTimeout(function(){
                        _saving%ColumnName%%UID% = false;
                    }, 100);
                }
            }

            /* =============== Create UI =============== */

            %ColumnName%%UID%ValidationMsg = $("<div>").css({
                "color": "#d9534f",
                "font-size": "0.875rem",
                "padding": "4px 8px",
                "display": "none",
                "margin-top": "2px"
            }).appendTo($container%ColumnName%%UID%);

            %ColumnName%%UID%RealInstance = $("<div>")
                .appendTo($container%ColumnName%%UID%)
                .dxTextBox({
                    value: "",
                    width: "100%",
                    placeholder: "Nhập dữ liệu",
                    inputAttr: {
                        style: " padding: 6px 8px; font-size: inherit; font-weight: inherit; box-sizing: border-box; transition: all 0.2s;"
                    },
                    onValueChanged: function(e) {
                        if (e.value && e.value.trim() !== "") {
                            hideValidationError%ColumnName%%UID%();
                        }
                    },
                    onFocusIn: function(e) {
                        $container%ColumnName%%UID%.find("input").css({
                            "padding": "5px 7px"
                        });
                    },
                    onFocusOut: function(e) {
                        if (_saving%ColumnName%%UID%) return;

                        const currentValue = $container%ColumnName%%UID%.find("input").val();

                        // Reset border về 1px
                        $container%ColumnName%%UID%.find("input").css({
                            "padding": "6px 8px"
                        });

                        // Nếu giá trị không đổi
                        if (currentValue === %ColumnName%%UID%OriginalValue) {
                            hideValidationError%ColumnName%%UID%();
                            return;
                        }

                        // Validate nếu field bắt buộc
                        if (%IsRequired% === 1) {
                            if (!currentValue || currentValue.trim() === "") {
                                const errorMsg = window.ValidationEngine && window.ValidationEngine.getRequiredMessage
                                    ? window.ValidationEngine.getRequiredMessage("%DisplayName%")
                                    : "%DisplayName% là bắt buộc";

                                showValidationError%ColumnName%%UID%(errorMsg);
                                return;
                            }
                        }

                        // Validation pass → SAVE
                        hideValidationError%ColumnName%%UID%();
                        %ColumnName%%UID%RealInstance.option("value", currentValue);
                        saveValue%ColumnName%%UID%();
                    },
                    onKeyDown: function(e) {
                        if (e.event.key === "Enter") {
                            e.event.preventDefault();

                            const currentValue = $container%ColumnName%%UID%.find("input").val();

                            if (%IsRequired% === 1) {
                                if (!currentValue || currentValue.trim() === "") {
                                    const errorMsg = window.ValidationEngine && window.ValidationEngine.getRequiredMessage
                                        ? window.ValidationEngine.getRequiredMessage("%DisplayName%")
                                        : "%DisplayName% là bắt buộc";

                                    showValidationError%ColumnName%%UID%(errorMsg);
                                    return;
                                }
                            }

                            hideValidationError%ColumnName%%UID%();
                            %ColumnName%%UID%RealInstance.option("value", currentValue);
                            saveValue%ColumnName%%UID%();
                        }

                        if (e.event.key === "Escape") {
                            e.event.preventDefault();
                            %ColumnName%%UID%RealInstance.option("value", %ColumnName%%UID%OriginalValue);
                            hideValidationError%ColumnName%%UID%();
                            $container%ColumnName%%UID%.find("input").blur();
                        }
                    }
                })
                .dxTextBox("instance");

            /* =============== Public API =============== */
            Instance%ColumnName%%UID% = {
                setValue: function(val) {
                    const displayVal = (val == null || val === "") ? "" : String(val);
                    %ColumnName%%UID%OriginalValue = displayVal;
                    %ColumnName%%UID%RealInstance.option("value", displayVal);
                },
                getValue: function() {
                    return %ColumnName%%UID%RealInstance.option("value");
                },
                option: function(name, value) {
                    if (value !== undefined) {
                        %ColumnName%%UID%RealInstance.option(name, value);

                        if (name === "value") {
                            const val = value || "";
                            %ColumnName%%UID%OriginalValue = val;

                            if (
                                this.__cellInfo &&
                                typeof this.__cellInfo.setValue === "function" &&
                                this.__cellInfo.component
                            ) {
                                try {
                                    this.__cellInfo.setValue(val);
       } catch (e) {
                                    console.warn("[hpaControlText] Grid sync skipped", e);
                                }
                            }
                        }
                    } else {
                        return %ColumnName%%UID%RealInstance.option(name);
                    }
                },
                repaint: function() {
                    %ColumnName%%UID%RealInstance.repaint();
                },
                _suppressValueChangeAction: function() {
                    if (%ColumnName%%UID%RealInstance._suppressValueChangeAction) {
                        %ColumnName%%UID%RealInstance._suppressValueChangeAction();
                    }
                },
                _resumeValueChangeAction: function() {
                    if (%ColumnName%%UID%RealInstance._resumeValueChangeAction) {
                        %ColumnName%%UID%RealInstance._resumeValueChangeAction();
                    }
                }
            };
        '
    WHERE [Type] = 'hpaControlText' AND [ReadOnly] = 0 AND [AutoSave] = 1;

    -- =========================================================================
    -- hpaControlText - NO AUTOSAVE MODE (Chỉ dùng input, không có TextDisplay)
    -- =========================================================================
    UPDATE #temptable SET
        loadUI = N'
            let Instance%ColumnName%%UID% = null;
            if (!$("head").find("#hpa-inherit-font-style").length) $("head").append("<style id=\"hpa-inherit-font-style\">.dx-widget{font-size:inherit!important;font-weight:inherit!important;line-height:inherit!important;border-radius:inherit!important}.dx-texteditor, .dx-texteditor-input{font-size:inherit!important;font-weight:inherit!important;line-height:inherit!important;box-sizing:border-box!important;}</style>");
            let $container%ColumnName%%UID% = $("#%UID%");

            let _autoSave%ColumnName%%UID% = false;
            let _readOnly%ColumnName%%UID% = false;

            let %ColumnName%%UID%OriginalValue = "";
            let %ColumnName%%UID%ValidationMsg = null;
            let _saving%ColumnName%%UID% = false;
            let %ColumnName%%UID%RealInstance = null;

            /* =============== Helper Functions =============== */

            function showValidationError%ColumnName%%UID%(message) {
                %ColumnName%%UID%ValidationMsg.text(message).show();
                $container%ColumnName%%UID%.find("input").css({
                    "border": "2px solid #d9534f",
                    "box-shadow": "0 0 0 0.2rem rgba(217, 83, 79, 0.25)"
                });
            }

            function hideValidationError%ColumnName%%UID%() {
                %ColumnName%%UID%ValidationMsg.hide();
                $container%ColumnName%%UID%.find("input").css({
                    "border": "",
                    "box-shadow": "none"
                });
            }

            async function saveValue%ColumnName%%UID%() {
                if (_saving%ColumnName%%UID%) return;

                const newVal = %ColumnName%%UID%RealInstance.option("value");

                if (newVal === %ColumnName%%UID%OriginalValue) {
                    _saving%ColumnName%%UID% = false;
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

                            setTimeout(() => {
                                $container%ColumnName%%UID%.find("input").focus();
                            }, 50);
                            console.log("Required");
                            return;
                        }
                    }

                    hideValidationError%ColumnName%%UID%();
                    console.log(_autoSave%ColumnName%%UID%);
                    if (_autoSave%ColumnName%%UID%) {
                        const dataJSON = JSON.stringify(["%tableId%", ["%ColumnName%"], [newVal]]);

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
                        console.log(dataJSON);
                        console.log(idValsJSON);
                        const json = await saveFunction(dataJSON, idValsJSON);

                        const dtError = json.data[json.data.length - 1] || [];
                        if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                            if ("%IsAlert%" === "1") {
                                uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "Lưu thất bại" });
                            }
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

                                    // Thực hiện update shared grid
                                    window.updateSharedGridRow("%GridColumnName%", updateData);

                                    // Kiểm tra và cập nhật biến DataSource cục bộ
                                    if (typeof DataSource !== "undefined" && Array.isArray(DataSource)) {
                                        var ds;
                                        if (!hasKey2) {
                                            // Trường hợp 1 khóa
                               ds = DataSource.filter(item => item["%ColumnIDName%"] === updateData["%ColumnIDName%"]);
                                        } else {
                                            // Trường hợp 2 khóa
                                            ds = DataSource.filter(item =>
                                                item["%ColumnIDName%"] === updateData["%ColumnIDName%"] &&
                                                item[id2FieldName] === updateData[id2FieldName]
                                            );
                                        }

                                        if (ds && ds.length > 0) {
                                            ds[0]["%ColumnName%"] = updateData["%ColumnName%"];
                                        }
                                    } // <-- Bạn thiếu dấu này
                                } catch (dsErr) {
                                    console.warn("[Grid Sync] TextBox %ColumnName%%UID%: Không thể sync shared grid data source:", dsErr);
                                }
                            }


                        if ("%IsAlert%" === "1") {
                            uiManager.showAlert({ type: "success", message: "Lưu thành công" });
                        }
                    }

                    %ColumnName%%UID%OriginalValue = newVal;

                    if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                        try {
                            const grid = cellInfo.component;
                            grid.cellValue(cellInfo.rowIndex, "%ColumnName%", newVal);
                            grid.repaint();
                        } catch (syncErr) {
                            console.warn("[Grid Sync] Không thể sync grid:", syncErr);
                        }
                    }

                } catch (err) {
                    console.warn("[%ColumnName%%UID%] Có lỗi:", err);
                } finally {
                    setTimeout(function(){
                        _saving%ColumnName%%UID% = false;
                    }, 100);
                }
            }

            /* =============== Create UI =============== */

            %ColumnName%%UID%ValidationMsg = $("<div>").css({
                "color": "#d9534f",
                "font-size": "0.875rem",
                "padding": "4px 8px",
                "display": "none",
                "margin-top": "2px"
            }).appendTo($container%ColumnName%%UID%);

            %ColumnName%%UID%RealInstance = $("<div>")
                .appendTo($container%ColumnName%%UID%)
                .dxTextBox({
                    value: "",
                    width: "100%",
                    placeholder: "Nhập dữ liệu",
                    readOnly: _readOnly%ColumnName%%UID%,
                    inputAttr: {
                        style: " padding: 6px 8px; font-size: inherit; font-weight: inherit; box-sizing: border-box; transition: all 0.2s;"
                    },
                    onValueChanged: function(e) {
                        if (e.value && e.value.trim() !== "") {
                            hideValidationError%ColumnName%%UID%();
                        }
                    },
                    onFocusIn: function(e) {
                        if (_readOnly%ColumnName%%UID%) return;

                        $container%ColumnName%%UID%.find("input").css({
                            "padding": "5px 7px"
                        });
                    },
                    onFocusOut: function(e) {
                        if (_readOnly%ColumnName%%UID%) return;

                        const $input = $container%ColumnName%%UID%.find("input");
                        const currentValue = $input.val();

                        // Reset padding
                        $input.css({
        "padding": "6px 8px"
                        });

    // Validate required
                        if (%IsRequired% === 1) {
                            if (!currentValue || currentValue.trim() === "") {
                                const errorMsg = window.ValidationEngine && window.ValidationEngine.getRequiredMessage
                                    ? window.ValidationEngine.getRequiredMessage("%DisplayName%")
                                    : "%DisplayName% là bắt buộc";

                                showValidationError%ColumnName%%UID%(errorMsg);
                                return;
                            }
                        }

                        hideValidationError%ColumnName%%UID%();

                        // 👉 chỉ save khi value thay đổi
                        if (currentValue !== %ColumnName%%UID%OriginalValue) {
                            %ColumnName%%UID%RealInstance.option("value", currentValue);
                            saveValue%ColumnName%%UID%();
                            %ColumnName%%UID%OriginalValue = currentValue;
                        }
                    },
                    onKeyDown: function(e) {
                        if (e.event.key === "Enter") {
                            e.event.preventDefault();

                            const currentValue = $container%ColumnName%%UID%.find("input").val();

                            if (%IsRequired% === 1) {
                                if (!currentValue || currentValue.trim() === "") {
                                    const errorMsg = window.ValidationEngine && window.ValidationEngine.getRequiredMessage
                                        ? window.ValidationEngine.getRequiredMessage("%DisplayName%")
                                        : "%DisplayName% là bắt buộc";

                                    showValidationError%ColumnName%%UID%(errorMsg);
                                    return;
                                }
                            }

                            hideValidationError%ColumnName%%UID%();
                            %ColumnName%%UID%RealInstance.option("value", currentValue);
                            saveValue%ColumnName%%UID%();
                        }

                        if (e.event.key === "Tab") {
                            e.event.preventDefault();
                            const $input = $container%ColumnName%%UID%.find("input");
                            const currentValue = $input.val();
                            %ColumnName%%UID%RealInstance.option("value", currentValue);
                            saveValue%ColumnName%%UID%();
                        }

                        if (e.event.key === "Escape") {
                            e.event.preventDefault();
                            %ColumnName%%UID%RealInstance.option("value", %ColumnName%%UID%OriginalValue);
                            hideValidationError%ColumnName%%UID%();
                            $container%ColumnName%%UID%.find("input").blur();
                        }
                    }
                })
                .dxTextBox("instance");

            /* =============== Public API =============== */
            Instance%ColumnName%%UID% = {
                setValue: function(val) {
                    const displayVal = (val == null || val === "") ? "" : String(val);
                    %ColumnName%%UID%OriginalValue = displayVal;
                    %ColumnName%%UID%RealInstance.option("value", displayVal);
                },
                getValue: function() {
                    return %ColumnName%%UID%RealInstance.option("value");
                },
                option: function(name, value) {
                    if (value !== undefined) {
                        %ColumnName%%UID%RealInstance.option(name, value);

                        if (name === "value") {
                            const val = value || "";
                 %ColumnName%%UID%OriginalValue = val;

                            if (
                                this.__cellInfo &&
                                typeof this.__cellInfo.setValue === "function" &&
                                this.__cellInfo.component
                            ) {
                                try {
                                    this.__cellInfo.setValue(val);
                                } catch (e) {
                                    console.warn("[hpaControlText] Grid sync skipped", e);
                                }
                            }
                        }
                    } else {
                        return %ColumnName%%UID%RealInstance.option(name);
                }
                },
                repaint: function() {
                    %ColumnName%%UID%RealInstance.repaint();
                },
                _suppressValueChangeAction: function() {
                    if (%ColumnName%%UID%RealInstance._suppressValueChangeAction) {
                        %ColumnName%%UID%RealInstance._suppressValueChangeAction();
                    }
                },
                _resumeValueChangeAction: function() {
                    if (%ColumnName%%UID%RealInstance._resumeValueChangeAction) {
                        %ColumnName%%UID%RealInstance._resumeValueChangeAction();
                    }
                }
            };
        '
    WHERE [Type] = 'hpaControlText' AND [ReadOnly] = 0 AND [AutoSave] = 0;
END
GO
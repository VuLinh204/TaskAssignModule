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
    -- hpaControlText - NORMAL MODE: READONLY
    -- =========================================================================
    UPDATE #temptable SET
        loadUI = N'
            if (!$("head").find("#hpa-inherit-font-style").length) $("head").append("<style id=\"hpa-inherit-font-style\">.dx-widget{font-size:inherit!important;font-weight:inherit!important;line-height:inherit!important;border-radius:inherit!important}.dx-texteditor, .dx-texteditor-input{font-size:inherit!important;font-weight:inherit!important;line-height:inherit!important;box-sizing:border-box!important;}</style>");
            window.Instance%columnName% = $("#%UID%").dxTextBox({
                value: "",
                width: "100%",
                readOnly: true,
                elementAttr: { style: "border: none !important; box-shadow: none !important; background: transparent !important; padding: inherit !important;" },
                inputAttr: { style: "max-height: 100%; border: none !important; background: transparent; box-shadow: none; padding: inherit; font-size: inherit; font-weight: inherit;" }
            }).dxTextBox("instance");
        '
    WHERE [Type] = 'hpaControlText' AND [ReadOnly] = 1;

    -- =========================================================================
    -- hpaControlText - NORMAL MODE: AUTOSAVE + Inline Edit + Popup Save/Cancel
    -- =========================================================================
    UPDATE #temptable SET
        loadUI = N'
            if (!$("head").find("#hpa-inherit-font-style").length) $("head").append("<style id=\"hpa-inherit-font-style\">.dx-widget{font-size:inherit!important;font-weight:inherit!important;line-height:inherit!important;border-radius:inherit!important}.dx-texteditor, .dx-texteditor-input{font-size:inherit!important;font-weight:inherit!important;line-height:inherit!important;box-sizing:border-box!important;}</style>");
            const $container%columnName% = $("#%UID%");

            let %columnName%OriginalValue = "";
            let %columnName%IsEditing   = false;
            let %columnName%TextDisplay = null;
            let %columnName%MouseDownInside = false;
            let _cancelingSave%columnName% = false;
            let _justSaved%columnName% = false;
            let _saving%columnName% = false;
            window.%columnName%RealInstance = null;

            /* =============== Popup Save/Cancel =============== */
            let actionPopup%columnName%     = null;
            let currentFieldId%columnName%  = null;
            let saveCallback%columnName%    = null;
            let cancelCallback%columnName%  = null;

            function initActionPopup%columnName%() {
                if (actionPopup%columnName%) return;
                actionPopup%columnName% = $("<div>").appendTo("body").dxPopup({
                    width: "auto",
                    height: "auto",
                    showTitle: false,
                    visible: false,
                    shading: false,
                    dragEnabled: false,
                    hideOnOutsideClick: false,
                    animation: null,
                    showCloseButton: false,
                    position: { at: "bottom right", my: "top right", offset: "0 4" },
                    onShown: function(e) {
                        $(e.component.content()).closest(".dx-overlay-wrapper").css("z-index", "9999");
                    },
                    contentTemplate: () => {
                        return $("<div class=\"d-flex\" style=\"gap: 6px; padding: 6px; min-height: fit-content; display: flex; align-items: center; justify-content: center; \">").append(
                            $("<div>").dxButton({
                                icon: "check",
                              type: "success",
                                stylingMode: "contained",
                                width: 32, height: 32,
                                elementAttr: { style: "border-radius: 4px !important;" },
                                onInitialized: function(e) {
                                    // Bind mousedown để set flag sớm hơn onFocusOut
                                    $(e.element).on("mousedown", function() {
                                        _justSaved%columnName% = true;
                                        _saving%columnName% = true;
                                    });
                                },
                                onClick: async function() {
                                    if (saveCallback%columnName%) {
                                        await saveCallback%columnName%(true); // Pass true để báo từ button
                                    }

                                    actionPopup%columnName%.hide();

                                    setTimeout(function(){
                                        _justSaved%columnName% = false;
                                        _saving%columnName% = false;
                                    }, 300);
                                }
                            }),
                            $("<div>").dxButton({
                                icon: "close",
                                stylingMode: "outlined",
                                width: 32, height: 32,
                                elementAttr: { style: "border-radius: 4px !important;" },
                                onInitialized: function(e) {
                                    // Bind mousedown để set flag sớm hơn onFocusOut
                                    $(e.element).on("mousedown", function() {
                                        _cancelingSave%columnName% = true;
                                    });
                                },
                                onClick: function() {
                                    if (cancelCallback%columnName%) {
                                        cancelCallback%columnName%();
                                    }

                                    actionPopup%columnName%.hide();

                                    setTimeout(function(){
                                        _cancelingSave%columnName% = false;
                                    }, 300);
                                }
                            })
                        );
                    },
                    onHiding: function() {
                        currentFieldId%columnName% = saveCallback%columnName% = cancelCallback%columnName% = null;
                    }
                }).dxPopup("instance");
            }

            function showActionPopup%columnName%(inputElement, fieldId, onSave, onCancel) {
                if (!actionPopup%columnName%) initActionPopup%columnName%();

                if (currentFieldId%columnName% && currentFieldId%columnName% !== fieldId && cancelCallback%columnName%) {
                    cancelCallback%columnName%();
                }

                currentFieldId%columnName% = fieldId;
                saveCallback%columnName%   = onSave;
                cancelCallback%columnName% = onCancel;

                const updatePos = () => {
                    if (!actionPopup%columnName%?.option("visible")) return;
                    const $input = $(inputElement).find("input");
                    if ($input.length === 0) return;
                    actionPopup%columnName%.option({
                        position: {
                            my: "top right",
                            at: "bottom right",
                            of: $input,
                            offset: "0 4"
                        }
                    });
                    actionPopup%columnName%.repaint();
                };

                actionPopup%columnName%.show();
                setTimeout(updatePos, 10);

                $(window).off("scroll.ap" + fieldId).on("scroll.ap" + fieldId, updatePos);
                $(window).off("resize.ap" + fieldId).on("resize.ap" + fieldId, updatePos);
                $(".dx-scrollable").off("scroll.ap" + fieldId).on("scroll.ap" + fieldId, updatePos);

                const intervalId = setInterval(() => {
                    if (actionPopup%columnName%?.option("visible")) updatePos();
                    else clearInterval(intervalId);
                }, 100);

                actionPopup%columnName%.option("onHiding", function() {
                    clearInterval(intervalId);
                    $(window).off("scroll.ap" + fieldId);
                    $(window).off("resize.ap" + fieldId);
                    $(".dx-scrollable").off("scroll.ap" + fieldId);
                    currentFieldId%columnName% = saveCallback%columnName% = cancelCallback%columnName% = null;
                });
            }

            /* =============== Inline Edit logic =============== */
            function exitEdit%columnName%(cancel = false) {
                if (!%columnName%IsEditing) return;
                %columnName%IsEditing = false;
                %columnName%MouseDownInside = false;
                $(document).off("mousedown.edit%columnName%");
                $(document).off("mouseup.edit%columnName%");

                if (cancel) {
                    %columnName%RealInstance.option("value", %columnName%OriginalValue);
                } else {
                    %columnName%OriginalValue = %columnName%RealInstance.option("value");
                }

                if (actionPopup%columnName% && actionPopup%columnName%.option("visible")) {
                    actionPopup%columnName%.option("visible", false);
                }

                $container%columnName%.find(".dx-texteditor").hide();
                %columnName%TextDisplay.text(%columnName%OriginalValue || "").show();
            }

            async function saveValue%columnName%(fromButton = false) {
                if (_cancelingSave%columnName%) {
                    _cancelingSave%columnName% = false;
                    exitEdit%columnName%(true);
                    return;
                }

                // Chỉ check flag _saving khi KHÔNG phải từ button
                // Vì khi từ button thì flag đã được set ở mousedown
                if (!fromButton && _saving%columnName%) {
                    return;
                }

                const newVal = %columnName%RealInstance.option("value");

                if (newVal === %columnName%OriginalValue) {
                    exitEdit%columnName%();
                    _saving%columnName% = false;
                    _justSaved%columnName% = false;
                    return;
                }

                try {
                    // Chỉ set flag nếu chưa được set (từ button đã set rồi)
                    if (!fromButton) {
                        _saving%columnName% = true;
                    }

                    const dataJSON = JSON.stringify(["%tableId%", ["%columnName%"], [newVal]]);

                    let currentRecordIDValue = [
                        currentRecordID_%ColumnIDName%
                    ];

                    let currentRecordID = [
                        "%ColumnIDName%"
                    ];

                    // chỉ nối khi ColumnIDName2 có thật
                    if ("%ColumnIDName2%" && "%ColumnIDName2%".trim() !== "") {
                        currentRecordIDValue.push(currentRecordID_%ColumnIDName2%);
                        currentRecordID.push("%ColumnIDName2%");
                    }

                    const idValsJSON = JSON.stringify([currentRecordIDValue, currentRecordID]);

                    const json = await saveFunction(dataJSON, idValsJSON);

                    const dtError = json.data[json.data.length - 1] || [];
                    if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                        if ("%IsAlert%" === "1") {
                            uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "Lưu thất bại" });
                        }
                        _saving%columnName% = false;
                        _justSaved%columnName% = false;
                        return;
                    }

                    %columnName%OriginalValue = newVal;
                    if ("%IsAlert%" === "1") {
                        uiManager.showAlert({ type: "success", message: "Lưu thành công" });
                    }

                    exitEdit%columnName%();

                    if (cellInfo && cellInfo.component) {
                        try {
                            const grid = cellInfo.component;
                            const rowKey = cellInfo.key || cellInfo.data["%ColumnIDName%"];

                            // Cập nhật cell value trong grid
                            grid.cellValue(cellInfo.rowIndex, "%columnName%", newVal);

                            // Refresh cell để hiển thị giá trị mới
                            grid.repaint();

                        } catch (syncErr) {
                            console.warn("[Grid Sync] Không thể sync grid:", syncErr);
                        }
                    }
                } catch (err) {
                    if ("%IsAlert%" === "1") {
                        uiManager.showAlert({ type: "error", message: "Có lỗi xảy ra khi lưu" });
                    }
                } finally {
                    setTimeout(function(){
                        _saving%columnName% = false;
                        _justSaved%columnName% = false;
                    }, 100);
                }
            }

            /* =============== Handle Click Outside =============== */
            function handleMouseDown%columnName%(e) {
                if (!%columnName%IsEditing) return;

                // Nếu đang save hoặc cancel thì không xử lý
                if (_saving%columnName% || _cancelingSave%columnName%) return;

                const $t = $(e.target);
                const isInsideControl = $t.closest($container%columnName%).length > 0;
                const isInsidePopup = $t.closest(".dx-popup-wrapper").length > 0;

                if (isInsideControl || isInsidePopup) {
                    %columnName%MouseDownInside = true;
                } else {
                    %columnName%MouseDownInside = false;
                }
            }

            function handleMouseUp%columnName%(e) {
                if (!%columnName%IsEditing) return;

                // Nếu đang save, cancel hoặc vừa save xong thì không xử lý
                if (_saving%columnName% || _cancelingSave%columnName% || _justSaved%columnName%) {
                    %columnName%MouseDownInside = false;
                    return;
                }

                const $t = $(e.target);
                const isInsideControl = $t.closest($container%columnName%).length > 0;
                const isInsidePopup = $t.closest(".dx-popup-wrapper").length > 0;

                // Chỉ save khi cả mousedown và mouseup đều ở ngoài
                if (!%columnName%MouseDownInside && !isInsideControl && !isInsidePopup) {
                    saveValue%columnName%();
                }

                %columnName%MouseDownInside = false;
            }

            /* =============== Create UI =============== */
            %columnName%TextDisplay = $("<div>").css({
                "padding": "1px 8px",
                "cursor": "text",
                "min-height": "20px",
                "line-height": "1.5",
                "word-break": "break-word",
                "border": "1px solid transparent",
                "border-radius": "inherit !important",
                "transition": "border-color 0.2s"
            }).appendTo($container%columnName%);

            // Hover effect
            %columnName%TextDisplay.hover(
                function() {
                    if (!%columnName%IsEditing) {
                        $(this).css("border-color", "#ddd");
                    }
                },
                function() {
                    if (!%columnName%IsEditing) {
                        $(this).css("border-color", "transparent");
                    }
                }
            );

            %columnName%TextDisplay.on("click", function() {
                if (%columnName%IsEditing) return;
                %columnName%IsEditing = true;
                %columnName%MouseDownInside = false;
                %columnName%OriginalValue = %columnName%RealInstance.option("value");
                %columnName%TextDisplay.hide();

                $container%columnName%.find(".dx-texteditor").show();

                const $input = $container%columnName%.find("input");
                setTimeout(() => {
                    $input.focus();
                    const len = $input.val().length;
                    $input[0].setSelectionRange(len, len);
                }, 10);

                $input.css({
                    "border-color": "#1c975e",
                    "padding": "1px 8px",
                    "max-height": "100%",
                    "cursor": "text",
                    "border-radius": "inherit !important",
                    "font-size": "inherit",
                    "font-weight": "inherit",
                    "box-sizing": "border-box"
                });

                showActionPopup%columnName%(
                    $container%columnName%,
                    "%columnName%",
                    async (fromButton) => { await saveValue%columnName%(fromButton); },
                    () => exitEdit%columnName%(true)
                );

                // Bind events sau khi mở edit mode
                setTimeout(() => {
                    $(document).on("mousedown.edit%columnName%", handleMouseDown%columnName%);
                    $(document).on("mouseup.edit%columnName%", handleMouseUp%columnName%);
                }, 100);
            });

            %columnName%RealInstance = $("<div>")
                .appendTo($container%columnName%)
                .dxTextBox({
                    value: "",
                    width: "100%",
                    inputAttr: { style: "max-height: 100%; line-height: 1.5; font-size: inherit; font-weight: inherit; padding: 1px 8px; box-sizing: border-box;" },
                    onKeyDown: function(e) {
                        if (!%columnName%IsEditing) return;

                        if (e.event.key === "Enter") {
                            e.event.preventDefault();
                            // Cập nhật value từ input element trước khi save
                            const $input = $container%columnName%.find("input");
                            const currentValue = $input.val();
                            %columnName%RealInstance.option("value", currentValue);
                            saveValue%columnName%();
                        }

                        if (e.event.key === "Tab") {
                            e.event.preventDefault();
                            // Tab cũng lưu giống Enter
                            const $input = $container%columnName%.find("input");
                            const currentValue = $input.val();
                            %columnName%RealInstance.option("value", currentValue);
                            saveValue%columnName%();
                        }

                        if (e.event.key === "Escape") {
                            e.event.preventDefault();
                            exitEdit%columnName%(true);
                        }
                    },
                    onFocusOut: function(e) {
                        // Kiểm tra các flag để tránh save trùng
                        if (_cancelingSave%columnName%) {
                            _cancelingSave%columnName% = false;
                            return;
                        }
                        if (_justSaved%columnName%) {
                            _justSaved%columnName% = false;
                            return;
                        }
                        if (_saving%columnName%) {
                            return;
                        }

                        // Auto-save khi mất focus
                        if (%columnName%IsEditing) {
                            const $input = $container%columnName%.find("input");
                            if ($input.val() !== %columnName%OriginalValue) {
                                const currentValue = $input.val();
                                %columnName%RealInstance.option("value", currentValue);
                                saveValue%columnName%();
                            } else {
                                exitEdit%columnName%(false);
                            }
                        }
                    }
                })
                .dxTextBox("instance");

            $container%columnName%.find(".dx-texteditor").hide();

            /* =============== Public API =============== */
            let Instance%columnName% = {
                setValue: function(val) {
                    %columnName%OriginalValue = val || "";
                    %columnName%RealInstance.option("value", val || "");
                    %columnName%TextDisplay.text(val || "");
                },
                getValue: function() {
                    return %columnName%RealInstance.option("value");
                },
                option: function(name, value) {
                    if (value !== undefined) {
                        %columnName%RealInstance.option(name, value);
                        if (name === "value") {
                            %columnName%OriginalValue = value || "";
                            %columnName%TextDisplay.text(value || "");
                        }
                    } else {
                        return %columnName%RealInstance.option(name);
                    }
                },
                repaint: function() {
                    %columnName%RealInstance.repaint();
                },
                _suppressValueChangeAction: function() {
                    if (%columnName%RealInstance._suppressValueChangeAction) {
                        %columnName%RealInstance._suppressValueChangeAction();
                    }
                },
                _resumeValueChangeAction: function() {
                    if (%columnName%RealInstance._resumeValueChangeAction) {
                        %columnName%RealInstance._resumeValueChangeAction();
                    }
                }
            };
        '
    WHERE [Type] = 'hpaControlText' AND [ReadOnly] = 0 AND [AutoSave] = 1;

    -- =========================================================================
    -- hpaControlText - NORMAL MODE: NO AUTOSAVE (ReadOnly=0, AutoSave=0)
    -- Cho phép edit nhưng chỉ lưu text local, không gọi API
    -- =========================================================================
    UPDATE #temptable SET
    loadUI = N'
            if (!$("head").find("#hpa-inherit-font-style").length) $("head").append("<style id=\"hpa-inherit-font-style\">.dx-widget{font-size:inherit!important;font-weight:inherit!important;line-height:inherit!important;border-radius:inherit!important}.dx-texteditor, .dx-texteditor-input{font-size:inherit!important;font-weight:inherit!important;line-height:inherit!important;box-sizing:border-box!important;}</style>");
            const $container%columnName% = $("#%UID%");

            let %columnName%OriginalValue = "";
            let %columnName%IsEditing   = false;
            let %columnName%TextDisplay = null;
            let %columnName%MouseDownInside = false;
            let _cancelingSave%columnName% = false;
            window.%columnName%RealInstance = null;

            /* =============== Inline Edit logic (No API Save) =============== */
            function exitEdit%columnName%(cancel = false) {
                if (!%columnName%IsEditing) return;
                %columnName%IsEditing = false;
                %columnName%MouseDownInside = false;
                $(document).off("mousedown.edit%columnName%");
                $(document).off("mouseup.edit%columnName%");

                if (cancel) {
                    %columnName%RealInstance.option("value", %columnName%OriginalValue);
                } else {
                    // Chỉ lưu giá trị mới vào biến, không gọi API
                    %columnName%OriginalValue = %columnName%RealInstance.option("value");
                }

                $container%columnName%.find(".dx-texteditor").hide();
                %columnName%TextDisplay.text(%columnName%OriginalValue || "").show();
            }

            function saveValueLocal%columnName%() {
                const newVal = %columnName%RealInstance.option("value");
                if (_cancelingSave%columnName%) { _cancelingSave%columnName% = false; exitEdit%columnName%(true); return; }

                // Chỉ cập nhật giá trị local, không gọi API
                %columnName%OriginalValue = newVal;
                exitEdit%columnName%();
            }

            /* =============== Handle Click Outside =============== */
            function handleMouseDown%columnName%(e) {
                if (!%columnName%IsEditing) return;

                const $t = $(e.target);
                const isInsideControl = $t.closest($container%columnName%).length > 0;

                if (isInsideControl) {
                    %columnName%MouseDownInside = true;
                } else {
                    %columnName%MouseDownInside = false;
                }
            }

            function handleMouseUp%columnName%(e) {
                if (!%columnName%IsEditing) return;

                const $t = $(e.target);
                const isInsideControl = $t.closest($container%columnName%).length > 0;

                // Chỉ save local khi cả mousedown và mouseup đều ở ngoài
                if (!%columnName%MouseDownInside && !isInsideControl) {
                    saveValueLocal%columnName%();
                }

                %columnName%MouseDownInside = false;
            }

            /* =============== Create UI =============== */
            %columnName%TextDisplay = $("<div>").css({
                "padding": "1px 8px",
                "cursor": "text",
                "min-height": "20px",
                "line-height": "1.5",
                "word-break": "break-word",
                "border": "1px solid transparent",
                "border-radius": "inherit !important",
                "transition": "border-color 0.2s"
            }).appendTo($container%columnName%);

            // Hover effect để người dùng biết có thể click
            %columnName%TextDisplay.hover(
                function() {
                    if (!%columnName%IsEditing) {
                        $(this).css("border-color", "#ddd");
                }
                },
                function() {
                    if (!%columnName%IsEditing) {
                        $(this).css("border-color", "transparent");
                    }
                }
            );

            %columnName%TextDisplay.on("click", function() {
                if (%columnName%IsEditing) return;
                %columnName%IsEditing = true;
                %columnName%MouseDownInside = false;
                %columnName%OriginalValue = %columnName%RealInstance.option("value");
                %columnName%TextDisplay.hide();

                $container%columnName%.find(".dx-texteditor").show();

                const $input = $container%columnName%.find("input");
                setTimeout(() => {
                    $input.focus();
                    const len = $input.val().length;
                    $input[0].setSelectionRange(len, len);
                }, 10);

                $input.css({
                    "border-color": "#1c975e",
                    "padding": "1px 8px",
                    "max-height": "100%",
                    "cursor": "text",
                    "border-radius": "inherit !important",
                    "font-size": "inherit",
                    "font-weight": "inherit",
                    "box-sizing": "border-box"
                });

                // Bind events sau khi mở edit mode
                setTimeout(() => {
                    $(document).on("mousedown.edit%columnName%", handleMouseDown%columnName%);
                    $(document).on("mouseup.edit%columnName%", handleMouseUp%columnName%);
                }, 100);
            });

            window.%columnName%RealInstance = $("<div>")
                .appendTo($container%columnName%)
                .dxTextBox({
                    value: "",
                    width: "100%",
                    inputAttr: { style: "max-height: 100%; line-height: 1.5; font-size: inherit; font-weight: inherit; padding: 1px 8px; box-sizing: border-box;" },
                    onKeyDown: function(e) {
                        if (!%columnName%IsEditing) return;

                        if (e.event.key === "Enter") {
                            e.event.preventDefault();
                            // Cập nhật value từ input trước khi save local
                            const $input = $container%columnName%.find("input");
                            const currentValue = $input.val();
                            %columnName%RealInstance.option("value", currentValue);
                            saveValueLocal%columnName%();
                        }

                        if (e.event.key === "Tab") {
                            e.event.preventDefault();
                            // Tab cũng save local
                            const $input = $container%columnName%.find("input");
                            const currentValue = $input.val();
                            %columnName%RealInstance.option("value", currentValue);
                            saveValueLocal%columnName%();
                        }

                        if (e.event.key === "Escape") {
                            e.event.preventDefault();
                            exitEdit%columnName%(true);
                        }
                    },
                    onFocusOut: function(e) {
                        // Do not save if Cancel was just clicked
                        if (_cancelingSave%columnName%) { _cancelingSave%columnName% = false; return; }

                        // Auto-save local khi mất focus
                        if (%columnName%IsEditing) {
                            const $input = $container%columnName%.find("input");
                            if ($input.val() !== %columnName%OriginalValue) {
                                const currentValue = $input.val();
                                %columnName%RealInstance.option("value", currentValue);
                                saveValueLocal%columnName%();
                            } else {
                                exitEdit%columnName%(false);
                            }
                        }
                    }
                })
                .dxTextBox("instance");

            $container%columnName%.find(".dx-texteditor").hide();

            /* =============== Public API =============== */
            let Instance%columnName% = {
                setValue: function(val) {
                    %columnName%OriginalValue = val || "";
                    %columnName%RealInstance.option("value", val || "");
                    %columnName%TextDisplay.text(val || "");
                },
                getValue: function() {
                    return %columnName%RealInstance.option("value");
                },
                option: function(name, value) {
                    if (value !== undefined) {
                        %columnName%RealInstance.option(name, value);
                        if (name === "value") {
                            %columnName%OriginalValue = value || "";
                            %columnName%TextDisplay.text(value || "");
                        }
                    } else {
                        return %columnName%RealInstance.option(name);
                    }
                },
                repaint: function() {
                    %columnName%RealInstance.repaint();
                },
                _suppressValueChangeAction: function() {
                    if (%columnName%RealInstance._suppressValueChangeAction) {
                        %columnName%RealInstance._suppressValueChangeAction();
                    }
                },
                _resumeValueChangeAction: function() {
                    if (%columnName%RealInstance._resumeValueChangeAction) {
                        %columnName%RealInstance._resumeValueChangeAction();
                    }
                }
            };
        '
    WHERE [Type] = 'hpaControlText' AND [ReadOnly] = 0 AND [AutoSave] = 0;
END
GO
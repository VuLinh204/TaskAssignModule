
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
            let Instance%ColumnName%%UID% = null;
            
            if (!$("head").find("#hpa-inherit-font-style").length) $("head").append("<style id=\"hpa-inherit-font-style\">.dx-widget{font-size:inherit!important;font-weight:inherit!important;line-height:inherit!important;border-radius:inherit!important}.dx-texteditor, .dx-texteditor-input{font-size:inherit!important;font-weight:inherit!important;line-height:inherit!important;box-sizing:border-box!important;}</style>");
            Instance%ColumnName%%UID% = $("#%UID%").dxTextBox({
                value: "",
                width: "100%",
                readOnly: true,
                elementAttr: { 
                    style: "border: none !important; box-shadow: none !important; background: transparent !important; padding: inherit !important;" 
                },
                inputAttr: { 
                    style: "max-height: 100%; border: none !important; background: transparent; box-shadow: none; padding: inherit; font-size: inherit; font-weight: inherit;" 
                }
            }).dxTextBox("instance");
        '
    WHERE [Type] = 'hpaControlText' AND [ReadOnly] = 1;

    -- =========================================================================
    -- hpaControlText - NORMAL MODE: AUTOSAVE + Inline Edit + Popup Save/Cancel
    -- =========================================================================
    UPDATE #temptable SET 
        loadUI = N'
            let Instance%ColumnName%%UID% = null;
            if (!$("head").find("#hpa-inherit-font-style").length) $("head").append("<style id=\"hpa-inherit-font-style\">.dx-widget{font-size:inherit!important;font-weight:inherit!important;line-height:inherit!important;border-radius:inherit!important}.dx-texteditor, .dx-texteditor-input{font-size:inherit!important;font-weight:inherit!important;line-height:inherit!important;box-sizing:border-box!important;}</style>");
            const $container%ColumnName%%UID% = $("#%UID%");

            let %ColumnName%%UID%OriginalValue = "";
            let %ColumnName%%UID%IsEditing = false;
            let %ColumnName%%UID%TextDisplay = null;
            let %ColumnName%%UID%MouseDownInside = false;
            let _cancelingSave%ColumnName%%UID% = false;
            let _justSaved%ColumnName%%UID% = false;
            let _saving%ColumnName%%UID% = false;
            let %ColumnName%%UID%RealInstance = null;

            /* =============== Popup Save/Cancel =============== */
            let actionPopup%ColumnName%%UID%     = null;
            let currentFieldId%ColumnName%%UID%  = null;
            let saveCallback%ColumnName%%UID%    = null;
            let cancelCallback%ColumnName%%UID%  = null;

            function initActionPopup%ColumnName%%UID%() {
                if (actionPopup%ColumnName%%UID%) return;
                actionPopup%ColumnName%%UID% = $("<div>").appendTo("body").dxPopup({
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
                                        _justSaved%ColumnName%%UID% = true;
                                        _saving%ColumnName%%UID% = true;
                                    });
                                },
                                onClick: async function() {
                                    if (saveCallback%ColumnName%%UID%) {
                                        await saveCallback%ColumnName%%UID%(true); // Pass true để báo từ button
                                    }
                                    
                                    actionPopup%ColumnName%%UID%.hide();
                                    
                                    setTimeout(function(){ 
                                        _justSaved%ColumnName%%UID% = false;
                                        _saving%ColumnName%%UID% = false;
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
                                        _cancelingSave%ColumnName%%UID% = true;
                                    });
                                },
                                onClick: function() {
                                    if (cancelCallback%ColumnName%%UID%) {
                                        cancelCallback%ColumnName%%UID%();
                                    }
                                    
                                    actionPopup%ColumnName%%UID%.hide();
                                    
                                    setTimeout(function(){ 
                                        _cancelingSave%ColumnName%%UID% = false; 
                                    }, 300);
                                }
                            })
                        );
                    },
                    onHiding: function() {
                        currentFieldId%ColumnName%%UID% = saveCallback%ColumnName%%UID% = cancelCallback%ColumnName%%UID% = null;
                    }
                }).dxPopup("instance");
            }

            function showActionPopup%ColumnName%%UID%(inputElement, fieldId, onSave, onCancel) {
                if (!actionPopup%ColumnName%%UID%) initActionPopup%ColumnName%%UID%();

                if (currentFieldId%ColumnName%%UID% && currentFieldId%ColumnName%%UID% !== fieldId && cancelCallback%ColumnName%%UID%) {
                    cancelCallback%ColumnName%%UID%();
                }

                currentFieldId%ColumnName%%UID% = fieldId;
                saveCallback%ColumnName%%UID%   = onSave;
                cancelCallback%ColumnName%%UID% = onCancel;

                const updatePos = () => {
                    if (!actionPopup%ColumnName%%UID%?.option("visible")) return;
                    const $input = $(inputElement).find("input");
                    if ($input.length === 0) return;
                    actionPopup%ColumnName%%UID%.option({
                        position: {
                            my: "top right",
                            at: "bottom right",
                            of: $input,
                            offset: "0 4"
                        }
                    });
                    actionPopup%ColumnName%%UID%.repaint();
                };

                actionPopup%ColumnName%%UID%.show();
                setTimeout(updatePos, 10);

                $(window).off("scroll.ap" + fieldId).on("scroll.ap" + fieldId, updatePos);
                $(window).off("resize.ap" + fieldId).on("resize.ap" + fieldId, updatePos);
                $(".dx-scrollable").off("scroll.ap" + fieldId).on("scroll.ap" + fieldId, updatePos);

                const intervalId = setInterval(() => {
                    if (actionPopup%ColumnName%%UID%?.option("visible")) updatePos();
                    else clearInterval(intervalId);
                }, 100);

                actionPopup%ColumnName%%UID%.option("onHiding", function() {
                    clearInterval(intervalId);
                    $(window).off("scroll.ap" + fieldId);
                    $(window).off("resize.ap" + fieldId);
                    $(".dx-scrollable").off("scroll.ap" + fieldId);
                    currentFieldId%ColumnName%%UID% = saveCallback%ColumnName%%UID% = cancelCallback%ColumnName%%UID% = null;
                });
            }

            /* =============== Inline Edit logic =============== */
            function exitEdit%ColumnName%%UID%(cancel = false) {
                if (!%ColumnName%%UID%IsEditing) return;
                %ColumnName%%UID%IsEditing = false;
                %ColumnName%%UID%MouseDownInside = false;
                $(document).off("mousedown.edit%ColumnName%%UID%");
                $(document).off("mouseup.edit%ColumnName%%UID%");

                if (cancel) {
                    %ColumnName%%UID%RealInstance.option("value", %ColumnName%%UID%OriginalValue);
                } else {
                    %ColumnName%%UID%OriginalValue = %ColumnName%%UID%RealInstance.option("value");
                }

                if (actionPopup%ColumnName%%UID% && actionPopup%ColumnName%%UID%.option("visible")) {
                    actionPopup%ColumnName%%UID%.option("visible", false);
                }

                $container%ColumnName%%UID%.find(".dx-texteditor").hide();
                %ColumnName%%UID%TextDisplay.text(%ColumnName%%UID%OriginalValue || "").show();
            }

            async function saveValue%ColumnName%%UID%(fromButton = false) {
                if (_cancelingSave%ColumnName%%UID%) { 
                    _cancelingSave%ColumnName%%UID% = false; 
                    exitEdit%ColumnName%%UID%(true); 
                    return; 
                }

                // Chỉ check flag _saving khi KHÔNG phải từ button
                // Vì khi từ button thì flag đã được set ở mousedown
                if (!fromButton && _saving%ColumnName%%UID%) {
                    return;
                }
                
                const newVal = %ColumnName%%UID%RealInstance.option("value");
                
                if (newVal === %ColumnName%%UID%OriginalValue) {
                    exitEdit%ColumnName%%UID%();
                    _saving%ColumnName%%UID% = false;
                    _justSaved%ColumnName%%UID% = false;
                    return;
                }

                try {
                    // Chỉ set flag nếu chưa được set (từ button đã set rồi)
                    if (!fromButton) {
                        _saving%ColumnName%%UID% = true;
                    }
                    
                    const dataJSON = JSON.stringify(["%tableId%", ["%ColumnName%"], [newVal]]);

                    let currentRecordIDValue = [
                        currentRecordID_%ColumnIDName%
                    ];

                    let currentRecordID = [
                        "%ColumnIDName%"
                    ];

                    // Xử lý multiple IDs nếu ColumnIDName chứa dấu phẩy
                    if ("%ColumnIDName%".includes(",")) {
                        const ids = "%ColumnIDName%".split(",").map(id => id.trim());
                        ids.forEach(id => {
                            let idVal = window["currentRecordID_" + id];
                            currentRecordIDValue.push(idVal);
                        });
                        currentRecordID = "%ColumnIDName%".split(",").map(id => id.trim());
                    }

                    const idValsJSON = JSON.stringify([currentRecordIDValue, currentRecordID]);
                    const json = await saveFunction(dataJSON, idValsJSON);

                    const dtError = json.data[json.data.length - 1] || [];
                    if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                        if ("%IsAlert%" === "1") {
                            uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "Lưu thất bại" });
                        }
                        _saving%ColumnName%%UID% = false;
                        _justSaved%ColumnName%%UID% = false;
                        return;
                    }

                    %ColumnName%%UID%OriginalValue = newVal;
                    if ("%IsAlert%" === "1") {
                        uiManager.showAlert({ type: "success", message: "Lưu thành công" });
                    }
                    
                    exitEdit%ColumnName%%UID%();

                    if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                        try {
                            const grid = cellInfo.component;
                            const rowKey = cellInfo.key || cellInfo.data["%ColumnIDName%"];
                            
                            // Cập nhật cell value trong grid
                            grid.cellValue(cellInfo.rowIndex, "%ColumnName%%UID%", newVal);
                            
                            // Refresh cell để hiển thị giá trị mới
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
                        _justSaved%ColumnName%%UID% = false;
                    }, 100);
                }
            }

            /* =============== Handle Click Outside =============== */
            function handleMouseDown%ColumnName%%UID%(e) {
                if (!%ColumnName%%UID%IsEditing) return;
                
                // Nếu đang save hoặc cancel thì không xử lý
                if (_saving%ColumnName%%UID% || _cancelingSave%ColumnName%%UID%) return;

                const $t = $(e.target);
                const isInsideControl = $t.closest($container%ColumnName%%UID%).length > 0;
                const isInsidePopup = $t.closest(".dx-popup-wrapper").length > 0;

                if (isInsideControl || isInsidePopup) {
                    %ColumnName%%UID%MouseDownInside = true;
                } else {
                    %ColumnName%%UID%MouseDownInside = false;
                }
            }

            function handleMouseUp%ColumnName%%UID%(e) {
                if (!%ColumnName%%UID%IsEditing) return;

                // Nếu đang save, cancel hoặc vừa save xong thì không xử lý
                if (_saving%ColumnName%%UID% || _cancelingSave%ColumnName%%UID% || _justSaved%ColumnName%%UID%) {
                    %ColumnName%%UID%MouseDownInside = false;
                    return;
                }

                const $t = $(e.target);
                const isInsideControl = $t.closest($container%ColumnName%%UID%).length > 0;
                const isInsidePopup = $t.closest(".dx-popup-wrapper").length > 0;

                // Chỉ save khi cả mousedown và mouseup đều ở ngoài
                if (!%ColumnName%%UID%MouseDownInside && !isInsideControl && !isInsidePopup) {
                    saveValue%ColumnName%%UID%();
                }

                %ColumnName%%UID%MouseDownInside = false;
            }

            function updateDisplayText%ColumnName%%UID%(val) {
                const displayVal = val || "";
                if (displayVal === "") {
                    %ColumnName%%UID%TextDisplay.html(`<i style="color: #999;">Nhập dữ liệu</i>`);
                } else {
                    %ColumnName%%UID%TextDisplay.text(displayVal);
                }
            }

            /* =============== Create UI =============== */
            %ColumnName%%UID%TextDisplay = $("<div>").css({
                "padding": "1px 8px",
                "cursor": "text",
                "min-height": "20px",
                "line-height": "1.5",
                "word-break": "break-word",
                "border": "1px solid transparent",
                "border-radius": "inherit !important",
                "transition": "border-color 0.2s"
            }).appendTo($container%ColumnName%%UID%);

            updateDisplayText%ColumnName%%UID%("");

            // Hover effect
            %ColumnName%%UID%TextDisplay.hover(
                function() {
                    if (!%ColumnName%%UID%IsEditing) {
                        $(this).css("border-color", "#ddd");
                    }
                },
                function() {
                    if (!%ColumnName%%UID%IsEditing) {
                        $(this).css("border-color", "transparent");
                    }
                }
            );

            %ColumnName%%UID%TextDisplay.on("click", function() {
                if (%ColumnName%%UID%IsEditing) return;
                %ColumnName%%UID%IsEditing = true;
                %ColumnName%%UID%MouseDownInside = false;
                %ColumnName%%UID%OriginalValue = %ColumnName%%UID%RealInstance.option("value");
                %ColumnName%%UID%TextDisplay.hide();

                $container%ColumnName%%UID%.find(".dx-texteditor").show();

                const $input = $container%ColumnName%%UID%.find("input");
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

                showActionPopup%ColumnName%%UID%(
                    $container%ColumnName%%UID%,
                    "%ColumnName%%UID%",
                    async (fromButton) => { await saveValue%ColumnName%%UID%(fromButton); },
                    () => exitEdit%ColumnName%%UID%(true)
                );

                // Bind events sau khi mở edit mode
                setTimeout(() => {
                    $(document).on("mousedown.edit%ColumnName%%UID%", handleMouseDown%ColumnName%%UID%);
                    $(document).on("mouseup.edit%ColumnName%%UID%", handleMouseUp%ColumnName%%UID%);
                }, 100);
            });

            %ColumnName%%UID%RealInstance = $("<div>")
                .appendTo($container%ColumnName%%UID%)
                .dxTextBox({
                    value: "",
                    width: "100%",
                    inputAttr: { style: "max-height: 100%; line-height: 1.5; font-size: inherit; font-weight: inherit; padding: 1px 8px; box-sizing: border-box;" },
                    onKeyDown: function(e) {
                        if (!%ColumnName%%UID%IsEditing) return;

                        if (e.event.key === "Enter") {
                            e.event.preventDefault();
                            // Cập nhật value từ input element trước khi save
                            const $input = $container%ColumnName%%UID%.find("input");
                            const currentValue = $input.val();
                            %ColumnName%%UID%RealInstance.option("value", currentValue);
                            saveValue%ColumnName%%UID%();
                        }

                        if (e.event.key === "Tab") {
                            e.event.preventDefault();
                            // Tab cũng lưu giống Enter
                            const $input = $container%ColumnName%%UID%.find("input");
                            const currentValue = $input.val();
                            %ColumnName%%UID%RealInstance.option("value", currentValue);
                            saveValue%ColumnName%%UID%();
                        }

                        if (e.event.key === "Escape") {
                            e.event.preventDefault();
                            exitEdit%ColumnName%%UID%(true);
                        }
                    },
                    onFocusOut: function(e) {
                        // Kiểm tra các flag để tránh save trùng
                        if (_cancelingSave%ColumnName%%UID%) { 
                            _cancelingSave%ColumnName%%UID% = false; 
                            return; 
                        }
                        if (_justSaved%ColumnName%%UID%) { 
                            _justSaved%ColumnName%%UID% = false; 
                            return; 
                        }
                        if (_saving%ColumnName%%UID%) {
                            return;
                        }
                        
                        // Auto-save khi mất focus
                        if (%ColumnName%%UID%IsEditing) {
                            const $input = $container%ColumnName%%UID%.find("input");
                            if ($input.val() !== %ColumnName%%UID%OriginalValue) {
                                const currentValue = $input.val();
                                %ColumnName%%UID%RealInstance.option("value", currentValue);
                                saveValue%ColumnName%%UID%();
                            } else {
                                exitEdit%ColumnName%%UID%(false);
                            }
                        }
                    }
                })
                .dxTextBox("instance");

            $container%ColumnName%%UID%.find(".dx-texteditor").hide();

            /* =============== Public API =============== */
            Instance%ColumnName%%UID% = {
                setValue: function(val) {
                    const displayVal = (val == null || val === "") ? "" : String(val);
                    %ColumnName%%UID%OriginalValue = displayVal;
                    %ColumnName%%UID%RealInstance.option("value", displayVal);
                    updateDisplayText%ColumnName%%UID%(displayVal); // ← CẬP NHẬT TEXT VIEW MODE
                },
                getValue: function() {
                    return %ColumnName%%UID%RealInstance.option("value");
                },
                option: function(name, value) {
                    if (value !== undefined) {
                        %ColumnName%%UID%RealInstance.option(name, value);
                        if (name === "value") {
                            %ColumnName%%UID%OriginalValue = value || "";
                            %ColumnName%%UID%TextDisplay.text(value || "");
                        }
                        updateDisplayText%ColumnName%%UID%(value);
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
    -- hpaControlText - NORMAL MODE: NO AUTOSAVE (ReadOnly=0, AutoSave=0)
    -- Cho phép edit nhưng chỉ lưu text local, không gọi API (giống AutoSave=1 nhưng không lưu DB)
    -- =========================================================================
    UPDATE #temptable SET 
        loadUI = N'
            let Instance%ColumnName%%UID% = null;
            if (!$("head").find("#hpa-inherit-font-style").length) $("head").append("<style id=\"hpa-inherit-font-style\">.dx-widget{font-size:inherit!important;font-weight:inherit!important;line-height:inherit!important;border-radius:inherit!important}.dx-texteditor, .dx-texteditor-input{font-size:inherit!important;font-weight:inherit!important;line-height:inherit!important;box-sizing:border-box!important;}</style>");
            const $container%ColumnName%%UID% = $("#%UID%");

            let _autoSave%ColumnName%%UID% = false;
            let _readOnly%ColumnName%%UID% = false;

            let %ColumnName%%UID%OriginalValue = "";
            let %ColumnName%%UID%IsEditing   = false;
            let %ColumnName%%UID%TextDisplay = null;
            let %ColumnName%%UID%MouseDownInside = false;
            let _cancelingSave%ColumnName%%UID% = false;
            let _justSaved%ColumnName%%UID% = false;
            let _saving%ColumnName%%UID% = false;
            let %ColumnName%%UID%RealInstance = null;

            /* =============== Popup Save/Cancel (No API) =============== */
            let actionPopup%ColumnName%%UID%     = null;
            let currentFieldId%ColumnName%%UID%  = null;
            let saveCallback%ColumnName%%UID%    = null;
            let cancelCallback%ColumnName%%UID%  = null;

            function initActionPopup%ColumnName%%UID%() {
                if (actionPopup%ColumnName%%UID%) return;
                actionPopup%ColumnName%%UID% = $("<div>").appendTo("body").dxPopup({
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
                                    $(e.element).on("mousedown", function() {
                                        _justSaved%ColumnName%%UID% = true;
                                        _saving%ColumnName%%UID% = true;
                                    });
                                },
                                onClick: async function() {
                                    if (saveCallback%ColumnName%%UID%) {
                                        await saveCallback%ColumnName%%UID%(true);
                                    }
                                    
                                    actionPopup%ColumnName%%UID%.hide();
                                    
                                    setTimeout(function(){ 
                                        _justSaved%ColumnName%%UID% = false;
                                        _saving%ColumnName%%UID% = false;
                                    }, 300);
                                }
                            }),
                            $("<div>").dxButton({
                                icon: "close",
                                stylingMode: "outlined",
                                width: 32, height: 32,
                                elementAttr: { style: "border-radius: 4px !important;" },
                                onInitialized: function(e) {
                                    $(e.element).on("mousedown", function() {
                                        _cancelingSave%ColumnName%%UID% = true;
                                    });
                                },
                                onClick: function() {
                                    if (cancelCallback%ColumnName%%UID%) {
                                        cancelCallback%ColumnName%%UID%();
                                    }
                                    
                                    actionPopup%ColumnName%%UID%.hide();
                                    
                                    setTimeout(function(){ 
                                        _cancelingSave%ColumnName%%UID% = false; 
                                    }, 300);
                                }
                            })
                        );
                    },
                    onHiding: function() {
                        currentFieldId%ColumnName%%UID% = saveCallback%ColumnName%%UID% = cancelCallback%ColumnName%%UID% = null;
                    }
                }).dxPopup("instance");
            }

            function showActionPopup%ColumnName%%UID%(inputElement, fieldId, onSave, onCancel) {
                if (!actionPopup%ColumnName%%UID%) initActionPopup%ColumnName%%UID%();

                if (currentFieldId%ColumnName%%UID% && currentFieldId%ColumnName%%UID% !== fieldId && cancelCallback%ColumnName%%UID%) {
                    cancelCallback%ColumnName%%UID%();
                }

                currentFieldId%ColumnName%%UID% = fieldId;
                saveCallback%ColumnName%%UID%   = onSave;
                cancelCallback%ColumnName%%UID% = onCancel;

                const updatePos = () => {
                    if (!actionPopup%ColumnName%%UID%?.option("visible")) return;
                    const $input = $(inputElement).find("input");
                    if ($input.length === 0) return;
                    actionPopup%ColumnName%%UID%.option({
                        position: {
                            my: "top right",
                            at: "bottom right",
                            of: $input,
                            offset: "0 4"
                        }
                    });
                    actionPopup%ColumnName%%UID%.repaint();
                };

                actionPopup%ColumnName%%UID%.show();
                setTimeout(updatePos, 10);

                $(window).off("scroll.ap" + fieldId).on("scroll.ap" + fieldId, updatePos);
                $(window).off("resize.ap" + fieldId).on("resize.ap" + fieldId, updatePos);
                $(".dx-scrollable").off("scroll.ap" + fieldId).on("scroll.ap" + fieldId, updatePos);

                const intervalId = setInterval(() => {
                    if (actionPopup%ColumnName%%UID%?.option("visible")) updatePos();
                    else clearInterval(intervalId);
                }, 100);

                actionPopup%ColumnName%%UID%.option("onHiding", function() {
                    clearInterval(intervalId);
                    $(window).off("scroll.ap" + fieldId);
                    $(window).off("resize.ap" + fieldId);
                    $(".dx-scrollable").off("scroll.ap" + fieldId);
                    currentFieldId%ColumnName%%UID% = saveCallback%ColumnName%%UID% = cancelCallback%ColumnName%%UID% = null;
                });
            }

            /* =============== Inline Edit logic (Local Only) =============== */
            function exitEdit%ColumnName%%UID%(cancel = false) {
                if (!%ColumnName%%UID%IsEditing) return;
                %ColumnName%%UID%IsEditing = false;
                %ColumnName%%UID%MouseDownInside = false;
                $(document).off("mousedown.edit%ColumnName%%UID%");
                $(document).off("mouseup.edit%ColumnName%%UID%");

                if (cancel) {
                    %ColumnName%%UID%RealInstance.option("value", %ColumnName%%UID%OriginalValue);
                } else {
                    // Chỉ lưu giá trị mới vào biến, không gọi API
                    %ColumnName%%UID%OriginalValue = %ColumnName%%UID%RealInstance.option("value");
                }

                if (actionPopup%ColumnName%%UID% && actionPopup%ColumnName%%UID%.option("visible")) {
                    actionPopup%ColumnName%%UID%.option("visible", false);
                }

                $container%ColumnName%%UID%.find(".dx-texteditor").hide();
                %ColumnName%%UID%TextDisplay.text(%ColumnName%%UID%OriginalValue || "").show();
            }

            async function saveValue%ColumnName%%UID%(fromButton = false) {
                if (_cancelingSave%ColumnName%%UID%) { 
                    _cancelingSave%ColumnName%%UID% = false; 
                    exitEdit%ColumnName%%UID%(true); 
                    return; 
                }
                
                if (!fromButton && _saving%ColumnName%%UID%) {
                    return;
                }
                
                const newVal = %ColumnName%%UID%RealInstance.option("value");
                
                if (newVal === %ColumnName%%UID%OriginalValue) {
                    exitEdit%ColumnName%%UID%();
                    _saving%ColumnName%%UID% = false;
                    _justSaved%ColumnName%%UID% = false;
                    return;
                }

                try {
                    if (!fromButton) {
                        _saving%ColumnName%%UID% = true;
                    }
                    
                    // Feature: Check Instance AutoSave Flag
                    if (_autoSave%ColumnName%%UID%) {
                        const dataJSON = JSON.stringify(["%tableId%", ["%ColumnName%"], [newVal]]);

                        let currentRecordIDValue = [
                            currentRecordID_%ColumnIDName%
                        ];

                        let currentRecordID = [
                            "%ColumnIDName%"
                        ];

                        // Xử lý multiple IDs nếu ColumnIDName chứa dấu phẩy
                        if ("%ColumnIDName%".includes(",")) {
                            const ids = "%ColumnIDName%".split(",").map(id => id.trim());
                            ids.forEach(id => {
                                let idVal = window["currentRecordID_" + id];
                                currentRecordIDValue.push(idVal);
                            });
                            currentRecordID = "%ColumnIDName%".split(",").map(id => id.trim());
                        }

                        const idValsJSON = JSON.stringify([currentRecordIDValue, currentRecordID]);
                        const json = await saveFunction(dataJSON, idValsJSON);

                        const dtError = json.data[json.data.length - 1] || [];
                        if (dtError.length > 0 && dtError[0].Status === "ERROR") {
                            if ("%IsAlert%" === "1") {
                                uiManager.showAlert({ type: "error", message: dtError[0]?.Message || "Lưu thất bại" });
                            }
                            _saving%ColumnName%%UID% = false;
                            _justSaved%ColumnName%%UID% = false;
                            
                            // Revert value if needed or keep it for retry?
                            // For now, let"s keep UI as is but not exit edit?
                            // Or exit edit and revert? Standard behavior seems to be stop and alert.
                            return;
                        }

                        if ("%IsAlert%" === "1") {
                            uiManager.showAlert({ type: "success", message: "Lưu thành công" });
                        }
                    }
                    
                    // Cập nhật giá trị local (luôn thực hiện để sync UI)
                    %ColumnName%%UID%OriginalValue = newVal;
                    
                    exitEdit%ColumnName%%UID%();

                    // Sync grid cell nếu được gọi từ grid
                    if (typeof cellInfo !== "undefined" && cellInfo && cellInfo.component) {
                        try {
                            const grid = cellInfo.component;
                            grid.cellValue(cellInfo.rowIndex, "%ColumnName%%UID%", newVal);
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
                        _justSaved%ColumnName%%UID% = false;
                    }, 100);
                }
            }

            /* =============== Handle Click Outside =============== */
            function handleMouseDown%ColumnName%%UID%(e) {
                if (!%ColumnName%%UID%IsEditing) return;
                
                if (_saving%ColumnName%%UID% || _cancelingSave%ColumnName%%UID%) return;

                const $t = $(e.target);
                const isInsideControl = $t.closest($container%ColumnName%%UID%).length > 0;
                const isInsidePopup = $t.closest(".dx-popup-wrapper").length > 0;

                if (isInsideControl || isInsidePopup) {
                    %ColumnName%%UID%MouseDownInside = true;
                } else {
                    %ColumnName%%UID%MouseDownInside = false;
                }
            }

            function handleMouseUp%ColumnName%%UID%(e) {
                if (!%ColumnName%%UID%IsEditing) return;

                if (_saving%ColumnName%%UID% || _cancelingSave%ColumnName%%UID% || _justSaved%ColumnName%%UID%) {
                    %ColumnName%%UID%MouseDownInside = false;
                    return;
                }

                const $t = $(e.target);
                const isInsideControl = $t.closest($container%ColumnName%%UID%).length > 0;
                const isInsidePopup = $t.closest(".dx-popup-wrapper").length > 0;

                if (!%ColumnName%%UID%MouseDownInside && !isInsideControl && !isInsidePopup) {
                    saveValue%ColumnName%%UID%();
                }

                %ColumnName%%UID%MouseDownInside = false;
            }

            function updateDisplayText%ColumnName%%UID%(val) {
                const displayVal = val || "";
                if (displayVal === "") {
                    %ColumnName%%UID%TextDisplay.html(`<i style="color: #999;">Nhập dữ liệu</i>`);
                } else {
                    %ColumnName%%UID%TextDisplay.text(displayVal);
                }
            }

            /* =============== Create UI =============== */
            %ColumnName%%UID%TextDisplay = $("<div>").css({
                "padding": "1px 8px",
                "cursor": "text",
                "min-height": "20px",
                "line-height": "1.5",
                "word-break": "break-word",
                "border": "1px solid transparent",
                "border-radius": "inherit !important",
                "transition": "border-color 0.2s"
            }).appendTo($container%ColumnName%%UID%);

            updateDisplayText%ColumnName%%UID%("");

            %ColumnName%%UID%TextDisplay.hover(
                function() {
                    if (!%ColumnName%%UID%IsEditing) {
                        $(this).css("border-color", "#ddd");
                    }
                },
                function() {
                    if (!%ColumnName%%UID%IsEditing) {
                        $(this).css("border-color", "transparent");
                    }
                }
            );

            %ColumnName%%UID%TextDisplay.on("click", function() {
                // Feature: Check Instance ReadOnly Flag
                if (_readOnly%ColumnName%%UID%) return;

                if (%ColumnName%%UID%IsEditing) return;
                %ColumnName%%UID%IsEditing = true;
                %ColumnName%%UID%MouseDownInside = false;
                %ColumnName%%UID%OriginalValue = %ColumnName%%UID%RealInstance.option("value");
                %ColumnName%%UID%TextDisplay.hide();

                $container%ColumnName%%UID%.find(".dx-texteditor").show();

                const $input = $container%ColumnName%%UID%.find("input");
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

                showActionPopup%ColumnName%%UID%(
                    $container%ColumnName%%UID%,
                    "%ColumnName%%UID%",
                    async (fromButton) => { await saveValue%ColumnName%%UID%(fromButton); },
                    () => exitEdit%ColumnName%%UID%(true)
                );

                setTimeout(() => {
                    $(document).on("mousedown.edit%ColumnName%%UID%", handleMouseDown%ColumnName%%UID%);
                    $(document).on("mouseup.edit%ColumnName%%UID%", handleMouseUp%ColumnName%%UID%);
                }, 100);
            });

            %ColumnName%%UID%RealInstance = $("<div>")
                .appendTo($container%ColumnName%%UID%)
                .dxTextBox({
                    value: "",
                    width: "100%",
                    inputAttr: { style: "max-height: 100%; line-height: 1.5; font-size: inherit; font-weight: inherit; padding: 1px 8px; box-sizing: border-box;" },
                    onKeyDown: function(e) {
                        if (!%ColumnName%%UID%IsEditing) return;

                        if (e.event.key === "Enter") {
                            e.event.preventDefault();
                            const $input = $container%ColumnName%%UID%.find("input");
                            const currentValue = $input.val();
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
                            exitEdit%ColumnName%%UID%(true);
                        }
                    },
                    onFocusOut: function(e) {
                        if (_cancelingSave%ColumnName%%UID%) { 
                            _cancelingSave%ColumnName%%UID% = false; 
                            return; 
                        }
                        if (_justSaved%ColumnName%%UID%) { 
                            _justSaved%ColumnName%%UID% = false; 
                            return; 
                        }
                        if (_saving%ColumnName%%UID%) {
                            return;
                        }
                        
                        if (%ColumnName%%UID%IsEditing) {
                            const $input = $container%ColumnName%%UID%.find("input");
                            if ($input.val() !== %ColumnName%%UID%OriginalValue) {
                                const currentValue = $input.val();
                                %ColumnName%%UID%RealInstance.option("value", currentValue);
                                saveValue%ColumnName%%UID%();
                            } else {
                                exitEdit%ColumnName%%UID%(false);
                            }
                        }
                    }
                })
                .dxTextBox("instance");

            $container%ColumnName%%UID%.find(".dx-texteditor").hide();

            /* =============== Public API =============== */
            Instance%ColumnName%%UID% = {
                setValue: function(val) {
                    const displayVal = (val == null || val === "") ? "" : String(val);
                    %ColumnName%%UID%OriginalValue = displayVal;
                    %ColumnName%%UID%RealInstance.option("value", displayVal);
                    updateDisplayText%ColumnName%%UID%(displayVal); // ← CẬP NHẬT TEXT VIEW MODE
                },
                getValue: function() {
                    return %ColumnName%%UID%RealInstance.option("value");
                },
                option: function(name, value) {
                    if (value !== undefined) {
                        %ColumnName%%UID%RealInstance.option(name, value);
                        if (name === "value") {
                            %ColumnName%%UID%OriginalValue = value || "";
                            %ColumnName%%UID%TextDisplay.text(value || "");
                        }
                        updateDisplayText%ColumnName%%UID%(value);
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
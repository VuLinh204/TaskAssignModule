// ==================== GLOBAL ACTION POPUP ====================
let actionPopup = null;
let currentField = null;
let currentFieldId = null;
let saveCallback = null;
let cancelCallback = null;

function initActionPopup() {
    actionPopup = $(`<div id="actionPopup">`).appendTo("body").dxPopup({
        width: "auto",
        height: "auto",
        showTitle: false,
        visible: false,
        dragEnabled: false,
        hideOnOutsideClick: false,
        showCloseButton: false,
        shading: false,
        position: {
            at: "bottom right",
            my: "top right",
            collision: "fit flip",
            offset: "0 4"
        },
        contentTemplate: function() {
            return $(`<div class="d-flex" style="gap: .5rem; padding: 8px 12px;">`).append(
                $("<div>").dxButton({
                    icon: "check",
                    hint: "Lưu",
                    stylingMode: "contained",
                    type: "success",
                    width: 28,
                    height: 28,
                    elementAttr: {
                        style: "border-radius: 6px !important;"
                    },
                    onClick: async function() {
                        if (saveCallback) {
                            await saveCallback();
                        }
                        actionPopup.hide();
                    }
                }),
                $("<div>").dxButton({
                    icon: "close",
                    hint: "Hủy",
                    stylingMode: "outlined",
                    type: "normal",
                    width: 28,
                    height: 28,
                    elementAttr: {
                        style: "border-radius: 6px !important;"
                    },
                    onClick: function() {
                        if (cancelCallback) {
                            cancelCallback();
                        }
                        actionPopup.hide();
                    }
                })
            );
        },
        onHiding: function() {
            currentField = null;
            currentFieldId = null;
            saveCallback = null;
            cancelCallback = null;
        }
    }).dxPopup("instance");
}

function showActionPopup(targetElement, fieldId, onSave, onCancel) {
    if (!actionPopup) {
        initActionPopup();
    }
    
    if (currentFieldId && currentFieldId !== fieldId) {
        if (cancelCallback) {
            cancelCallback();
        }
    }
    
    saveCallback = onSave;
    cancelCallback = onCancel;
    currentField = targetElement;
    currentFieldId = fieldId;
    
    actionPopup.option("position.of", targetElement);
    actionPopup.show();
}

function hideActionPopup() {
    if (actionPopup && actionPopup.option("visible")) {
        actionPopup.hide();
    }
}

// ==================== TEXTBOX TEMPLATE ====================
let %ColumnName%Instance = null;
let %ColumnName%OriginalValue = "";
let %ColumnName%IsEditing = false;

function loadUITextBox%ColumnName%() {
    const $container = $("#%ColumnName%");
    const fieldId = "%ColumnName%";
    const readOnly = %ReadOnly%; // true hoặc false
    
    %ColumnName%OriginalValue = "";

    // ========== READONLY MODE ==========
    if (readOnly) {
        %ColumnName%Instance = $("<div>").appendTo($container).dxTextBox({
            value: %ColumnName%OriginalValue,
            width: "100%",
            readOnly: true,
            inputAttr: {
                class: "form-control form-control-sm",
                style: "font-size: 14px; max-height: 100%;"
            }
        }).dxTextBox("instance");
        return;
    }

    // ========== EDITABLE MODE ==========
    %ColumnName%Instance = $("<div>").appendTo($container).dxTextBox({
        value: %ColumnName%OriginalValue,
        width: "100%",
        inputAttr: {
            class: "form-control form-control-sm",
            style: "font-size: 14px; max-height: 100%;"
        },
        onFocusIn: function(e) {
            if (%ColumnName%IsEditing) return;
            %ColumnName%IsEditing = true;
            %ColumnName%OriginalValue = %ColumnName%Instance.option("value");

            // Thay đổi border khi focus
            $(e.element).find("input").css("border", "1px solid #1c975e");

            showActionPopup(
                $container,
                fieldId,
                async () => {
                    await save%ColumnName%Value();
                    exit%ColumnName%EditMode();
                },
                () => {
                    exit%ColumnName%EditMode(true);
                }
            );

            setTimeout(() => {
                $(document).on("click.editmode" + fieldId, function(e) {
                    const $target = $(e.target);
                    if (!$target.closest($container).length && 
                        !$target.closest(".dx-popup-wrapper").length &&
                        !$target.closest(".dx-texteditor").length) {
                        exit%ColumnName%EditMode(true);
                        hideActionPopup();
                    }
                });
            }, 100);
        },
        onFocusOut: function(e) {
            // Reset border khi blur
            $(e.element).find("input").css("border", "");
        },
        onKeyDown: function(e) {
            if (!%ColumnName%IsEditing) return;
            
            if (e.event.key === "Enter") {
                e.event.preventDefault();
                save%ColumnName%Value().then(() => {
                    exit%ColumnName%EditMode();
                    hideActionPopup();
                });
            } else if (e.event.key === "Escape") {
                e.event.preventDefault();
                exit%ColumnName%EditMode(true);
                hideActionPopup();
            }
        }
    }).dxTextBox("instance");

    function exit%ColumnName%EditMode(cancel = false) {
        if (!%ColumnName%IsEditing) return;
        %ColumnName%IsEditing = false;

        $(document).off("click.editmode" + fieldId);

        if (cancel) {
            %ColumnName%Instance.option("value", %ColumnName%OriginalValue);
        } else {
            %ColumnName%OriginalValue = %ColumnName%Instance.option("value");
        }
    }

    async function save%ColumnName%Value() {
        const newValue = %ColumnName%Instance.option("value");

        if (newValue === %ColumnName%OriginalValue) {
            return;
        }

        try {
            const dataJSON = JSON.stringify([%TableID%, ["%ColumnName%"], [newValue]]);
            const idValues = %IDValues%;
            
            console.log("Saving %ColumnName% with IDValues:", idValues);
            console.log("Saving %ColumnName% with dataJSON:", dataJSON);
            
            const json = await saveFunction(dataJSON, idValues);
            const dtError = json.data && json.data[json.data.length - 1];

            %ColumnName%OriginalValue = newValue;

            uiManager.showAlert({
                type: "success",
                message: "Lưu thành công"
            });

            // Callback (optional)
            if (typeof window.on%ColumnName%Saved === "function") {
                window.on%ColumnName%Saved(newValue, json);
            }
        } catch (err) {
            console.error("Save error:", err);
            uiManager.showAlert({
                type: "error",
                message: "Có lỗi xảy ra khi lưu"
            });
        }
    }
}
USE Paradise_Beta_Tai2
GO
if object_id('[dbo].[sp_Task_MyWork_html]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_Task_MyWork_html] as select 1')
GO

ALTER PROCEDURE [dbo].[sp_Task_MyWork_html]
    @LoginID    INT = 3,
    @LanguageID VARCHAR(2) = 'VN',
    @isWeb      INT = 1
AS
BEGIN
SET NOCOUNT ON;
DECLARE @html NVARCHAR(MAX);
SET @html = N'
    <div class="container-fluid p-3">
        <div class="row mb-3">
            <div class="col-md-6" style="position: relative;">
                <label class="form-label">Mã nhân viên</label>
                <div class="field-container" data-field="EmployeeID1"></div>
            </div>
            <div class="col-md-6" style="position: relative;">
                <label class="form-label">Họ và tên</label>
                <div class="field-container" data-field="FullName1"></div>
            </div>
        </div>
        <div class="row mb-3">
            <div class="col-md-6" style="position: relative;">
                <label class="form-label">Mã nhân viên</label>
                <div class="field-container" data-field="EmployeeID2"></div>
            </div>
            <div class="col-md-6" style="position: relative;">
                <label class="form-label">Họ và tên</label>
                <div class="field-container" data-field="FullName2"></div>
            </div>
        </div>
    </div>
    <script>
        async function saveFunction(dataJSON, IDValues) {
            let data = await AjaxHPAParadiseAsync({
                data: {
                    name: "sp_Common_SaveDataTable",
                    param: [
                        "LanguageID", window.LanguageID,
                        "DataJSON", dataJSON,
                        "IDValues", IDValues
                    ],
                },
            });
            return typeof data === "string" ? JSON.parse(data) : data;
        }
    </script>

    <script>
        (() => {
            let actionPopup = null;
            let currentFieldId = null;
            let saveCallback = null;
            let cancelCallback = null;
            let fieldInstances = {};
            let fieldOriginalValues = {};
            let fieldEditingState = {};
            let employeeIdKey = null;
            
            const fieldsConfig = [
                { name: "EmployeeID1", readOnly: true, editable: false },
                { name: "FullName1", readOnly: false, editable: true },
                { name: "EmployeeID2", readOnly: true, editable: false },
                { name: "FullName2", readOnly: false, editable: true }
            ];
            
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
                currentFieldId = fieldId;
                
                actionPopup.option("position.of", targetElement);
                actionPopup.show();
            }

            function hideActionPopup() {
                if (actionPopup && actionPopup.option("visible")) {
                    actionPopup.hide();
                }
            }

            function initField(fieldName, readOnly) {
                const $container = $(`[data-field="${fieldName}"]`);
                if ($container.length === 0) return;

                fieldOriginalValues[fieldName] = "";
                fieldEditingState[fieldName] = false;

                const instance = $("<div>").appendTo($container).dxTextBox({
                    value: fieldOriginalValues[fieldName],
                    width: "100%",
                    readOnly: readOnly,
                    inputAttr: {
                        class: "form-control form-control-sm",
                        style: "font-size: 14px; max-height: 100%;"
                    },
                    onFocusIn: !readOnly ? function(e) {
                        if (fieldEditingState[fieldName]) return;
                        fieldEditingState[fieldName] = true;
                        fieldOriginalValues[fieldName] = instance.option("value");

                        $(e.element).find("input").css("border", "1px solid #1c975e");

                        showActionPopup(
                            $container,
                            fieldName,
                            async () => {
                                await saveFieldValue(fieldName);
                                exitEditMode(fieldName);
                            },
                            () => {
                                exitEditMode(fieldName, true);
                            }
                        );

                        setTimeout(() => {
                            $(document).on("click.editmode" + fieldName, function(e) {
                                const $target = $(e.target);
                                if (!$target.closest($container).length && 
                                    !$target.closest(".dx-popup-wrapper").length &&
                                    !$target.closest(".dx-texteditor").length) {
                                    exitEditMode(fieldName, true);
                                    hideActionPopup();
                                }
                            });
                        }, 100);
                    } : undefined,
                    onFocusOut: !readOnly ? function(e) {
                        $(e.element).find("input").css("border", "");
                    } : undefined,
                    onKeyDown: !readOnly ? function(e) {
                        if (!fieldEditingState[fieldName]) return;
                        
                        if (e.event.key === "Enter") {
                            e.event.preventDefault();
                            saveFieldValue(fieldName).then(() => {
                                exitEditMode(fieldName);
                                hideActionPopup();
                            });
                        } else if (e.event.key === "Escape") {
                            e.event.preventDefault();
                            exitEditMode(fieldName, true);
                            hideActionPopup();
                        }
                    } : undefined
                }).dxTextBox("instance");

                fieldInstances[fieldName] = instance;

                function exitEditMode(name, cancel = false) {
                    if (!fieldEditingState[name]) return;
                    fieldEditingState[name] = false;

                    $(document).off("click.editmode" + name);

                    if (cancel) {
                        instance.option("value", fieldOriginalValues[name]);
                    } else {
                        fieldOriginalValues[name] = instance.option("value");
                    }
                }

                async function saveFieldValue(name) {
                    const newValue = instance.option("value");

                    if (newValue === fieldOriginalValues[name]) {
                        return;
                    }

                    try {
                        const baseFieldName = name.replace(/\d+$/, "");
                        const dataJSON = JSON.stringify([-99218308, [baseFieldName], [newValue]]);
                        
                        let idValues = [[employeeIdKey], "EmployeeID"];
                        console.log("Saving " + name + " with IDValues:", idValues);
                        console.log("Saving " + name + " with dataJSON:", dataJSON);
                        
                        const json = await saveFunction(dataJSON, idValues);

                        fieldOriginalValues[name] = newValue;

                        uiManager.showAlert({
                            type: "success",
                            message: "Lưu thành công"
                        });
                    } catch (err) {
                        console.error("Save error:", err);
                        uiManager.showAlert({
                            type: "error",
                            message: "Có lỗi xảy ra khi lưu"
                        });
                    }
                }
                
                return {
                    setValue: function(val) {
                        fieldOriginalValues[fieldName] = val;
                        if (instance) {
                            instance.option("value", val);
                        }
                    },
                    getValue: function() {
                        return instance ? instance.option("value") : fieldOriginalValues[fieldName];
                    }
                };
            }

            function loadUI() {
                fieldsConfig.forEach(function(field) {
                    initField(field.name, field.readOnly);
                });
            }

            function loadData() {
                AjaxHPAParadise({
                    data: {
                        name: "sp_Task_GetAllTasks",
                        param: []
                    },
                    success: function (res) {
                        const json = typeof res === "string" ? JSON.parse(res) : res;
                        const results = (json.data && json.data[0]) || [];
                        const obj = results[0];
                        const obj2 = results[1];
                        
                        employeeIdKey = obj.EmployeeID;
                        
                        // Set giá trị cho row 1
                        if (fieldInstances["EmployeeID1"]) {
                            fieldOriginalValues["EmployeeID1"] = obj.EmployeeID;
                            fieldInstances["EmployeeID1"].option("value", obj.EmployeeID);
                        }
                        if (fieldInstances["FullName1"]) {
                            fieldOriginalValues["FullName1"] = obj.FullName;
                            fieldInstances["FullName1"].option("value", obj.FullName);
                        }
                        
                        // Set giá trị cho row 2 (giống row 1)
                        if (fieldInstances["EmployeeID2"]) {
                            fieldOriginalValues["EmployeeID2"] = obj2.EmployeeID;
                            fieldInstances["EmployeeID2"].option("value", obj2.EmployeeID);
                        }
                        if (fieldInstances["FullName2"]) {
                            fieldOriginalValues["FullName2"] = obj2.FullName;
                            fieldInstances["FullName2"].option("value", obj2.FullName);
                        }
                    }
                });
            }

            $(document).ready(function() {
                loadUI();
                loadData();
            });
        })();
    </script>
';
    SELECT @html AS html;
END
GO

EXEC sp_GenerateHTMLScript 'sp_Task_MyWork_html'
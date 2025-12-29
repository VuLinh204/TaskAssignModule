USE Paradise_Beta_Tai2
GO
if object_id('[dbo].[sptblCommonControlType_Signed_Linh]') is null
 EXEC ('CREATE PROCEDURE [dbo].[sptblCommonControlType_Signed_Linh] as select 1')
GO
ALTER PROCEDURE [dbo].[sptblCommonControlType_Signed_Linh]
    @TableName VARCHAR(256) = ''
AS
BEGIN
    -- =====================================================================
    -- BƯỚC 1: TẠO BẢNG TẠM VÀ LOAD DỮ LIỆU CƠ BẢN
    -- =====================================================================
    IF OBJECT_ID('tempdb..#temptable') IS NOT NULL DROP TABLE #temptable

    SELECT t.*,
        CAST('' AS NVARCHAR(MAX)) html,
        CAST('' AS NVARCHAR(MAX)) loadUI,
        CAST('' AS NVARCHAR(MAX)) loadData,
        CAST(ISNULL(c.name, t.ColumnName) AS NVARCHAR(64)) columnId
    INTO #temptable
    FROM dbo.tblCommonControlType_Signed t
    LEFT JOIN sys.columns c ON c.name = t.[ColumnName] AND c.object_id = OBJECT_ID(t.TableEditor)
    WHERE TableName = @TableName

    DECLARE @object_Id VARCHAR(MAX) = CAST(OBJECT_ID(@TableName) AS NVARCHAR(64))

    -- =====================================================================
    -- BƯỚC 2: CẬP NHẬT TEMPLATE CHO TỪNG LOẠI CONTROL
    -- =====================================================================

    -- ---------------------------------------------------------------------
    -- 2.1. hpaControlText - Normal (popup lưu/hủy)
    -- ---------------------------------------------------------------------
    UPDATE #temptable SET loadUI = N'
        if ($("#%IDDiv%").length === 0) {
            $("<div>", { id: "%IDDiv%" }).appendTo("body");
        }

        let actionPopup%columnName% = null;
        let currentField%columnName% = null;
        let currentFieldId%columnName% = null;
        let saveCallback%columnName% = null;
        let cancelCallback%columnName% = null;

        function initActionPopup() {
            actionPopup%columnName% = $(`<div id="actionPopup%columnName%">`).appendTo("body").dxPopup({
                width: "auto", height: "auto", showTitle: false, visible: false,
                dragEnabled: false, hideOnOutsideClick: false, showCloseButton: false, shading: false,
                position: { at: "bottom right", my: "top right", collision: "fit flip", offset: "0 4" },
                contentTemplate: function() {
                    return $(`<div class="d-flex" style="gap: .5rem; padding: 8px 12px;">`).append(
                        $("<div>").dxButton({ icon: "check", hint: "Lưu", stylingMode: "contained", type: "success", width: 28, height: 28,
                            elementAttr: { style: "border-radius: 6px !important;" },
                            onClick: async function() { if (saveCallback%columnName%) await saveCallback%columnName%(); actionPopup%columnName%.hide(); }
                        }),
                        $("<div>").dxButton({ icon: "close", hint: "Hủy", stylingMode: "outlined", type: "normal", width: 28, height: 28,
                            elementAttr: { style: "border-radius: 6px !important;" },
                            onClick: function() { if (cancelCallback%columnName%) cancelCallback%columnName%(); actionPopup%columnName%.hide(); }
                        })
                    );
                },
                onHiding: function() { currentField%columnName% = currentFieldId%columnName% = saveCallback%columnName% = cancelCallback%columnName% = null; }
            }).dxPopup("instance");
        }

        function showActionPopup(target, fieldId, onSave, onCancel) {
            if (!actionPopup%columnName%) initActionPopup();
            if (currentFieldId%columnName% && currentFieldId%columnName% !== fieldId && cancelCallback%columnName%) cancelCallback%columnName%();
            saveCallback%columnName% = onSave; cancelCallback%columnName% = onCancel; currentField%columnName% = target; currentFieldId%columnName% = fieldId;
            actionPopup%columnName%.option("position.of", target); actionPopup%columnName%.show();
        }

        let %columnName%Instance, %columnName%OriginalValue, %columnName%IsEditing = false;



        function loadUI%columnName%() {
            const $container = $("#%IDDiv%");
            const fieldId = "%columnName%";

            /*BEGIN_DX*/
            %columnName%Instance = $("<div>").appendTo($container).dxTextBox({
                value: %columnName%OriginalValue || "",
                width: "100%",
                inputAttr: { class: "form-control form-control-sm", style: "font-size: 14px; max-height: 100%;" },
                onFocusIn: function(e) {
                    if (%columnName%IsEditing) return;
                    %columnName%IsEditing = true;
                    %columnName%OriginalValue = %columnName%Instance.option("value");
                    $(e.element).find("input").css("border", "1px solid #1c975e");
                    showActionPopup($container, fieldId,
                        async () => { await saveValue%columnName%(); exitEdit%columnName%(); },
                        () => exitEdit%columnName%(true)
                    );
                    setTimeout(() => {
                        $(document).on("click.editmode" + fieldId, function(ev) {
                            const $t = $(ev.target);
                            if (!$t.closest($container).length && !$t.closest(".dx-popup-wrapper").length && !$t.closest(".dx-texteditor").length) {
                                exitEdit%columnName%(true);
                            }
                        });
                    }, 100);
                },
                onFocusOut: function(e) { $(e.element).find("input").css("border", ""); },
                onKeyDown: function(e) {
                    if (!%columnName%IsEditing) return;
                    if (e.event.key === "Enter") { e.event.preventDefault(); saveValue%columnName%().then(() => exitEdit%columnName%()); }
                    if (e.event.key === "Escape") { e.event.preventDefault(); exitEdit%columnName%(true); }
                }
            }).dxTextBox("instance");
            /*END_DX*/

            function exitEdit%columnName%(cancel = false) {
                if (!%columnName%IsEditing) return;
                %columnName%IsEditing = false;
                $(document).off("click.editmode" + fieldId);
                if (cancel) %columnName%Instance.option("value", %columnName%OriginalValue);
                else %columnName%OriginalValue = %columnName%Instance.option("value");
            }

            async function saveValue%columnName%() {
                const newVal = %columnName%Instance.option("value");
                if (newVal === %columnName%OriginalValue) return;
                try {
                    await saveFunction(JSON.stringify([-99218308, ["%columnName%"], [newVal]]), [[%columnName%Key.%columnId%], "%columnId%"]);
                    %columnName%OriginalValue = newVal;
                    uiManager.showAlert({ type: "success", message: "Lưu thành công" });
                } catch (err) {
                    uiManager.showAlert({ type: "error", message: "Có lỗi xảy ra khi lưu" });
                }
            }

            return {
                setValue: val => { %columnName%OriginalValue = val; if (%columnName%Instance) %columnName%Instance.option("value", val); },
                getValue: () => %columnName%Instance ? %columnName%Instance.option("value") : %columnName%OriginalValue
            };
        }
    ' WHERE [Type] = 'hpaControlText' AND [AutoSave] = 0 AND [ReadOnly] = 0

    -- ---------------------------------------------------------------------
    -- 2.2. hpaControlText - ReadOnly
    -- ---------------------------------------------------------------------
    UPDATE #temptable SET loadUI = N'
        if ($("#%IDDiv%").length === 0) {
            $("<div>", { id: "%IDDiv%" }).appendTo("body");
        }
        let %columnName%Instance;
        let %columnName%OriginalValue = "";

        function loadUI%columnName%() {
            const $container = $("#%IDDiv%");
            /*BEGIN_DX*/
            %columnName%Instance = $("<div>").appendTo($container).dxTextBox({
                value: %columnName%OriginalValue,
                width: "100%",
                readOnly: true,
                inputAttr: { class: "form-control form-control-sm", style: "font-size: 14px; max-height: 100%;" }
            }).dxTextBox("instance");
            /*END_DX*/
            return {
                setValue: val => { %columnName%OriginalValue = val; if (%columnName%Instance) %columnName%Instance.option("value", val); },
                getValue: () => %columnName%Instance ? %columnName%Instance.option("value") : %columnName%OriginalValue
            };
        }
    ' WHERE [Type] = 'hpaControlText' AND [ReadOnly] = 1

    -- ---------------------------------------------------------------------
    -- 2.3. hpaControlText - AutoSave
    -- ---------------------------------------------------------------------
    UPDATE #temptable SET loadUI = N'
        if ($("#%IDDiv%").length === 0) {
            $("<div>", { id: "%IDDiv%" }).appendTo("body");
        }
        let %columnName%Instance;
        let %columnName%OriginalValue = "";
        let %columnName%TimeOut;

        function loadUI%columnName%() {
            const $container = $("#%IDDiv%");

            async function saveValue%columnName%() {
                const newVal = %columnName%Instance.option("value");
                if (newVal === %columnName%OriginalValue) return;
                try {
                    await saveFunction(JSON.stringify([-99218308, ["%columnName%"], [newVal]]), [[%columnName%Key.%columnId%], "%columnId%"]);
                    %columnName%OriginalValue = newVal;
                    uiManager.showAlert({ type: "success", message: "Lưu thành công" });
                } catch (err) {
                    %columnName%Instance.option("value", %columnName%OriginalValue);
                    uiManager.showAlert({ type: "error", message: "Có lỗi xảy ra khi lưu" });
                }
            }

            /*BEGIN_DX*/
            %columnName%Instance = $("<div>").appendTo($container).dxTextBox({
                value: %columnName%OriginalValue,
                width: "100%",
                inputAttr: { class: "form-control form-control-sm", style: "font-size: 14px; max-height: 100%;" },
                onValueChanged: e => { clearTimeout(%columnName%TimeOut); saveValue%columnName%(); },
                onKeyUp: e => { clearTimeout(%columnName%TimeOut); %columnName%TimeOut = setTimeout(saveValue%columnName%, 100); }
            }).dxTextBox("instance");
            /*END_DX*/

            return {
                setValue: val => { %columnName%OriginalValue = val; if (%columnName%Instance) %columnName%Instance.option("value", val); },
                getValue: () => %columnName%Instance ? %columnName%Instance.option("value") : %columnName%OriginalValue
            };
        }
    ' WHERE [Type] = 'hpaControlText' AND [AutoSave] = 1 AND [ReadOnly] = 0

    -- ---------------------------------------------------------------------
    -- 2.4. hpaControlText - LoadData
    -- ---------------------------------------------------------------------
    UPDATE #temptable SET loadData = N'
        %columnName%Control = loadUI%columnName%();
        %columnName%Control.setValue(obj.%columnName%);
        %columnName%Key = { %columnId%: obj.%columnId% }'
    WHERE [Type] = 'hpaControlText'

    -- ---------------------------------------------------------------------
    -- 2.5. hpaControlSelectBox - Normal (editable)
    -- ---------------------------------------------------------------------
    UPDATE #temptable SET loadUI = N'
        if ($("#%IDDiv%").length === 0) {
            $("<div>", { id: "%IDDiv%" }).appendTo("body");
        }

        let %columnName%Instance
        let %columnName%OriginalValue = null

  function loadUI%columnName%() {
            const $container = $("#%IDDiv%");

            const customStore = new DevExpress.data.CustomStore({
                key: "%columnName%",
                byKey: function(key) {
                    const item = DataSource.find(i => i.ID === key);
                    return $.Deferred().resolve(item || null).promise();
                },
                load: function(loadOptions) {
                    const searchValue = loadOptions.searchValue || "";
                    let filteredData = DataSource;

                    if (searchValue) {
                        const searchLower = searchValue.toLowerCase();
                        filteredData = DataSource.filter(item =>
                            (item.Name && item.Name.toLowerCase().includes(searchLower)) ||
                            (item.Text && item.Text.toLowerCase().includes(searchLower))
                        );

                        const exactMatch = filteredData.some(item =>
                            (item.Name && item.Name.toLowerCase() === searchLower) ||
                            (item.Text && item.Text.toLowerCase() === searchLower)
                        );

                        if (!exactMatch && searchValue.trim()) {
                            filteredData = [{
                                ID: "add_new_%columnName%",
                                Name: "Thêm mới: \"" + searchValue + "\"",
                                Text: "Thêm mới: \"" + searchValue + "\"",
                                _isAddNew: true,
                                _newValue: searchValue
                            }].concat(filteredData);
                        }
                    }

                    return filteredData;
                }
            });

            /*BEGIN_DX*/
            %columnName%Instance = $("<div>").appendTo($container).dxSelectBox({
                dataSource: customStore,
                valueExpr: "ID",
                displayExpr: "Name",
                placeholder: "Chọn...",
                searchEnabled: true,
                searchMode: "contains",
                searchTimeout: 300,
                minSearchLength: 0,
                showClearButton: true,
                showDataBeforeSearch: true,
                stylingMode: "outlined",
                itemTemplate: function(data) {
                    if (data._isAddNew) {
                        return $("<div>").addClass("d-flex align-items-center text-success fw-semibold").append(
                            $("<i>").addClass("bi bi-plus-circle me-2"),
                            $("<span>").text(data.Name)
                        );
                    }
                    return $("<div>").addClass("d-flex align-items-center").text(data.Name || data.Text || "");
                },
                onValueChanged: async function(e) {
                    if (e.value === "add_new_%columnName%") {
                        const selectedItem = e.component.option("selectedItem");
                        if (selectedItem && selectedItem._isAddNew) {
                            const newItem = {
                                ID: Date.now(),
                                Name: selectedItem._newValue,
                                Text: selectedItem._newValue
                            };
                            DataSource.push(newItem);
                            e.component.option("value", newItem.ID);
                            e.component.getDataSource().reload();
                            console.log("Created new item %columnName%:", newItem);
                            return;
                        }
                    }

                    if (e.value !== %columnName%OriginalValue) {
                        await save%columnName%Value(e.value);
                    }
                }
            }).dxSelectBox("instance");
  /*END_DX*/

            async function save%columnName%Value(newValue) {
                if (newValue === %columnName%OriginalValue) return;

                try {
                    const dataJSON = JSON.stringify([-99218308, ["%columnName%"], [newValue || ""]]);
                    let idValues = [[%columnName%Key.%columnId%], "%columnId%"];

                    console.log("Saving %columnName% with IDValues:", idValues);
                    console.log("Saving %columnName% with dataJSON:", dataJSON);

                    const json = await saveFunction(dataJSON, idValues);
                    %columnName%OriginalValue = newValue;

                    uiManager.showAlert({
                        type: "success",
                        message: "Lưu thành công"
                    });
                } catch (err) {
                    console.error("Save error:", err);
                    %columnName%Instance.option("value", %columnName%OriginalValue);
                    uiManager.showAlert({
                        type: "error",
                        message: "Có lỗi xảy ra khi lưu: " + (err.message || "Vui lòng thử lại")
                    });
                }
            }

            return {
                setValue: function(val) {
                    %columnName%OriginalValue = val;
                    if (%columnName%Instance) {
                        %columnName%Instance.option("value", val);
                    }
                },
                getValue: function() {
                    return %columnName%Instance ? %columnName%Instance.option("value") : %columnName%OriginalValue;
                }
            };
        }
    ' WHERE [Type] = 'hpaControlSelectBox' AND [AutoSave] = 1 AND [ReadOnly] = 0

    -- ---------------------------------------------------------------------
    -- 2.6. hpaControlSelectBox - ReadOnly
    -- ---------------------------------------------------------------------
    UPDATE #temptable SET loadUI = N'
        if ($("#%IDDiv%").length === 0) {
            $("<div>", { id: "%IDDiv%" }).appendTo("body");
        }

        let %columnName%Instance
        let %columnName%OriginalValue = null

        function loadUI%columnName%() {
            const $container = $("#%IDDiv%");

            const customStore = new DevExpress.data.CustomStore({
                key: "%columnName%",
                byKey: function(key) {
                    const item = DataSource.find(i => i.ID === key);
                    return $.Deferred().resolve(item || null).promise();
                },
                load: function(loadOptions) {
                    const searchValue = loadOptions.searchValue || "";
                    let filteredData = DataSource;

                    if (searchValue) {
                        const searchLower = searchValue.toLowerCase();
                        filteredData = DataSource.filter(item =>
                            (item.Name && item.Name.toLowerCase().includes(searchLower)) ||
                            (item.Text && item.Text.toLowerCase().includes(searchLower))
                        );
                    }

                    return filteredData;
                }
            });

            /*BEGIN_DX*/
            %columnName%Instance = $("<div>").appendTo($container).dxSelectBox({
                dataSource: customStore,
                valueExpr: "ID",
                displayExpr: "Name",
                placeholder: "Chọn...",
                searchEnabled: true,
                searchMode: "contains",
                searchTimeout: 300,
                minSearchLength: 0,
                showClearButton: true,
                showDataBeforeSearch: true,
    stylingMode: "outlined",
                disabled: true,
                itemTemplate: function(data) {
                    return $("<div>").addClass("d-flex align-items-center").text(data.Name || data.Text || "");
                }
            }).dxSelectBox("instance");
            /*END_DX*/

            return {
                setValue: function(val) {
                    %columnName%OriginalValue = val;
                    if (%columnName%Instance) {
                        %columnName%Instance.option("value", val);
                    }
                },
                getValue: function() {
                    return %columnName%Instance ? %columnName%Instance.option("value") : %columnName%OriginalValue;
                }
            };
        }
    ' WHERE [Type] = 'hpaControlSelectBox' AND [ReadOnly] = 1

    -- ---------------------------------------------------------------------
    -- 2.7. hpaControlSelectBox - Manual (no autosave, no popup)
    -- ---------------------------------------------------------------------
    UPDATE #temptable SET loadUI = N'
        if ($("#%IDDiv%").length === 0) {
            $("<div>", { id: "%IDDiv%" }).appendTo("body");
        }

        let %columnName%Instance
        let %columnName%OriginalValue = null

        function loadUI%columnName%() {
            const $container = $("#%IDDiv%");

            const customStore = new DevExpress.data.CustomStore({
                key: "%columnName%",
                byKey: function(key) {
                    const item = DataSource.find(i => i.ID === key);
                    return $.Deferred().resolve(item || null).promise();
                },
                load: function(loadOptions) {
                    const searchValue = loadOptions.searchValue || "";
                    let filteredData = DataSource;

                    if (searchValue) {
                        const searchLower = searchValue.toLowerCase();
                        filteredData = DataSource.filter(item =>
                            (item.Name && item.Name.toLowerCase().includes(searchLower)) ||
                            (item.Text && item.Text.toLowerCase().includes(searchLower))
                        );
                    }

                    return filteredData;
                }
            });

            /*BEGIN_DX*/
            %columnName%Instance = $("<div>").appendTo($container).dxSelectBox({
                dataSource: customStore,
                valueExpr: "ID",
                displayExpr: "Name",
                placeholder: "Chọn...",
                searchEnabled: true,
                searchMode: "contains",
                searchTimeout: 300,
                minSearchLength: 0,
                showClearButton: true,
                showDataBeforeSearch: true,
                stylingMode: "outlined",
                itemTemplate: function(data) {
                    return $("<div>").addClass("d-flex align-items-center").text(data.Name || data.Text || "");
                }
            }).dxSelectBox("instance");
            /*END_DX*/

            return {
                setValue: function(val) {
                    %columnName%OriginalValue = val;
                    if (%columnName%Instance) {
                        %columnName%Instance.option("value", val);
                    }
                },
                getValue: function() {
                    return %columnName%Instance ? %columnName%Instance.option("value") : %columnName%OriginalValue;
                }
            };
        }
    ' WHERE [Type] = 'hpaControlSelectBox' AND [AutoSave] = 0 AND [ReadOnly] = 0

    -- ---------------------------------------------------------------------
    -- 2.8. hpaControlSelectBox - LoadData
    -- ---------------------------------------------------------------------
    UPDATE #temptable SET loadData = N'
        %columnName%Control = loadUI%columnName%();
        %columnName%Control.setValue(obj.%columnName%);
        %columnName%Key = { %columnId%: obj.%columnId% }'
    WHERE [Type] = 'hpaControlSelectBox'

    -- ---------------------------------------------------------------------
    -- 2.9. hpaControlSelectBoxApi - Normal (editable with API)
    -- ---------------------------------------------------------------------
    UPDATE #temptable SET loadUI = N'
        if ($("#%IDDiv%").length === 0) {
            $("<div>", { id: "%IDDiv%" }).appendTo("body");
        }

        let %columnName%Instance
        let %columnName%OriginalValue = null

        function loadUI%columnName%() {
            const $container = $("#%IDDiv%");

            const customStore = new DevExpress.data.CustomStore({
                key: "%columnName%",
                byKey: function(key) {
                    const item = DataSource.find(i => i.ID === key);
                    return $.Deferred().resolve(item || null).promise();
                },
                load: function(loadOptions) {
                    const deferred = $.Deferred();
                    const searchValue = loadOptions.searchValue || "";

                    setTimeout(() => {
                        let filteredData = DataSource;

                        if (searchValue) {
                            const searchLower = searchValue.toLowerCase();
                            filteredData = DataSource.filter(item => {
                                return Object.values(item).some(val =>
                                    val && val.toString().toLowerCase().includes(searchLower)
                                );
                            });

                            const exactMatch = filteredData.some(item =>
                                (item.Name && item.Name.toLowerCase() === searchLower) ||
                                (item.Text && item.Text.toLowerCase() === searchLower)
                            );

                            if (!exactMatch && searchValue.trim()) {
                                filteredData = [{
                                    ID: "add_new_%columnName%",
                                    Name: "Thêm mới: \"" + searchValue + "\"",
                                    Text: "Thêm mới: \"" + searchValue + "\"",
                                    _isAddNew: true,
                                    _newValue: searchValue
                                }].concat(filteredData);
                            }
                        }

                        deferred.resolve(filteredData);
                    }, 300);

                    return deferred.promise();
                }
            });

            /*BEGIN_DX*/
            %columnName%Instance = $("<div>").appendTo($container).dxSelectBox({
                dataSource: customStore,
                valueExpr: "ID",
                displayExpr: "Name",
                placeholder: "Tìm và chọn...",
                searchEnabled: true,
                searchMode: "contains",
                searchTimeout: 500,
                minSearchLength: 0,
                showClearButton: true,
                showDataBeforeSearch: true,
                stylingMode: "outlined",
                itemTemplate: function(data) {
                    if (data._isAddNew) {
                        return $("<div>").addClass("d-flex align-items-center text-success fw-semibold").append(
                            $("<i>").addClass("bi bi-plus-circle me-2"),
                            $("<span>").text(data.Name)
                        );
                    }
                    let displayHtml = $("<div>");
                    if (data.Name) {
                        displayHtml.append($("<div>").addClass("fw-semibold").text(data.Name));
                    }
                    if (data.Description) {
                        displayHtml.append($("<div>").addClass("small text-muted").text(data.Description));
                    }
                    return displayHtml;
                },
  onValueChanged: async function(e) {
                    if (e.value === "add_new_%columnName%") {
                        const selectedItem = e.component.option("selectedItem");
                        if (selectedItem && selectedItem._isAddNew) {
                            const newItem = {
                                ID: Date.now(),
                                Name: selectedItem._newValue,
                                Text: selectedItem._newValue
                            };
                            DataSource.push(newItem);
                            e.component.option("value", newItem.ID);
                            e.component.getDataSource().reload();
                            console.log("Created new item %columnName%:", newItem);
                            return;
                        }
                    }

                    if (e.value !== %columnName%OriginalValue) {
                        await save%columnName%Value(e.value);
                    }
                }
            }).dxSelectBox("instance");
            /*END_DX*/

            async function save%columnName%Value(newValue) {
                if (newValue === %columnName%OriginalValue) return;

                try {
                    const dataJSON = JSON.stringify([-99218308, ["%columnName%"], [newValue || ""]]);
                    let idValues = [[%columnName%Key.%columnId%], "%columnId%"];

                    console.log("Saving %columnName% with IDValues:", idValues);
                    console.log("Saving %columnName% with dataJSON:", dataJSON);

                    const json = await saveFunction(dataJSON, idValues);
                    %columnName%OriginalValue = newValue;

                    uiManager.showAlert({
                        type: "success",
                        message: "Lưu thành công"
                    });
                } catch (err) {
                    console.error("Save error:", err);
                    %columnName%Instance.option("value", %columnName%OriginalValue);
                    uiManager.showAlert({
                        type: "error",
                        message: "Có lỗi xảy ra khi lưu: " + (err.message || "Vui lòng thử lại")
                    });
                }
            }

            return {
                setValue: function(val) {
                    %columnName%OriginalValue = val;
                    if (%columnName%Instance) {
                        %columnName%Instance.option("value", val);
                    }
                },
                getValue: function() {
                    return %columnName%Instance ? %columnName%Instance.option("value") : %columnName%OriginalValue;
                }
            };
        }
    ' WHERE [Type] = 'hpaControlSelectBoxApi' AND [AutoSave] = 1 AND [ReadOnly] = 0

    -- ---------------------------------------------------------------------
    -- 2.10. hpaControlSelectBoxApi - ReadOnly
    -- ---------------------------------------------------------------------
    UPDATE #temptable SET loadUI = N'
        if ($("#%IDDiv%").length === 0) {
            $("<div>", { id: "%IDDiv%" }).appendTo("body");
        }

        let %columnName%Instance
        let %columnName%OriginalValue = null

        function loadUI%columnName%() {
            const $container = $("#%IDDiv%");

            const customStore = new DevExpress.data.CustomStore({
                key: "%columnName%",
                byKey: function(key) {
                    const item = DataSource.find(i => i.ID === key);
                    return $.Deferred().resolve(item || null).promise();
                },
                load: function(loadOptions) {
                    const deferred = $.Deferred();
                    const searchValue = loadOptions.searchValue || "";

                    setTimeout(() => {
                        let filteredData = DataSource;

                        if (searchValue) {
                            const searchLower = searchValue.toLowerCase();
                            filteredData = DataSource.filter(item => {
                                return Object.values(item).some(val =>
                                    val && val.toString().toLowerCase().includes(searchLower)
                                );
                            });
                        }

                        deferred.resolve(filteredData);
                    }, 300);

                    return deferred.promise();
                }
            });

            /*BEGIN_DX*/
            %columnName%Instance = $("<div>").appendTo($container).dxSelectBox({
                dataSource: customStore,
                valueExpr: "ID",
                displayExpr: "Name",
                placeholder: "Tìm và chọn...",
                searchEnabled: true,
                searchMode: "contains",
                searchTimeout: 500,
                minSearchLength: 0,
                showClearButton: true,
                showDataBeforeSearch: true,
                stylingMode: "outlined",
                disabled: true,
                itemTemplate: function(data) {
                    let displayHtml = $("<div>");
                    if (data.Name) {
                        displayHtml.append($("<div>").addClass("fw-semibold").text(data.Name));
                    }
                    if (data.Description) {
                        displayHtml.append($("<div>").addClass("small text-muted").text(data.Description));
                    }
                    return displayHtml;
                }
            }).dxSelectBox("instance");
            /*END_DX*/

            return {
                setValue: function(val) {
                    %columnName%OriginalValue = val;
                    if (%columnName%Instance) {
                        %columnName%Instance.option("value", val);
                    }
                },
                getValue: function() {
                    return %columnName%Instance ? %columnName%Instance.option("value") : %columnName%OriginalValue;
                }
            };
        }
    ' WHERE [Type] = 'hpaControlSelectBoxApi' AND [ReadOnly] = 1

    -- ---------------------------------------------------------------------
    -- 2.11. hpaControlSelectBoxApi - Manual
    -- ---------------------------------------------------------------------
    UPDATE #temptable SET loadUI = N'
        if ($("#%IDDiv%").length === 0) {
            $("<div>", { id: "%IDDiv%" }).appendTo("body");
        }

        let %columnName%Instance
        let %columnName%OriginalValue = null

        function loadUI%columnName%() {
            const $container = $("#%IDDiv%");

            const customStore = new DevExpress.data.CustomStore({
                key: "%columnName%",
                byKey: function(key) {
                    const item = DataSource.find(i => i.ID === key);
                    return $.Deferred().resolve(item || null).promise();
                },
                load: function(loadOptions) {
                    const deferred = $.Deferred();
                    const searchValue = loadOptions.searchValue || "";

                    setTimeout(() => {
                        let filteredData = DataSource;

                        if (searchValue) {
                            const searchLower = searchValue.toLowerCase();
                            filteredData = DataSource.filter(item => {
                                return Object.values(item).some(val =>
                                    val && val.toString().toLowerCase().includes(searchLower)
                                );
                            });
                        }

                        deferred.resolve(filteredData);
                    }, 300);

 return deferred.promise();
                }
            });

            /*BEGIN_DX*/
            %columnName%Instance = $("<div>").appendTo($container).dxSelectBox({
                dataSource: customStore,
                valueExpr: "ID",
                displayExpr: "Name",
                placeholder: "Tìm và chọn...",
                searchEnabled: true,
                searchMode: "contains",
                searchTimeout: 500,
                minSearchLength: 0,
                showClearButton: true,
                showDataBeforeSearch: true,
                stylingMode: "outlined",
                itemTemplate: function(data) {
                    let displayHtml = $("<div>");
                    if (data.Name) {
                        displayHtml.append($("<div>").addClass("fw-semibold").text(data.Name));
                    }
                    if (data.Description) {
                        displayHtml.append($("<div>").addClass("small text-muted").text(data.Description));
                    }
                    return displayHtml;
                }
            }).dxSelectBox("instance");
            /*END_DX*/

            return {
                setValue: function(val) {
                    %columnName%OriginalValue = val;
                    if (%columnName%Instance) {
                        %columnName%Instance.option("value", val);
                    }
                },
                getValue: function() {
                    return %columnName%Instance ? %columnName%Instance.option("value") : %columnName%OriginalValue;
                }
            };
        }
    ' WHERE [Type] = 'hpaControlSelectBoxApi' AND [AutoSave] = 0 AND [ReadOnly] = 0

    -- ---------------------------------------------------------------------
    -- 2.12. hpaControlSelectBoxApi - LoadData
    -- ---------------------------------------------------------------------
    UPDATE #temptable SET loadData = N'
        %columnName%Control = loadUI%columnName%();
        %columnName%Control.setValue(obj.%columnName%);
        %columnName%Key = { %columnId%: obj.%columnId% }'
    WHERE [Type] = 'hpaControlSelectBoxApi'

    -- ---------------------------------------------------------------------
    -- 2.13. hpaControlSelectEmployee - Normal
    -- ---------------------------------------------------------------------
    UPDATE #temptable SET loadUI = N'
        if ($("#%IDDiv%").length === 0) {
            $("<div>", { id: "%IDDiv%" }).appendTo("body");
        }

        let %columnName%Instance
        let %columnName%SelectedIds = []
        let %columnName%SelectedIdsOriginal = []
        const %columnName%MAX_VISIBLE = 3
        let %columnName%AvatarCache = {}

        function getInitials(name) {
            const words = name.trim().split(/\s+/);
            if (words.length >= 2) {
                return (words[0][0] + words[words.length - 1][0]).toUpperCase();
            }
            return name.substring(0, 2).toUpperCase();
        }

        function getColorForId(id) {
            const colors = [
                { bg: "#e3f2fd", text: "#1976d2" },
                { bg: "#f3e5f5", text: "#7b1fa2" },
                { bg: "#e8f5e9", text: "#388e3c" },
                { bg: "#fff3e0", text: "#f57c00" },
                { bg: "#fce4ec", text: "#c2185b" }
            ];
            return colors[id % colors.length];
        }

        function loadAvatarImage(employee) {
            if (!employee || !employee.storeImgName || !employee.paramImg) {
                return null;
            }

            const cacheKey = employee.storeImgName + "|" + employee.paramImg;

            if (%columnName%AvatarCache[cacheKey]) {
                return %columnName%AvatarCache[cacheKey];
            }

            return new Promise((resolve) => {
                try {
                    AjaxHPAParadise({
 data: {
              name: "sp_GetParadiseFile",
                            param: [employee.storeImgName, employee.paramImg]
                        },
                        success: function(res) {
                            const json = typeof res === "string" ? JSON.parse(res) : res;
                            const fileUrl = (json.data && json.data[0] && json.data[0][0]) || null;
                            if (fileUrl) {
                                %columnName%AvatarCache[cacheKey] = fileUrl;
                            }
                            resolve(fileUrl);
                        },
                        error: function() {
                            resolve(null);
                        }
                    });
                } catch (err) {
                    console.error("Avatar loading error:", err);
                    resolve(null);
                }
            });
        }

        function loadUI%columnName%() {
            const $container = $("#%IDDiv%");
            const uniqueId = "%columnName%_" + Date.now();
            const $displayBox = $("<div>").attr("id", uniqueId + "_display");
            $container.append($displayBox);

            function renderDisplayBox() {
                $displayBox.empty();
                const $wrapper = $("<div>").css({
                    border: "1px solid #dee2e6",
                    borderRadius: "4px",
                    padding: "8px 12px",
                    backgroundColor: "#fff",
                    cursor: "pointer",
                    minHeight: "42px",
                    display: "flex",
                    alignItems: "center"
                });

                if (%columnName%SelectedIds.length === 0) {
                    $wrapper.append(
                        $("<span>").addClass("text-muted").html(
                            "<i class=\"bi bi-person-plus me-1\"></i>Chọn nhân viên..."
                        )
                    );
                } else {
                    const $avatarGroup = $("<div>").css({
                        display: "flex",
                        alignItems: "center"
                    });

                    const displayIds = %columnName%SelectedIds.slice(0, %columnName%MAX_VISIBLE);

                    displayIds.forEach((id, index) => {
                        const item = DataSource.find(e => e.ID === id);
                        if (!item) return;

                        const $chip = $("<div>").css({
                            display: "inline-flex",
                            alignItems: "center",
                            justifyContent: "center",
                            width: "32px",
                            height: "32px",
                            borderRadius: "50%",
                            border: "2px solid #fff",
                            boxShadow: "0 2px 4px rgba(0,0,0,0.1)",
                            marginLeft: index === 0 ? "0" : "-8px",
                            zIndex: %columnName%MAX_VISIBLE - index,
                            transition: "transform 0.2s ease",
                            background: "#f8f9fa",
                            overflow: "hidden"
                        }).attr("title", item.Name || item.FullName || "");

                        $chip.hover(
                      function() { $(this).css("transform", "translateY(-2px) scale(1.05)"); },
                            function() { $(this).css("transform", "translateY(0) scale(1)"); }
                        );

                        const cacheKey = (item.storeImgName || "") + "|" + (item.paramImg || "");
                        const cachedUrl = %columnName%AvatarCache[cacheKey];

                        if (cachedUrl) {
                            $chip.append(
                                $("<img>").attr({ src: cachedUrl, alt: item.Name || item.FullName || "" }).css({
                               width: "100%", height: "100%", objectFit: "cover"
                                })
                            );
                        } else {
                            const initials = getInitials(item.Name || item.FullName || "");
                            const color = getColorForId(item.ID);
                            $chip.css({
                                background: color.bg,
                                color: color.text,
                                fontWeight: "600",
                                fontSize: "12px"
                            }).text(initials);
                        }

                        $avatarGroup.append($chip);
                    });

                    if (%columnName%SelectedIds.length > %columnName%MAX_VISIBLE) {
                        const remaining = %columnName%SelectedIds.length - %columnName%MAX_VISIBLE;
                        const $badge = $("<div>").css({
                            display: "inline-flex",
                            alignItems: "center",
                            justifyContent: "center",
                            width: "32px",
                            height: "32px",
                            borderRadius: "50%",
                            border: "2px solid #fff",
                            background: "#6c757d",
                            color: "#fff",
                            fontWeight: "600",
                            fontSize: "12px",
                            boxShadow: "0 2px 4px rgba(0,0,0,0.1)",
                            marginLeft: "-8px",
                            zIndex: "0",
                            transition: "transform 0.2s ease"
                        }).text(`+${remaining}`).attr("title", `Còn ${remaining} người nữa`);

                        $badge.hover(
                            function() { $(this).css("transform", "translateY(-2px) scale(1.05)"); },
                            function() { $(this).css("transform", "translateY(0) scale(1)"); }
                        );

                        $avatarGroup.append($badge);
                    }

                    $wrapper.append($avatarGroup);
                }

                $displayBox.append($wrapper);
                $wrapper.off("click").on("click", function() {
                    popup.show();
                });
            }

            const popup = $("<div>").attr("id", uniqueId + "_popup").appendTo($container).dxPopup({
                width: 750,
                height: 600,
                showTitle: true,
                title: "Chọn nhân viên",
                dragEnabled: true,
                closeOnOutsideClick: true,
                showCloseButton: true,
                toolbarItems: [
                    {
                        widget: "dxButton",
                        location: "after",
                        toolbar: "bottom",
                        options: {
                            text: "Xác nhận",
                            type: "success",
                            onClick: async function() {
                                try {
                                  await save%columnName%Value();
                                    popup.hide();
                                } catch (err) {
                                    console.error("Save error:", err);
                                }
                            }
                        }
                    }
                ],
                contentTemplate: function() {
                    return $("<div>").attr("id", uniqueId + "_grid");
                },
                onShown: function() {
                    const gridContainer = $(`#${uniqueId}_grid`);
                    gridContainer.dxDataGrid({
                        dataSource: DataSource,
                        keyExpr: "ID",
           selection: {
                            mode: "multiple",
                            showCheckBoxesMode: "always"
                        },
                        selectedRowKeys: %columnName%SelectedIds,
                        columns: [
                            {
                                caption: "Ảnh",
                                width: 70,
                                alignment: "center",
                                cellTemplate: function(container, options) {
                                    const item = options.data;
                                    const $cell = $("<div>").addClass("d-flex justify-content-center align-items-center");

                                    const cacheKey = (item.storeImgName || "") + "|" + (item.paramImg || "");
                                    const cachedUrl = %columnName%AvatarCache[cacheKey];

                                    if (cachedUrl) {
                                        $cell.append(
                                            $("<div>").addClass("d-flex align-items-center justify-content-center bg-light border").css({
                                                width: "40px", height: "40px", borderRadius: "50%", overflow: "hidden", boxShadow: "0 2px 4px rgba(0,0,0,0.1)"
                                            }).append(
                                                $("<img>").attr({ src: cachedUrl, alt: item.Name || item.FullName || "" }).css({
                                                    width: "100%", height: "100%", objectFit: "cover"
                                                })
                                            )
                                        );
                                    } else {
                                        const initials = getInitials(item.Name || item.FullName || "");
                                        const color = getColorForId(item.ID);
                                        $cell.append(
                                            $("<div>").addClass("d-flex align-items-center justify-content-center border").css({
                                                width: "40px", height: "40px", borderRadius: "50%", background: color.bg, color: color.text, fontWeight: 600, fontSize: "14px", boxShadow: "0 2px 4px rgba(0,0,0,0.1)"
                                            }).text(initials)
                                        );
                                    }

                                    container.append($cell);
                                }
                            },
                            {
                                dataField: "Name",
                                caption: "Họ tên",
                                width: 200,
                                cellTemplate: function(container, options) {
                                    const item = options.data;
                                    container.append(
                                        $("<div>").append(
               $("<div>").addClass("fw-semibold").text(item.Name || item.FullName || ""),
                                            $("<div>").addClass("small text-muted").text(item.Position || "")
                                        )
                                    );
                                }
                            },
                            {
                                dataField: "Email",
                                caption: "Email",
                                width: 200,
                                cellTemplate: function(container, options) {
                                    const email = options.data.Email || "";
                                    container.append(
                                        $("<div>").addClass("small").css("word-break", "break-word").text(email)
                          );
    }
                            }
                        ],
                        showBorders: true,
                        showRowLines: true,
                        rowAlternationEnabled: true,
                        hoverStateEnabled: true,
                        searchPanel: { visible: true, placeholder: "Tìm kiếm..." },
                        paging: { pageSize: 10 },
                        onSelectionChanged: function(e) {
                            %columnName%SelectedIds = e.selectedRowKeys || [];
                        }
                    });
                },
                onHidden: function() {
                    renderDisplayBox();
                }
            }).dxPopup("instance");

            /*BEGIN_DX*/
            %columnName%Instance = { renderDisplay: renderDisplayBox, popup: popup };
            /*END_DX*/
            renderDisplayBox();

            async function save%columnName%Value() {
                const originalStr = %columnName%SelectedIdsOriginal.slice().sort().join(",");
                const currentStr = %columnName%SelectedIds.slice().sort().join(",");

                if (originalStr === currentStr) return;

                try {
                    const dataJSON = JSON.stringify([-99218308, ["%columnName%"], [%columnName%SelectedIds.join(",")]]);
                    const idValues = [[%columnName%Key.%columnId%], "%columnId%"];

                    console.log("Saving %columnName% with IDValues:", idValues);
                    console.log("Saving %columnName% with dataJSON:", dataJSON);

                    const json = await saveFunction(dataJSON, idValues);
                    %columnName%SelectedIdsOriginal = [...%columnName%SelectedIds];

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
                    throw err;
                }
            }

            return {
                setValue: function(val) {
                    if (typeof val === "string" && val.trim() !== "") {
                        %columnName%SelectedIds = val.split(",").map(v => {
                            const num = parseInt(v);
                            return isNaN(num) ? v : num;
                        });
                    } else if (Array.isArray(val)) {
                        %columnName%SelectedIds = val;
                    } else {
                        %columnName%SelectedIds = [];
                    }
                    %columnName%SelectedIdsOriginal = [...%columnName%SelectedIds];
                    if (%columnName%Instance) {
                        %columnName%Instance.renderDisplay();
        }
                },
                getValue: function() {
                    return %columnName%SelectedIds;
                }
            };
        }
    ' WHERE [Type] = 'hpaControlSelectEmployee'

    -- ---------------------------------------------------------------------
    -- 2.14. hpaControlSelectEmployeeNoAvatar
    -- ---------------------------------------------------------------------
    UPDATE #temptable SET loadUI = N'
        if ($("#%IDDiv%").length === 0) {
            $("<div>", { id: "%IDDiv%" }).appendTo("body");
        }

        let %columnName%Instance
        let %columnName%SelectedIds = []
        let %columnName%SelectedIdsOriginal = []

        function loadUI%columnName%() {
            const $container = $("#%IDDiv%");

            function renderDisplayBox() {
                $container.empty();
                const $wrapper = $("<div>").css({
                    border: "1px solid #dee2e6",
                    borderRadius: "4px",
                    padding: "8px 12px",
                    backgroundColor: "#fff",
                    minHeight: "42px",
                    display: "flex",
                    alignItems: "center",
                    flexWrap: "wrap",
                    gap: "4px"
                });

                if (%columnName%SelectedIds.length === 0) {
                    $wrapper.append(
                        $("<span>").addClass("text-muted").html(
                            "<i class=\"bi bi-person-fill-add me-1\"></i>Chọn nhân viên..."
                        )
                    );
                } else {
                    %columnName%SelectedIds.forEach((id) => {
                        const item = DataSource.find(e => e.ID === id);
                        if (!item) return;

                        const $tag = $("<span>").addClass("badge bg-light text-dark border").css({
                            padding: "6px 10px",
                            borderRadius: "20px",
                            fontSize: "13px",
                            fontWeight: "500",
                            whiteSpace: "nowrap",
                            cursor: "default"
                        }).text(item.Name || item.FullName || "");

                        $wrapper.append($tag);
                    });
                }

                $container.append($wrapper);
            }

            renderDisplayBox();

            return {
                setValue: function(val) {
                    if (typeof val === "string" && val.trim() !== "") {
                        %columnName%SelectedIds = val.split(",").map(v => {
                            const num = parseInt(v);
                            return isNaN(num) ? v : num;
                        });
                    } else if (Array.isArray(val)) {
                        %columnName%SelectedIds = val;
                    } else {
                        %columnName%SelectedIds = [];
                    }
                    %columnName%SelectedIdsOriginal = [...%columnName%SelectedIds];
                    renderDisplayBox();
                },
                getValue: function() {
                    return %columnName%SelectedIds;
                }
            };
        }
    ' WHERE [Type] = 'hpaControlSelectEmployeeNoAvatar'

    -- ---------------------------------------------------------------------
    -- 2.15. hpaControlSelectEmployee - LoadData
    -- ---------------------------------------------------------------------
    UPDATE #temptable SET loadData = N'
        %columnName%Control = loadUI%columnName%();
        %columnName%Control.setValue(obj.%columnName%);
        %columnName%Key = { %columnId%: obj.%columnId% }'
    WHERE [Type] = 'hpaControlSelectEmployee'

    UPDATE #temptable SET loadData = N'
        %columnName%Control = loadUI%columnName%();
        %columnName%Control.setValue(obj.%columnName%);
        %columnName%Key = { %columnId%: obj.%columnId% }'
    WHERE [Type] = 'hpaControlSelectEmployeeNoAvatar'

    -- ---------------------------------------------------------------------
    -- 2.16. hpaControlTagBox - Normal (editable)
    -- ---------------------------------------------------------------------
    UPDATE #temptable SET loadUI = N'
        if ($("#%IDDiv%").length === 0) {
            $("<div>", { id: "%IDDiv%" }).appendTo("body");
        }

        let %columnName%Instance
        let %columnName%OriginalValue = []

        function loadUI%columnName%() {
            const $container = $("#%IDDiv%");

            const customStore = new DevExpress.data.CustomStore({
                key: "%columnName%",
                byKey: function(key) {
                    const item = DataSource.find(i => i.ID === key);
                    return $.Deferred().resolve(item || null).promise();
           },
                load: function(loadOptions) {
                    const searchValue = loadOptions.searchValue || "";
                    let filteredData = DataSource;

                    if (searchValue) {
                        const searchLower = searchValue.toLowerCase();
                        filteredData = DataSource.filter(item =>
                            (item.Name && item.Name.toLowerCase().includes(searchLower)) ||
                            (item.Text && item.Text.toLowerCase().includes(searchLower))
                        );

                        const exactMatch = filteredData.some(item =>
                            (item.Name && item.Name.toLowerCase() === searchLower) ||
                            (item.Text && item.Text.toLowerCase() === searchLower)
                        );

                        if (!exactMatch && searchValue.trim()) {
                            filteredData = [{
                                ID: "add_new_%columnName%",
                                Name: "Thêm mới: \"" + searchValue + "\"",
                                Text: "Thêm mới: \"" + searchValue + "\"",
                                Icon: "plus-circle",
                                _isAddNew: true,
                                _newValue: searchValue
                            }].concat(filteredData);
                        }
                    }

                    return filteredData;
                }
            });

            /*BEGIN_DX*/
            %columnName%Instance = $("<div>").appendTo($container).dxTagBox({
                dataSource: customStore,
                valueExpr: "ID",
                displayExpr: "Name",
                placeholder: "Chọn hoặc thêm...",
                searchEnabled: true,
                showClearButton: true,
                showSelectionControls: true,
                applyValueMode: "useButtons",
                stylingMode: "outlined",
                multiline: false,
                searchMode: "contains",
                searchTimeout: 300,
                minSearchLength: 0,
                itemTemplate: function(data) {
                    if (data._isAddNew) {
                        return $("<div>").addClass("d-flex align-items-center text-success fw-semibold").append(
                            $("<i>").addClass("bi bi-" + (data.Icon || "plus-circle") + " me-2"),
                            $("<span>").text(data.Name)
                        );
                    }
                    return $("<div>").addClass("d-flex align-items-center").append(
                        $("<i>").addClass("bi bi-" + (data.Icon || "tag") + " me-2 text-primary"),
                        $("<span>").text(data.Name || data.Text || "")
                    );
                },
                tagTemplate: function(data) {
                    return $("<div>").addClass("d-flex align-items-center").append(
                        $("<i>").addClass("bi bi-" + (data.Icon || "tag") + " me-1").css("font-size", "11px"),
                        $("<span>").text(data.Name || data.Text || "")
                    );
                },
                onSelectionChanged: function(e) {
                    const addedItems = e.addedItems || [];
                    addedItems.forEach(item => {
                        if (item._isAddNew) {
                            const newTag = {
                                ID: Date.now(),
                                Name: item._newValue,
                                Text: item._newValue,
                                Icon: "tag"
                            };
                            DataSource.push(newTag);
                            const currentValues = e.component.option("value") || [];
                            const filteredValues = currentValues.filter(v => v !== "add_new_%columnName%");
              filteredValues.push(newTag.ID);
                            e.component.option("value", filteredValues);
                            e.component.getDataSource().reload();
                            console.log("Created new tag %columnName%:", newTag);
                        }
                    });
                },
                onInitialized: function(e) {
                    const $element = $(e.element);
                    $element.find(".dx-placeholder").css({ "top": "0", "transform": "none", "padding-top": "8px", "transition": "none" });
                    $element.find(".dx-texteditor-input").css({ "padding-top": "8px", "padding-bottom": "8px" });
                    $element.find(".dx-tag-container").css({ "padding-top": "4px", "padding-bottom": "4px" });
                },
                onFocusIn: function(e) {
                    setTimeout(() => {
                        const $element = $(e.element);
                        $element.find(".dx-placeholder").css({ "top": "0", "transform": "none", "padding-top": "8px", "transition": "none" });
                        $element.find(".dx-texteditor-input").css({ "padding-top": "8px", "padding-bottom": "8px" });
                        $element.find(".dx-tag-container").css({ "padding-top": "4px", "padding-bottom": "4px" });
                    }, 0);
                },
                onValueChanged: async function(e) {
                    const values = (e.value || []).filter(v => v !== "add_new_%columnName%");

                    if (JSON.stringify(values.slice().sort()) !== JSON.stringify(%columnName%OriginalValue.slice().sort())) {
                        await save%columnName%Value(values);
                    }

                    setTimeout(() => {
                        const $element = $(e.element);
                        $element.find(".dx-placeholder").css({ "top": "0", "transform": "none", "padding-top": "8px", "transition": "none" });
                        $element.find(".dx-texteditor-input").css({ "padding-top": "8px", "padding-bottom": "8px" });
                        $element.find(".dx-tag-container").css({ "padding-top": "4px", "padding-bottom": "4px" });
                    }, 0);
                }
            }).dxTagBox("instance");
            /*END_DX*/

            async function save%columnName%Value(newValue) {
                try {
                    const dataJSON = JSON.stringify([-99218308, ["%columnName%"], [newValue.join(",")]]);
                    const idValues = [[%columnName%Key.%columnId%], "%columnId%"];

                    console.log("Saving %columnName% with IDValues:", idValues);
                    console.log("Saving %columnName% with dataJSON:", dataJSON);

                    const json = await saveFunction(dataJSON, idValues);
                    %columnName%OriginalValue = newValue;

                    uiManager.showAlert({
                        type: "success",
                        message: "Lưu thành công"
                    });
                } catch (err) {
                console.error("Save error:", err);
                    %columnName%Instance.option("value", %columnName%OriginalValue);
                    uiManager.showAlert({
                        type: "error",
                        message: "Có lỗi xảy ra khi lưu: " + (err.message || "Vui lòng thử lại")
                    });
                }
            }

            return {
                setValue: function(val) {
                    if (typeof val === "string") {
                        %columnName%OriginalValue = val.split(",").map(v => {
                            const num = parseInt(v);
                            return isNaN(num) ? v : num;
                        });
                    } else if (Array.isArray(val)) {
                        %columnName%OriginalValue = val;
    } else {
                        %columnName%OriginalValue = [];
   }
                    if (%columnName%Instance) {
                        %columnName%Instance.option("value", %columnName%OriginalValue);
                    }
                },
                getValue: function() {
                    return %columnName%Instance ? %columnName%Instance.option("value") : %columnName%OriginalValue;
                }
            };
        }
    ' WHERE [Type] = 'hpaControlTagBox' AND [AutoSave] = 1 AND [ReadOnly] = 0

    -- ---------------------------------------------------------------------
    -- 2.17. hpaControlTagBox - ReadOnly
    -- ---------------------------------------------------------------------
    UPDATE #temptable SET loadUI = N'
        if ($("#%IDDiv%").length === 0) {
            $("<div>", { id: "%IDDiv%" }).appendTo("body");
        }

        let %columnName%Instance
        let %columnName%OriginalValue = []

        function loadUI%columnName%() {
            const $container = $("#%IDDiv%");

            const customStore = new DevExpress.data.CustomStore({
                key: "%columnName%",
                byKey: function(key) {
                    const item = DataSource.find(i => i.ID === key);
                    return $.Deferred().resolve(item || null).promise();
                },
                load: function(loadOptions) {
                    const searchValue = loadOptions.searchValue || "";
                    let filteredData = DataSource;

                    if (searchValue) {
                        const searchLower = searchValue.toLowerCase();
                        filteredData = DataSource.filter(item =>
                            (item.Name && item.Name.toLowerCase().includes(searchLower)) ||
                            (item.Text && item.Text.toLowerCase().includes(searchLower))
                        );
                    }

                    return filteredData;
                }
            });

            /*BEGIN_DX*/
            %columnName%Instance = $("<div>").appendTo($container).dxTagBox({
                dataSource: customStore,
                valueExpr: "ID",
                displayExpr: "Name",
                placeholder: "Chọn hoặc thêm...",
                searchEnabled: true,
                showClearButton: true,
                showSelectionControls: true,
                applyValueMode: "useButtons",
                stylingMode: "outlined",
                multiline: false,
                searchMode: "contains",
                searchTimeout: 300,
                minSearchLength: 0,
                disabled: true,
                itemTemplate: function(data) {
                    return $("<div>").addClass("d-flex align-items-center").append(
                        $("<i>").addClass("bi bi-" + (data.Icon || "tag") + " me-2 text-primary"),
                        $("<span>").text(data.Name || data.Text || "")
                    );
                },
                tagTemplate: function(data) {
                    return $("<div>").addClass("d-flex align-items-center").append(
                        $("<i>").addClass("bi bi-" + (data.Icon || "tag") + " me-1").css("font-size", "11px"),
                        $("<span>").text(data.Name || data.Text || "")
                    );
                }
            }).dxTagBox("instance");
            /*END_DX*/

            return {
                setValue: function(val) {
                    if (typeof val === "string") {
                        %columnName%OriginalValue = val.split(",").map(v => {
                            const num = parseInt(v);
                            return isNaN(num) ? v : num;
                        });
                    } else if (Array.isArray(val)) {
                        %columnName%OriginalValue = val;
                    } else {
 %columnName%OriginalValue = [];
                    }
                    if (%columnName%Instance) {
                   %columnName%Instance.option("value", %columnName%OriginalValue);
                    }
                },
                getValue: function() {
                    return %columnName%Instance ? %columnName%Instance.option("value") : %columnName%OriginalValue;
                }
            };
        }
    ' WHERE [Type] = 'hpaControlTagBox' AND [ReadOnly] = 1

    -- ---------------------------------------------------------------------
    -- 2.18. hpaControlTagBox - Manual
    -- ---------------------------------------------------------------------
    UPDATE #temptable SET loadUI = N'
        if ($("#%IDDiv%").length === 0) {
            $("<div>", { id: "%IDDiv%" }).appendTo("body");
        }

        let %columnName%Instance
        let %columnName%OriginalValue = []

        function loadUI%columnName%() {
            const $container = $("#%IDDiv%");

            const customStore = new DevExpress.data.CustomStore({
                key: "%columnName%",
                byKey: function(key) {
                    const item = DataSource.find(i => i.ID === key);
                    return $.Deferred().resolve(item || null).promise();
                },
                load: function(loadOptions) {
                    const searchValue = loadOptions.searchValue || "";
                    let filteredData = DataSource;

                    if (searchValue) {
                        const searchLower = searchValue.toLowerCase();
                        filteredData = DataSource.filter(item =>
                            (item.Name && item.Name.toLowerCase().includes(searchLower)) ||
                            (item.Text && item.Text.toLowerCase().includes(searchLower))
                        );
                    }

                    return filteredData;
                }
            });

            /*BEGIN_DX*/
            %columnName%Instance = $("<div>").appendTo($container).dxTagBox({
                dataSource: customStore,
                valueExpr: "ID",
                displayExpr: "Name",
                placeholder: "Chọn hoặc thêm...",
                searchEnabled: true,
                showClearButton: true,
                showSelectionControls: true,
                applyValueMode: "useButtons",
                stylingMode: "outlined",
                multiline: false,
                searchMode: "contains",
                searchTimeout: 300,
                minSearchLength: 0,
                itemTemplate: function(data) {
                    return $("<div>").addClass("d-flex align-items-center").append(
        $("<i>").addClass("bi bi-" + (data.Icon || "tag") + " me-2 text-primary"),
                        $("<span>").text(data.Name || data.Text || "")
                    );
                },
                tagTemplate: function(data) {
                    return $("<div>").addClass("d-flex align-items-center").append(
                        $("<i>").addClass("bi bi-" + (data.Icon || "tag") + " me-1").css("font-size", "11px"),
                        $("<span>").text(data.Name || data.Text || "")
                    );
                },
                onInitialized: function(e) {
                    const $element = $(e.element);
                    $element.find(".dx-placeholder").css({ "top": "0", "transform": "none", "padding-top": "8px", "transition": "none" });
                    $element.find(".dx-texteditor-input").css({ "padding-top": "8px", "padding-bottom": "8px" });
                    $element.find(".dx-tag-container").css({ "padding-top": "4px", "padding-bottom": "4px" });
                }
            }).dxTagBox("instance");
            /*END_DX*/

            return {
                setValue: function(val) {
                    if (typeof val === "string") {
                 %columnName%OriginalValue = val.split(",").map(v => {
               const num = parseInt(v);
                       return isNaN(num) ? v : num;
                        });
                    } else if (Array.isArray(val)) {
                        %columnName%OriginalValue = val;
                    } else {
                        %columnName%OriginalValue = [];
                    }
                    if (%columnName%Instance) {
                        %columnName%Instance.option("value", %columnName%OriginalValue);
                    }
                },
                getValue: function() {
                    return %columnName%Instance ? %columnName%Instance.option("value") : %columnName%OriginalValue;
                }
            };
        }
    ' WHERE [Type] = 'hpaControlTagBox' AND [AutoSave] = 0 AND [ReadOnly] = 0

    -- ---------------------------------------------------------------------
    -- 2.19. hpaControlTagBox - LoadData
    -- ---------------------------------------------------------------------
    UPDATE #temptable SET loadData = N'
        %columnName%Control = loadUI%columnName%();
        %columnName%Control.setValue(obj.%columnName%);
        %columnName%Key = { %columnId%: obj.%columnId% }'
    WHERE [Type] = 'hpaControlTagBox'

    -- =====================================================================
    -- BƯỚC 3: THAY THẾ PLACEHOLDER (KHÔNG BAO GỒM GRID)
    -- =====================================================================
    update #temptable set loadUI =replace(loadUI,'%IDDiv%',[IDDiv]) where [Type] IN ('hpaControlText', 'hpaControlSelectBox', 'hpaControlSelectBoxApi', 'hpaControlSelectEmployee', 'hpaControlSelectEmployeeNoAvatar', 'hpaControlTagBox', 'hpaControlGrid')
    update #temptable set loadUI =replace(loadUI,'%columnName%',[ColumnName]) where [Type] IN ('hpaControlText', 'hpaControlSelectBox', 'hpaControlSelectBoxApi', 'hpaControlSelectEmployee', 'hpaControlSelectEmployeeNoAvatar', 'hpaControlTagBox', 'hpaControlGrid')
    update #temptable set loadUI =replace(loadUI,'%tableId%',@object_Id) where [Type] IN ('hpaControlText', 'hpaControlSelectBox', 'hpaControlSelectBoxApi', 'hpaControlSelectEmployee', 'hpaControlSelectEmployeeNoAvatar', 'hpaControlTagBox', 'hpaControlGrid')
    update #temptable set loadUI =replace(loadUI,'%columnId%',columnId) where [Type] IN ('hpaControlText', 'hpaControlSelectBox', 'hpaControlSelectBoxApi', 'hpaControlSelectEmployee', 'hpaControlSelectEmployeeNoAvatar', 'hpaControlTagBox', 'hpaControlGrid')
    update #temptable set loadData =replace(loadData,'%columnName%',[ColumnName]) where [Type] IN ('hpaControlText', 'hpaControlSelectBox', 'hpaControlSelectBoxApi', 'hpaControlSelectEmployee', 'hpaControlSelectEmployeeNoAvatar', 'hpaControlTagBox', 'hpaControlGrid')
    update #temptable set loadData =replace(loadData,'%columnId%',columnId) where [Type] IN ('hpaControlText', 'hpaControlSelectBox', 'hpaControlSelectBoxApi', 'hpaControlSelectEmployee', 'hpaControlSelectEmployeeNoAvatar', 'hpaControlTagBox', 'hpaControlGrid')
    update #temptable set html =replace(html,'%columnName%',[ColumnName]) where [Type] IN ('hpaControlText', 'hpaControlSelectBox', 'hpaControlSelectBoxApi', 'hpaControlSelectEmployee', 'hpaControlSelectEmployeeNoAvatar', 'hpaControlTagBox', 'hpaControlGrid')

    -- =====================================================================
    -- BƯỚC 4: XỬ LÝ hpaControlGrid - TRÍCH XUẤT DXBoxUI
    -- =====================================================================

    IF OBJECT_ID('tempdb..#DXBoxUI') IS NOT NULL DROP TABLE #DXBoxUI;

    SELECT
        t.ID,
        t.TableName,
        t.ColumnName,
        t.Type,
        t.DisplayName,
        t.GridColumnName,
        t.AutoSave,
        t.ReadOnly,
        t.SPLoadData,
        t.TableEditor,
        t.columnId,
        DXBoxUI = SUBSTRING(
            t.loadUI,
  CHARINDEX('/*BEGIN_DX*/', t.loadUI) + LEN('/*BEGIN_DX*/'),
            CHARINDEX('/*END_DX*/', t.loadUI) - (CHARINDEX('/*BEGIN_DX*/', t.loadUI) + LEN('/*BEGIN_DX*/'))
        )
    INTO #DXBoxUI
    FROM #temptable t
    WHERE t.loadUI LIKE '%/*BEGIN_DX*/%'
      AND CHARINDEX('/*BEGIN_DX*/', t.loadUI) > 0
      AND CHARINDEX('/*END_DX*/', t.loadUI) > CHARINDEX('/*BEGIN_DX*/', t.loadUI);

    -- =====================================================================
    -- BƯỚC 5: TẠO BẢNG #GridChildControls
    -- =====================================================================

    IF OBJECT_ID('tempdb..#GridChildControls') IS NOT NULL DROP TABLE #GridChildControls;

    SELECT
        g.ColumnName AS GridColumnName,
        c.ColumnName AS ChildColumnName,
        c.Type AS ChildControlType,
        c.ReadOnly,
        c.AutoSave,
        ISNULL(dx.DXBoxUI, '') AS ChildDXBoxUI,
        ISNULL(c.DisplayName, c.ColumnName) AS Caption,
        c.columnId AS ChildColumnId,
        ROW_NUMBER() OVER (PARTITION BY g.ColumnName ORDER BY c.ID) AS ColOrder
    INTO #GridChildControls
    FROM #temptable g
    INNER JOIN #temptable c ON c.GridColumnName = g.ColumnName AND c.GridColumnName IS NOT NULL
    LEFT JOIN #DXBoxUI dx ON dx.ColumnName = c.ColumnName AND dx.TableName = c.TableName
    WHERE g.Type = 'hpaControlGrid';

    -- =====================================================================
    -- BƯỚC 6: TẠO CẤU HÌNH COLUMNS CHO TỪNG GRID VÀ UPDATE GRID TEMPLATE
    -- =====================================================================
    DECLARE grid_cursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT DISTINCT GridColumnName FROM #GridChildControls
    DECLARE @currentGrid NVARCHAR(256), @columnsConfig NVARCHAR(MAX), @gridColumnId NVARCHAR(64), @gridPrimaryKey NVARCHAR(256)
    OPEN grid_cursor
    FETCH NEXT FROM grid_cursor INTO @currentGrid
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @columnsConfig = N''
        SELECT @gridColumnId = columnId FROM #temptable WHERE ColumnName = @currentGrid AND Type = 'hpaControlGrid'

        -- Lấy GridPrimaryKeyField từ config table
        SELECT @gridPrimaryKey = ISNULL(GridPrimaryKeyField, @gridColumnId) FROM dbo.tblCommonControlType_Signed
        WHERE ColumnName = @currentGrid AND Type = 'hpaControlGrid'

        IF @gridPrimaryKey IS NULL
            SET @gridPrimaryKey = @gridColumnId

        -- Build columns config - SIMPLE: no cellTemplate, just display data
        SELECT @columnsConfig +=
            CASE WHEN @columnsConfig <> N'' THEN N',' + CHAR(13)+CHAR(10) ELSE N'' END +
            N'    { dataField: "' + ChildColumnName + N'", caption: "' + Caption + N'", width: 150, allowEditing: ' +
            CASE WHEN ReadOnly = 1 THEN 'false' ELSE 'true' END + N' }'
        FROM #GridChildControls
        WHERE GridColumnName = @currentGrid
        ORDER BY ColOrder

        IF EXISTS (SELECT 1 FROM #GridChildControls WHERE GridColumnName = @currentGrid AND ChildColumnName = 'ParentTaskID')
        BEGIN
            SET @columnsConfig =
                N'    { dataField: "ParentTaskID", caption: "Task cha", width: 100, alignment: "center", allowGrouping: false, allowFiltering: true, visible: true },' +
                CHAR(13)+CHAR(10) + @columnsConfig
        END

        IF @columnsConfig = N''
            SET @columnsConfig = N'    { dataField: "ID", caption: "ID", width: 80 },' + CHAR(13)+CHAR(10) +
                                N'    { dataField: "Name", caption: "Tên", minWidth: 200 }'

        SET @columnsConfig = N'[' + CHAR(13)+CHAR(10) + @columnsConfig + CHAR(13)+CHAR(10) + N']'
        -- CẬP NHẬT GRID TEMPLATE
        UPDATE #temptable
        SET
            loadUI = N'
    if ($("#' + @currentGrid + N'").length === 0) {
     $("<div>", { id: "' + @currentGrid + N'" }).appendTo("body");
    }
    let ' + @currentGrid + N'Instance;
    let ' + @currentGrid + N'DataSource = [];
    function loadUI' + @currentGrid + N'() {
     const $container = $("#' + @currentGrid + N'");
     const store = new DevExpress.data.ArrayStore({ data: ' + @currentGrid + N'DataSource, key: "' + @gridPrimaryKey + N'" });
     /*BEGIN_DX*/
     ' + @currentGrid + N'Instance = $("<div>").appendTo($container).dxDataGrid({
      dataSource: store,
      keyExpr: "' + @gridPrimaryKey + N'",
      showBorders: true,
      showRowLines: true,
      showColumnLines: false,
      rowAlternationEnabled: false,
      hoverStateEnabled: true,
      columnAutoWidth: true,
      allowColumnReordering: true,
      allowColumnResizing: true,
      columnResizingMode: "widget",
      wordWrapEnabled: true,
      toolbar: {
       items: [
        {
         location: "before",
         widget: "dxButton",
         options: {
          text: "Danh sách",
          icon: "menu",
          onClick: function() { console.log("List view") }
         }
        },
        "groupPanel",
        "exportButton",
        "columnChooserButton",
        "searchPanel"
       ]
      },
      selection: {
       mode: "multiple",
       showCheckBoxesMode: "always",
       allowSelectAll: true
      },
      paging: {
       enabled: true,
       pageSize: 50
      },
      pager: {
       visible: true,
       allowedPageSizes: [10, 20, 50, 100],
       showPageSizeSelector: true,
       showInfo: true,
       showNavigationButtons: true
      },
      grouping: {
       autoExpandAll: true,
       contextMenuEnabled: true
      },
      groupPanel: {
       visible: true,
       emptyPanelText: "Kéo cột vào đây để nhóm theo tiêu chí"
      },
      filterRow: {
       visible: true,
       applyFilter: "auto"
      },
      searchPanel: {
       visible: true,
       width: 240,
       placeholder: "Tìm kiếm..."
      },
      headerFilter: {
       visible: true
      },
      columnChooser: {
       enabled: true,
       mode: "select",
       title: "Chọn cột hiển thị"
      },
      export: {
       enabled: true,
       fileName: "ExportData",
       formats: ["pdf", "xlsx"],
       allowExportSelectedData: true
      },
      stateStoring: {
       enabled: true,
       type: "localStorage",
       storageKey: "' + @currentGrid + N'GridState"
      },
      sorting: {
       mode: "multiple"
      },
      scrolling: {
       mode: "virtual",
       rowRenderingMode: "virtual",
       showScrollbar: "onHover"
      },
      columnFixing: {
       enabled: true
      },
      columns: ' + @columnsConfig + N',
      summary: {
       totalItems: [
        {
         column: "' + @gridColumnId + N'",
         summaryType: "count",
         displayFormat: "Tổng: {0} bản ghi"
        }
       ],
       groupItems: [
        {
         column: "' + @gridColumnId + N'",
         summaryType: "count",
         displayFormat: "{0}"
        }
       ]
      },
      masterDetail: {
       enabled: true,
       autoExpandAll: false,
       template: function(container, options) {
        var parentTaskId = options.data.TaskID;
        var subtasks = window.' + @currentGrid + N'AllData ? window.' + @currentGrid + N'AllData.filter(function(t) { return t.ParentTaskID === parentTaskId; }) : [];
        if (subtasks.length > 0) {
         var html = `<div style="padding: 16px; background: var(--bg-light);"><strong style="display: flex; align-items: center; gap: 8px; margin-bottom: 12px;"><i class="bi bi-diagram-3"></i>Subtasks (${subtasks.length})</strong>`;
         html += `<table class="table" style="margin: 0;"><thead><tr><th style="padding: 10px 12px;">Mã</th><th style="padding: 10px 12px;">Tên</th><th style="padding: 10px 12px;">Trạng thái</th><th style="padding: 10px 12px;">Ưu tiên</th><th style="padding: 10px 12px;">Tiến độ</th><th style="padding: 10px 12px;">Người thực hiện</th></tr></thead><tbody>`;
         subtasks.forEach(function(st) {
          var statusClass = "sts-" + (st.StatusCode || 1);
          var statusText = (st.StatusCode || 1) === 1 ? "Chưa làm" : (st.StatusCode || 1) === 2 ? "Đang làm" : "Hoàn thành";
          var prioClass = "prio-" + (st.AssignPriority || 3);
          var prioText = (st.AssignPriority || 3) === 1 ? "Cao" : (st.AssignPriority || 3) === 2 ? "Trung bình" : "Thấp";
          html += `<tr style="border-bottom: 1px solid var(--bg-lighter);"><td style="padding: 10px 12px;">#${st.TaskID}</td><td style="padding: 10px 12px;">${st.TaskName}</td><td style="padding: 10px 12px;"><span class="badge-sts ${statusClass}">${statusText}</span></td><td style="padding: 10px 12px; text-align: center;"><i class="bi bi-flag-fill priority-icon ${prioClass}" title="${prioText}"></i></td><td style="padding: 10px 12px; text-align: center;">${st.ProgressPct || 0}%</td><td style="padding: 10px 12px;">${st.AssignedToName || "-"}</td></tr>`;
         });
         html += "</tbody></table></div>";
         $(container).html(html);
        } else {
         $(container).html(`<div style="padding: 16px; color: var(--text-muted);"><i class="bi bi-info-circle"></i> Không có subtasks</div>`);
        }
       }
      },
      onRowPrepared: function(e) {
       if (e.rowType === "data") {
        // Custom row styling if needed
        if (e.data.IsOverdue === 1) {
         e.rowElement.css("background-color", "rgba(229, 57, 53, 0.03)");
        }
        if (e.data.StatusCode === 3 || e.data.Status === 3) {
         e.rowElement.css("opacity", "0.7");
        }
       }
      },
      onCellPrepared: function(e) {
       if (e.rowType === "data" && e.column.command === "drag") {
        e.cellElement.css({
         cursor: "grab",
         userSelect: "none"
        });
       }
      },
      onContextMenuPreparing: function(e) {
       if (e.row && e.row.rowType === "data") {
        e.items = [
         {
          text: "Xem chi tiết",
          icon: "info",
          onItemClick: function() {
           console.log("View details for record:", e.row.data);
          }
         },
         {
          text: "Chỉnh sửa",
          icon: "edit",
          onItemClick: function() {
           console.log("Edit record:", e.row.data);
          }
         },
         { beginGroup: true },
         {
          text: "Xóa",
          icon: "trash",
          onItemClick: function() {
           if (confirm("Bạn có chắc chắn muốn xóa?")) {
            console.log("Delete record:", e.row.data);
           }
          }
         }
        ];
       }
      },
      onCellClick: function(e) {
       if (e.rowType === "data" && e.column && e.column.allowEditing === true) {
        e.component.editCell(e.rowIndex, e.column.dataField);
       }
      },
      onRowUpdating: async function(e) {
       const col = Object.keys(e.newData)[0];
       let newVal = e.newData[col];
       if (e.row?.data?._grid_controls?.[col]) {
        newVal = e.row.data._grid_controls[col].option("value");
       }
       try {
        await saveFunction(JSON.stringify([-99218308, [col], [newVal]]), [[e.key], "' + @gridColumnId + N'"]);
        const rowIdx = ' + @currentGrid + N'Instance.getRowIndexByKey(e.key);
        ' + @currentGrid + N'Instance.cellValue(rowIdx, col, newVal);
        if (window.uiManager && window.uiManager.showAlert) {
         uiManager.showAlert({ type: "success", message: "Lưu thành công" });
        }
       } catch (err) {
        e.cancel = true;
        if (window.uiManager && window.uiManager.showAlert) {
         uiManager.showAlert({ type: "error", message: "Lưu thất bại" });
        }
        console.error("Error saving:", err);
       }
      },
      onToolbarPreparing: function(e) {
       // Add custom toolbar items if needed
      }
     }).dxDataGrid("instance");
     /*END_DX*/
     return {
      setValue: val => { ' + @currentGrid + N'DataSource = val || []; if (' + @currentGrid + N'Instance) { ' + @currentGrid + N'Instance.option("dataSource", ' + @currentGrid + N'DataSource); ' + @currentGrid + N'Instance.refresh(); } },
      getValue: () => ' + @currentGrid + N'DataSource,
      getInstance: () => ' + @currentGrid + N'Instance
     };
    }',
            loadData = N'
    ' + @currentGrid + N'Control = loadUI' + @currentGrid + N'();
    ' + @currentGrid + N'Control.setValue(obj.' + @currentGrid + N');
    ' + @currentGrid + N'Key = { ' + @gridColumnId + N': obj.' + @gridColumnId + N' }'
        WHERE ColumnName = @currentGrid AND Type = 'hpaControlGrid'

        FETCH NEXT FROM grid_cursor INTO @currentGrid
    END
    CLOSE grid_cursor
    DEALLOCATE grid_cursor

    -- =====================================================================
    -- BƯỚC 7: KẾT XUẤT CUỐI CÙNG
    -- =====================================================================

    --DECLARE @loadUI_Final NVARCHAR(MAX) = N'let DataSource = [];', @loadData_Final NVARCHAR(MAX) = N''

    --SELECT @loadUI_Final += ISNULL(loadUI, ''), @loadData_Final += ISNULL(loadData, '')
    --FROM #temptable
    --ORDER BY ID

 DECLARE @loadUI_Final NVARCHAR(MAX) = N'let DataSource = [];', @loadData_Final NVARCHAR(MAX) = N''
 select @loadUI_Final += ISNULL(loadUI, ''), @loadData_Final += ISNULL(loadData, '')
    FROM #temptable where GridColumnName is null

    -- Lấy tên grid (IDDiv của hpaControlGrid)
    DECLARE @gridId NVARCHAR(256) = (SELECT TOP 1 IDDiv FROM #temptable WHERE Type = 'hpaControlGrid')

    DECLARE @nsql NVARCHAR(MAX) = N'
    <script>
        (() => {
            ' + @loadUI_Final + N'
            function loadData() {
                AjaxHPAParadise({
                    data: { name: "%SPLoadData%", param: [] },
                    success: function (res) {
                        try {
                            const json = typeof res === "string" ? JSON.parse(res) : res;
                            const results = (json.data && json.data[0]) || [];
                            DataSource = results;
                            // Lưu tất cả dữ liệu (gồm cả parent và subtasks) để master-detail dùng
                            window.gridMyTasksAllData = results;
                            if (results.length > 0) {
                                let obj = results[0];
                                ' + @loadData_Final + N'
                                // Filter chỉ parent tasks để hiển thị
                                var parentTasks = results.filter(function(t) { return t.ParentTaskID === null || t.ParentTaskID === undefined; });
                                if (window.gridMyTasksInstance && parentTasks.length > 0) {
                                    window.gridMyTasksInstance.option("dataSource", parentTasks);
                                    window.gridMyTasksInstance.refresh();
                                }
                            }
                        } catch(err) {
                            console.error("Error loading grid data:", err);
                            if (window.uiManager && window.uiManager.showAlert) {
                                uiManager.showAlert({ type: "error", message: "Lỗi khi tải dữ liệu grid" });
                            }
                        }
                    },
                    error: function(err) {
                        console.error("Ajax error:", err);
                        if (window.uiManager && window.uiManager.showAlert) {
                            uiManager.showAlert({ type: "error", message: "Không thể kết nối server" });
                        }
                    }
                });
            }
            // Load data on ready
            $(document).ready(function() {
                loadData();
            });
        })();
    </script>'

    SET @nsql = REPLACE(@nsql, '%SPLoadData%', (SELECT TOP 1 SPLoadData FROM #temptable WHERE SPLoadData IS NOT NULL))
    SET @nsql = REPLACE(@nsql, '%columnName%', (SELECT TOP 1 columnName FROM #temptable WHERE columnName IS NOT NULL))
    SET @nsql = REPLACE(@nsql, '%columnId%', (SELECT TOP 1 columnId FROM #temptable WHERE columnId IS NOT NULL))

    -- Wrap script properly and export
    DECLARE @finalScript NVARCHAR(MAX) = @nsql

    -- Return both script and grid ID for application to handle injection
    SELECT
        @finalScript AS htmlProc,
        @gridId AS gridId
END
GO


exec sptblCommonControlType_Signed_Linh 'sp_Task_MyWork_html'
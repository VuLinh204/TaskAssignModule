// ==================== TAGBOX TEMPLATE (Multi Select with Add New) ====================
let %ColumnName%Instance = null;
let %ColumnName%OriginalValue = [];
const %ColumnName%DataSource = [
    { ID: 1, Name: "Frontend", Icon: "code-slash" },
    { ID: 2, Name: "Backend", Icon: "server" },
    { ID: 3, Name: "Database", Icon: "database" },
    { ID: 4, Name: "DevOps", Icon: "gear" },
    { ID: 5, Name: "UI/UX", Icon: "palette" }
];

function loadUI%ColumnName%() {
    const $container = $("#%ColumnName%");

    const customStore = new DevExpress.data.CustomStore({
        key: "ID",
        load: function(loadOptions) {
            const searchValue = loadOptions.searchValue || "";
            let filteredData = %ColumnName%DataSource;
            
            if (searchValue) {
                const searchLower = searchValue.toLowerCase();
                filteredData = %ColumnName%DataSource.filter(item => 
                    item.Name.toLowerCase().includes(searchLower)
                );
                
                const exactMatch = filteredData.some(item => 
                    item.Name.toLowerCase() === searchLower
                );
                
                if (!exactMatch && searchValue.trim()) {
                    filteredData = [{
                        ID: "add_new",
                        Name: "Thêm mới: \"" + searchValue + "\"",
                        Icon: "plus-circle",
                        _isAddNew: true,
                        _newValue: searchValue
                    }].concat(filteredData);
                }
            }
            
            return filteredData;
        }
    });

    %ColumnName%Instance = $("<div>").appendTo($container).dxTagBox({
        dataSource: customStore,
        valueExpr: "ID",
        displayExpr: "Name",
        placeholder: "Chọn hoặc thêm %PlaceholderText%...",
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
                    $("<i>").addClass("bi bi-" + data.Icon + " me-2"),
                    $("<span>").text(data.Name)
                );
            }
            return $("<div>").addClass("d-flex align-items-center").append(
                $("<i>").addClass("bi bi-" + (data.Icon || "tag") + " me-2 text-primary"),
                $("<span>").text(data.Name)
            );
        },
        tagTemplate: function(data) {
            return $("<div>").addClass("d-flex align-items-center").append(
                $("<i>").addClass("bi bi-" + (data.Icon || "tag") + " me-1").css("font-size", "11px"),
                $("<span>").text(data.Name)
            );
        },
        onSelectionChanged: function(e) {
            const addedItems = e.addedItems || [];
            addedItems.forEach(item => {
                if (item._isAddNew) {
                    const newItem = {
                        ID: Date.now(),
                        Name: item._newValue,
                        Icon: "tag"
                    };
                    %ColumnName%DataSource.push(newItem);
                    const currentValues = e.component.option("value") || [];
                    const filteredValues = currentValues.filter(v => v !== "add_new");
                    filteredValues.push(newItem.ID);
                    e.component.option("value", filteredValues);
                    e.component.getDataSource().reload();
                    console.log("Created new tag:", newItem);
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
            const values = (e.value || []).filter(v => v !== "add_new");
            
            if (JSON.stringify(values.sort()) !== JSON.stringify(%ColumnName%OriginalValue.sort())) {
                await save%ColumnName%Value(values);
            }
            
            setTimeout(() => {
                const $element = $(e.element);
                $element.find(".dx-placeholder").css({ "top": "0", "transform": "none", "padding-top": "8px", "transition": "none" });
                $element.find(".dx-texteditor-input").css({ "padding-top": "8px", "padding-bottom": "8px" });
                $element.find(".dx-tag-container").css({ "padding-top": "4px", "padding-bottom": "4px" });
            }, 0);
        }
    }).dxTagBox("instance");
}

async function save%ColumnName%Value(newValue) {
    try {
        const dataJSON = JSON.stringify([%TableID%, ["%ColumnName%"], [newValue.join(",")]]);
        const idValues = %IDValues%;
        
        console.log("Saving %ColumnName% with IDValues:", idValues);
        console.log("Saving %ColumnName% with dataJSON:", dataJSON);
        
        const json = await saveFunction(dataJSON, idValues);
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
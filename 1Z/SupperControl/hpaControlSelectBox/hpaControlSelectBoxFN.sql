// ==================== SELECTBOX TEMPLATE (Single Select with Add New) ====================
let %ColumnName%Instance = null;
let %ColumnName%OriginalValue = null;
const %ColumnName%DataSource = [
    { ID: 1, Name: "Chưa làm", Color: "#6c757d" },
    { ID: 2, Name: "Đang làm", Color: "#0dcaf0" },
    { ID: 3, Name: "Hoàn thành", Color: "#198754" },
    { ID: 4, Name: "Tạm dừng", Color: "#ffc107" }
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
                        Color: "#198754",
                        _isAddNew: true,
                        _newValue: searchValue
                    }].concat(filteredData);
                }
            }
            
            return filteredData;
        }
    });

    %ColumnName%Instance = $("<div>").appendTo($container).dxSelectBox({
        dataSource: customStore,
        valueExpr: "ID",
        displayExpr: "Name",
        placeholder: "Chọn %PlaceholderText%...",
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
            return $("<div>").addClass("d-flex align-items-center").append(
                $("<span>").addClass("badge me-2").css({
                    backgroundColor: data.Color,
                    width: "8px",
                    height: "8px",
                    borderRadius: "50%",
                    padding: 0
                }),
                $("<span>").text(data.Name)
            );
        },
        onValueChanged: async function(e) {
            if (e.value === "add_new") {
                const selectedItem = e.component.option("selectedItem");
                if (selectedItem && selectedItem._isAddNew) {
                    const newItem = {
                        ID: Date.now(),
                        Name: selectedItem._newValue,
                        Color: "#6c757d"
                    };
                    %ColumnName%DataSource.push(newItem);
                    e.component.option("value", newItem.ID);
                    e.component.getDataSource().reload();
                    console.log("Created new item:", newItem);
                    return;
                }
            }
            
            if (e.value !== %ColumnName%OriginalValue) {
                await save%ColumnName%Value(e.value);
            }
        }
    }).dxSelectBox("instance");
}

async function save%ColumnName%Value(newValue) {
    if (newValue === %ColumnName%OriginalValue) return;

    try {
        const dataJSON = JSON.stringify([%TableID%, ["%ColumnName%"], [newValue]]);
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
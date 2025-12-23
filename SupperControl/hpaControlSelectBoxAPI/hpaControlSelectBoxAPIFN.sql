// ==================== SELECTBOX API TEMPLATE (Search + Load More + Add New) ====================
let %ColumnName%Instance = null;
let %ColumnName%OriginalValue = null;
const all%ColumnName%Data = [
    { ID: 1, Name: "Phòng IT", Manager: "Nguyễn Văn A" },
    { ID: 2, Name: "Phòng Kế toán", Manager: "Trần Thị B" },
    { ID: 3, Name: "Phòng Nhân sự", Manager: "Lê Văn C" },
    { ID: 4, Name: "Phòng Marketing", Manager: "Phạm Thị D" },
    { ID: 5, Name: "Phòng Kinh doanh", Manager: "Hoàng Văn E" }
];

function loadUI%ColumnName%() {
    const $container = $("#%ColumnName%");

    const customStore = new DevExpress.data.CustomStore({
        key: "ID",
        load: function(loadOptions) {
            const deferred = $.Deferred();
            const searchValue = loadOptions.searchValue || "";
            
            setTimeout(() => {
                let filteredData = all%ColumnName%Data;
                
                if (searchValue) {
                    const searchLower = searchValue.toLowerCase();
                    filteredData = all%ColumnName%Data.filter(item => 
                        item.Name.toLowerCase().includes(searchLower) ||
                        item.Manager.toLowerCase().includes(searchLower)
                    );
                    
                    const exactMatch = filteredData.some(item => 
                        item.Name.toLowerCase() === searchLower
                    );
                    
                    if (!exactMatch && searchValue.trim()) {
                        filteredData = [{
                            ID: "add_new",
                            Name: "Thêm mới: \"" + searchValue + "\"",
                            Manager: "",
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

    %ColumnName%Instance = $("<div>").appendTo($container).dxSelectBox({
        dataSource: customStore,
        valueExpr: "ID",
        displayExpr: "Name",
        placeholder: "Tìm và chọn %PlaceholderText%...",
        searchEnabled: true,
        searchMode: "contains",
        searchExpr: ["Name", "Manager"],
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
            return $("<div>").append(
                $("<div>").addClass("fw-semibold").text(data.Name),
                $("<div>").addClass("small text-muted").text("Quản lý: " + data.Manager)
            );
        },
        onValueChanged: async function(e) {
            if (e.value === "add_new") {
                const selectedItem = e.component.option("selectedItem");
                if (selectedItem && selectedItem._isAddNew) {
                    const newItem = {
                        ID: Date.now(),
                        Name: selectedItem._newValue,
                        Manager: ""
                    };
                    all%ColumnName%Data.push(newItem);
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
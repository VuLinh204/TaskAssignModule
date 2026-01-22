USE Paradise_Beta_Tai2
GO

-- ========================================================================
-- CONTROL 3: SELECTBOX with API (Search + Load More + Add New)
-- ========================================================================

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
    <div class="container-fluid p-4">
        <div class="card shadow-sm">
            <div class="card-header bg-white">
                <h5 class="mb-0">
                    <i class="bi bi-building text-warning me-2"></i>
                    Control 3: SelectBox with API
                </h5>
            </div>
            <div class="card-body">
                <div class="row mb-3">
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Phòng ban</label>
                        <div id="DepartmentField"></div>
                    </div>
                </div>
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
            // ==================== GLOBAL VARIABLES ====================
            let DepartmentInstance;
            let DepartmentOriginalValue = null;
            const allDepartments = [
                { ID: 1, Name: "Phòng IT", Manager: "Nguyễn Văn A" },
                { ID: 2, Name: "Phòng Kế toán", Manager: "Trần Thị B" },
                { ID: 3, Name: "Phòng Nhân sự", Manager: "Lê Văn C" },
                { ID: 4, Name: "Phòng Marketing", Manager: "Phạm Thị D" },
                { ID: 5, Name: "Phòng Kinh doanh", Manager: "Hoàng Văn E" }
            ];

            // ==================== LOAD UI ====================
            function loadUIDepartment() {
                const $container = $("#DepartmentField");

                const customStore = new DevExpress.data.CustomStore({
                    key: "ID",
                    load: function(loadOptions) {
                        const deferred = $.Deferred();
                        const searchValue = loadOptions.searchValue || "";
                        
                        setTimeout(() => {
                            let filteredData = allDepartments;
                            
                            if (searchValue) {
                                const searchLower = searchValue.toLowerCase();
                                filteredData = allDepartments.filter(item => 
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

                DepartmentInstance = $("<div>").appendTo($container).dxSelectBox({
                    dataSource: customStore,
                    valueExpr: "ID",
                    displayExpr: "Name",
                    placeholder: "Tìm và chọn phòng ban...",
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
                                const newDept = {
                                    ID: Date.now(),
                                    Name: selectedItem._newValue,
                                    Manager: ""
                                };
                                allDepartments.push(newDept);
                                e.component.option("value", newDept.ID);
                                e.component.getDataSource().reload();
                                console.log("Created new department:", newDept);
                                return;
                            }
                        }
                        
                        if (e.value !== DepartmentOriginalValue) {
                            await saveDepartmentValue(e.value);
                        }
                    }
                }).dxSelectBox("instance");
            }

            function loadUI() {
                loadUIDepartment();
            }

            // ==================== SAVE ====================
            async function saveDepartmentValue(newValue) {
                if (newValue === DepartmentOriginalValue) return;

                try {
                    const dataJSON = JSON.stringify([-99218308, ["DepartmentID"], [newValue]]);
                    const idValues = [[1], "TaskID"];
                    
                    const json = await saveFunction(dataJSON, idValues);
                    DepartmentOriginalValue = newValue;
                    
                    console.log("Saved Department:", newValue);
                } catch (err) {
                    console.error("Save error:", err);
                }
            }

            // ==================== LOAD DATA ====================
            function loadData() {
                setTimeout(() => {
                    const obj = { DepartmentID: 1 };
                    
                    DepartmentOriginalValue = obj.DepartmentID;
                    DepartmentInstance.option("value", obj.DepartmentID);
                }, 100);
            }

            // ==================== INIT ====================
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
USE Paradise_Beta_Tai2
GO

-- ========================================================================
-- CONTROL 1: SELECTBOX (Single Select with Add New)
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
                    <i class="bi bi-check-circle text-success me-2"></i>
                    Control 1: SelectBox (Single Select)
                </h5>
            </div>
            <div class="card-body">
                <div class="row mb-3">
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Trạng thái</label>
                        <div id="StatusField"></div>
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
            let StatusInstance;
            let StatusOriginalValue = null;
            const dataSource = [
                { ID: 1, Name: "Chưa làm", Color: "#6c757d" },
                { ID: 2, Name: "Đang làm", Color: "#0dcaf0" },
                { ID: 3, Name: "Hoàn thành", Color: "#198754" },
                { ID: 4, Name: "Tạm dừng", Color: "#ffc107" }
            ];

            // ==================== LOAD UI ====================
            function loadUIStatus() {
                const $container = $("#StatusField");
                
                const customStore = new DevExpress.data.CustomStore({
                    key: "ID",
                    load: function(loadOptions) {
                        const searchValue = loadOptions.searchValue || "";
                        let filteredData = dataSource;
                        
                        if (searchValue) {
                            const searchLower = searchValue.toLowerCase();
                            filteredData = dataSource.filter(item => 
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

                StatusInstance = $("<div>").appendTo($container).dxSelectBox({
                    dataSource: customStore,
                    valueExpr: "ID",
                    displayExpr: "Name",
                    placeholder: "Chọn trạng thái...",
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
                                dataSource.push(newItem);
                                e.component.option("value", newItem.ID);
                                e.component.getDataSource().reload();
                                console.log("Created new status:", newItem);
                                return;
                            }
                        }
                        
                        if (e.value !== StatusOriginalValue) {
                            await saveStatusValue(e.value);
                        }
                    }
                }).dxSelectBox("instance");
            }

            function loadUI() {
                loadUIStatus();
            }

            // ==================== SAVE ====================
            async function saveStatusValue(newValue) {
                if (newValue === StatusOriginalValue) return;

                try {
                    const dataJSON = JSON.stringify([-99218308, ["Status"], [newValue]]);
                    const idValues = [[1], "TaskID"]; // Replace with actual ID
                    
                    const json = await saveFunction(dataJSON, idValues);
                    StatusOriginalValue = newValue;
                    
                    console.log("Saved Status:", newValue);
                } catch (err) {
                    console.error("Save error:", err);
                }
            }

            // ==================== LOAD DATA ====================
            function loadData() {
                // Simulate loading data from API
                setTimeout(() => {
                    const obj = { Status: 2 }; // Sample data
                    
                    StatusOriginalValue = obj.Status;
                    StatusInstance.option("value", obj.Status);
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
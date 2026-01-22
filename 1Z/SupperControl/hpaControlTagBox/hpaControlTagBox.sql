USE Paradise_Beta_Tai2
GO

-- ========================================================================
-- CONTROL 2: TAGBOX (Multi Select with Add New)
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
                    <i class="bi bi-tags text-info me-2"></i>
                    Control 2: TagBox (Multi Select)
                </h5>
            </div>
            <div class="card-body">
                <div class="row mb-3">
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Tags</label>
                        <div id="TagsField"></div>
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
            let TagsInstance;
            let TagsOriginalValue = [];
            const tagsDataSource = [
                { ID: 1, Name: "Frontend", Icon: "code-slash" },
                { ID: 2, Name: "Backend", Icon: "server" },
                { ID: 3, Name: "Database", Icon: "database" },
                { ID: 4, Name: "DevOps", Icon: "gear" },
                { ID: 5, Name: "UI/UX", Icon: "palette" }
            ];

            // ==================== LOAD UI ====================
            function loadUITags() {
                const $container = $("#TagsField");

                const customStore = new DevExpress.data.CustomStore({
                    key: "ID",
                    load: function(loadOptions) {
                        const searchValue = loadOptions.searchValue || "";
                        let filteredData = tagsDataSource;
                        
                        if (searchValue) {
                            const searchLower = searchValue.toLowerCase();
                            filteredData = tagsDataSource.filter(item => 
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

                TagsInstance = $("<div>").appendTo($container).dxTagBox({
                    dataSource: customStore,
                    valueExpr: "ID",
                    displayExpr: "Name",
                    placeholder: "Chọn hoặc thêm tags...",
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
                                const newTag = {
                                    ID: Date.now(),
                                    Name: item._newValue,
                                    Icon: "tag"
                                };
                                tagsDataSource.push(newTag);
                                const currentValues = e.component.option("value") || [];
                                const filteredValues = currentValues.filter(v => v !== "add_new");
                                filteredValues.push(newTag.ID);
                                e.component.option("value", filteredValues);
                                e.component.getDataSource().reload();
                                console.log("Created new tag:", newTag);
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
                        
                        if (JSON.stringify(values.sort()) !== JSON.stringify(TagsOriginalValue.sort())) {
                            await saveTagsValue(values);
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

            function loadUI() {
                loadUITags();
            }

            // ==================== SAVE ====================
            async function saveTagsValue(newValue) {
                try {
                    const dataJSON = JSON.stringify([-99218308, ["Tags"], [newValue.join(",")]]);
                    const idValues = [[1], "TaskID"];
                    
                    const json = await saveFunction(dataJSON, idValues);
                    TagsOriginalValue = newValue;
                    
                    console.log("Saved Tags:", newValue);
                } catch (err) {
                    console.error("Save error:", err);
                }
            }

            // ==================== LOAD DATA ====================
            function loadData() {
                setTimeout(() => {
                    const obj = { Tags: [1, 3, 5] };
                    
                    TagsOriginalValue = obj.Tags;
                    TagsInstance.option("value", obj.Tags);
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
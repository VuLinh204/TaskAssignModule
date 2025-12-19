USE Paradise_Beta_Tai2
GO

-- =====================================================
-- NO AutoSave với TEXTAREA (Type 2) - Batch Save
-- =====================================================
IF OBJECT_ID('[dbo].[sp_Task_MyWork_html]') IS NULL
    EXEC ('CREATE PROCEDURE [dbo].[sp_Task_MyWork_html] AS SELECT 1')
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
        <style>
            body {
                padding: 40px;
                font-family: system-ui, -apple-system, sans-serif;
                padding-bottom: 200px;
                background: #fff3e0;
            }
            h2 { 
                color: #e65100; 
            }
            .table {
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
                table-layout: fixed;
                width: 100%;
                border-collapse: separate;
                border-spacing: 0;
            }
            th.col-id { 
                width: 80px; 
            }
            th.col-desc { 
                width: calc(100% - 80px); 
            }
            .hpa-editable-row.editing {
                box-shadow: 0 0 0 2px rgba(230, 81, 0, 0.5) !important;
            }
        </style>
        
        <h2 class="mb-4">Không AutoSave - Type 2 (Textarea cho mô tả dài)</h2>
        <p>Sửa nhiều dòng mô tả → bấm "Lưu tất cả" để áp dụng batch</p>

        <button id="saveAll" class="btn btn-warning btn-lg mb-4">Lưu tất cả thay đổi</button>
        <button id="clearChanges" class="btn btn-secondary btn-lg mb-4 ms-2">Hủy thay đổi</button>

        <table class="table table-bordered table-hover align-middle">
            <thead class="table-warning">
                <tr>
                    <th class="col-id">ID</th>
                    <th class="col-desc">Mô tả chi tiết (textarea)</th>
                </tr>
            </thead>
            <tbody id="taskBody"></tbody>
        </table>

        <div class="mt-5">
            <h5>Dữ liệu mẫu hiện tại:</h5>
            <pre id="dataPreview" class="p-3 rounded shadow-sm bg-white"></pre>
        </div>

        <script>
            // ==================== PENDING CHANGES ====================
            let pendingChanges = {};

            // ==================== LOAD DATA ====================
            function loadData() {
                AjaxHPAParadise({
                    data: { 
                        name: "sp_Task_GetAllTasks", 
                        param: [] 
                    },
                    success: function(res) {
                        const json = typeof res === "string" ? JSON.parse(res) : res;
                        const results = (json.data && json.data[0]) || [];
                        let tasks = results.map(item => ({
                            TaskID: item.TaskID,
                            Description: item.Description
                        }));
                        renderTasks(tasks);
                    }
                });
            }

            // ==================== RENDER TASKS ====================
            function renderTasks(tasks) {
                const $body = $("#taskBody").empty();
                tasks.forEach((task) => {
                    const row = `
                    <tr>
                        <td class="text-center text-muted">${task.TaskID}</td>
                        <td class="editable position-relative" data-id="${task.TaskID}" data-col="Description">
                            <div class="editable-content">${task.Description || ""}</div>
                            <template class="editFormTemplate" onclick="hpaControlEditTableRowNoAutoSave(event)" 
                                style="display: block; position: absolute; inset: 0; height: 100%; z-index: 1; cursor: pointer;">
                                <div class="position-relative w-100">
                                    <textarea class="form-control form-control-sm edit-input w-100 rounded py-1 px-2" rows="5"
                                        style="display: none; border: 1px solid #ef6c00 !important; min-height: 100px; font-size: inherit;" 
                                        oninput="hpaControlEditTableRowNoAutoSave(event)" 
                                        onkeydown="hpaControlEditTableRowNoAutoSave(event)"></textarea>
                                    <div class="edit-actions" 
                                        style="position: absolute; top: 110%; right: 0; display: flex; gap: 4px; z-index: 100; padding: 6px 8px; background: white; border: 1px solid #ddd; border-radius: 6px; box-shadow: 0 4px 15px rgba(0,0,0,.15);">
                                        <button type="button" class="btn-save btn btn-sm" onclick="hpaControlEditTableRowNoAutoSave(event)" 
                                            style="width: 28px; height: 28px; padding: 0; display: inline-flex; align-items: center; justify-content: center; border-radius: 4px !important; background: #ef6c00; color: white; cursor: pointer; border: 1px solid #e8eaed;" 
                                            title="OK"><i class="bi bi-check-lg"></i></button>
                                        <button type="button" class="btn-cancel btn btn-sm" onclick="hpaControlEditTableRowNoAutoSave(event)" 
                                            style="width: 28px; height: 28px; padding: 0; display: inline-flex; align-items: center; justify-content: center; border-radius: 4px !important; cursor: pointer; border: 1px solid #e8eaed; color: #676879;" 
                                            title="Hủy"><i class="bi bi-x-lg"></i></button>
                                    </div>
                                </div>
                            </template>
                        </td>
                    </tr>`;
                    $body.append(row);
                });
                updatePreview(tasks);
            }

            function updatePreview(tasks) {
                $("#dataPreview").text(JSON.stringify(tasks, null, 2));
            }

            // ==================== CONFIG ====================
            window.hpaControlEditConfig = { 
                tableSN: "-1233093056", 
                idColumnName: "TaskID", 
                autoSave: false 
            };

            // ==================== BUTTON: SAVE ALL ====================
            $("#saveAll").click(() => {
                if (Object.keys(pendingChanges).length === 0) {
                    return alert("Không có thay đổi nào!");
                }
                
                let completed = 0;
                const total = Object.keys(pendingChanges).length;
                
                Object.keys(pendingChanges).forEach((id) => {
                    const changes = pendingChanges[id];
                    const columns = Object.keys(changes);
                    const values = columns.map(col => changes[col]);
                    
                    saveDataTableCommon({
                        tableSN: window.hpaControlEditConfig.tableSN,
                        columns: columns,
                        values: values,
                        idValue: id,
                        idColumnName: window.hpaControlEditConfig.idColumnName,
                        onSuccess: function() {
                            completed++;
                            if (completed === total) {
                                alert("Đã lưu batch tất cả mô tả!");
                                pendingChanges = {};
                                loadData();
                            }
                        },
                        onError: function(msg) {
                            alert("Lỗi: " + msg);
                        }
                    });
                });
            });

            // ==================== BUTTON: CLEAR CHANGES ====================
            $("#clearChanges").click(() => {
                if (Object.keys(pendingChanges).length === 0) {
                    return alert("Không có thay đổi để hủy!");
                }
                pendingChanges = {};
                loadData();
                alert("Đã hủy tất cả thay đổi.");
            });

            // ==================== INIT ====================
            $(document).ready(loadData);
        </script>
    ';
    SELECT @html AS html;
END
GO

-- Generate HTML Script
EXEC sp_GenerateHTMLScript 'sp_Task_MyWork_html'
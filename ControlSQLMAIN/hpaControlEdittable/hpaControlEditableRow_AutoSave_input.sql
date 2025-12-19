USE Paradise_Beta_Tai2
GO

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
                padding-bottom: 200px; /* Tăng padding bottom để không bị che khi edit dòng cuối */
            }
            h2 {
                color: #155724;
            }
            .table {
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
                table-layout: fixed;
                width: 100%;
                border-collapse: separate; /* Giúp z-index hoạt động tốt hơn trên tr/td */
                border-spacing: 0;
            }
            pre {
                border: 1px solid #dee2e6;
            }
            th.col-id { width: 80px; }
            th.col-name { width: 30%; }
            th.col-desc { width: 45%; }
            th.col-status { width: 25%; }

            /* Style cho ô đang edit */
            .hpa-editable-row.editing {
                box-shadow: 0 0 0 2px rgba(28, 151, 94, 0.5) !important;
            }
        </style>
        
        <table class="table table-bordered table-hover align-middle">
            <thead class="table-success">
                <tr>
                    <th class="col-id">ID</th>
                    <th class="col-name">Tên Task</th>
                    <th class="col-desc">Mô tả</th>
                    <th class="col-status">Trạng thái</th>
                </tr>
            </thead>
            <tbody id="taskBody"></tbody>
        </table>

        <div class="mt-5">
            <h5>Dữ liệu mẫu hiện tại (cập nhật real-time):</h5>
            <pre id="dataPreview" class="p-3 rounded shadow-sm"></pre>
        </div>

        <script>
            // ==================== DỮ LIỆU MẪU ====================
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
                            TaskName: item.TaskName,
                            Unit: item.Unit
                        }));
                        window.hpaControlEditConfig = window.hpaControlEditConfig || { tableSN: "-1233093056", columnNameSN: "TaskName", idColumnSN: "TaskID" };
                        renderTasks(tasks);
                    }
                });
            }

            let nextId = 5;

            // ==================== RENDER ====================
            function renderTasks(tasks) {
                const $body = $("#taskBody").empty();
                tasks.forEach((task) => {
                    const row = `
                    <tr>
                        <td class="text-center text-muted">${task.TaskID || ""}</td>
                        
                        <!-- QUAN TRỌNG: Thêm onclick vào td để click là nhận -->
                        <td class="editable position-relative" data-id="${task.TaskID}">
                            <div class="editable-content">${task.TaskName || ""}</div>
                            <template class="editFormTemplate" onclick="hpaControlEditTableRowAutoSave(event, window.hpaControlEditConfig.tableSN, window.hpaControlEditConfig.columnNameSN, window.hpaControlEditConfig.idColumnSN)" style="display: block; position: absolute; inset: 0; height: 100%; z-index: 1; cursor: pointer;">
                                <div class="position-relative w-100">
                                    <input type="text" class="form-control form-control-sm edit-input w-100 rounded py-1 px-2" 
                                        style="display: none; border: 1px solid #1c975e !important;" 
                                        oninput="hpaControlEditTableRowAutoSave(event, window.hpaControlEditConfig.tableSN, window.hpaControlEditConfig.columnNameSN, window.hpaControlEditConfig.idColumnSN)" 
                                        onkeydown="hpaControlEditTableRowAutoSave(event, window.hpaControlEditConfig.tableSN, window.hpaControlEditConfig.columnNameSN, window.hpaControlEditConfig.idColumnSN)">
                                    <div class="edit-actions" style="position: absolute; top: 110%; right: 0; display: flex; justify-content: flex-end; gap: 4px; align-items: center; z-index: 100; padding: 6px 8px; border-radius: 6px; box-shadow: 0 4px 15px rgba(0,0,0,0.15);">
                                        <button type="button" class="btn-save btn btn-sm" onclick="hpaControlEditTableRowAutoSave(event, window.hpaControlEditConfig.tableSN, window.hpaControlEditConfig.columnNameSN, window.hpaControlEditConfig.idColumnSN)" style="width: 28px; height: 28px; padding: 0; display: inline-flex; align-items: center; justify-content: center; border-radius: 4px !important; border: 1px solid #e8eaed; background: #2E7D32; color: white; cursor: pointer; transition: all 0.2s; font-size: 14px;" title="Lưu"><i class="bi bi-check-lg"></i></button>
                                        <button type="button" class="btn-cancel btn btn-sm" onclick="hpaControlEditTableRowAutoSave(event, window.hpaControlEditConfig.tableSN, window.hpaControlEditConfig.columnNameSN, window.hpaControlEditConfig.idColumnSN)" style="width: 28px; height: 28px; padding: 0; display: inline-flex; align-items: center; justify-content: center; border-radius: 4px !important; border: 1px solid #e8eaed; backdrop-filter: blur(50px); cursor: pointer; transition: all 0.2s; font-size: 14px;" title="Hủy"><i class="bi bi-x-lg"></i></button>
                                    </div>
                                </div>
                            </template>
                        </td>
                        
                        <td class="editable position-relative" data-id="${task.TaskID}">
                            <div class="editable-content">${task.Unit || ""}</div>
                            <template class="editFormTemplate" onclick="hpaControlEditTableRowAutoSave(event, window.hpaControlEditConfig.tableSN, window.hpaControlEditConfig.columnNameSN, window.hpaControlEditConfig.idColumnSN)" style="display: block; position: absolute; inset: 0; height: 100%; z-index: 1; cursor: pointer;">
                                <div class="position-relative w-100">
                                    <input type="text" class="form-control form-control-sm edit-input w-100 rounded py-1 px-2" 
                                        style="display: none; border: 1px solid #1c975e !important;" 
                                        oninput="hpaControlEditTableRowAutoSave(event, window.hpaControlEditConfig.tableSN, window.hpaControlEditConfig.columnNameSN, window.hpaControlEditConfig.idColumnSN)" 
                                        onkeydown="hpaControlEditTableRowAutoSave(event, window.hpaControlEditConfig.tableSN, window.hpaControlEditConfig.columnNameSN, window.hpaControlEditConfig.idColumnSN)">
                                    <div class="edit-actions" style="position: absolute; top: 110%; right: 0; display: flex; justify-content: flex-end; gap: 4px; align-items: center; z-index: 100; padding: 6px 8px; border-radius: 6px; box-shadow: 0 4px 15px rgba(0,0,0,0.15);">
                                        <button type="button" class="btn-save btn btn-sm" onclick="hpaControlEditTableRowAutoSave(event, window.hpaControlEditConfig.tableSN, window.hpaControlEditConfig.columnNameSN, window.hpaControlEditConfig.idColumnSN)" style="width: 28px; height: 28px; padding: 0; display: inline-flex; align-items: center; justify-content: center; border-radius: 4px !important; border: 1px solid #e8eaed; background: #2E7D32; color: white; cursor: pointer; transition: all 0.2s; font-size: 14px;" title="Lưu"><i class="bi bi-check-lg"></i></button>
                                        <button type="button" class="btn-cancel btn btn-sm" onclick="hpaControlEditTableRowAutoSave(event, window.hpaControlEditConfig.tableSN, window.hpaControlEditConfig.columnNameSN, window.hpaControlEditConfig.idColumnSN)" style="width: 28px; height: 28px; padding: 0; display: inline-flex; align-items: center; justify-content: center; border-radius: 4px !important; border: 1px solid #e8eaed; backdrop-filter: blur(50px); cursor: pointer; transition: all 0.2s; font-size: 14px;" title="Hủy"><i class="bi bi-x-lg"></i></button>
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

            // ==================== HÀM XỬ LÝ CHÍNH ====================
            // Global defaults for the edit handler; can be overridden by passing options
            window.hpaControlEditConfig = window.hpaControlEditConfig || { tableSN: "-1233093056", columnNameSN: "TaskName", idColumnSN: "TaskID" };

            $(document).ready(loadData);
        </script>
    ';
    SELECT @html AS html;
END
GO
EXEC sp_GenerateHTML 'sp_Task_MyWork_html'
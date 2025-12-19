USE Paradise_Beta_Tai2
GO

-- =====================================================
-- 1. AutoSave với TEXTAREA (Type 2)
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
                background: #e8f5e9;
            }
            h2 { color: #2e7d32; }
            .table {
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
                table-layout: fixed;
                width: 100%;
                border-collapse: separate;
                border-spacing: 0;
            }
            th.col-id { width: 80px; }
            th.col-desc { width: 100%; }
            .hpa-editable-row.editing {
                box-shadow: 0 0 0 2px rgba(46, 125, 50, 0.5) !important;
            }
        </style>
        
        <h2 class="mb-4">AutoSave - Type 2 (Textarea cho mô tả dài)</h2>

        <table class="table table-bordered table-hover align-middle">
            <thead class="table-success">
                <tr>
                    <th class="col-id">ID</th>
                    <th class="col-desc">Mô tả chi tiết</th>
                </tr>
            </thead>
            <tbody id="taskBody"></tbody>
        </table>

        <pre id="dataPreview" class="mt-5 p-3 rounded shadow-sm"></pre>

        <script>
            function loadData() {
                AjaxHPAParadise({
                    data: { name: "sp_Task_GetAllTasks", param: [] },
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

            function renderTasks(tasks) {
                const $body = $("#taskBody").empty();
                tasks.forEach((task) => {
                    const row = `
                    <tr>
                        <td class="text-center text-muted">${task.TaskID || ""}</td>
                        <td class="editable position-relative" data-id="${task.TaskID}" data-col="Description">
                            <div class="editable-content">${task.Description || ""}</div>
                            <template class="editFormTemplate" onclick="hpaControlEditTableRowAutoSave(event)" style="display: block; position: absolute; inset: 0; height: 100%; z-index: 1; cursor: pointer;">
                                <div class="position-relative w-100">
                                    <textarea class="form-control form-control-sm edit-input w-100 rounded py-1 px-2" rows="4"
                                        style="display: none; border: 1px solid #2e7d32 !important; min-height: 80px;" 
                                        oninput="hpaControlEditTableRowAutoSave(event)" 
                                        onkeydown="hpaControlEditTableRowAutoSave(event)"></textarea>
                                    <div class="edit-actions" style="position: absolute; top: 110%; right: 0; display: flex; justify-content: flex-end; gap: 4px; z-index: 100; padding: 6px 8px; border: 1px solid #ddd; border-radius: 6px;">
                                        <button type="button" class="btn-save btn btn-sm" onclick="hpaControlEditTableRowAutoSave(event)" style="width: 28px; height: 28px; padding: 0; display: inline-flex; align-items: center; justify-content: center; border-radius: 4px !important; background: #2e7d32; color: white; cursor: pointer; border: 1px solid #e8eaed;" title="Lưu"><i class="bi bi-check-lg"></i></button>
                                        <button type="button" class="btn-cancel btn btn-sm" onclick="hpaControlEditTableRowAutoSave(event)" style="width: 28px; height: 28px; padding: 0; display: inline-flex; align-items: center; justify-content: center; border-radius: 4px !important; cursor: pointer; border: 1px solid #e8eaed;" title="Hủy"><i class="bi bi-x-lg"></i></button>
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

            window.hpaControlEditConfig = { tableSN: "-1233093056", idColumnName: "TaskID" };

            $(document).ready(loadData);
        </script>
    ';
    SELECT @html AS html;
END
GO
EXEC sp_GenerateHTMLScript 'sp_Task_MyWork_html'

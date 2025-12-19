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
                            Description: item.Description,
                            Status: item.Status
                        }));
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
                        <td class="editable position-relative" data-id="${task.TaskID}" data-col="TaskName">
                            <div class="editable-content">${task.TaskName || ""}</div>
                            <template class="editFormTemplate" onclick="hpaControlEditTableRowAutoSave(event)" style="display: block; position: absolute; inset: 0; height: 100%; z-index: 1; cursor: pointer;">
                                <div class="position-relative w-100">
                                    <input type="text" class="form-control form-control-sm edit-input w-100 rounded py-1 px-2" 
                                        style="display: none; border: 1px solid #1c975e !important;" 
                                        oninput="hpaControlEditTableRowAutoSave(event)" 
                                        onkeydown="hpaControlEditTableRowAutoSave(event)">
                                    <div class="edit-actions" style="position: absolute; top: 110%; right: 0; display: flex; justify-content: flex-end; gap: 4px; align-items: center; z-index: 100; padding: 6px 8px; border-radius: 6px; box-shadow: 0 4px 15px rgba(0,0,0,0.15);">
                                        <button type="button" class="btn-save btn btn-sm" onclick="hpaControlEditTableRowAutoSave(event)" style="width: 28px; height: 28px; padding: 0; display: inline-flex; align-items: center; justify-content: center; border-radius: 4px !important; border: 1px solid #e8eaed; background: #2E7D32; color: white; cursor: pointer; transition: all 0.2s; font-size: 14px;" title="Lưu"><i class="bi bi-check-lg"></i></button>
                                        <button type="button" class="btn-cancel btn btn-sm" onclick="hpaControlEditTableRowAutoSave(event)" style="width: 28px; height: 28px; padding: 0; display: inline-flex; align-items: center; justify-content: center; border-radius: 4px !important; border: 1px solid #e8eaed; backdrop-filter: blur(50px); cursor: pointer; transition: all 0.2s; font-size: 14px;" title="Hủy"><i class="bi bi-x-lg"></i></button>
                                    </div>
                                </div>
                            </template>
                        </td>
                        
                        <td class="editable position-relative" data-id="${task.TaskID}" data-col="Description">
                            <div class="editable-content">${task.Description || ""}</div>
                            <template class="editFormTemplate" onclick="hpaControlEditTableRowAutoSave(event)" style="display: block; position: absolute; inset: 0; height: 100%; z-index: 1; cursor: pointer;">
                                <div class="position-relative w-100">
                                    <input type="text" class="form-control form-control-sm edit-input w-100 rounded py-1 px-2" 
                                        style="display: none; border: 1px solid #1c975e !important;" 
                                        oninput="hpaControlEditTableRowAutoSave(event)" 
                                        onkeydown="hpaControlEditTableRowAutoSave(event)">
                                    <div class="edit-actions" style="position: absolute; top: 110%; right: 0; display: flex; justify-content: flex-end; gap: 4px; align-items: center; z-index: 100; padding: 6px 8px; border-radius: 6px; box-shadow: 0 4px 15px rgba(0,0,0,0.15);">
                                        <button type="button" class="btn-save btn btn-sm" onclick="hpaControlEditTableRowAutoSave(event)" style="width: 28px; height: 28px; padding: 0; display: inline-flex; align-items: center; justify-content: center; border-radius: 4px !important; border: 1px solid #e8eaed; background: #2E7D32; color: white; cursor: pointer; transition: all 0.2s; font-size: 14px;" title="Lưu"><i class="bi bi-check-lg"></i></button>
                                        <button type="button" class="btn-cancel btn btn-sm" onclick="hpaControlEditTableRowAutoSave(event)" style="width: 28px; height: 28px; padding: 0; display: inline-flex; align-items: center; justify-content: center; border-radius: 4px !important; border: 1px solid #e8eaed; backdrop-filter: blur(50px); cursor: pointer; transition: all 0.2s; font-size: 14px;" title="Hủy"><i class="bi bi-x-lg"></i></button>
                                    </div>
                                </div>
                            </template>
                        </td>
                        
                        <td class="editable position-relative" data-id="${task.TaskID}" data-col="Status">
                            <div class="editable-content">${task.Status || ""}</div>
                            <template class="editFormTemplate" onclick="hpaControlEditTableRowAutoSave(event)" style="display: block; position: absolute; inset: 0; height: 100%; z-index: 1; cursor: pointer;">
                                <div class="position-relative w-100">
                                    <input type="text" class="form-control form-control-sm edit-input w-100 rounded py-1 px-2" 
                                        style="display: none; border: 1px solid #1c975e !important;" 
                                        oninput="hpaControlEditTableRowAutoSave(event)" 
                                        onkeydown="hpaControlEditTableRowAutoSave(event)">
                                    <div class="edit-actions" style="position: absolute; top: 110%; right: 0; display: flex; justify-content: flex-end; gap: 4px; align-items: center; z-index: 100; padding: 6px 8px; border-radius: 6px; box-shadow: 0 4px 15px rgba(0,0,0,0.15);">
                                        <button type="button" class="btn-save btn btn-sm" onclick="hpaControlEditTableRowAutoSave(event)" style="width: 28px; height: 28px; padding: 0; display: inline-flex; align-items: center; justify-content: center; border-radius: 4px !important; border: 1px solid #e8eaed; background: #2E7D32; color: white; cursor: pointer; transition: all 0.2s; font-size: 14px;" title="Lưu"><i class="bi bi-check-lg"></i></button>
                                        <button type="button" class="btn-cancel btn btn-sm" onclick="hpaControlEditTableRowAutoSave(event)" style="width: 28px; height: 28px; padding: 0; display: inline-flex; align-items: center; justify-content: center; border-radius: 4px !important; border: 1px solid #e8eaed; backdrop-filter: blur(50px); cursor: pointer; transition: all 0.2s; font-size: 14px;" title="Hủy"><i class="bi bi-x-lg"></i></button>
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

            // Generic save helper using sp_Common_SaveDataTable
            function saveDataTableCommon(config) {
                const {
                    tableSN,
                    columns,
                    values,
                    types = [],
                    idValue = null,
                    idColumnName = "ID",
                    onSuccess = null,
                    onError = null,
                } = config;

                if (!columns || columns.length === 0) {
                    if (onError) onError("Thiếu columns");
                    return;
                }

                const fullTypes = columns.map((_, i) => types[i] || "text");
                const dataJSON = JSON.stringify([tableSN, columns, values.map((v) => String(v || "")), fullTypes]);

                let idValuesJSON = null;
                if (idValue !== null && idValue !== undefined && String(idValue).trim() !== "") {
                    idValuesJSON = JSON.stringify([[String(idValue)], idColumnName]);
                }

                AjaxHPAParadise({
                    data: {
                        name: "sp_Common_SaveDataTable",
                        param: [
                            "LoginID",
                            window.LoginID || 0,
                            "LanguageID",
                            typeof LanguageID !== "undefined" ? LanguageID : "VN",
                            "DataJSON",
                            dataJSON,
                            "IDValues",
                            idValuesJSON,
                        ],
                    },
                    success: function (res) {
                        try {
                            const json = typeof res === "string" ? JSON.parse(res) : res;
                            const results = (json.data && json.data[0]) || [];
                            const errorRow = results.find((r) => r.Status === "ERROR");
                            if (errorRow) {
                                if (onError) onError(errorRow.Message || "Lưu thất bại");
                                return;
                            }
                            const newIdRow = results.find((r) => !idValue && r.IDValue);
                            const returnedId = newIdRow ? newIdRow.IDValue : idValue;
                            if (onSuccess) onSuccess(returnedId);
                        } catch (e) {
                            console.error("Parse response error:", e);
                            if (onError) onError("Parse kết quả lỗi");
                        }
                    },
                    error: function () {
                        if (onError) onError("Lỗi kết nối");
                    },
                });
            }

            // ==================== HÀM XỬ LÝ CHÍNH ====================
            // Global defaults for the edit handler; can be overridden by passing options
            window.hpaControlEditConfig = window.hpaControlEditConfig || { tableSN: "-1233093056", idColumnName: "TaskID" };

            // Main handler: accepts an event and optional options object to override defaults
            function hpaControlEditTableRowAutoSave(event, options) {
                options = $.extend({}, window.hpaControlEditConfig || {}, options || {});
                event.stopPropagation();

                let $el = $(event.target).closest(".editable");
                const $editingCell = $(".hpa-editable-row.editing");

                // CLICK NGOÀI: Đóng form
                if ($editingCell.length > 0 && $el.length === 0) {
                    const $content = $editingCell.find(".editable-content");
                    const curVal = $editingCell.data("original-value") || "";
                    $content.show().text(curVal);
                    _hpa_close_editing($editingCell);
                    $(document).off("click.hpaEdit");
                    return;
                }

                if ($el.length === 0) return;

                // TRƯỜNG HỢP 1: CLICK ĐỂ MỞ EDIT (Khi chưa edit hoặc click sang ô khác)
                // Logic: Click vào td hoặc template nhưng chưa có class .editing hoặc click sang ô mới
                const isClickOnNewCell = !$el.hasClass("editing");
                
                if (isClickOnNewCell) {
                    // Đóng ô cũ trước
                    if ($editingCell.length > 0) {
                        $editingCell.find(".editable-content").show();
                        _hpa_close_editing($editingCell);
                    }

                    if (!$el.hasClass("hpa-editable-row")) {
                        $el.addClass("hpa-editable-row control-editable cursor-pointer d-table-cell align-middle w-100");
                    }

                    const $content = $el.find(".editable-content");
                    const $template = $el.find(".editFormTemplate");
                    const curVal = $el.text().trim();

                    // Render Form
                    $content.hide();
                    $el.append($template.html());
                    
                    const $input = $el.find(".edit-input");
                    $input.val(curVal).show();

                    let isAddMode = false;
                    let recordId = $el.data("id");

                    // Lưu state
                    $el.data("original-value", curVal);
                    $el.data("is-add-mode", isAddMode);
                    $el.data("record-id", recordId);

                    // QUAN TRỌNG: Set z-index cực cao (9999) để nổi lên trên các dòng dưới
                    $el.addClass("editing").css({ 
                        padding: "4px 8px", 
                        zIndex: 9999,
                        display: "table-cell",
                        position: "relative" // Đảm bảo z-index ăn
                    });

                    // Xử lý vị trí popup nếu sát đáy màn hình
                    const $actions = $el.find(".edit-actions");
                    const rect = $el[0].getBoundingClientRect();
                    const spaceBelow = window.innerHeight - rect.bottom;
                    if (spaceBelow < 60) {
                        $actions.css({ top: "auto", bottom: "100%", marginBottom: "5px" });
                    }

                    // Đăng ký event click ngoài (đảm bảo truyền options hiện tại)
                    $(document).off("click.hpaEdit").on("click.hpaEdit", function(e){
                        hpaControlEditTableRowAutoSave(e, options);
                    });

                    // Lưu options trên cell để có thể truy xuất nếu cần
                    $el.data("hpaOptions", options);

                    // Focus input
                    setTimeout(() => {
                        const inputEl = $input[0];
                        if(inputEl) {
                            inputEl.focus();
                            inputEl.setSelectionRange(inputEl.value.length, inputEl.value.length);
                        }
                    }, 50);

                    return;
                }

                // TRƯỜNG HỢP 2: XỬ LÝ SỰ KIỆN TRONG FORM (INPUT, SAVE, CANCEL)
                if (!$el.hasClass("editing")) return;

                const $input = $el.find(".edit-input");

                if (event.type === "click") {
                    const $target = $(event.target).closest("button");
                    if ($target.hasClass("btn-save")) {
                        // ---> SAVE
                        const newVal = $input.val().trim();
                        const curVal = $el.data("original-value") || "";
                        const isAddMode = $el.data("is-add-mode") || false;
                        let recordId = $el.data("record-id");

                        if (newVal !== curVal || isAddMode) {
                            $el.find(".editable-content").text("Đang lưu...");

                            const col = $el.data("col");
                            const currentId = recordId || $el.data("id");

                            // Use common save helper; tableSN/idColumnName come from options or global defaults
                            saveDataTableCommon({
                                tableSN: options.tableSN,
                                columns: [col],
                                values: [newVal],
                                idValue: currentId,
                                idColumnName: options.idColumnName,
                                onSuccess: function(returnedId) {
                                    $(document).off("click.hpaEdit");
                                    // Refresh data from server
                                    loadData();
                                },
                                onError: function() {
                                    $el.find(".editable-content").show().text(curVal);
                                    _hpa_close_editing($el);
                                    $(document).off("click.hpaEdit");
                                }
                            });
                        } else {
                            // Không đổi gì -> đóng
                            $el.find(".editable-content").show().text(curVal);
                            _hpa_close_editing($el);
                            $(document).off("click.hpaEdit");
                        }
                    } else if ($target.hasClass("btn-cancel")) {
                        // ---> CANCEL
                        const curVal = $el.data("original-value") || "";
                        $el.find(".editable-content").show().text(curVal);
                        _hpa_close_editing($el);
                        $(document).off("click.hpaEdit");
                    }
                } else if (event.type === "keydown") {
                    if (event.key === "Enter") {
                        event.preventDefault();
                        $el.find(".btn-save").trigger("click");
                    }
                    if (event.key === "Escape") {
                        event.preventDefault();
                        $el.find(".btn-cancel").trigger("click");
                    }
                } else if (event.type === "input") {
                    // Logic đổi icon nút save khi nhập liệu (cho dòng thêm mới)
                    const isEmpty = $input.val().trim().length === 0;
                    let isAddMode = $el.data("is-add-mode") || false;

                    if (isEmpty && !isAddMode) {
                        isAddMode = true;
                        $el.data("is-add-mode", true);
                        $el.find(".btn-save").html(`<i class="bi bi-plus-lg"></i>`).attr("title", "Thêm mới");
                    } else if (!isEmpty && isAddMode) {
                        isAddMode = false;
                        $el.data("is-add-mode", false);
                        $el.find(".btn-save").html(`<i class="bi bi-check-lg"></i>`).attr("title", "Lưu");
                    }
                }

                function _hpa_close_editing($cell) {
                    try {
                        const $popup = $cell.data("hpaPopup");
                        if ($popup && $popup.remove) $popup.remove();
                    } catch (e) {}
                    
                    $cell.removeData("hpaPopup");
                    $cell.find(".position-relative").remove(); // Xóa input/actions
                    $cell.removeClass("editing hpa-editable-row");
                    
                    // QUAN TRỌNG: Reset style (đặc biệt là z-index) để không đè lên dòng trên
                    $cell.css({
                        "z-index": "",
                        "background": "",
                        "padding": "",
                        "display": ""
                    });
                }
            }

            $(document).ready(loadData);
        </script>
    ';
    SELECT @html AS html;
END
GO
EXEC sp_GenerateHTMLScript 'sp_Task_MyWork_html'
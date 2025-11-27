USE Paradise_Beta_Tai2
GO
if object_id('[dbo].[sp_Task_TaskList_html]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_Task_TaskList_html] as select 1')
GO

    ALTER PROCEDURE [dbo].[sp_Task_TaskList_html]
        @LoginID INT = 3,
        @LanguageID VARCHAR(2) = 'VN',
        @isWeb INT = 1
    AS
    BEGIN
        SET NOCOUNT ON;
        DECLARE @html NVARCHAR(MAX);
        SET @html = N'
        <style>
            :root {
                --cu-bg: #fbfbfb; --cu-border: #e6e6e6; --cu-text: #292d34; --task-primary: #2E7D32; --task-primary-light: #1c975eff;
                --cu-danger: #E53935; --cu-success: #4CAF50;
            }
            body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; background: var(--cu-bg); color: var(--cu-text); }

            /* Main Container */
            #sp_Task_TaskList_html { padding: 20px; margin: 0 auto; }
            #sp_Task_TaskList_html .cu-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; }
            #sp_Task_TaskList_html .cu-title { font-size: 28px; font-weight: 700; display: flex; align-items: center; gap: 12px; }
            #sp_Task_TaskList_html .cu-title i { color: var(--task-primary); }

            /* Button Standard */
            #sp_Task_TaskList_html .btn-cu { background: var(--task-primary); color: white; border: none; padding: 10px 18px; border-radius: 8px; font-weight: 600; transition: all 0.2s; cursor: pointer; font-size: 14px; }
            #sp_Task_TaskList_html .btn-cu:hover { transform: translateY(-2px); box-shadow: 0 4px 12px rgba(123, 104, 238, 0.3); }

            /* Filters */
            #sp_Task_TaskList_html .filter-bar { display: flex; gap: 12px; margin-bottom: 20px; padding: 16px; border-radius: 12px; border: 1px solid var(--cu-border); }
            #sp_Task_TaskList_html .search-box { flex: 1; position: relative; }
            #sp_Task_TaskList_html .search-box i { position: absolute; left: 14px; top: 50%; transform: translateY(-50%); color: #999; font-size: 16px; }
            #sp_Task_TaskList_html .search-box input { width: 100%; padding: 10px 10px 10px 42px; border: 1.5px solid var(--cu-border); border-radius: 8px; outline: none; transition: all 0.2s; }
            #sp_Task_TaskList_html .search-box input:focus { border-color: var(--task-primary); box-shadow: 0 0 0 4px rgba(123, 104, 238, 0.08); }

            /* Kanban Board View */
            #sp_Task_TaskList_html .kanban-board { display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 20px; }
            #sp_Task_TaskList_html .kanban-column { border-radius: 12px; padding: 16px; min-height: 400px; border: 1px solid var(--cu-border); }
            #sp_Task_TaskList_html .column-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; padding-bottom: 12px; border-bottom: 2px solid #f0f0f0; }
            #sp_Task_TaskList_html .column-title { font-weight: 700; font-size: 15px; display: flex; align-items: center; gap: 8px; }
            #sp_Task_TaskList_html .column-count { background: #e6e9f0; padding: 4px 10px; border-radius: 12px; font-size: 12px; font-weight: 700; color: #676879; }

            /* Task Card */
            #sp_Task_TaskList_html .task-card { border: 2px solid #e6e9f0; border-radius: 10px; padding: 14px; margin-bottom: 12px; cursor: move; transition: all 0.2s; position: relative; }
            #sp_Task_TaskList_html .task-card:hover { border-color: var(--task-primary); box-shadow: 0 4px 16px rgba(123, 104, 238, 0.12); transform: translateY(-2px); }
            #sp_Task_TaskList_html .task-card.dragging { opacity: 0.5; }
            #sp_Task_TaskList_html .task-card .task-name { font-weight: 600; font-size: 14px; margin-bottom: 8px; cursor: pointer; }
            #sp_Task_TaskList_html .task-card .task-name:hover { color: var(--task-primary); }
            #sp_Task_TaskList_html .task-card .task-meta { display: flex; gap: 12px; font-size: 12px; margin-top: 8px; flex-wrap: wrap; }
            #sp_Task_TaskList_html .task-card .meta-item { display: flex; align-items: center; gap: 4px; }

            /* Table View */
            #sp_Task_TaskList_html .cu-table { width: 100%; border-collapse: separate; border-spacing: 0; border-radius: 12px; border: 1px solid var(--cu-border); overflow: hidden; }
            #sp_Task_TaskList_html .cu-table th { padding: 14px 16px; text-align: left; font-weight: 700; font-size: 13px; border-bottom: 2px solid var(--cu-border); text-transform: uppercase; letter-spacing: 0.5px; }
            #sp_Task_TaskList_html .cu-table td { padding: 14px 16px; border-bottom: 1px solid #f0f0f0; vertical-align: middle; }
            #sp_Task_TaskList_html .cu-table tbody tr { transition: all 0.2s; }
            #sp_Task_TaskList_html .cu-table tbody tr:hover { cursor: pointer; }

            /* Inline Edit */
            #sp_Task_TaskList_html .editable { cursor: text; padding: 4px 8px; border-radius: 4px; transition: all 0.2s; }
            #sp_Task_TaskList_html .editing { border: 2px solid var(--task-primary) !important; outline: none; }

            /* Action Buttons */
            #sp_Task_TaskList_html .action-btn { width: 32px; height: 32px; display: inline-flex; align-items: center; justify-content: center; border-radius: 6px; border: 1px solid transparent; transition: all 0.2s; cursor: pointer; }
            #sp_Task_TaskList_html .action-btn:hover { background: #f0f0f0; color: #323338; }
            #sp_Task_TaskList_html .action-btn.delete:hover { background: #ffe0e0; color: var(--cu-danger); }

            /* Modal */
            #sp_Task_TaskList_html .modal-content { border: none; border-radius: 16px; box-shadow: 0 10px 40px rgba(0,0,0,0.15); }
            #sp_Task_TaskList_html .modal-header { border-bottom: 1px solid #f0f0f0; padding: 24px; }
            #sp_Task_TaskList_html .modal-body { padding: 24px; }
            #sp_Task_TaskList_html .form-label { font-weight: 600; font-size: 13px; margin-bottom: 8px; }
            #sp_Task_TaskList_html .form-control,
            #sp_Task_TaskList_html .form-select { border-radius: 8px; border: 1.5px solid var(--cu-border); padding: 10px 14px; font-size: 14px; transition: all 0.2s; }
            #sp_Task_TaskList_html .form-control:focus,
            #sp_Task_TaskList_html .form-select:focus { border-color: var(--task-primary); box-shadow: 0 0 0 4px rgba(123, 104, 238, 0.08); outline: none; }

            /* Parent-Child Task Styles */
            #sp_Task_TaskList_html .task-parent-badge {
                background: linear-gradient(135deg, var(--task-primary) 0%, var(--task-primary-light) 100%);
                color: white;
                font-size: 11px;
                padding: 2px 8px;
                border-radius: 12px;
                font-weight: 600;
            }
            #sp_Task_TaskList_html .task-child-row {
                background: #f8fff8 !important;
                border-left: 4px solid #4CAF50;
            }
            #sp_Task_TaskList_html .task-child-row:hover {
                background: #e8f5e8 !important;
            }
            #sp_Task_TaskList_html .parent-task-name {
                font-weight: 700;
                color: #2E7D32;
            }
            #sp_Task_TaskList_html .child-indicator {
                margin-left: 8px;
                font-size: 12px;
                color: #666;
            }
            #sp_Task_TaskList_html .no-subtask-add {
                opacity: 0.5;
                pointer-events: none;
                cursor: not-allowed !important;
            }

            /* Quick Add */
            #sp_Task_TaskList_html .quick-add { border: 2px dashed var(--task-primary); border-radius: 10px; padding: 12px; margin-bottom: 12px; display: none; }
            #sp_Task_TaskList_html .quick-add input { width: 100%; border: none; outline: none; font-size: 14px; }
            #sp_Task_TaskList_html .quick-add.active { display: block; animation: fadeIn 0.2s; }
            @keyframes fadeIn { from { opacity: 0; transform: translateY(-10px); } to { opacity: 1; transform: translateY(0); } }
            /* responsive table wrapper */
            #sp_Task_TaskList_html .table-wrapper { overflow-x: auto; }

            @media (max-width: 768px) {
                #sp_Task_TaskList_html .filter-bar { flex-direction: column; align-items: stretch; }
                #sp_Task_TaskList_html .filter-bar .search-box { width: 100%; }
                #sp_Task_TaskList_html .filter-bar .form-select, #sp_Task_TaskList_html #cboFilterPos { width: 100% !important; }
            }
        </style>

        <div id="sp_Task_TaskList_html">
            <!-- HEADER -->
            <div class="cu-header">
                <div class="cu-title"><i class="bi bi-layers-fill"></i> Quản lý Công Việc</div>
                <button class="btn-cu" onclick="TaskList.openModal()"><i class="bi bi-plus-lg"></i> Tạo mới</button>
            </div>

            <div class="filter-bar">
                <div class="search-box">
                    <i class="bi bi-search"></i>
                    <input type="text" id="txtSearch" placeholder="Tìm kiếm công việc..." onkeyup="TaskList.filterList()">
                </div>
                <select class="form-select" style="width: 200px;" id="cboFilterPos" onchange="TaskList.filterList()">
                    <option value="">Tất cả chức vụ</option>
                </select>
            </div>

            <!-- TABLE VIEW -->
            <div id="table-view"><div class="text-center p-5"><div class="spinner-border text-primary"></div></div></div>

            <!-- MODAL ADD/EDIT -->
            <div class="modal fade" id="taskModal" tabindex="-1">
                <div class="modal-dialog modal-lg modal-dialog-centered">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title fw-bold" id="modalTitle">Cấu hình công việc</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body">
                            <input type="hidden" id="hdID" value="0">

                            <div class="row g-3">
                                <div class="col-12">
                                    <label class="form-label">Tên công việc <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control" id="txtName" placeholder="VD: Gọi điện chăm sóc khách hàng cũ...">
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label">Chức vụ áp dụng <small class="text-muted">(Chọn nhiều)</small></label>
                                    <div class="multi-pos-wrap" style="position:relative;">
                                        <div id="cboPosDisplay" class="form-control" style="min-height:44px; display:flex; gap:6px; align-items:center; flex-wrap:wrap; cursor:pointer;"></div>
                                        <div id="pos-dropdown" class="card" style="display:none; position:absolute; z-index:2200; top:48px; left:0; right:0; max-height:220px; overflow:auto; padding:8px;">
                                            <div class="mb-2"><input type="text" id="posSearch" class="form-control" placeholder="Tìm chức vụ..." style="width:100%"></div>
                                            <div id="pos-list" style="display:grid; grid-template-columns:1fr 1fr; gap:6px;"></div>
                                        </div>
                                    </div>
                                    <small class="text-muted">Bấm để chọn nhiều chức vụ, có thể tìm nhanh.</small>
                                </div>
                                <div class="col-12"><hr class="my-2 opacity-25"></div>
                                <div class="col-12"><label class="form-label text-success fw-bold">Cấu hình KPI chuẩn (1 Ngày công)</label></div>

                                <div class="col-md-6">
                                    <label class="form-label">KPI / Ngày</label>
                                    <input type="number" class="form-control" id="txtKPI" value="0" placeholder="0">
                                    <small class="text-muted">Số lượng phải làm trong 1 ngày</small>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Đơn vị tính</label>
                                    <input type="text" class="form-control" id="txtUnit" placeholder="VD: Cuộc gọi, Hợp đồng...">
                                </div>

                                <!-- Relations Section -->
                                <div class="col-12 mt-4">
                                    <div class="d-flex justify-content-between align-items-center mb-2">
                                        <label class="form-label mb-0">Công việc con (Checklist/Subtasks)</label>
                                        <button type="button" class="btn btn-sm border text-success" onclick="TaskList.toggleRelations()">
                                            <i class="bi bi-gear"></i> Cấu hình
                                        </button>
                                    </div>
                                    <div id="relation-panel" style="display:none; padding:16px; border-radius:10px; border:2px dashed #ccc;">
                                        <p class="text-muted mb-2">Chọn các công việc con thuộc task này:</p>
                                        <div id="subtask-list" style="max-height:200px; overflow-y:auto; display:grid; grid-template-columns: 1fr 1fr; gap: 10px;"></div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-white border" data-bs-dismiss="modal">Đóng</button>
                            <button type="button" class="btn-cu" onclick="TaskList.saveTask()"><i class="bi bi-check-lg"></i> Lưu cấu hình</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <script>
            (function(){
            var allTasks = [], allPos = [];
            var currentID = 0;
            var currentView = "table";
            var draggedTaskId = null;

            var STATUSTASK = {
                TODO: 1,
                DOING: 2,
                DONE: 3
            };

            $(document).ready(function() {
                loadData();
            });

            function loadData() {
                AjaxHPAParadise({
                    data: { name: "sp_Task_GetPositions", param: [] },
                    success: function(res) {
                        allPos = JSON.parse(res).data[0] || [];
                        renderPosOptions();
                    }
                });

                AjaxHPAParadise({
                    data: { name: "sp_Task_GetAllTasks", param: ["LoginID", LoginID] },
                    success: function(res) {
                        allTasks = JSON.parse(res).data[0] || [];
                        if(currentView === "table") {
                            renderTableView(allTasks);
                        } else {
                            renderKanbanView(allTasks);
                        }
                        renderSubtaskList();
                    }
                });
            }

            function renderPosOptions() {
                let opts = allPos.map(p => `<option value="${p.PositionID}">${p.PositionName || p.PositionID}</option>`).join("");
                $("#cboFilterPos").append(opts);

                // Render custom multi-select dropdown
                let itemsHtml = allPos.map(p => {
                    return `<label class="form-check" style="cursor:pointer; display:flex; gap:6px; align-items:center;">
                        <input type="checkbox" class="form-check-input pos-item" data-id="${p.PositionID}" />
                        <span class="pos-label">${p.PositionName || p.PositionID}</span>
                    </label>`;
                }).join("");
                $("#pos-list").html(itemsHtml);

                // Wire search
                $(document).off("keyup.posSearch").on("keyup.posSearch", "#posSearch", function(){
                    let q = $(this).val().toLowerCase();
                    $("#pos-list .pos-label").each(function(){
                        let show = $(this).text().toLowerCase().indexOf(q) !== -1;
                        $(this).closest(".form-check").toggle(show);
                    });
                });

                // Handle clicks on checkbox
                $(document).off("change.posItem").on("change.posItem", ".pos-item", function(){
                    TaskList.updatePosDisplayFromCheckboxes();
                });
            }

            function renderTableView(data) {
                if(data.length === 0) {
                    $("#table-view").html(`<div class="text-center p-5 text-muted">Chưa có dữ liệu</div>`);
                    return;
                }

                // Wrap table in a horizontally-scrollable container for small screens
                let html = `<div class="table-wrapper"><table class="cu-table">
                    <thead>
                        <tr>
                            <th width="50">#</th>
                            <th>Tên công việc</th>
                            <th width="150">Chức vụ</th>
                            <th width="150">KPI Chuẩn</th>
                            <th width="120">Trạng thái</th>
                            <th width="100" class="text-end">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>`;

                html += data.map((t, idx) => {
                    return `
                        <tr onclick="TaskList.editTask(${t.TaskID})" data-id="${t.TaskID}">

                        <td class="text-center text-muted">${idx+1}</td>
                        <td>
                            <div class="editable" contenteditable="false" data-field="TaskName" data-id="${t.TaskID}"
                                onclick="event.stopPropagation(); TaskList.makeEditable(this)"
                                onblur="TaskList.saveInlineEdit(this)">
                                ${t.TaskName}
                            </div>
                        </td>
                        <td>
                            <span class="badge bg-light text-dark border">
                                ${t.PositionNames ? t.PositionNames : `<span class="text-muted">Không có chức vụ</span>`}
                            </span>
                        </td>
                        <td>
                            ${t.DefaultKPI > 0 ? `<span class="badge bg-primary">${t.DefaultKPI} ${t.Unit}</span>` : `<span class="text-muted small">-</span>`}
                        </td>
                        <td class="text-center">
                            <div class="action-btn rounded-circle ${t.Status == 5 ? "bg-danger bg-opacity-10 text-danger" : "bg-success bg-opacity-10 text-success"} shadow-sm"
                                style="width:42px; height:42px; display:inline-flex; align-items:center; justify-content:center; cursor:pointer; transition:all 0.2s;"
                                onclick="event.stopPropagation(); TaskList.toggleActiveStatus(${t.TaskID})"
                                title="${t.Status == 5 ? "Không hiệu lực → Click để bật" : "Đang hiệu lực → Click để tắt"}">
                                <i class="bi ${t.Status == 5 ? "bi-toggle-off" : "bi-toggle-on"} fs-3"></i>
                            </div>
                        </td>
                        <td>
                            <div class="d-flex justify-content-end gap-2">
                                <div class="action-btn" onclick="TaskList.editTask(${t.TaskID}); event.stopPropagation()" title="Chỉnh sửa">
                                    <i class="bi bi-pencil"></i>
                                </div>
                                <div class="action-btn delete" onclick="TaskList.delTask(${t.TaskID}); event.stopPropagation()" title="Xóa">
                                    <i class="bi bi-trash"></i>
                                </div>
                            </div>
                        </td>
                    </tr>`;
                }).join("");

                html += `</tbody></table></div>`;
                $("#table-view").html(html);
            }

            function renderKanbanView(data) {
                $("#tasks-todo, #tasks-doing, #tasks-done").html("");

                let todoTasks  = data.filter(t => t.Status == STATUSTASK.TODO);
                let doingTasks = data.filter(t => t.Status == STATUSTASK.DOING);
                let doneTasks  = data.filter(t => t.Status == STATUSTASK.DONE);

                $("#count-todo").text(todoTasks.length);
                $("#count-doing").text(doingTasks.length);
                $("#count-done").text(doneTasks.length);

                renderTaskCards("#tasks-todo", todoTasks);
                renderTaskCards("#tasks-doing", doingTasks);
                renderTaskCards("#tasks-done", doneTasks);
            }

            function renderTaskCards(container, tasks) {
                let html = tasks.map(t => {
                    return `
                    <div class="task-card" draggable="true" ondragstart="TaskList.dragTask(event, ${t.TaskID})" data-id="${t.TaskID}">
                        <div class="task-name" onclick="TaskList.editTask(${t.TaskID})">${t.TaskName}</div>
                        <div class="task-meta">
                            ${t.DefaultKPI > 0 ? `<span class="meta-item"><i class="bi bi-graph-up"></i> ${t.DefaultKPI} ${t.Unit}</span>` : ""}
                            ${t.PositionNames ? `<span class="meta-item"><i class="bi bi-person-badge"></i> ${t.PositionNames}</span>` : ""}
                        </div>
                    </div>
                    `;
                }).join("");
                $(container).html(html);
            }

            // Multi-position helpers
            window.TaskList = window.TaskList || {};
            TaskList.selectedPositions = new Set();
            TaskList.togglePosDropdown = function(e){
                e.stopPropagation();
                $("#pos-dropdown").toggle();
                $("#posSearch").val("");
                $("#pos-list .form-check").show();
            };
            TaskList.updatePosDisplayFromCheckboxes = function(){
                TaskList.selectedPositions.clear();
                $("#pos-list .pos-item:checked").each(function(){ TaskList.selectedPositions.add($(this).data("id")); });
                TaskList.updatePosDisplay();
            };
            TaskList.updatePosDisplay = function(){
                let container = $("#cboPosDisplay");
                container.empty();
                if(TaskList.selectedPositions.size === 0){
                    container.html(`<span class="text-muted">Chưa chọn chức vụ</span>`);
                    return;
                }
                TaskList.selectedPositions.forEach(function(id){
                    let name = (allPos.find(p => p.PositionID == id) || {}).PositionName || id;
                    let badge = $(`<span class="badge bg-light text-dark border pos-badge" data-id="${id}" style="display:inline-flex; align-items:center; gap:6px;"><span class="pos-name">${name}</span> <a href="#" class="ms-1 text-danger pos-remove" data-id="${id}" style="text-decoration:none;">&times;</a></span>`);
                    badge.find(".pos-remove").on("click", function(ev){ ev.preventDefault(); let rid=$(this).data("id"); TaskList.selectedPositions.delete(rid); $(`#pos-list .pos-item[data-id="${rid}"]`).prop("checked", false); TaskList.updatePosDisplay(); });
                    container.append(badge);
                });
            };
            TaskList.getSelectedPositionsCSV = function(){
                return Array.from(TaskList.selectedPositions).join(",");
            };
            TaskList.setSelectedPositionsFromCSV = function(csv){
                TaskList.selectedPositions.clear();
                if(csv){
                    let ids = (""+csv).split(",").map(x=>x.trim()).filter(x=>x);
                    ids.forEach(id=>TaskList.selectedPositions.add(id));
                }
                // update checkbox states
                $("#pos-list .pos-item").each(function(){
                    let id = $(this).data("id");
                    $(this).prop("checked", TaskList.selectedPositions.has(id));
                });
                TaskList.updatePosDisplay();
            };

            // Close dropdown when clicking outside
            $(document).on("click", function(e){ if(!$(e.target).closest(".multi-pos-wrap").length){ $("#pos-dropdown").hide(); } });

            // Drag and Drop
            function dragTask(event, taskId) {
                draggedTaskId = taskId;
                event.target.classList.add("dragging");
            }

            function allowDrop(event) {
                event.preventDefault();
            }

            function dropTask(event, newStatus) {
                event.preventDefault();
                document.querySelector(".dragging")?.classList.remove("dragging");

                if(draggedTaskId) {
                    AjaxHPAParadise({
                        data: {
                            name: "sp_Task_UpdateTaskStatus",
                            param: ["TaskID", draggedTaskId, "NewStatus", newStatus]
                        },
                        success: function() {
                            loadData();
                        }
                    });
                }
            }

            // Quick Add
            function showQuickAdd(status) {
                $(".quick-add").removeClass("active");
                $(`#quick-add-${status}`).addClass("active").find("input").focus();
            }

            function quickAdd(status, taskName) {
                if(!taskName.trim()) return;

                AjaxHPAParadise({
                    data: {
                        name: "sp_Task_SaveTask",
                        param: [
                            "TaskID", 0,
                            "TaskName", taskName,
                            "PositionID", "",
                            "DefaultKPI", 0,
                            "Unit", "đơn",
                            "Status", status
                        ]
                    },
                    success: function() {
                        $(`#quick-add-${status}`).removeClass("active").find("input").val("");
                        loadData();
                    }
                });
            }

            // Inline Edit
            function makeEditable(el) {
                $(el).attr("contenteditable", "true").addClass("editing").focus();
                document.execCommand("selectAll", false, null);
            }

            function saveInlineEdit(el) {
                let $el = $(el);
                $el.attr("contenteditable", "false").removeClass("editing");
                let field = $el.data("field");
                let id = $el.data("id");
                let newValue = $el.text().trim();

                if(!newValue) {
                    loadData(); // Revert
                    return;
                }

                let params = ["TaskID", id];
                params.push(field, newValue);

                AjaxHPAParadise({
                    data: { name: "sp_Task_UpdateField", param: params },
                    success: function() {
                        // Updated successfully
                    }
                });
            }

            function renderSubtaskList() {
                const currentEditingTaskId = parseInt($("#hdID").val()) || 0;

                const availableAsSubtask = allTasks.filter(t => {
                    if (t.TaskID === currentEditingTaskId) return false;
                    if (t.ParentTaskID && t.ParentTaskID !== 0) return false;
                    if (t.Status === 5) return false;

                    // LỌC TASK CÓ PositionID (task cố định)
                    if (t.PositionID && t.PositionID !== null && t.PositionID.trim() !== "") {
                        return false;
                    }

                    const isAlreadyParent = allTasks.some(task => task.ParentTaskID === t.TaskID);
                    if (isAlreadyParent) return false;

                    return true;
                });

                availableAsSubtask.sort((a, b) => a.TaskName.localeCompare(b.TaskName));

                let html = "";
                if (availableAsSubtask.length === 0) {
                    html = `<div class="text-muted text-center p-3 small">
                        Không có công việc nào phù hợp để làm nhiệm vụ con<br>
                        <small>(Chỉ công việc độc lập, chưa có con, và <strong>không cố định</strong> mới được chọn)</small>
                    </div>`;
                } else {
                    html = availableAsSubtask.map(t => {
                        // Kiểm tra xem task có phải đã được giao tự động không
                        let hasAutoAssign = false; // Có thể check thêm nếu cần

                        return `
                            <label class="d-flex align-items-center gap-2 p-2 rounded hover-bg"
                                style="cursor:pointer; background:#f8fff8; margin:4px 0; border:1px solid #d4edda; border-radius:6px;">
                                <input type="checkbox" class="form-check-input subtask-chk" value="${t.TaskID}">
                                <span style="font-size:14px; color:#155724;">${escapeHtml(t.TaskName)}</span>
                            </label>
                        `;
                    }).join("");
                }

                $("#subtask-list").html(html);
            }

            function toggleActiveStatus(taskId) {
                let task = allTasks.find(t => t.TaskID == taskId);
                if (!task) return;
                let isDisabled = task.Status == 5;
                let newStatus = isDisabled ? 1 : 5;

                showConfirmPopup({
                    title: isDisabled ? "Bật hiệu lực công việc" : "Tắt hiệu lực công việc",
                    message: isDisabled
                        ? "Bạn có muốn <strong>bật lại</strong> công việc này?"
                        : "Bạn có muốn <strong>tắt hiệu lực</strong> công việc này?<br><small>Công việc sẽ không xuất hiện trong danh sách làm việc.</small>",
                    icon: isDisabled ? "success" : "warning",
                    YesText: "Có, thực hiện",
                    NoText: "Hủy bỏ",
                    onYes: function() {
                        AjaxHPAParadise({
                            data: { name: "sp_Task_UpdateField", param: ["TaskID", taskId, "Status", newStatus] },
                            success: function() { loadData(); },
                            error: function() {
                                uiManager.showAlert({ type: "error", message: "Cập nhật thất bại!" });
                            }
                        });
                    }
                });
            }

            /* --- ACTIONS --- */
            function openModal() {
                currentID = 0;
                $("#hdID").val(0);
                $("#modalTitle").text("Tạo công việc mới");
                $("#txtName, #txtKPI, #txtUnit").val("");
                $("#cboPos").val("");
                $(".subtask-chk").prop("checked", false);
                $("#relation-panel").hide();

                // CLEAR SELECTED POSITIONS
                TaskList.selectedPositions.clear();
                $("#pos-list .pos-item").prop("checked", false);
                TaskList.updatePosDisplay();

                renderSubtaskList();

                new bootstrap.Modal(document.getElementById("taskModal")).show();
                // show modal and ensure it stacks above existing modals
                $("#taskModal").one("shown.bs.modal", function(){
                    var idx = $(".modal.show").length; // total open modals including this
                    var zIndexModal = 1050 + (idx-1) * 10;
                    $(this).css("z-index", zIndexModal);
                    // adjust backdrop z-index for this modal (only for un-stacked backdrops)
                    $(".modal-backdrop").not(".modal-stack").css("z-index", zIndexModal - 1).addClass("modal-stack");
                });
            }

            function editTask(id) {
                currentID = id;
                $("#hdID").val(id); // quan trọng!

                let t = allTasks.find(x => x.TaskID == id);
                if (!t) return;

                $("#modalTitle").text("Chỉnh sửa: " + t.TaskName);
                $("#txtName").val(t.TaskName);
                TaskList.setSelectedPositionsFromCSV(t.PositionID || "");
                $("#txtKPI").val(t.DefaultKPI || 0);
                $("#txtUnit").val(t.Unit || "");

                // Load quan hệ subtask
                AjaxHPAParadise({
                    data: { name: "sp_Task_GetTaskRelations", param: ["ParentTaskID", id] },
                    success: function(res) {
                        let rels = JSON.parse(res).data[0] || [];
                        $(".subtask-chk").prop("checked", false);
                        rels.forEach(r => {
                            $(`.subtask-chk[value="${r.ChildTaskID}"]`).prop("checked", true);
                        });
                    }
                });

                renderSubtaskList(); // gọi lại ở đây để lọc đúng

                new bootstrap.Modal(document.getElementById("taskModal")).show();
                $("#taskModal").one("shown.bs.modal", function(){
                    var idx = $(".modal.show").length;
                    var zIndexModal = 1050 + (idx-1) * 10;
                    $(this).css("z-index", zIndexModal);
                    $(".modal-backdrop").not(".modal-stack").css("z-index", zIndexModal - 1).addClass("modal-stack");
                });
            }

            function saveTask() {
                let name = $("#txtName").val().trim();
                let pos = TaskList.getSelectedPositionsCSV();

                if(!name) {
                    alert("Vui lòng nhập tên công việc");
                    return;
                }

                let subtasks = [];
                $(".subtask-chk:checked").each(function() {
                    subtasks.push(parseInt($(this).val()));
                });

                // BƯỚC 1: LƯU TASK CHÍNH
                AjaxHPAParadise({
                    data: {
                        name: "sp_Task_SaveTask",
                        param: [
                            "TaskID", currentID,
                            "TaskName", name,
                            "PositionID", pos || "",
                            "DefaultKPI", $("#txtKPI").val() || 0,
                            "Unit", $("#txtUnit").val() || "đơn",
                            "Status", 1
                        ]
                    },
                    success: function(res) {
                        try {
                            let result = JSON.parse(res);
                            let newTaskID = result.data[0][0].TaskID;

                            // BƯỚC 2: LƯU QUAN HỆ TASK CON (VỚI VALIDATION)
                            AjaxHPAParadise({
                                data: {
                                    name: "sp_Task_SaveTaskRelations",
                                    param: [
                                        "ParentTaskID", newTaskID,
                                        "ChildTaskIDs", subtasks.join(",")
                                    ]
                                },
                                success: function(relRes) {
                                  try {
                                        let relResult = JSON.parse(relRes);
                                        let relData = relResult.data[0];

                                        if (relData && relData.length > 0) {
                                            let firstRow = relData[0];

                                            // KIỂM TRA SUCCESS FLAG
                                            if (firstRow.Success === 0) {
                                                // ❌ CÓ LỖI VALIDATION
                                                showValidationError(relData);
                                                return;
                                            }

                     // THÀNH CÔNG
                                            bootstrap.Modal.getInstance(
                                                document.getElementById("taskModal")
                                            ).hide();

                                            // Hiển thị thông báo thành công
                                            showSuccessNotification(
                                                firstRow.Message || "✅ Lưu thành công!",
                                                `Đã lưu ${firstRow.TotalChildren || 0} task con`
                                            );

                                            loadData();
                                        }
                                    } catch(e) {
                                        console.error("Parse relation result error:", e);
                                        alert("⚠️ Lỗi khi xử lý kết quả lưu quan hệ!");
                                    }
                                },
                                error: function() {
                                    alert("❌ Lưu quan hệ công việc con thất bại!");
                                }
                            });
                        } catch(e) {
                            console.error("Parse error:", e);
                            alert("⚠️ Lỗi khi xử lý kết quả từ server!");
                        }
                    },
                    error: function() {
                        alert("❌ Lưu công việc thất bại!");
                    }
                });
            }

            function showValidationError(errorData) {
                // Tạo HTML danh sách lỗi
                let errorListHtml = errorData.map(err => `
                    <div class="alert alert-danger d-flex align-items-start"
                        style="border-left: 4px solid #dc3545; margin-bottom: 12px;">
                        <i class="bi bi-exclamation-triangle-fill fs-4 me-3 text-danger"></i>
                        <div>
                            <strong>${escapeHtml(err.TaskName || "Unknown")}</strong>
                            <p class="mb-0 small">${escapeHtml(err.Reason || "")}</p>
</div>
                    </div>
                `).join("");

                let modalHtml = `
                    <div class="modal fade" id="mdlValidationError" tabindex="-1">
                        <div class="modal-dialog modal-dialog-centered modal-lg">
                            <div class="modal-content">
                                <div class="modal-header bg-danger text-white">
                                    <h5 class="modal-title">
                                        <i class="bi bi-shield-exclamation"></i>
                                        Không thể lưu quan hệ task con
                                    </h5>
                                    <button type="button" class="btn-close btn-close-white"
                                            data-bs-dismiss="modal"></button>
                                </div>
                                <div class="modal-body">
        <div class="alert alert-warning mb-3">
                                        <i class="bi bi-info-circle-fill"></i>
                                        <strong>Lý do:</strong> Task cố định theo chức vụ hoặc đã được giao tự động
                                        sẽ bị <strong>trùng lặp</strong> nếu làm task con.
                                    </div>

                                    <h6 class="mb-3">Các task không hợp lệ:</h6>
                                    ${errorListHtml}

                                    <div class="alert alert-info mb-0">
                                        <i class="bi bi-lightbulb-fill"></i>
                                        <strong>Giải pháp:</strong>
                                        <ul class="mb-0 mt-2">
                                            <li>Bỏ chọn các task có <strong>PositionID</strong> (task cố định)</li>
                                            <li>Hoặc chọn task khác chưa từng được giao tự động</li>
                                            <li>Hoặc tạo task mới để làm subtask</li>
                                        </ul>
                                    </div>
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-primary" data-bs-dismiss="modal">
                                        <i class="bi bi-check-lg"></i> Đã hiểu
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                `;

                // Xóa modal cũ nếu có
                $("#mdlValidationError").remove();

                // Thêm modal mới vào body
                $("body").append(modalHtml);

                // Hiển thị modal
                let modal = new bootstrap.Modal(document.getElementById("mdlValidationError"));
                modal.show();

                // Tự động xóa modal khi đóng
                $("#mdlValidationError").on("hidden.bs.modal", function() {
                    $(this).remove();
                });
            }

            // FUNCTION MỚI: Hiển thị thông báo thành công
            function showSuccessNotification(title, message) {
                // Nếu có hệ thống notification toàn cục, dùng nó
                if (typeof showNotification === "function") {
                    showNotification({
                        type: "success",
                        title: title,
                        message: message
                    });
                    return;
                }

                // Fallback: Toast notification đơn giản
                let toastHtml = `
                    <div class="toast-container position-fixed top-0 end-0 p-3" style="z-index: 9999;">
                        <div class="toast show" role="alert">
                            <div class="toast-header bg-success text-white">
                                <i class="bi bi-check-circle-fill me-2"></i>
                                <strong class="me-auto">${title}</strong>
                                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="toast"></button>
                            </div>
                            <div class="toast-body">
                                ${message}
                            </div>
                        </div>
                    </div>
                `;

                let $toast = $(toastHtml);
                $("body").append($toast);

                setTimeout(() => {
                    $toast.fadeOut(300, function() {
                        $(this).remove();
                    });
                }, 3000);
            }

            // HELPER: Escape HTML để tránh XSS
            function escapeHtml(str) {
  if (str === null || str === undefined) return "";
                return String(str)
                    .replace(/&/g, "&amp;")
                    .replace(/</g, "&lt;")
                    .replace(/>/g, "&gt;")
                    .replace(/""/g, "&quot;")
                    .replace(/"/g, "&#39;");
            }

            function delTask(id) {
                if(confirm("Bạn chắc chắn muốn xóa công việc này?")) {
    AjaxHPAParadise({
                        data: { name: "sp_Task_DeleteTask", param: ["TaskID", id] },
                success: function() {
                            loadData();
                        }
                    });
                }
            }

            function filterList() {
                let term = $("#txtSearch").val().toLowerCase();
                let pos = $("#cboFilterPos").val();

                let filtered = allTasks.filter(t => {
                    let matchName = t.TaskName.toLowerCase().includes(term);
                    let matchPos = pos === "" || t.PositionID == pos;
                    return matchName && matchPos;
                });

                if(currentView === "table") {
                    renderTableView(filtered);
                } else {
                    renderKanbanView(filtered);
                }
            }

            function toggleRelations() {
                $("#relation-panel").slideToggle();
            }

            // Expose public API to avoid global name conflicts with other pages
            window.TaskList = {
                // core actions
                loadData: loadData,
                filterList: filterList,
                toggleActiveStatus: toggleActiveStatus,
                openModal: openModal,
                editTask: editTask,
                saveTask: saveTask,
                delTask: delTask,

                // rendering
                renderTableView: renderTableView,
                renderKanbanView: renderKanbanView,
                renderSubtaskList: renderSubtaskList,

                // drag/drop
                dragTask: dragTask,
                allowDrop: allowDrop,
                dropTask: dropTask,

                // quick helpers
                showQuickAdd: showQuickAdd,
                quickAdd: quickAdd,
                makeEditable: makeEditable,
                saveInlineEdit: saveInlineEdit,
                toggleRelations: toggleRelations,

                // multi-position helpers and state
                selectedPositions: new Set(),
                togglePosDropdown: function(e){ e.stopPropagation(); $("#pos-dropdown").toggle(); $("#posSearch").val(""); $("#pos-list .form-check").show(); },
                updatePosDisplayFromCheckboxes: function(){ TaskList.selectedPositions.clear(); $("#pos-list .pos-item:checked").each(function(){ TaskList.selectedPositions.add($(this).data("id")); }); TaskList.updatePosDisplay(); },
                updatePosDisplay: function(){ let container = $("#cboPosDisplay"); container.empty(); if(TaskList.selectedPositions.size === 0){ container.html(`<span class="text-muted">Chưa chọn chức vụ</span>`); return; } TaskList.selectedPositions.forEach(function(id){ let name = (allPos.find(p => p.PositionID == id) || {}).PositionName || id; let badge = $(`<span class="badge bg-light text-dark border pos-badge" data-id="${id}" style="display:inline-flex; align-items:center; gap:6px;"><span class="pos-name">${name}</span> <a href="#" class="ms-1 text-danger pos-remove" data-id="${id}" style="text-decoration:none;">&times;</a></span>`); badge.find(".pos-remove").on("click", function(ev){ ev.preventDefault(); let rid=$(this).data("id"); TaskList.selectedPositions.delete(rid); $(`#pos-list .pos-item[data-id="${rid}"]`).prop("checked", false); TaskList.updatePosDisplay(); }); container.append(badge); }); },
                getSelectedPositionsCSV: function(){ return Array.from(TaskList.selectedPositions).join(","); },
                setSelectedPositionsFromCSV: function(csv){ TaskList.selectedPositions.clear(); if(csv){ let ids = (""+csv).split(",").map(x=>x.trim()).filter(x=>x); ids.forEach(id=>TaskList.selectedPositions.add(id)); } $("#pos-list .pos-item").each(function(){ let id = $(this).data("id"); $(this).prop("checked", TaskList.selectedPositions.has(id)); }); TaskList.updatePosDisplay(); }
            };

            // Bind click on display to toggle dropdown (ensure global TaskList already set)
            $(document).ready(function(){
                $("#cboPosDisplay").on("click", function(e){ window.TaskList && window.TaskList.togglePosDropdown(e); });
            });

            })();
        </script>
        ';
        SELECT @html AS html;
        -- EXEC sp_GenerateHTMLScript 'sp_Task_TaskList_html'
    END
GO

EXEC sp_GenerateHTMLScript 'sp_Task_TaskList_html'
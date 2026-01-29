/**
 * Task UI Components
 *
 * Chứa toàn bộ logic render UI và interaction
 * Sử dụng DevExtreme cho grid và form
 */

const TaskUI = (function () {
    'use strict';

    // Reference đến các element chính
    let dataGrid = null;
    let createTaskPopup = null;
    let detailTaskPopup = null;

    // ============================================
    // UTILITY FUNCTIONS
    // ============================================

    /**
     * Format date sang dạng dd/mm/yyyy
     */
    function formatDate(dateString) {
        if (!dateString) return '';
        const date = new Date(dateString);
        const day = String(date.getDate()).padStart(2, '0');
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const year = date.getFullYear();
        return `${day}/${month}/${year}`;
    }

    /**
     * Format datetime sang dạng dd/mm/yyyy HH:mm
     */
    function formatDateTime(dateString) {
        if (!dateString) return '';
        const date = new Date(dateString);
        const day = String(date.getDate()).padStart(2, '0');
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const year = date.getFullYear();
        const hours = String(date.getHours()).padStart(2, '0');
        const minutes = String(date.getMinutes()).padStart(2, '0');
        return `${day}/${month}/${year} ${hours}:${minutes}`;
    }

    /**
     * Get status badge HTML
     */
    function getStatusBadge(status) {
        const statusClass = status.toLowerCase().replace(/ /g, '-');
        return `<span class="badge badge-status-${statusClass}">${status}</span>`;
    }

    /**
     * Get priority badge HTML
     */
    function getPriorityBadge(priority) {
        const priorityClass = priority.toLowerCase();
        return `<span class="badge badge-priority-${priorityClass}">${priority}</span>`;
    }

    /**
     * Show notification
     */
    function showNotification(message, type = 'info') {
        DevExpress.ui.notify({
            message: message,
            type: type, // 'info', 'success', 'warning', 'error'
            displayTime: 3000,
            position: {
                my: 'top right',
                at: 'top right',
                offset: '20 60',
            },
        });
    }

    // ============================================
    // STATISTICS
    // ============================================

    /**
     * Render statistics cards
     */
    function renderStatistics() {
        const stats = TaskService.getStatistics();

        const html = `
            <div class="stat-card todo">
                <div class="stat-card-label">Todo</div>
                <div class="stat-card-value">${stats.todo}</div>
            </div>
            <div class="stat-card in-progress">
                <div class="stat-card-label">In Progress</div>
                <div class="stat-card-value">${stats.inProgress}</div>
            </div>
            <div class="stat-card review">
                <div class="stat-card-label">Review</div>
                <div class="stat-card-value">${stats.review}</div>
            </div>
            <div class="stat-card done">
                <div class="stat-card-label">Done</div>
                <div class="stat-card-value">${stats.done}</div>
            </div>
            <div class="stat-card blocked">
                <div class="stat-card-label">Blocked</div>
                <div class="stat-card-value">${stats.blocked}</div>
            </div>
        `;

        $('#statsContainer').html(html);
    }

    // ============================================
    // DATA GRID
    // ============================================

    /**
     * Initialize DevExtreme DataGrid
     */
    function initDataGrid() {
        dataGrid = $('#taskGrid')
            .dxDataGrid({
                dataSource: TaskService.getAllTasks(),
                showBorders: true,
                showRowLines: true,
                rowAlternationEnabled: true,
                hoverStateEnabled: true,
                columnAutoWidth: true,
                wordWrapEnabled: true,
                allowColumnReordering: true,
                allowColumnResizing: true,
                columnResizingMode: 'widget',

                // Paging
                paging: {
                    pageSize: 20,
                },

                // Sorting
                sorting: {
                    mode: 'multiple',
                },

                // Filtering
                filterRow: {
                    visible: true,
                },
                headerFilter: {
                    visible: true,
                },

                // Search
                searchPanel: {
                    visible: true,
                    width: 240,
                    placeholder: 'Tìm kiếm...',
                },

                // Selection
                selection: {
                    mode: 'single',
                },

                // Export
                export: {
                    enabled: true,
                    fileName: 'Tasks',
                },

                // Columns
                columns: [
                    {
                        dataField: 'id',
                        caption: 'ID',
                        width: 60,
                        alignment: 'center',
                    },
                    {
                        dataField: 'taskName',
                        caption: 'Tên công việc',
                        minWidth: 200,
                    },
                    {
                        dataField: 'assigneeIds',
                        caption: 'Người thực hiện',
                        width: 220,
                        cellTemplate: function (container, options) {
                            const names = options.data.assigneeNames || '';
                            const avatars = options.data.assigneeAvatars || '';
                            $('<div>').html(`${avatars} ${names}`).appendTo(container);
                        },
                        editorOptions: {
                            // in edit mode this will be a TagBox
                            dataSource: TaskService.getAllUsers(),
                            displayExpr: 'name',
                            valueExpr: 'id',
                        },
                    },
                    {
                        dataField: 'department',
                        caption: 'Phòng ban',
                        width: 140,
                        alignment: 'center',
                    },
                    {
                        dataField: 'priority',
                        caption: 'Ưu tiên',
                        width: 100,
                        alignment: 'center',
                        cellTemplate: function (container, options) {
                            $('<div>').html(getPriorityBadge(options.value)).appendTo(container);
                        },
                    },
                    {
                        dataField: 'status',
                        caption: 'Trạng thái',
                        width: 130,
                        alignment: 'center',
                        cellTemplate: function (container, options) {
                            $('<div>').html(getStatusBadge(options.value)).appendTo(container);
                        },
                    },
                    {
                        dataField: 'progress',
                        caption: 'Tiến độ',
                        width: 150,
                        alignment: 'center',
                        cellTemplate: function (container, options) {
                            const isOverdue = options.data.isOverdue;
                            const fillClass = isOverdue ? 'overdue' : '';

                            $('<div>')
                                .addClass('progress-container')
                                .html(
                                    `
                                <div class="progress-bar">
                                    <div class="progress-fill ${fillClass}" style="width: ${options.value}%"></div>
                                </div>
                                <span class="progress-text">${options.value}%</span>
                            `,
                                )
                                .appendTo(container);
                        },
                    },
                    {
                        dataField: 'dueDate',
                        caption: 'Deadline',
                        width: 120,
                        dataType: 'date',
                        format: 'dd/MM/yyyy',
                        cellTemplate: function (container, options) {
                            const isOverdue = options.data.isOverdue;
                            const className = isOverdue ? 'text-danger' : '';
                            const days = options.data.daysRemaining;
                            const daysText = days > 0 ? `(còn ${days} ngày)` : days === 0 ? '(hôm nay)' : `(quá ${Math.abs(days)} ngày)`;

                            $('<div>')
                                .addClass(className)
                                .html(
                                    `
                                ${formatDate(options.value)}<br>
                                <small>${daysText}</small>
                            `,
                                )
                                .appendTo(container);
                        },
                    },
                    {
                        type: 'buttons',
                        width: 100,
                        buttons: [
                            {
                                hint: 'Xem chi tiết',
                                icon: 'info',
                                onClick: function (e) {
                                    showTaskDetail(e.row.data.id);
                                },
                            },
                            {
                                hint: 'Cập nhật trạng thái',
                                icon: 'edit',
                                onClick: function (e) {
                                    showStatusUpdatePopup(e.row.data);
                                },
                            },
                        ],
                    },
                ],

                // Editing
                keyExpr: 'id',
                editing: {
                    mode: 'row',
                    allowUpdating: true,
                    allowAdding: false,
                    allowDeleting: false,
                },

                // Events
                onRowUpdated: function (e) {
                    const updates = {};
                    // e.data contains changed fields only; use e.data directly
                    if (e.data.taskName !== undefined) updates.taskName = e.data.taskName;
                    if (e.data.description !== undefined) updates.description = e.data.description;
                    if (e.data.priority !== undefined) updates.priority = e.data.priority;
                    if (e.data.status !== undefined) updates.status = e.data.status;
                    if (e.data.startDate !== undefined) updates.startDate = e.data.startDate;
                    if (e.data.dueDate !== undefined) updates.dueDate = e.data.dueDate;
                    if (e.data.assigneeIds !== undefined) updates.assigneeIds = e.data.assigneeIds;

                    const res = TaskService.updateTask(e.key, updates);
                    if (!res.success) showNotification(res.errors.join('\n'), 'error');
                    else {
                        showNotification('Cập nhật thành công', 'success');
                        refreshGrid();
                        // If detail popup open for this task, refresh it
                        const popup = $('#taskDetailPopup').dxPopup('instance');
                        if (popup && popup.option('visible')) {
                            showTaskDetail(e.key);
                        }
                    }
                },

                onRowClick: function (e) {
                    // Double click để xem chi tiết
                    if (e.rowType === 'data') {
                        showTaskDetail(e.data.id);
                    }
                },

                onToolbarPreparing: function (e) {
                    e.toolbarOptions.items.unshift({
                        location: 'before',
                        widget: 'dxButton',
                        options: {
                            icon: 'refresh',
                            hint: 'Refresh',
                            onClick: function () {
                                refreshGrid();
                            },
                        },
                    });
                },
            })
            .dxDataGrid('instance');
    }

    /**
     * Refresh data grid
     */
    function refreshGrid() {
        if (dataGrid) {
            dataGrid.option('dataSource', TaskService.getAllTasks());
            dataGrid.refresh();
            renderStatistics();
            showNotification('Dữ liệu đã được làm mới', 'success');
        }
    }

    // ============================================
    // CREATE TASK POPUP
    // ============================================

    /**
     * Initialize create task popup
     */
    function initCreateTaskPopup() {
        createTaskPopup = $('#createTaskPopup')
            .dxPopup({
                width: 600,
                height: 'auto',
                maxHeight: '90vh',
                showTitle: true,
                title: 'Tạo công việc mới',
                dragEnabled: true,
                closeOnOutsideClick: false,
                showCloseButton: true,
                visible: false,
                contentTemplate: function (contentElement) {
                    const formContainer = $('<div>').attr('id', 'createTaskForm');
                    contentElement.append(formContainer);

                    formContainer.dxForm({
                        formData: {
                            taskName: '',
                            description: '',
                            department: null,
                            assigneeId: null,
                            priority: 'Medium',
                            status: 'Todo',
                            startDate: new Date(),
                            dueDate: null,
                        },
                        items: [
                            {
                                dataField: 'taskName',
                                label: { text: 'Tên công việc' },
                                editorType: 'dxTextBox',
                                editorOptions: {
                                    placeholder: 'Nhập tên công việc...',
                                },
                                validationRules: [
                                    {
                                        type: 'required',
                                        message: 'Tên công việc không được để trống',
                                    },
                                ],
                            },
                            {
                                dataField: 'department',
                                label: { text: 'Phòng ban' },
                                editorType: 'dxSelectBox',
                                editorOptions: {
                                    items: TaskService.getDepartments(),
                                    placeholder: 'Chọn phòng ban...',
                                    onValueChanged: function (e) {
                                        const formInst = formContainer.dxForm('instance');
                                        const dep = e.value;
                                        const usersList = dep ? TaskService.getAllUsers().filter((u) => u.department === dep) : TaskService.getAllUsers();
                                        try {
                                            const assigneeEditor = formInst.getEditor('assigneeIds');
                                            if (assigneeEditor) {
                                                assigneeEditor.option('dataSource', usersList);
                                            }
                                        } catch (err) {
                                            // ignore if editor not ready yet
                                        }
                                    },
                                },
                            },
                            {
                                dataField: 'description',
                                label: { text: 'Mô tả' },
                                editorType: 'dxTextArea',
                                editorOptions: {
                                    height: 100,
                                    placeholder: 'Mô tả chi tiết công việc...',
                                },
                            },
                            {
                                dataField: 'assigneeIds',
                                label: { text: 'Người thực hiện' },
                                editorType: 'dxTagBox',
                                editorOptions: {
                                    dataSource: TaskService.getAllUsers(),
                                    displayExpr: 'name',
                                    valueExpr: 'id',
                                    placeholder: 'Chọn người thực hiện...',
                                    searchEnabled: true,
                                    showSelectionControls: true,
                                },
                                validationRules: [
                                    {
                                        type: 'required',
                                        message: 'Phải chọn người thực hiện',
                                    },
                                ],
                            },
                            {
                                dataField: 'priority',
                                label: { text: 'Độ ưu tiên' },
                                editorType: 'dxSelectBox',
                                editorOptions: {
                                    items: TaskService.PRIORITIES,
                                    placeholder: 'Chọn độ ưu tiên...',
                                },
                                validationRules: [
                                    {
                                        type: 'required',
                                        message: 'Phải chọn độ ưu tiên',
                                    },
                                ],
                            },
                            {
                                dataField: 'status',
                                label: { text: 'Trạng thái' },
                                editorType: 'dxSelectBox',
                                editorOptions: {
                                    items: TaskService.STATUSES,
                                    placeholder: 'Chọn trạng thái...',
                                },
                                validationRules: [
                                    {
                                        type: 'required',
                                        message: 'Phải chọn trạng thái',
                                    },
                                ],
                            },
                            {
                                dataField: 'startDate',
                                label: { text: 'Ngày bắt đầu' },
                                editorType: 'dxDateBox',
                                editorOptions: {
                                    type: 'date',
                                    displayFormat: 'dd/MM/yyyy',
                                },
                                validationRules: [
                                    {
                                        type: 'required',
                                        message: 'Phải chọn ngày bắt đầu',
                                    },
                                ],
                            },
                            {
                                dataField: 'dueDate',
                                label: { text: 'Deadline' },
                                editorType: 'dxDateBox',
                                editorOptions: {
                                    type: 'date',
                                    displayFormat: 'dd/MM/yyyy',
                                },
                                validationRules: [
                                    {
                                        type: 'required',
                                        message: 'Phải chọn deadline',
                                    },
                                    {
                                        type: 'custom',
                                        validationCallback: function (options) {
                                            const startDate = formContainer.dxForm('instance').option('formData').startDate;
                                            const dueDate = options.value;
                                            if (startDate && dueDate) {
                                                return new Date(dueDate) >= new Date(startDate);
                                            }
                                            return true;
                                        },
                                        message: 'Deadline phải sau ngày bắt đầu',
                                    },
                                ],
                            },
                        ],
                    });

                    // Buttons
                    const buttonsContainer = $('<div>').css({
                        marginTop: '20px',
                        display: 'flex',
                        justifyContent: 'flex-end',
                        gap: '10px',
                    });

                    $('<div>')
                        .dxButton({
                            text: 'Hủy',
                            onClick: function () {
                                createTaskPopup.hide();
                            },
                        })
                        .appendTo(buttonsContainer);

                    $('<div>')
                        .dxButton({
                            text: 'Tạo công việc',
                            type: 'default',
                            onClick: function () {
                                const form = formContainer.dxForm('instance');
                                const validationResult = form.validate();

                                if (validationResult.isValid) {
                                    const formData = form.option('formData');

                                    // Format dates to YYYY-MM-DD
                                    const taskData = {
                                        ...formData,
                                        startDate: formData.startDate.toISOString().split('T')[0],
                                        dueDate: formData.dueDate.toISOString().split('T')[0],
                                        createdBy: 1, // Default manager ID
                                        department: formData.department,
                                    };

                                    const result = TaskService.createTask(taskData);

                                    if (result.success) {
                                        showNotification('Tạo công việc thành công!', 'success');
                                        createTaskPopup.hide();
                                        refreshGrid();

                                        // Reset form
                                        form.resetValues();
                                    } else {
                                        showNotification(result.errors.join('<br>'), 'error');
                                    }
                                }
                            },
                        })
                        .appendTo(buttonsContainer);

                    contentElement.append(buttonsContainer);
                },
            })
            .dxPopup('instance');
    }

    // ============================================
    // USER MANAGEMENT
    // ============================================

    function initUserManagementPopup() {
        if ($('#userManagementPopup').length === 0) {
            $('<div id="userManagementPopup"></div>').appendTo('body');
        }

        $('#userManagementPopup')
            .dxPopup({
                width: 800,
                height: '70vh',
                showTitle: true,
                title: 'Quản lý Người dùng',
                visible: false,
                dragEnabled: true,
                contentTemplate: function (contentElement) {
                    const grid = $('<div id="usersGrid"></div>');
                    contentElement.append(grid);

                    grid.dxDataGrid({
                        dataSource: TaskService.getAllUsers(),
                        keyExpr: 'id',
                        columns: [
                            { dataField: 'id', caption: 'ID', width: 60 },
                            { dataField: 'avatar', caption: 'Avatar', width: 80 },
                            { dataField: 'name', caption: 'Tên', validationRules: [{ type: 'required' }] },
                            { dataField: 'email', caption: 'Email', validationRules: [{ type: 'required' }] },
                            { dataField: 'role', caption: 'Role' },
                            {
                                dataField: 'department',
                                caption: 'Phòng ban',
                                editorType: 'dxSelectBox',
                                editorOptions: { items: TaskService.getDepartments(), valueExpr: null },
                            },
                        ],
                        editing: {
                            mode: 'row',
                            allowUpdating: true,
                            allowAdding: true,
                            allowDeleting: true,
                        },
                        onRowInserted: function (e) {
                            const res = TaskService.createUser(e.data);
                            if (!res.success) showNotification(res.errors.join('\n'), 'error');
                            else showNotification('Người dùng đã được tạo', 'success');
                            refreshGrid();
                        },
                        onRowUpdated: function (e) {
                            const res = TaskService.updateUser(e.key, e.data);
                            if (!res.success) showNotification(res.errors.join('\n'), 'error');
                            else showNotification('Người dùng đã được cập nhật', 'success');
                            refreshGrid();
                        },
                        onRowRemoved: function (e) {
                            const res = TaskService.deleteUser(e.key);
                            if (!res.success) showNotification(res.errors.join('\n'), 'error');
                            else showNotification('Người dùng đã bị xóa', 'success');
                            refreshGrid();
                        },
                    }).dxDataGrid('instance');
                },
            })
            .dxPopup('instance');
    }

    function showUserManagementPopup() {
        if (!$('#userManagementPopup').dxPopup('instance')) initUserManagementPopup();
        $('#userManagementPopup').dxPopup('instance').show();
    }

    // ============================================
    // DEPARTMENT MANAGEMENT
    // ============================================

    function initDepartmentManagementPopup() {
        if ($('#departmentManagementPopup').length === 0) {
            $('<div id="departmentManagementPopup"></div>').appendTo('body');
        }

        $('#departmentManagementPopup')
            .dxPopup({
                width: 500,
                height: 'auto',
                showTitle: true,
                title: 'Quản lý Phòng ban',
                visible: false,
                contentTemplate: function (contentElement) {
                    const listDiv = $('<div id="depsList"></div>');
                    const input = $('<div id="newDepInput"></div>');
                    const btnDiv = $('<div style="margin-top:10px"></div>');
                    contentElement.append(listDiv).append(input).append(btnDiv);

                    listDiv.dxList({ dataSource: TaskService.getDepartments(), height: 240, selectionMode: 'single' });

                    input.dxTextBox({ placeholder: 'Tên phòng ban mới' });

                    btnDiv.dxButton({
                        text: 'Thêm',
                        onClick: function () {
                            const name = input.dxTextBox('instance').option('value');
                            const res = TaskService.createDepartment(name);
                            if (!res.success) showNotification(res.errors.join('\n'), 'error');
                            else {
                                showNotification('Đã thêm phòng ban', 'success');
                                // refresh list
                                listDiv.dxList('instance').option('dataSource', TaskService.getDepartments());
                                input.dxTextBox('instance').option('value', '');
                            }
                        },
                    });

                    btnDiv.dxButton({
                        text: 'Xóa đã chọn',
                        onClick: function () {
                            const sel = listDiv.dxList('instance').option('selectedItems')[0];
                            if (!sel) {
                                showNotification('Chưa chọn phòng ban', 'warning');
                                return;
                            }
                            const res = TaskService.deleteDepartment(sel);
                            if (!res.success) showNotification(res.errors.join('\n'), 'error');
                            else {
                                showNotification('Đã xóa phòng ban', 'success');
                                listDiv.dxList('instance').option('dataSource', TaskService.getDepartments());
                            }
                        },
                    });
                },
            })
            .dxPopup('instance');
    }

    function showDepartmentManagementPopup() {
        if (!$('#departmentManagementPopup').dxPopup('instance')) initDepartmentManagementPopup();
        $('#departmentManagementPopup').dxPopup('instance').show();
    }

    /**
     * Show create task popup
     */
    function showCreateTaskPopup() {
        if (createTaskPopup) {
            // Reset form
            const form = $('#createTaskForm').dxForm('instance');
            if (form) {
                form.resetValues();
                form.option('formData.status', 'Todo');
                form.option('formData.priority', 'Medium');
                form.option('formData.startDate', new Date());
            }

            // Refresh dynamic editors (departments, assignees)
            if (form) {
                try {
                    const depEditor = form.getEditor('department');
                    if (depEditor) depEditor.option('items', TaskService.getDepartments());
                    const assigneeEditor = form.getEditor('assigneeIds');
                    if (assigneeEditor) assigneeEditor.option('dataSource', TaskService.getAllUsers());
                } catch (err) {
                    // ignore
                }
            }

            createTaskPopup.show();
        }
    }

    // ============================================
    // TASK DETAIL POPUP
    // ============================================

    /**
     * Show task detail popup
     */
    function showTaskDetail(taskId) {
        const task = TaskService.getTaskById(taskId);
        if (!task) return showNotification('Không tìm thấy công việc', 'error');

        const history = TaskService.getTaskHistory(taskId);

        // Build popup content: left = editable form, right = history
        const content = $('<div style="display:flex;gap:20px;">');
        const formDiv = $('<div style="flex:1;min-width:360px;" id="detailTaskForm"></div>');
        const histDiv = $('<div style="width:300px;" id="detailHistory"></div>');

        // history HTML
        let historyHtml = '<div class="history-timeline">';
        history.forEach((h) => {
            historyHtml += `
                <div class="history-item">
                    <div class="history-header">
                        <span>${h.changedByAvatar}</span>
                        <span class="history-user">${h.changedByName}</span>
                        <span>→</span>
                        ${getStatusBadge(h.status)}
                        <span class="history-time">${formatDateTime(h.changedAt)}</span>
                    </div>
                    <div class="history-note">${h.note}</div>
                </div>
            `;
        });
        historyHtml += '</div>';

        histDiv.html(`<h4>Lịch sử</h4>` + historyHtml);
        content.append(formDiv).append(histDiv);

        // create form
        formDiv.dxForm({
            formData: {
                taskName: task.taskName,
                description: task.description,
                assigneeIds: task.assigneeIds || [],
                priority: task.priority,
                status: task.status,
                startDate: new Date(task.startDate),
                dueDate: new Date(task.dueDate),
            },
            items: [
                { dataField: 'taskName', label: { text: 'Tên công việc' }, editorType: 'dxTextBox' },
                { dataField: 'description', label: { text: 'Mô tả' }, editorType: 'dxTextArea', editorOptions: { height: 120 } },
                {
                    dataField: 'assigneeIds',
                    label: { text: 'Người thực hiện' },
                    editorType: 'dxTagBox',
                    editorOptions: { dataSource: TaskService.getAllUsers(), displayExpr: 'name', valueExpr: 'id', searchEnabled: true },
                },
                { dataField: 'priority', label: { text: 'Độ ưu tiên' }, editorType: 'dxSelectBox', editorOptions: { items: TaskService.PRIORITIES } },
                { dataField: 'status', label: { text: 'Trạng thái' }, editorType: 'dxSelectBox', editorOptions: { items: TaskService.STATUSES } },
                {
                    dataField: 'startDate',
                    label: { text: 'Ngày bắt đầu' },
                    editorType: 'dxDateBox',
                    editorOptions: { type: 'date', displayFormat: 'dd/MM/yyyy' },
                },
                { dataField: 'dueDate', label: { text: 'Deadline' }, editorType: 'dxDateBox', editorOptions: { type: 'date', displayFormat: 'dd/MM/yyyy' } },
            ],
        });

        $('#taskDetailContent').empty().append(content);

        detailTaskPopup = $('#taskDetailPopup')
            .dxPopup({
                width: 820,
                height: 'auto',
                maxHeight: '90vh',
                showTitle: true,
                title: `Chi tiết công việc #${task.id}`,
                dragEnabled: true,
                closeOnOutsideClick: true,
                showCloseButton: true,
                visible: true,
                toolbarItems: [
                    {
                        widget: 'dxButton',
                        toolbar: 'bottom',
                        location: 'after',
                        options: {
                            text: 'Hủy',
                            onClick: function () {
                                $('#taskDetailPopup').dxPopup('instance').hide();
                            },
                        },
                    },
                    {
                        widget: 'dxButton',
                        toolbar: 'bottom',
                        location: 'after',
                        options: {
                            text: 'Lưu',
                            type: 'default',
                            onClick: function () {
                                const form = $('#detailTaskForm').dxForm('instance');
                                const fd = form.option('formData');
                                const updates = {
                                    taskName: fd.taskName,
                                    description: fd.description,
                                    assigneeIds: fd.assigneeIds,
                                    priority: fd.priority,
                                    status: fd.status,
                                    startDate: fd.startDate ? fd.startDate.toISOString().split('T')[0] : null,
                                    dueDate: fd.dueDate ? fd.dueDate.toISOString().split('T')[0] : null,
                                };
                                const res = TaskService.updateTask(taskId, updates);
                                if (!res.success) showNotification(res.errors.join('\n'), 'error');
                                else {
                                    showNotification('Cập nhật thành công', 'success');
                                    refreshGrid();
                                    showTaskDetail(taskId);
                                }
                            },
                        },
                    },
                ],
            })
            .dxPopup('instance');
    }

    // ============================================
    // STATUS UPDATE POPUP
    // ============================================

    /**
     * Show status update popup
     */
    function showStatusUpdatePopup(task) {
        const popupContent = $('<div>');

        const form = $('<div>')
            .dxForm({
                formData: {
                    newStatus: task.status,
                    note: '',
                },
                items: [
                    {
                        dataField: 'newStatus',
                        label: { text: 'Trạng thái mới' },
                        editorType: 'dxSelectBox',
                        editorOptions: {
                            items: TaskService.STATUSES,
                            value: task.status,
                        },
                    },
                    {
                        dataField: 'note',
                        label: { text: 'Ghi chú' },
                        editorType: 'dxTextArea',
                        editorOptions: {
                            height: 80,
                            placeholder: 'Nhập ghi chú về thay đổi này...',
                        },
                    },
                ],
            })
            .appendTo(popupContent);

        const popup = $('<div>')
            .dxPopup({
                width: 500,
                height: 'auto',
                showTitle: true,
                title: `Cập nhật trạng thái: ${task.taskName}`,
                dragEnabled: true,
                closeOnOutsideClick: false,
                showCloseButton: true,
                visible: true,
                contentTemplate: function () {
                    return popupContent;
                },
                toolbarItems: [
                    {
                        widget: 'dxButton',
                        toolbar: 'bottom',
                        location: 'after',
                        options: {
                            text: 'Hủy',
                            onClick: function () {
                                popup.dxPopup('instance').hide();
                            },
                        },
                    },
                    {
                        widget: 'dxButton',
                        toolbar: 'bottom',
                        location: 'after',
                        options: {
                            text: 'Cập nhật',
                            type: 'default',
                            onClick: function () {
                                const formData = form.dxForm('instance').option('formData');

                                const result = TaskService.updateStatus(
                                    task.id,
                                    formData.newStatus,
                                    1, // Default user ID
                                    formData.note || `Cập nhật từ ${task.status} sang ${formData.newStatus}`,
                                );

                                if (result.success) {
                                    showNotification('Cập nhật trạng thái thành công!', 'success');
                                    popup.dxPopup('instance').hide();
                                    refreshGrid();
                                } else {
                                    showNotification(result.errors.join('<br>'), 'error');
                                }
                            },
                        },
                    },
                ],
            })
            .dxPopup('instance');
    }

    // ============================================
    // FILTER FUNCTIONS
    // ============================================

    /**
     * Apply filters
     */
    function applyFilters() {
        const statusFilter = $('#statusFilter').dxSelectBox('instance').option('value');
        const priorityFilter = $('#priorityFilter').dxSelectBox('instance').option('value');
        const assigneeFilter = $('#assigneeFilter').dxSelectBox('instance').option('value');
        const departmentFilter = $('#departmentFilter').dxSelectBox('instance') ? $('#departmentFilter').dxSelectBox('instance').option('value') : null;

        const filters = {};
        if (statusFilter) filters.status = statusFilter;
        if (priorityFilter) filters.priority = priorityFilter;
        if (assigneeFilter) filters.assigneeId = assigneeFilter;
        if (departmentFilter) filters.department = departmentFilter;

        const filteredTasks = TaskService.filterTasks(filters);
        dataGrid.option('dataSource', filteredTasks);
    }

    /**
     * Clear filters
     */
    function clearFilters() {
        $('#statusFilter').dxSelectBox('instance').option('value', null);
        $('#priorityFilter').dxSelectBox('instance').option('value', null);
        $('#assigneeFilter').dxSelectBox('instance').option('value', null);
        if ($('#departmentFilter').dxSelectBox('instance')) {
            $('#departmentFilter').dxSelectBox('instance').option('value', null);
        }

        refreshGrid();
    }

    // ============================================
    // PUBLIC INTERFACE
    // ============================================

    return {
        init: function () {
            initDataGrid();
            initCreateTaskPopup();
            renderStatistics();
        },

        showCreateTaskPopup: showCreateTaskPopup,
        showTaskDetail: showTaskDetail,
        refreshGrid: refreshGrid,
        applyFilters: applyFilters,
        clearFilters: clearFilters,
    };
})();

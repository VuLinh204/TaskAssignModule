/**
 * Task Assignment Tool - Main Application
 *
 * Entry point của ứng dụng
 * Khởi tạo và kết nối các components
 */

$(document).ready(function () {
    'use strict';

    console.log('🚀 Task Assignment Tool is starting...');

    // ============================================
    // INITIALIZE FILTER CONTROLS
    // ============================================

    // Status Filter
    // Department Filter
    $('#departmentFilter').dxSelectBox({
        placeholder: 'Lọc theo phòng ban...',
        showClearButton: true,
        items: TaskService.getDepartments(),
        onValueChanged: function () {
            TaskUI.applyFilters();
        },
    });

    // Status Filter
    $('#statusFilter').dxSelectBox({
        placeholder: 'Lọc theo trạng thái...',
        showClearButton: true,
        items: TaskService.STATUSES,
        onValueChanged: function () {
            TaskUI.applyFilters();
        },
    });

    // Priority Filter
    $('#priorityFilter').dxSelectBox({
        placeholder: 'Lọc theo độ ưu tiên...',
        showClearButton: true,
        items: TaskService.PRIORITIES,
        onValueChanged: function () {
            TaskUI.applyFilters();
        },
    });

    // Assignee Filter
    $('#assigneeFilter').dxSelectBox({
        placeholder: 'Lọc theo người thực hiện...',
        showClearButton: true,
        dataSource: TaskService.getAllUsers(),
        displayExpr: 'name',
        valueExpr: 'id',
        searchEnabled: true,
        onValueChanged: function () {
            TaskUI.applyFilters();
        },
    });

    // Clear Filters Button
    $('#clearFiltersBtn').dxButton({
        text: 'Xóa bộ lọc',
        icon: 'clear',
        onClick: function () {
            TaskUI.clearFilters();
        },
    });

    // ============================================
    // INITIALIZE ACTION BUTTONS
    // ============================================

    // Create Task Button
    $('#createTaskBtn').dxButton({
        text: 'Tạo công việc mới',
        icon: 'add',
        type: 'default',
        onClick: function () {
            TaskUI.showCreateTaskPopup();
        },
    });

    // Manage Departments Button
    $('#manageDepartmentsBtn').dxButton({
        text: 'Phòng ban',
        icon: 'group',
        onClick: function () {
            TaskUI.showDepartmentManagementPopup();
        },
    });

    // Manage Users Button
    $('#manageUsersBtn').dxButton({
        text: 'Người dùng',
        icon: 'user',
        onClick: function () {
            TaskUI.showUserManagementPopup();
        },
    });

    // Refresh Button
    $('#refreshBtn').dxButton({
        text: 'Làm mới',
        icon: 'refresh',
        onClick: function () {
            TaskUI.refreshGrid();
        },
    });

    // ============================================
    // INITIALIZE MAIN UI
    // ============================================

    TaskUI.init();

    // ============================================
    // KEYBOARD SHORTCUTS
    // ============================================

    $(document).on('keydown', function (e) {
        // Ctrl/Cmd + N: Tạo task mới
        if ((e.ctrlKey || e.metaKey) && e.key === 'n') {
            e.preventDefault();
            TaskUI.showCreateTaskPopup();
        }

        // F5: Refresh (prevent default và dùng custom refresh)
        if (e.key === 'F5') {
            e.preventDefault();
            TaskUI.refreshGrid();
        }
    });

    // ============================================
    // RESPONSIVE HANDLING
    // ============================================

    function handleResize() {
        // Có thể thêm logic responsive nếu cần
        const width = $(window).width();

        if (width < 768) {
            console.log('Mobile view');
            // Adjust UI for mobile
        } else if (width < 1024) {
            console.log('Tablet view');
            // Adjust UI for tablet
        } else {
            console.log('Desktop view');
            // Adjust UI for desktop
        }
    }

    $(window).on('resize', function () {
        clearTimeout(window.resizeTimer);
        window.resizeTimer = setTimeout(handleResize, 250);
    });

    handleResize(); // Initial call

    // ============================================
    // GLOBAL ERROR HANDLING
    // ============================================

    window.addEventListener('error', function (e) {
        console.error('Global error:', e.error);
        DevExpress.ui.notify({
            message: 'Đã xảy ra lỗi. Vui lòng thử lại.',
            type: 'error',
            displayTime: 3000,
        });
    });

    // ============================================
    // DEV TOOLS (chỉ hiển thị trong development)
    // ============================================

    if (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') {
        console.log('📊 Development mode enabled');

        // Expose services to window for debugging
        window.TaskService = TaskService;
        window.TaskUI = TaskUI;

        console.log('Available commands:');
        console.log('- TaskService.getStatistics()');
        console.log('- TaskService.getAllTasks()');
        console.log('- resetData()');
    }

    // ============================================
    // WELCOME MESSAGE
    // ============================================

    setTimeout(function () {
        DevExpress.ui.notify({
            message: '✨ Chào mừng bạn đến với Task Assignment Tool!',
            type: 'info',
            displayTime: 3000,
            position: {
                my: 'top center',
                at: 'top center',
                offset: '0 60',
            },
        });
    }, 500);

    console.log('✅ Task Assignment Tool is ready!');
    console.log('📝 Total tasks:', TaskService.getAllTasks().length);
    console.log('👥 Total users:', TaskService.getAllUsers().length);
});

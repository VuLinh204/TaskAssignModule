/**
 * Mock Data cho Task Assignment Tool
 *
 * Cấu trúc:
 * - users: Danh sách nhân viên
 * - tasks: Danh sách công việc
 * - taskStatusHistory: Lịch sử thay đổi trạng thái
 */

// ============================================
// USERS - Danh sách nhân viên
// ============================================
// Departments (explicit list to allow management)
const departments = ['Management', 'IT', 'QA', 'Design'];

const users = [
    {
        id: 1,
        name: 'Nguyễn Văn An',
        email: 'an.nguyen@company.com',
        role: 'Manager',
        avatar: '👨‍💼',
        department: 'Management',
    },
    {
        id: 2,
        name: 'Trần Thị Bình',
        email: 'binh.tran@company.com',
        role: 'Developer',
        avatar: '👩‍💻',
        department: 'IT',
    },
    {
        id: 3,
        name: 'Lê Văn Cường',
        email: 'cuong.le@company.com',
        role: 'Developer',
        avatar: '👨‍💻',
        department: 'IT',
    },
    {
        id: 4,
        name: 'Phạm Thị Dung',
        email: 'dung.pham@company.com',
        role: 'Tester',
        avatar: '👩‍🔬',
        department: 'QA',
    },
    {
        id: 5,
        name: 'Hoàng Văn Em',
        email: 'em.hoang@company.com',
        role: 'Designer',
        avatar: '👨‍🎨',
        department: 'Design',
    },
];

// ============================================
// TASKS - Danh sách công việc
// ============================================
const tasks = [
    {
        id: 1,
        taskName: 'Thiết kế giao diện trang chủ',
        description: 'Thiết kế mockup và prototype cho trang chủ website mới. Cần tuân thủ brand guideline và responsive trên mobile.',
        assigneeIds: [5],
        priority: 'High',
        status: 'In Progress',
        startDate: '2026-01-20',
        dueDate: '2026-01-28',
        createdBy: 1,
        createdAt: '2026-01-20T09:00:00',
        updatedAt: '2026-01-25T14:30:00',
    },
    {
        id: 2,
        taskName: 'Phát triển API đăng nhập',
        description: 'Xây dựng API authentication với JWT token. Bao gồm login, logout, refresh token và validate permission.',
        assigneeIds: [2],
        priority: 'High',
        status: 'In Progress',
        startDate: '2026-01-22',
        dueDate: '2026-01-30',
        createdBy: 1,
        createdAt: '2026-01-22T10:15:00',
        updatedAt: '2026-01-27T11:20:00',
    },
    {
        id: 3,
        taskName: 'Viết unit test cho module User',
        description: 'Đảm bảo coverage >= 80% cho tất cả functions trong User module. Sử dụng Jest framework.',
        assigneeIds: [3],
        priority: 'Medium',
        status: 'Todo',
        startDate: '2026-01-25',
        dueDate: '2026-02-02',
        createdBy: 1,
        createdAt: '2026-01-25T08:30:00',
        updatedAt: '2026-01-25T08:30:00',
    },
    {
        id: 4,
        taskName: 'Test tính năng thanh toán',
        description: 'Thực hiện regression test cho module thanh toán. Kiểm tra các payment gateway: VNPay, Momo, ZaloPay.',
        assigneeIds: [4],
        priority: 'High',
        status: 'Review',
        startDate: '2026-01-18',
        dueDate: '2026-01-27',
        createdBy: 1,
        createdAt: '2026-01-18T13:00:00',
        updatedAt: '2026-01-26T16:45:00',
    },
    {
        id: 5,
        taskName: 'Tối ưu database query',
        description: 'Phân tích và tối ưu các query chậm. Thêm index, optimize JOIN, cân nhắc caching cho các query thường xuyên.',
        assigneeIds: [2],
        priority: 'Medium',
        status: 'Done',
        startDate: '2026-01-15',
        dueDate: '2026-01-25',
        createdBy: 1,
        createdAt: '2026-01-15T09:00:00',
        updatedAt: '2026-01-24T17:30:00',
    },
    {
        id: 6,
        taskName: 'Cập nhật documentation',
        description: 'Cập nhật API documentation cho tất cả endpoints mới. Sử dụng Swagger/OpenAPI format.',
        assigneeIds: [3],
        priority: 'Low',
        status: 'Todo',
        startDate: '2026-01-28',
        dueDate: '2026-02-05',
        createdBy: 1,
        createdAt: '2026-01-27T10:00:00',
        updatedAt: '2026-01-27T10:00:00',
    },
    {
        id: 7,
        taskName: 'Fix bug hiển thị sai dữ liệu',
        description: 'Khắc phục lỗi hiển thị sai số liệu trong dashboard khi filter theo ngày. Bug được report từ production.',
        assigneeIds: [2],
        priority: 'High',
        status: 'Blocked',
        startDate: '2026-01-26',
        dueDate: '2026-01-29',
        createdBy: 1,
        createdAt: '2026-01-26T14:20:00',
        updatedAt: '2026-01-27T09:15:00',
        blockedReason: 'Chờ team Database cung cấp query logs',
    },
    {
        id: 8,
        taskName: 'Implement notification system',
        description: 'Xây dựng hệ thống thông báo real-time sử dụng WebSocket. Hỗ trợ push notification trên browser.',
        assigneeIds: [3],
        priority: 'Medium',
        status: 'In Progress',
        startDate: '2026-01-23',
        dueDate: '2026-02-03',
        createdBy: 1,
        createdAt: '2026-01-23T11:00:00',
        updatedAt: '2026-01-27T15:00:00',
    },
];

// ============================================
// TASK STATUS HISTORY - Lịch sử thay đổi
// ============================================
const taskStatusHistory = [
    // Task 1
    { taskId: 1, status: 'Todo', changedBy: 1, changedAt: '2026-01-20T09:00:00', note: 'Task được tạo' },
    { taskId: 1, status: 'In Progress', changedBy: 5, changedAt: '2026-01-21T10:30:00', note: 'Bắt đầu thiết kế' },

    // Task 2
    { taskId: 2, status: 'Todo', changedBy: 1, changedAt: '2026-01-22T10:15:00', note: 'Task được tạo' },
    { taskId: 2, status: 'In Progress', changedBy: 2, changedAt: '2026-01-23T09:00:00', note: 'Bắt đầu code API' },

    // Task 3
    { taskId: 3, status: 'Todo', changedBy: 1, changedAt: '2026-01-25T08:30:00', note: 'Task được tạo' },

    // Task 4
    { taskId: 4, status: 'Todo', changedBy: 1, changedAt: '2026-01-18T13:00:00', note: 'Task được tạo' },
    { taskId: 4, status: 'In Progress', changedBy: 4, changedAt: '2026-01-19T09:30:00', note: 'Bắt đầu test' },
    { taskId: 4, status: 'Review', changedBy: 4, changedAt: '2026-01-26T16:45:00', note: 'Hoàn thành test, chờ review kết quả' },

    // Task 5
    { taskId: 5, status: 'Todo', changedBy: 1, changedAt: '2026-01-15T09:00:00', note: 'Task được tạo' },
    { taskId: 5, status: 'In Progress', changedBy: 2, changedAt: '2026-01-16T08:00:00', note: 'Bắt đầu analyze queries' },
    { taskId: 5, status: 'Review', changedBy: 2, changedAt: '2026-01-23T14:00:00', note: 'Hoàn thành optimization' },
    { taskId: 5, status: 'Done', changedBy: 1, changedAt: '2026-01-24T17:30:00', note: 'Đã verify performance improvement' },

    // Task 6
    { taskId: 6, status: 'Todo', changedBy: 1, changedAt: '2026-01-27T10:00:00', note: 'Task được tạo' },

    // Task 7
    { taskId: 7, status: 'Todo', changedBy: 1, changedAt: '2026-01-26T14:20:00', note: 'Task được tạo - Priority High' },
    { taskId: 7, status: 'In Progress', changedBy: 2, changedAt: '2026-01-26T15:00:00', note: 'Bắt đầu investigate bug' },
    { taskId: 7, status: 'Blocked', changedBy: 2, changedAt: '2026-01-27T09:15:00', note: 'Blocked - chờ query logs từ DBA team' },

    // Task 8
    { taskId: 8, status: 'Todo', changedBy: 1, changedAt: '2026-01-23T11:00:00', note: 'Task được tạo' },
    { taskId: 8, status: 'In Progress', changedBy: 3, changedAt: '2026-01-24T09:30:00', note: 'Setup WebSocket server' },
];

// ============================================
// HELPER FUNCTIONS
// ============================================

/**
 * Lấy thông tin user theo ID
 */
function getUserById(userId) {
    return users.find((u) => u.id === userId);
}

/**
 * Lấy tên user theo ID
 */
function getUserName(userId) {
    const user = getUserById(userId);
    return user ? user.name : 'Unknown';
}

/**
 * Lấy danh sách tasks
 */
function getTasks() {
    return [...tasks]; // Return copy để tránh modify trực tiếp
}

/**
 * Lấy task theo ID
 */
function getTaskById(taskId) {
    return tasks.find((t) => t.id === taskId);
}

/**
 * Lấy lịch sử của một task
 */
function getTaskHistory(taskId) {
    return taskStatusHistory.filter((h) => h.taskId === taskId).sort((a, b) => new Date(b.changedAt) - new Date(a.changedAt));
}

/**
 * Reset data về trạng thái ban đầu
 * Sử dụng khi cần demo hoặc test
 */
function resetData() {
    console.log('Data has been reset to initial state');
    location.reload();
}

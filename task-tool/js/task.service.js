/**
 * Task Service - single clean implementation
 * Provides CRUD for tasks, users and departments and persists to localStorage.
 */

const TaskService = (function () {
    'use strict';

    let nextTaskId = tasks.length > 0 ? Math.max(...tasks.map(t => t.id)) + 1 : 1;
    let nextUserId = users.length > 0 ? Math.max(...users.map(u => u.id)) + 1 : 1;

    const STORAGE_KEYS = {
        TASKS: 'tasktool_tasks',
        HISTORY: 'tasktool_taskHistory',
        USERS: 'tasktool_users',
        DEPARTMENTS: 'tasktool_departments'
    };

    function loadFromStorage() {
        try {
            const sTasks = localStorage.getItem(STORAGE_KEYS.TASKS);
            const sHistory = localStorage.getItem(STORAGE_KEYS.HISTORY);
            const sUsers = localStorage.getItem(STORAGE_KEYS.USERS);
            const sDeps = localStorage.getItem(STORAGE_KEYS.DEPARTMENTS);

            if (sDeps) {
                const parsed = JSON.parse(sDeps);
                if (Array.isArray(parsed)) {
                    departments.length = 0;
                    parsed.forEach(d => departments.push(d));
                }
            }

            if (sUsers) {
                const parsedUsers = JSON.parse(sUsers);
                users.length = 0;
                parsedUsers.forEach(u => users.push(u));
                nextUserId = users.length > 0 ? Math.max(...users.map(uu => uu.id)) + 1 : nextUserId;
            }

            if (sTasks) {
                const parsedTasks = JSON.parse(sTasks);
                tasks.length = 0;
                parsedTasks.forEach(t => tasks.push(t));
                nextTaskId = tasks.length > 0 ? Math.max(...tasks.map(tt => tt.id)) + 1 : nextTaskId;
            }

            if (sHistory) {
                const parsedHistory = JSON.parse(sHistory);
                taskStatusHistory.length = 0;
                parsedHistory.forEach(h => taskStatusHistory.push(h));
            }
        } catch (err) {
            console.error('loadFromStorage failed', err);
        }
    }

    function saveToStorage() {
        try {
            localStorage.setItem(STORAGE_KEYS.TASKS, JSON.stringify(tasks));
            localStorage.setItem(STORAGE_KEYS.HISTORY, JSON.stringify(taskStatusHistory));
            localStorage.setItem(STORAGE_KEYS.USERS, JSON.stringify(users));
            localStorage.setItem(STORAGE_KEYS.DEPARTMENTS, JSON.stringify(departments));
        } catch (err) {
            console.error('saveToStorage failed', err);
        }
    }

    function validateTask(taskData) {
        const errors = [];
        if (!taskData.taskName || taskData.taskName.trim() === '') errors.push('Tên công việc không được để trống');
        if (!taskData.assigneeId) errors.push('Phải chọn người thực hiện');
        if (!taskData.priority) errors.push('Phải chọn độ ưu tiên');
        if (!taskData.status) errors.push('Phải chọn trạng thái');
        if (!taskData.startDate) errors.push('Phải chọn ngày bắt đầu');
        if (!taskData.dueDate) errors.push('Phải chọn deadline');
        if (taskData.startDate && taskData.dueDate && new Date(taskData.startDate) > new Date(taskData.dueDate)) errors.push('Ngày bắt đầu phải trước deadline');
        return errors;
    }

    function calculateProgress(task) {
        const statusProgress = { 'Todo': 0, 'In Progress': 30, 'Review': 70, 'Done': 100, 'Blocked': 50 };
        let progress = statusProgress[task.status] || 0;
        if (task.status === 'Done') return 100;
        const now = new Date();
        const start = new Date(task.startDate);
        const due = new Date(task.dueDate);
        if (now >= due && task.status !== 'Done') return Math.min(progress, 95);
        if (now >= start) {
            const totalDays = (due - start) / (1000 * 60 * 60 * 24) || 1;
            const daysPassed = (now - start) / (1000 * 60 * 60 * 24);
            const timeProgress = Math.min((daysPassed / totalDays) * 100, 95);
            progress = Math.max(progress, timeProgress);
        }
        return Math.round(progress);
    }

    function isOverdue(task) { if (task.status === 'Done') return false; return new Date() > new Date(task.dueDate); }

    loadFromStorage();

    return {
        getAllTasks: function () {
            return tasks.map(task => {
                const assignee = getUserById(task.assigneeId);
                const creator = getUserById(task.createdBy);
                return {
                    ...task,
                    department: assignee ? assignee.department : (task.department || 'N/A'),
                    assigneeName: assignee ? assignee.name : 'N/A',
                    assigneeAvatar: assignee ? assignee.avatar : '👤',
                    creatorName: creator ? creator.name : 'N/A',
                    progress: calculateProgress(task),
                    isOverdue: isOverdue(task),
                    daysRemaining: this.getDaysRemaining(task)
                };
            });
        },

        getTaskById: function (taskId) {
            const task = tasks.find(t => t.id === taskId);
            if (!task) return null;
            const assignee = getUserById(task.assigneeId);
            const creator = getUserById(task.createdBy);
            return {
                ...task,
                department: assignee ? assignee.department : (task.department || 'N/A'),
                assigneeName: assignee ? assignee.name : 'N/A',
                assigneeAvatar: assignee ? assignee.avatar : '👤',
                creatorName: creator ? creator.name : 'N/A',
                progress: calculateProgress(task),
                isOverdue: isOverdue(task),
                daysRemaining: this.getDaysRemaining(task)
            };
        },

        createTask: function (taskData) {
            const errors = validateTask(taskData);
            if (errors.length) return { success: false, errors };
            const newTask = {
                id: nextTaskId++,
                taskName: taskData.taskName.trim(),
                description: taskData.description ? taskData.description.trim() : '',
                assigneeId: parseInt(taskData.assigneeId) || null,
                department: taskData.department || (getUserById(parseInt(taskData.assigneeId)) || {}).department || 'N/A',
                priority: taskData.priority,
                status: taskData.status || 'Todo',
                startDate: taskData.startDate,
                dueDate: taskData.dueDate,
                createdBy: taskData.createdBy || 1,
                createdAt: new Date().toISOString(),
                updatedAt: new Date().toISOString()
            };
            tasks.push(newTask);
            taskStatusHistory.push({ taskId: newTask.id, status: newTask.status, changedBy: newTask.createdBy, changedAt: newTask.createdAt, note: 'Task được tạo' });
            saveToStorage();
            return { success: true, task: newTask };
        },

        updateTask: function (taskId, updates) {
            const idx = tasks.findIndex(t => t.id === taskId);
            if (idx === -1) return { success: false, errors: ['Task không tồn tại'] };
            const task = tasks[idx];
            const oldStatus = task.status;
            Object.assign(task, updates, { updatedAt: new Date().toISOString() });
            if (updates.assigneeId) {
                const u = getUserById(parseInt(updates.assigneeId));
                if (u && u.department) task.department = u.department;
            }
            const errors = validateTask(task);
            if (errors.length) return { success: false, errors };
            if (updates.status && updates.status !== oldStatus) {
                taskStatusHistory.push({ taskId: taskId, status: updates.status, changedBy: updates.changedBy || 1, changedAt: new Date().toISOString(), note: updates.statusNote || `Cập nhật từ ${oldStatus} sang ${updates.status}` });
            }
            saveToStorage();
            return { success: true, task };
        },

        updateStatus: function (taskId, newStatus, changedBy, note) { return this.updateTask(taskId, { status: newStatus, changedBy, statusNote: note }); },

        deleteTask: function (taskId) {
            const idx = tasks.findIndex(t => t.id === taskId);
            if (idx === -1) return { success: false, errors: ['Task không tồn tại'] };
            tasks.splice(idx, 1);
            for (let i = taskStatusHistory.length - 1; i >= 0; i--) if (taskStatusHistory[i].taskId === taskId) taskStatusHistory.splice(i, 1);
            saveToStorage();
            return { success: true };
        },

        getTaskHistory: function (taskId) { return taskStatusHistory.filter(h => h.taskId === taskId).map(h => ({ ...h, changedByName: (getUserById(h.changedBy) || {}).name || 'Unknown', changedByAvatar: (getUserById(h.changedBy) || {}).avatar || '👤' })).sort((a, b) => new Date(b.changedAt) - new Date(a.changedAt)); },

        getDaysRemaining: function (task) { if (task.status === 'Done') return 0; const now = new Date(); const due = new Date(task.dueDate); return Math.ceil((due - now) / (1000 * 60 * 60 * 24)); },

        filterTasks: function (filters) {
            let filtered = this.getAllTasks();
            if (filters.status) filtered = filtered.filter(t => t.status === filters.status);
            if (filters.priority) filtered = filtered.filter(t => t.priority === filters.priority);
            if (filters.assigneeId) filtered = filtered.filter(t => t.assigneeId === parseInt(filters.assigneeId));
            if (filters.department) filtered = filtered.filter(t => t.department === filters.department);
            if (filters.searchText) {
                const s = filters.searchText.toLowerCase();
                filtered = filtered.filter(t => t.taskName.toLowerCase().includes(s) || (t.description && t.description.toLowerCase().includes(s)));
            }
            if (filters.overdueOnly) filtered = filtered.filter(t => t.isOverdue);
            return filtered;
        },

        getStatistics: function () { const all = this.getAllTasks(); return { total: all.length, todo: all.filter(t => t.status === 'Todo').length, inProgress: all.filter(t => t.status === 'In Progress').length, review: all.filter(t => t.status === 'Review').length, done: all.filter(t => t.status === 'Done').length, blocked: all.filter(t => t.status === 'Blocked').length, overdue: all.filter(t => t.isOverdue).length, highPriority: all.filter(t => t.priority === 'High').length }; },

        // Users CRUD
        getAllUsers: function () { return users; },

        createUser: function (userData) {
            if (!userData.name || !userData.email) return { success: false, errors: ['Name and email required'] };
            const newUser = { id: nextUserId++, name: userData.name, email: userData.email, role: userData.role || 'Staff', avatar: userData.avatar || '👤', department: userData.department || null };
            users.push(newUser);
            saveToStorage();
            return { success: true, user: newUser };
        },

        updateUser: function (userId, updates) {
            const idx = users.findIndex(u => u.id === userId);
            if (idx === -1) return { success: false, errors: ['User not found'] };
            Object.assign(users[idx], updates);
            if (updates.department !== undefined) {
                tasks.forEach(t => { if (t.assigneeId === userId) t.department = updates.department; });
            }
            saveToStorage();
            return { success: true, user: users[idx] };
        },

        deleteUser: function (userId) {
            const idx = users.findIndex(u => u.id === userId);
            if (idx === -1) return { success: false, errors: ['User not found'] };
            users.splice(idx, 1);
            tasks.forEach(t => { if (t.assigneeId === userId) { t.assigneeId = null; t.department = 'N/A'; } });
            saveToStorage();
            return { success: true };
        },

        // Departments CRUD
        getDepartments: function () { return departments.slice(); },

        createDepartment: function (name) {
            if (!name) return { success: false, errors: ['Tên phòng ban trống'] };
            if (departments.includes(name)) return { success: false, errors: ['Phòng ban đã tồn tại'] };
            departments.push(name);
            saveToStorage();
            return { success: true };
        },

        updateDepartment: function (oldName, newName) {
            const idx = departments.findIndex(d => d === oldName);
            if (idx === -1) return { success: false, errors: ['Phòng ban không tồn tại'] };
            if (!newName) return { success: false, errors: ['Tên mới rỗng'] };
            departments[idx] = newName;
            users.forEach(u => { if (u.department === oldName) u.department = newName; });
            tasks.forEach(t => { if (t.department === oldName) t.department = newName; });
            saveToStorage();
            return { success: true };
        },

        deleteDepartment: function (name) {
            const idx = departments.findIndex(d => d === name);
            if (idx === -1) return { success: false, errors: ['Phòng ban không tồn tại'] };
            departments.splice(idx, 1);
            users.forEach(u => { if (u.department === name) u.department = null; });
            tasks.forEach(t => { if (t.department === name) t.department = 'N/A'; });
            saveToStorage();
            return { success: true };
        },

        PRIORITIES: ['Low', 'Medium', 'High'],
        STATUSES: ['Todo', 'In Progress', 'Review', 'Done', 'Blocked']
    };

})();
/**
 * Task Service - clean implementation
 * Includes CRUD for tasks, users and departments, with localStorage persistence
 */

const TaskService = (function () {
    'use strict';

    // IDs
    let nextTaskId = tasks.length > 0 ? Math.max(...tasks.map(t => t.id)) + 1 : 1;
    let nextUserId = users.length > 0 ? Math.max(...users.map(u => u.id)) + 1 : 1;

    const STORAGE_KEYS = {
        TASKS: 'tasktool_tasks',
        HISTORY: 'tasktool_taskHistory',
        USERS: 'tasktool_users',
        DEPARTMENTS: 'tasktool_departments'
    };

    function loadFromStorage() {
        try {
            const sTasks = localStorage.getItem(STORAGE_KEYS.TASKS);
            const sHistory = localStorage.getItem(STORAGE_KEYS.HISTORY);
            const sUsers = localStorage.getItem(STORAGE_KEYS.USERS);
            const sDeps = localStorage.getItem(STORAGE_KEYS.DEPARTMENTS);

            if (sDeps) {
                const parsed = JSON.parse(sDeps);
                }

            })();
                isOverdue: isOverdue(task),
                daysRemaining: this.getDaysRemaining(task)
            };
        },

        /**
         * Tạo task mới
         */
        createTask: function (taskData) {
            // Validate
            const errors = validateTask(taskData);
            if (errors.length > 0) {
                return { success: false, errors: errors };
            }

            // Tạo task mới
            const newTask = {
                id: nextTaskId++,
                taskName: taskData.taskName.trim(),
                description: taskData.description ? taskData.description.trim() : '',
                assigneeId: parseInt(taskData.assigneeId),
                department: taskData.department || (getUserById(parseInt(taskData.assigneeId)) || {}).department || 'N/A',
                priority: taskData.priority,
                status: taskData.status || 'Todo',
                startDate: taskData.startDate,
                dueDate: taskData.dueDate,
                createdBy: taskData.createdBy || 1, // Default manager
                createdAt: new Date().toISOString(),
                updatedAt: new Date().toISOString()
            };

            // Thêm vào array
            tasks.push(newTask);

            // Thêm vào history
            taskStatusHistory.push({
                taskId: newTask.id,
                status: newTask.status,
                changedBy: newTask.createdBy,
                changedAt: newTask.createdAt,
                note: 'Task được tạo'
            });

            saveToStorage();

            return { success: true, task: newTask };
        },

        /**
         * Cập nhật task
         */
        updateTask: function (taskId, updates) {
            const taskIndex = tasks.findIndex(t => t.id === taskId);
            if (taskIndex === -1) {
                /**
                 * Task Service - single clean implementation
                 * Provides CRUD for tasks, users and departments and persists to localStorage.
                 */

                const TaskService = (function () {
                    'use strict';

                    let nextTaskId = tasks.length > 0 ? Math.max(...tasks.map(t => t.id)) + 1 : 1;
                    let nextUserId = users.length > 0 ? Math.max(...users.map(u => u.id)) + 1 : 1;

                    const STORAGE_KEYS = {
                        TASKS: 'tasktool_tasks',
                        HISTORY: 'tasktool_taskHistory',
                        USERS: 'tasktool_users',
                        DEPARTMENTS: 'tasktool_departments'
                    };

                    function loadFromStorage() {
                        try {
                            const sTasks = localStorage.getItem(STORAGE_KEYS.TASKS);
                            const sHistory = localStorage.getItem(STORAGE_KEYS.HISTORY);
                            const sUsers = localStorage.getItem(STORAGE_KEYS.USERS);
                            const sDeps = localStorage.getItem(STORAGE_KEYS.DEPARTMENTS);

                            if (sDeps) {
                                const parsed = JSON.parse(sDeps);
                                if (Array.isArray(parsed)) {
                                    departments.length = 0;
                                    parsed.forEach(d => departments.push(d));
                                }
                            }

                            if (sUsers) {
                                const parsedUsers = JSON.parse(sUsers);
                                users.length = 0;
                                parsedUsers.forEach(u => users.push(u));
                                nextUserId = users.length > 0 ? Math.max(...users.map(uu => uu.id)) + 1 : nextUserId;
                            }

                            if (sTasks) {
                                const parsedTasks = JSON.parse(sTasks);
                                tasks.length = 0;
                                parsedTasks.forEach(t => tasks.push(t));
                                nextTaskId = tasks.length > 0 ? Math.max(...tasks.map(tt => tt.id)) + 1 : nextTaskId;
                            }

                            if (sHistory) {
                                const parsedHistory = JSON.parse(sHistory);
                                taskStatusHistory.length = 0;
                                parsedHistory.forEach(h => taskStatusHistory.push(h));
                            }
                        } catch (err) {
                            console.error('loadFromStorage failed', err);
                        }
                    }

                    function saveToStorage() {
                        try {
                            localStorage.setItem(STORAGE_KEYS.TASKS, JSON.stringify(tasks));
                            localStorage.setItem(STORAGE_KEYS.HISTORY, JSON.stringify(taskStatusHistory));
                            localStorage.setItem(STORAGE_KEYS.USERS, JSON.stringify(users));
                            localStorage.setItem(STORAGE_KEYS.DEPARTMENTS, JSON.stringify(departments));
                        } catch (err) {
                            console.error('saveToStorage failed', err);
                        }
                    }

                    function validateTask(taskData) {
                        const errors = [];
                        if (!taskData.taskName || taskData.taskName.trim() === '') errors.push('Tên công việc không được để trống');
                        if (!taskData.assigneeId) errors.push('Phải chọn người thực hiện');
                        if (!taskData.priority) errors.push('Phải chọn độ ưu tiên');
                        if (!taskData.status) errors.push('Phải chọn trạng thái');
                        if (!taskData.startDate) errors.push('Phải chọn ngày bắt đầu');
                        if (!taskData.dueDate) errors.push('Phải chọn deadline');
                        if (taskData.startDate && taskData.dueDate && new Date(taskData.startDate) > new Date(taskData.dueDate)) errors.push('Ngày bắt đầu phải trước deadline');
                        return errors;
                    }

                    function calculateProgress(task) {
                        const statusProgress = { 'Todo': 0, 'In Progress': 30, 'Review': 70, 'Done': 100, 'Blocked': 50 };
                        let progress = statusProgress[task.status] || 0;
                        if (task.status === 'Done') return 100;
                        const now = new Date();
                        const start = new Date(task.startDate);
                        const due = new Date(task.dueDate);
                        if (now >= due && task.status !== 'Done') return Math.min(progress, 95);
                        if (now >= start) {
                            const totalDays = (due - start) / (1000 * 60 * 60 * 24) || 1;
                            const daysPassed = (now - start) / (1000 * 60 * 60 * 24);
                            const timeProgress = Math.min((daysPassed / totalDays) * 100, 95);
                            progress = Math.max(progress, timeProgress);
                        }
                        return Math.round(progress);
                    }

                    function isOverdue(task) { if (task.status === 'Done') return false; return new Date() > new Date(task.dueDate); }

                    loadFromStorage();

                    return {
                        getAllTasks: function () {
                            return tasks.map(task => {
                                const assignee = getUserById(task.assigneeId);
                                const creator = getUserById(task.createdBy);
                                return {
                                    ...task,
                                    department: assignee ? assignee.department : (task.department || 'N/A'),
                                    assigneeName: assignee ? assignee.name : 'N/A',
                                    assigneeAvatar: assignee ? assignee.avatar : '👤',
                                    creatorName: creator ? creator.name : 'N/A',
                                    progress: calculateProgress(task),
                                    isOverdue: isOverdue(task),
                                    daysRemaining: this.getDaysRemaining(task)
                                };
                            });
                        },

                        getTaskById: function (taskId) {
                            const task = tasks.find(t => t.id === taskId);
                            if (!task) return null;
                            const assignee = getUserById(task.assigneeId);
                            const creator = getUserById(task.createdBy);
                            return {
                                ...task,
                                department: assignee ? assignee.department : (task.department || 'N/A'),
                                assigneeName: assignee ? assignee.name : 'N/A',
                                assigneeAvatar: assignee ? assignee.avatar : '👤',
                                creatorName: creator ? creator.name : 'N/A',
                                progress: calculateProgress(task),
                                isOverdue: isOverdue(task),
                                daysRemaining: this.getDaysRemaining(task)
                            };
                        },

                        createTask: function (taskData) {
                            const errors = validateTask(taskData);
                            if (errors.length) return { success: false, errors };
                            const newTask = {
                                id: nextTaskId++,
                                taskName: taskData.taskName.trim(),
                                description: taskData.description ? taskData.description.trim() : '',
                                assigneeId: parseInt(taskData.assigneeId) || null,
                                department: taskData.department || (getUserById(parseInt(taskData.assigneeId)) || {}).department || 'N/A',
                                priority: taskData.priority,
                                status: taskData.status || 'Todo',
                                startDate: taskData.startDate,
                                dueDate: taskData.dueDate,
                                createdBy: taskData.createdBy || 1,
                                createdAt: new Date().toISOString(),
                                updatedAt: new Date().toISOString()
                            };
                            tasks.push(newTask);
                            taskStatusHistory.push({ taskId: newTask.id, status: newTask.status, changedBy: newTask.createdBy, changedAt: newTask.createdAt, note: 'Task được tạo' });
                            saveToStorage();
                            return { success: true, task: newTask };
                        },

                        updateTask: function (taskId, updates) {
                            const idx = tasks.findIndex(t => t.id === taskId);
                            if (idx === -1) return { success: false, errors: ['Task không tồn tại'] };
                            const task = tasks[idx];
                            const oldStatus = task.status;
                            Object.assign(task, updates, { updatedAt: new Date().toISOString() });
                            if (updates.assigneeId) {
                                const u = getUserById(parseInt(updates.assigneeId));
                                if (u && u.department) task.department = u.department;
                            }
                            const errors = validateTask(task);
                            if (errors.length) return { success: false, errors };
                            if (updates.status && updates.status !== oldStatus) {
                                taskStatusHistory.push({ taskId: taskId, status: updates.status, changedBy: updates.changedBy || 1, changedAt: new Date().toISOString(), note: updates.statusNote || `Cập nhật từ ${oldStatus} sang ${updates.status}` });
                            }
                            saveToStorage();
                            return { success: true, task };
                        },

                        updateStatus: function (taskId, newStatus, changedBy, note) { return this.updateTask(taskId, { status: newStatus, changedBy, statusNote: note }); },

                        deleteTask: function (taskId) {
                            const idx = tasks.findIndex(t => t.id === taskId);
                            if (idx === -1) return { success: false, errors: ['Task không tồn tại'] };
                            tasks.splice(idx, 1);
                            for (let i = taskStatusHistory.length - 1; i >= 0; i--) if (taskStatusHistory[i].taskId === taskId) taskStatusHistory.splice(i, 1);
                            saveToStorage();
                            return { success: true };
                        },

                        getTaskHistory: function (taskId) { return taskStatusHistory.filter(h => h.taskId === taskId).map(h => ({ ...h, changedByName: (getUserById(h.changedBy) || {}).name || 'Unknown', changedByAvatar: (getUserById(h.changedBy) || {}).avatar || '👤' })).sort((a, b) => new Date(b.changedAt) - new Date(a.changedAt)); },

                        getDaysRemaining: function (task) { if (task.status === 'Done') return 0; const now = new Date(); const due = new Date(task.dueDate); return Math.ceil((due - now) / (1000 * 60 * 60 * 24)); },

                        filterTasks: function (filters) {
                            let filtered = this.getAllTasks();
                            if (filters.status) filtered = filtered.filter(t => t.status === filters.status);
                            if (filters.priority) filtered = filtered.filter(t => t.priority === filters.priority);
                            if (filters.assigneeId) filtered = filtered.filter(t => t.assigneeId === parseInt(filters.assigneeId));
                            if (filters.department) filtered = filtered.filter(t => t.department === filters.department);
                            if (filters.searchText) {
                                const s = filters.searchText.toLowerCase();
                                filtered = filtered.filter(t => t.taskName.toLowerCase().includes(s) || (t.description && t.description.toLowerCase().includes(s)));
                            }
                            if (filters.overdueOnly) filtered = filtered.filter(t => t.isOverdue);
                            return filtered;
                        },

                        getStatistics: function () { const all = this.getAllTasks(); return { total: all.length, todo: all.filter(t => t.status === 'Todo').length, inProgress: all.filter(t => t.status === 'In Progress').length, review: all.filter(t => t.status === 'Review').length, done: all.filter(t => t.status === 'Done').length, blocked: all.filter(t => t.status === 'Blocked').length, overdue: all.filter(t => t.isOverdue).length, highPriority: all.filter(t => t.priority === 'High').length }; },

                        // Users CRUD
                        getAllUsers: function () { return users; },

                        createUser: function (userData) {
                            if (!userData.name || !userData.email) return { success: false, errors: ['Name and email required'] };
                            const newUser = { id: nextUserId++, name: userData.name, email: userData.email, role: userData.role || 'Staff', avatar: userData.avatar || '👤', department: userData.department || null };
                            users.push(newUser);
                            saveToStorage();
                            return { success: true, user: newUser };
                        },

                        updateUser: function (userId, updates) {
                            const idx = users.findIndex(u => u.id === userId);
                            if (idx === -1) return { success: false, errors: ['User not found'] };
                            Object.assign(users[idx], updates);
                            if (updates.department !== undefined) {
                                tasks.forEach(t => { if (t.assigneeId === userId) t.department = updates.department; });
                            }
                            saveToStorage();
                            return { success: true, user: users[idx] };
                        },

                        deleteUser: function (userId) {
                            const idx = users.findIndex(u => u.id === userId);
                            if (idx === -1) return { success: false, errors: ['User not found'] };
                            users.splice(idx, 1);
                            tasks.forEach(t => { if (t.assigneeId === userId) { t.assigneeId = null; t.department = 'N/A'; } });
                            saveToStorage();
                            return { success: true };
                        },

                        // Departments CRUD
                        getDepartments: function () { return departments.slice(); },

                        createDepartment: function (name) {
                            if (!name) return { success: false, errors: ['Tên phòng ban trống'] };
                            if (departments.includes(name)) return { success: false, errors: ['Phòng ban đã tồn tại'] };
                            departments.push(name);
                            saveToStorage();
                            return { success: true };
                        },

                        updateDepartment: function (oldName, newName) {
                            const idx = departments.findIndex(d => d === oldName);
                            if (idx === -1) return { success: false, errors: ['Phòng ban không tồn tại'] };
                            if (!newName) return { success: false, errors: ['Tên mới rỗng'] };
                            departments[idx] = newName;
                            users.forEach(u => { if (u.department === oldName) u.department = newName; });
                            tasks.forEach(t => { if (t.department === oldName) t.department = newName; });
                            saveToStorage();
                            return { success: true };
                        },

                        deleteDepartment: function (name) {
                            const idx = departments.findIndex(d => d === name);
                            if (idx === -1) return { success: false, errors: ['Phòng ban không tồn tại'] };
                            departments.splice(idx, 1);
                            users.forEach(u => { if (u.department === name) u.department = null; });
                            tasks.forEach(t => { if (t.department === name) t.department = 'N/A'; });
                            saveToStorage();
                            return { success: true };
                        },

                        PRIORITIES: ['Low', 'Medium', 'High'],
                        STATUSES: ['Todo', 'In Progress', 'Review', 'Done', 'Blocked']
                    };

                })();

        if (!taskData.dueDate) {
            errors.push('Phải chọn deadline');
        }

        // Kiểm tra logic ngày
        if (taskData.startDate && taskData.dueDate) {
            if (new Date(taskData.startDate) > new Date(taskData.dueDate)) {
                errors.push('Ngày bắt đầu phải trước deadline');
            }
        }

        return errors;
    }

    /**
     * Tính progress dựa trên status và ngày
     */
    function calculateProgress(task) {
        // Progress theo status
        const statusProgress = {
            'Todo': 0,
            'In Progress': 30,
            'Review': 70,
            'Done': 100,
            'Blocked': 50
        };

        let progress = statusProgress[task.status] || 0;

        // Nếu đã done thì 100%
        if (task.status === 'Done') {
            return 100;
        }

        // Tính thêm progress dựa trên thời gian
        const now = new Date();
        const start = new Date(task.startDate);
        const due = new Date(task.dueDate);

        if (now >= due && task.status !== 'Done') {
            // Quá hạn
            return Math.min(progress, 95); // Không cho 100% nếu chưa done
        }

        if (now >= start) {
            const totalDays = (due - start) / (1000 * 60 * 60 * 24);
            const daysPassed = (now - start) / (1000 * 60 * 60 * 24);
            const timeProgress = Math.min((daysPassed / totalDays) * 100, 95);

            // Lấy max giữa time progress và status progress
            progress = Math.max(progress, timeProgress);
        }

        return Math.round(progress);
    }

    /**
     * Kiểm tra task có bị quá hạn không
     */
    function isOverdue(task) {
        if (task.status === 'Done') return false;
        return new Date() > new Date(task.dueDate);
    }

    // ============================================
    // PUBLIC METHODS
    // ============================================

    return {
        /**
         * Lấy tất cả tasks với thông tin mở rộng
         */
        getAllTasks: function () {
            return tasks.map(task => {
                const assignee = getUserById(task.assigneeId);
                const creator = getUserById(task.createdBy);

                return {
                    ...task,
                    department: assignee ? assignee.department : (task.department || 'N/A'),
                    assigneeName: assignee ? assignee.name : 'N/A',
                    assigneeAvatar: assignee ? assignee.avatar : '👤',
                    creatorName: creator ? creator.name : 'N/A',
                    progress: calculateProgress(task),
                    isOverdue: isOverdue(task),
                    daysRemaining: this.getDaysRemaining(task)
                };
            });
        },

        /**
         * Lấy task theo ID
         */
        getTaskById: function (taskId) {
            const task = tasks.find(t => t.id === taskId);
            if (!task) return null;

            const assignee = getUserById(task.assigneeId);
            const creator = getUserById(task.createdBy);

            return {
                ...task,
                assigneeName: assignee ? assignee.name : 'N/A',
                assigneeAvatar: assignee ? assignee.avatar : '👤',
                creatorName: creator ? creator.name : 'N/A',
                progress: calculateProgress(task),
                isOverdue: isOverdue(task),
                daysRemaining: this.getDaysRemaining(task)
            };
        },

        /**
         * Tạo task mới
         */
        createTask: function (taskData) {
            // Validate
            const errors = validateTask(taskData);
            if (errors.length > 0) {
                return { success: false, errors: errors };
            }

            // Tạo task mới
            const newTask = {
                id: nextTaskId++,
                taskName: taskData.taskName.trim(),
                description: taskData.description ? taskData.description.trim() : '',
                assigneeId: parseInt(taskData.assigneeId),
                department: taskData.department || (getUserById(parseInt(taskData.assigneeId)) || {}).department || 'N/A',
                priority: taskData.priority,
                status: taskData.status || 'Todo',
                startDate: taskData.startDate,
                dueDate: taskData.dueDate,
                createdBy: taskData.createdBy || 1, // Default manager
                createdAt: new Date().toISOString(),
                updatedAt: new Date().toISOString()
            };

            // Thêm vào array
            tasks.push(newTask);

            saveToStorage();

            // Thêm vào history
            taskStatusHistory.push({
                taskId: newTask.id,
                status: newTask.status,
                changedBy: newTask.createdBy,
                changedAt: newTask.createdAt,
                note: 'Task được tạo'
            });

            return { success: true, task: newTask };
        },

        /**
         * Cập nhật task
         */
        updateTask: function (taskId, updates) {
            const taskIndex = tasks.findIndex(t => t.id === taskId);
            if (taskIndex === -1) {
                return { success: false, errors: ['Task không tồn tại'] };
            }

            const task = tasks[taskIndex];
            const oldStatus = task.status;

            // Merge updates
            Object.assign(task, updates, {
                updatedAt: new Date().toISOString()
            });

            // ensure department remains consistent if provided or if assignee changed
            if (updates.department) task.department = updates.department;
            if (updates.assigneeId) {
                const u = getUserById(parseInt(updates.assigneeId));
                if (u && u.department) task.department = u.department;
            }

            // Validate sau khi update
            const errors = validateTask(task);
            if (errors.length > 0) {
                return { success: false, errors: errors };
            }

            // Nếu status thay đổi, thêm vào history
            if (updates.status && updates.status !== oldStatus) {
                taskStatusHistory.push({
                    taskId: taskId,
                    status: updates.status,
                    changedBy: updates.changedBy || 1,
                    changedAt: new Date().toISOString(),
                    note: updates.statusNote || `Cập nhật từ ${oldStatus} sang ${updates.status}`
                });
            }

            saveToStorage();

            return { success: true, task: task };
        },

        /**
         * Cập nhật status của task
         */
        updateStatus: function (taskId, newStatus, changedBy, note) {
            return this.updateTask(taskId, {
                status: newStatus,
                changedBy: changedBy,
                statusNote: note
            });
        },

        /**
         * Xóa task
         */
        deleteTask: function (taskId) {
            const taskIndex = tasks.findIndex(t => t.id === taskId);
            if (taskIndex === -1) {
                return { success: false, errors: ['Task không tồn tại'] };
            }

            tasks.splice(taskIndex, 1);

            // Xóa history liên quan
            const historyIndexes = [];
            taskStatusHistory.forEach((h, idx) => {
                if (h.taskId === taskId) historyIndexes.push(idx);
            });
            historyIndexes.reverse().forEach(idx => {
                taskStatusHistory.splice(idx, 1);
            });

            saveToStorage();

            return { success: true };
        },

        /**
         * Lấy lịch sử của task
         */
        getTaskHistory: function (taskId) {
            return taskStatusHistory
                .filter(h => h.taskId === taskId)
                .map(h => {
                    const user = getUserById(h.changedBy);
                    return {
                        ...h,
                        changedByName: user ? user.name : 'Unknown',
                        changedByAvatar: user ? user.avatar : '👤'
                    };
                })
                .sort((a, b) => new Date(b.changedAt) - new Date(a.changedAt));
        },

        /**
         * Lấy số ngày còn lại
         */
        getDaysRemaining: function (task) {
            if (task.status === 'Done') return 0;

            const now = new Date();
            const due = new Date(task.dueDate);
            const diffTime = due - now;
            const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

            return diffDays;
        },

        /**
         * Lọc tasks theo điều kiện
         */
        filterTasks: function (filters) {
            let filtered = this.getAllTasks();

            if (filters.status) {
                filtered = filtered.filter(t => t.status === filters.status);
            }

            if (filters.priority) {
                filtered = filtered.filter(t => t.priority === filters.priority);
            }

            if (filters.assigneeId) {
                filtered = filtered.filter(t => t.assigneeId === parseInt(filters.assigneeId));
            }

            if (filters.searchText) {
                const search = filters.searchText.toLowerCase();
                filtered = filtered.filter(t =>
                    t.taskName.toLowerCase().includes(search) ||
                    (t.description && t.description.toLowerCase().includes(search))
                );
            }

            if (filters.overdueOnly) {
                filtered = filtered.filter(t => t.isOverdue);
            }

            return filtered;
        },

        /**
         * Lấy thống kê
         */
        getStatistics: function () {
            const allTasks = this.getAllTasks();

            return {
                total: allTasks.length,
                todo: allTasks.filter(t => t.status === 'Todo').length,
                inProgress: allTasks.filter(t => t.status === 'In Progress').length,
                review: allTasks.filter(t => t.status === 'Review').length,
                done: allTasks.filter(t => t.status === 'Done').length,
                blocked: allTasks.filter(t => t.status === 'Blocked').length,
                overdue: allTasks.filter(t => t.isOverdue).length,
                highPriority: allTasks.filter(t => t.priority === 'High').length
            };
        },

        /**
         * Lấy danh sách users
         */
        getAllUsers: function () {
            return users;
        },

        /**
         * Constant values
         */
        PRIORITIES: ['Low', 'Medium', 'High'],
        STATUSES: ['Todo', 'In Progress', 'Review', 'Done', 'Blocked']
    };
})();
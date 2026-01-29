/**
 * Task Service - single clean implementation (clean copy)
 * Provides CRUD for tasks, users and departments and persists to localStorage.
 */

const TaskService = (function () {
    'use strict';

    let nextTaskId = tasks.length > 0 ? Math.max(...tasks.map((t) => t.id)) + 1 : 1;
    let nextUserId = users.length > 0 ? Math.max(...users.map((u) => u.id)) + 1 : 1;

    const STORAGE_KEYS = {
        TASKS: 'tasktool_tasks',
        HISTORY: 'tasktool_taskHistory',
        USERS: 'tasktool_users',
        DEPARTMENTS: 'tasktool_departments',
        TEMPLATES: 'tasktool_templates',
    };

    // Templates storage (simple template objects: { id, name, data })
    let templates = [];
    let nextTemplateId = 1;

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
                    parsed.forEach((d) => departments.push(d));
                }
            }

            if (sUsers) {
                const parsedUsers = JSON.parse(sUsers);
                users.length = 0;
                parsedUsers.forEach((u) => users.push(u));
                nextUserId = users.length > 0 ? Math.max(...users.map((uu) => uu.id)) + 1 : nextUserId;
            }

            if (sTasks) {
                const parsedTasks = JSON.parse(sTasks);
                tasks.length = 0;
                parsedTasks.forEach((t) => tasks.push(t));
                nextTaskId = tasks.length > 0 ? Math.max(...tasks.map((tt) => tt.id)) + 1 : nextTaskId;
            }

            if (sHistory) {
                const parsedHistory = JSON.parse(sHistory);
                taskStatusHistory.length = 0;
                parsedHistory.forEach((h) => taskStatusHistory.push(h));
            }

            // Load templates
            try {
                const sTemplates = localStorage.getItem(STORAGE_KEYS.TEMPLATES);
                if (sTemplates) {
                    const parsedTemplates = JSON.parse(sTemplates);
                    if (Array.isArray(parsedTemplates)) {
                        templates.length = 0;
                        parsedTemplates.forEach((t) => templates.push(t));
                        nextTemplateId = templates.length > 0 ? Math.max(...templates.map((tt) => tt.id)) + 1 : nextTemplateId;
                    }
                }
            } catch (err) {
                console.warn('Failed to load templates from storage', err);
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
            localStorage.setItem(STORAGE_KEYS.TEMPLATES, JSON.stringify(templates));
        } catch (err) {
            console.error('saveToStorage failed', err);
        }
    }

    function validateTask(taskData) {
        const errors = [];
        if (!taskData.taskName || taskData.taskName.trim() === '') errors.push('Tên công việc không được để trống');
        if (!(taskData.assigneeIds && taskData.assigneeIds.length)) errors.push('Phải chọn ít nhất một người thực hiện');
        if (!taskData.priority) errors.push('Phải chọn độ ưu tiên');
        if (!taskData.status) errors.push('Phải chọn trạng thái');
        if (!taskData.startDate) errors.push('Phải chọn ngày bắt đầu');
        if (!taskData.dueDate) errors.push('Phải chọn deadline');
        if (taskData.startDate && taskData.dueDate && new Date(taskData.startDate) > new Date(taskData.dueDate))
            errors.push('Ngày bắt đầu phải trước deadline');
        return errors;
    }

    function calculateProgress(task) {
        const statusProgress = { Todo: 0, 'In Progress': 30, Review: 70, Done: 100, Blocked: 50 };
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

    function isOverdue(task) {
        if (task.status === 'Done') return false;
        return new Date() > new Date(task.dueDate);
    }

    loadFromStorage();

    return {
        getAllTasks: function () {
            return tasks.map((task) => {
                const assignees = (task.assigneeIds || []).map((id) => getUserById(id)).filter(Boolean);
                const creator = getUserById(task.createdBy);
                const assigneeNames = assignees.map((a) => a.name).join(', ');
                const assigneeAvatars = assignees.map((a) => a.avatar).join(' ');
                const deptSet = new Set(assignees.map((a) => a.department).filter(Boolean));
                const department = deptSet.size ? Array.from(deptSet).join(', ') : task.department || 'N/A';
                const children = tasks.filter((t) => t.parentId === task.id).map((t) => t.id);
                return {
                    ...task,
                    department: department,
                    assigneeNames: assigneeNames,
                    assigneeAvatars: assigneeAvatars,
                    assignees: assignees,
                    children: children,
                    creatorName: creator ? creator.name : 'N/A',
                    progress: calculateProgress(task),
                    isOverdue: isOverdue(task),
                    daysRemaining: this.getDaysRemaining(task),
                };
            });
        },

        getTaskById: function (taskId) {
            const task = tasks.find((t) => t.id === taskId);
            if (!task) return null;
            const assignees = (task.assigneeIds || []).map((id) => getUserById(id)).filter(Boolean);
            const creator = getUserById(task.createdBy);
            const assigneeNames = assignees.map((a) => a.name).join(', ');
            const assigneeAvatars = assignees.map((a) => a.avatar).join(' ');
            const deptSet = new Set(assignees.map((a) => a.department).filter(Boolean));
            const department = deptSet.size ? Array.from(deptSet).join(', ') : task.department || 'N/A';
            const subtasks = tasks.filter((t) => t.parentId === taskId).map((t) => ({ id: t.id, taskName: t.taskName, status: t.status }));
            return {
                ...task,
                department: department,
                assigneeNames: assigneeNames,
                assigneeAvatars: assigneeAvatars,
                assignees: assignees,
                subtasks: subtasks,
                creatorName: creator ? creator.name : 'N/A',
                progress: calculateProgress(task),
                isOverdue: isOverdue(task),
                daysRemaining: this.getDaysRemaining(task),
            };
        },

        createTask: function (taskData) {
            const errors = validateTask(taskData);
            if (errors.length) return { success: false, errors };
            const assigneeIds = (taskData.assigneeIds || []).map((v) => parseInt(v)).filter(Boolean);
            const assignees = assigneeIds.map((id) => getUserById(id)).filter(Boolean);
            const deptSet = new Set(assignees.map((a) => a.department).filter(Boolean));
            const department = deptSet.size ? Array.from(deptSet).join(', ') : taskData.department || 'N/A';

            const parentId = taskData.parentId !== undefined ? (taskData.parentId === null ? null : parseInt(taskData.parentId) || null) : null;

            const newTask = {
                id: nextTaskId++,
                taskName: taskData.taskName.trim(),
                description: taskData.description ? taskData.description.trim() : '',
                assigneeIds: assigneeIds,
                parentId: parentId,
                department: department,
                priority: taskData.priority,
                status: taskData.status || 'Todo',
                startDate: taskData.startDate,
                dueDate: taskData.dueDate,
                createdBy: taskData.createdBy || 1,
                createdAt: new Date().toISOString(),
                updatedAt: new Date().toISOString(),
            };
            tasks.push(newTask);
            taskStatusHistory.push({
                taskId: newTask.id,
                status: newTask.status,
                changedBy: newTask.createdBy,
                changedAt: newTask.createdAt,
                note: 'Task được tạo',
            });
            saveToStorage();
            return { success: true, task: newTask };
        },

        updateTask: function (taskId, updates) {
            const idx = tasks.findIndex((t) => t.id === taskId);
            if (idx === -1) return { success: false, errors: ['Task không tồn tại'] };
            const task = tasks[idx];
            const oldStatus = task.status;

            // Normalize assigneeIds if provided
            if (updates.assigneeIds) {
                updates.assigneeIds = updates.assigneeIds.map((v) => parseInt(v)).filter(Boolean);
                const assignees = updates.assigneeIds.map((id) => getUserById(id)).filter(Boolean);
                const deptSet = new Set(assignees.map((a) => a.department).filter(Boolean));
                if (deptSet.size) updates.department = Array.from(deptSet).join(', ');
            }

            // Normalize parentId if provided
            if (updates.parentId !== undefined) {
                updates.parentId = updates.parentId === null ? null : parseInt(updates.parentId) || null;
            }

            Object.assign(task, updates, { updatedAt: new Date().toISOString() });

            const errors = validateTask(task);
            if (errors.length) return { success: false, errors };
            if (updates.status && updates.status !== oldStatus) {
                taskStatusHistory.push({
                    taskId: taskId,
                    status: updates.status,
                    changedBy: updates.changedBy || 1,
                    changedAt: new Date().toISOString(),
                    note: updates.statusNote || `Cập nhật từ ${oldStatus} sang ${updates.status}`,
                });
            }
            saveToStorage();
            return { success: true, task };
        },

        updateStatus: function (taskId, newStatus, changedBy, note) {
            return this.updateTask(taskId, { status: newStatus, changedBy, statusNote: note });
        },

        deleteTask: function (taskId) {
            const idx = tasks.findIndex((t) => t.id === taskId);
            if (idx === -1) return { success: false, errors: ['Task không tồn tại'] };
            // Reparent any children to null instead of deleting them
            tasks.forEach((t) => {
                if (t.parentId === taskId) t.parentId = null;
            });
            tasks.splice(idx, 1);
            for (let i = taskStatusHistory.length - 1; i >= 0; i--) if (taskStatusHistory[i].taskId === taskId) taskStatusHistory.splice(i, 1);
            saveToStorage();
            return { success: true };
        },

        getTaskHistory: function (taskId) {
            return taskStatusHistory
                .filter((h) => h.taskId === taskId)
                .map((h) => ({
                    ...h,
                    changedByName: (getUserById(h.changedBy) || {}).name || 'Unknown',
                    changedByAvatar: (getUserById(h.changedBy) || {}).avatar || '👤',
                }))
                .sort((a, b) => new Date(b.changedAt) - new Date(a.changedAt));
        },

        getDaysRemaining: function (task) {
            if (task.status === 'Done') return 0;
            const now = new Date();
            const due = new Date(task.dueDate);
            return Math.ceil((due - now) / (1000 * 60 * 60 * 24));
        },

        filterTasks: function (filters) {
            let filtered = this.getAllTasks();
            if (filters.status) filtered = filtered.filter((t) => t.status === filters.status);
            if (filters.priority) filtered = filtered.filter((t) => t.priority === filters.priority);
            if (filters.assigneeId) filtered = filtered.filter((t) => (t.assigneeIds || []).includes(parseInt(filters.assigneeId)));
            if (filters.department) filtered = filtered.filter((t) => t.department === filters.department);
            if (filters.searchText) {
                const s = filters.searchText.toLowerCase();
                filtered = filtered.filter((t) => t.taskName.toLowerCase().includes(s) || (t.description && t.description.toLowerCase().includes(s)));
            }
            if (filters.overdueOnly) filtered = filtered.filter((t) => t.isOverdue);
            return filtered;
        },

        getStatistics: function () {
            const all = this.getAllTasks();
            return {
                total: all.length,
                todo: all.filter((t) => t.status === 'Todo').length,
                inProgress: all.filter((t) => t.status === 'In Progress').length,
                review: all.filter((t) => t.status === 'Review').length,
                done: all.filter((t) => t.status === 'Done').length,
                blocked: all.filter((t) => t.status === 'Blocked').length,
                overdue: all.filter((t) => t.isOverdue).length,
                highPriority: all.filter((t) => t.priority === 'High').length,
            };
        },

        // Templates CRUD
        getTemplates: function () {
            return templates.slice();
        },

        createTemplate: function (name, taskSnapshot) {
            if (!name) return { success: false, errors: ['Template name required'] };
            const tpl = { id: nextTemplateId++, name: name, data: taskSnapshot };
            templates.push(tpl);
            saveToStorage();
            return { success: true, template: tpl };
        },

        updateTemplate: function (templateId, updates) {
            const idx = templates.findIndex((t) => t.id === templateId);
            if (idx === -1) return { success: false, errors: ['Template not found'] };
            Object.assign(templates[idx], updates);
            saveToStorage();
            return { success: true, template: templates[idx] };
        },

        deleteTemplate: function (templateId) {
            const idx = templates.findIndex((t) => t.id === templateId);
            if (idx === -1) return { success: false, errors: ['Template not found'] };
            templates.splice(idx, 1);
            saveToStorage();
            return { success: true };
        },

        applyTemplate: function (templateId, overrides) {
            const tpl = templates.find((t) => t.id === templateId);
            if (!tpl) return { success: false, errors: ['Template not found'] };
            const taskData = Object.assign({}, tpl.data, overrides || {});
            return this.createTask(taskData);
        },

        // Parent / Child helpers
        createSubtask: function (parentId, taskData) {
            if (!parentId) return { success: false, errors: ['Parent ID required'] };
            const parent = tasks.find((t) => t.id === parentId);
            if (!parent) return { success: false, errors: ['Parent task not found'] };
            const data = Object.assign({}, taskData, { parentId: parentId });
            // Inherit dates if missing
            if (!data.startDate) data.startDate = parent.startDate;
            if (!data.dueDate) data.dueDate = parent.dueDate;
            return this.createTask(data);
        },

        getSubtasks: function (taskId) {
            return tasks.filter((t) => t.parentId === taskId).map((t) => ({ ...t }));
        },

        // Users CRUD
        getAllUsers: function () {
            return users;
        },

        createUser: function (userData) {
            if (!userData.name || !userData.email) return { success: false, errors: ['Name and email required'] };
            const newUser = {
                id: nextUserId++,
                name: userData.name,
                email: userData.email,
                role: userData.role || 'Staff',
                avatar: userData.avatar || '👤',
                department: userData.department || null,
            };
            users.push(newUser);
            saveToStorage();
            return { success: true, user: newUser };
        },

        updateUser: function (userId, updates) {
            const idx = users.findIndex((u) => u.id === userId);
            if (idx === -1) return { success: false, errors: ['User not found'] };
            Object.assign(users[idx], updates);
            if (updates.department !== undefined) {
                tasks.forEach((t) => {
                    if ((t.assigneeIds || []).includes(userId)) t.department = updates.department;
                });
            }
            saveToStorage();
            return { success: true, user: users[idx] };
        },

        deleteUser: function (userId) {
            const idx = users.findIndex((u) => u.id === userId);
            if (idx === -1) return { success: false, errors: ['User not found'] };
            users.splice(idx, 1);
            tasks.forEach((t) => {
                if (t.assigneeIds && t.assigneeIds.length) {
                    // remove the user from assigneeIds
                    t.assigneeIds = t.assigneeIds.filter((id) => id !== userId);
                    if (!t.assigneeIds.length) {
                        t.department = 'N/A';
                    }
                }
            });
            saveToStorage();
            return { success: true };
        },

        // Departments CRUD
        getDepartments: function () {
            return departments.slice();
        },

        createDepartment: function (name) {
            if (!name) return { success: false, errors: ['Tên phòng ban trống'] };
            if (departments.includes(name)) return { success: false, errors: ['Phòng ban đã tồn tại'] };
            departments.push(name);
            saveToStorage();
            return { success: true };
        },

        updateDepartment: function (oldName, newName) {
            const idx = departments.findIndex((d) => d === oldName);
            if (idx === -1) return { success: false, errors: ['Phòng ban không tồn tại'] };
            if (!newName) return { success: false, errors: ['Tên mới rỗng'] };
            departments[idx] = newName;
            users.forEach((u) => {
                if (u.department === oldName) u.department = newName;
            });
            tasks.forEach((t) => {
                if (t.department === oldName) t.department = newName;
            });
            saveToStorage();
            return { success: true };
        },

        deleteDepartment: function (name) {
            const idx = departments.findIndex((d) => d === name);
            if (idx === -1) return { success: false, errors: ['Phòng ban không tồn tại'] };
            departments.splice(idx, 1);
            users.forEach((u) => {
                if (u.department === name) u.department = null;
            });
            tasks.forEach((t) => {
                if (t.department === name) t.department = 'N/A';
            });
            saveToStorage();
            return { success: true };
        },

        PRIORITIES: ['Low', 'Medium', 'High'],
        STATUSES: ['Todo', 'In Progress', 'Review', 'Done', 'Blocked'],
    };
})();

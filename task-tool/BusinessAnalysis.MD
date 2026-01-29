# Phân tích nghiệp vụ - Hệ thống giao việc nội bộ

## 1. Tổng quan nghiệp vụ

### 1.1 Vấn đề hiện tại

- Nhập liệu thủ công tốn thời gian
- Thiếu chuẩn hóa quy trình
- Khó theo dõi tiến độ công việc phức tạp
- Quản lý task cha - con chưa rõ ràng

### 1.2 Giải pháp

- **Task Template Library**: Bộ công việc mẫu có sẵn
- **Hierarchical Task Structure**: Cấu trúc cha - con rõ ràng
- **Quick Assignment**: Giao việc nhanh từ template
- **Auto Calculation**: Tự động tính toán deadline và trạng thái

## 2. Business Flow

### 2.1 Quy trình giao việc

```
[Admin tạo Task Template]
        ↓
[Leader chọn Template]
        ↓
[Gán người thực hiện + Deadline]
        ↓
[Hệ thống sinh Task Instance]
        ↓
[Staff nhận việc và thực hiện]
        ↓
[Cập nhật trạng thái Subtask]
        ↓
[Task cha tự động cập nhật]
```

### 2.2 Chi tiết từng bước

#### Bước 1: Admin tạo Task Template

- Đặt tên template
- Tạo task cha với thông tin cơ bản
- Thêm các subtask
- Cấu hình:
    - Thời gian dự kiến (hours/days)
    - Thứ tự thực hiện
    - Bắt buộc/không bắt buộc
    - Role mặc định
    - Dependencies (phụ thuộc)

#### Bước 2: Leader giao việc

- Browse Task Template Library
- Chọn template phù hợp
- Customize:
    - Gán người thực hiện cụ thể
    - Điều chỉnh deadline
    - Thay đổi priority
    - Bỏ qua subtask không bắt buộc

#### Bước 3: Hệ thống sinh Task Instance

- Clone template thành task thực tế
- Tạo task ID mới
- Tính toán deadline cho từng subtask
- Thiết lập dependencies
- Gửi thông báo cho người thực hiện

#### Bước 4: Staff thực hiện

- Xem task được giao
- Cập nhật trạng thái subtask
- Report progress
- Block nếu có vấn đề

#### Bước 5: Auto Update

- Subtask done → Task cha cập nhật %
- Tất cả subtask done → Task cha done
- Có subtask blocked → Cảnh báo
- Quá deadline → Đánh dấu overdue

## 3. Sơ đồ cấu trúc Task Template

```
Task Template
├── Template Info
│   ├── ID
│   ├── Name
│   ├── Category
│   └── Description
│
├── Parent Task Config
│   ├── Name
│   ├── Description
│   ├── Estimated Duration
│   └── Default Priority
│
└── Subtasks []
    ├── Subtask 1
    │   ├── Name
    │   ├── Description
    │   ├── Estimated Hours
    │   ├── Order
    │   ├── Is Required
    │   ├── Default Role
    │   └── Dependencies []
    │
    ├── Subtask 2
    └── ...
```

## 4. Sơ đồ cấu trúc Task Instance

```
Task Instance (Task cha)
├── Task Info
│   ├── ID
│   ├── Template ID
│   ├── Name
│   ├── Description
│   ├── Assignee
│   ├── Created By
│   ├── Created At
│   ├── Start Date
│   ├── Due Date
│   ├── Status
│   └── Progress %
│
└── Subtasks []
    ├── Subtask Instance 1
    │   ├── ID
    │   ├── Parent Task ID
    │   ├── Name
    │   ├── Description
    │   ├── Assignee
    │   ├── Status
    │   ├── Start Date
    │   ├── Due Date
    │   ├── Estimated Hours
    │   ├── Actual Hours
    │   └── Dependencies []
    │
    ├── Subtask Instance 2
    └── ...
```

## 5. State Machine

### 5.1 Task cha (Parent Task)

```
[Not Started] → [In Progress] → [Completed]
       ↓              ↓              ↑
    [Overdue]    [Overdue]          |
                      ↓              |
                  [Blocked] ─────────┘
```

**Chuyển trạng thái:**

- Not Started → In Progress: Khi subtask đầu tiên bắt đầu
- In Progress → Completed: Khi tất cả subtask bắt buộc hoàn thành
- Any → Overdue: Khi qua deadline mà chưa done
- Any → Blocked: Khi có subtask quan trọng bị block

### 5.2 Subtask

```
[Todo] → [In Progress] → [Done]
   ↓          ↓
[Blocked] ←───┘
```

**Chuyển trạng thái:**

- Todo → In Progress: User bắt đầu làm
- In Progress → Done: User hoàn thành
- Any → Blocked: Gặp vấn đề, cần hỗ trợ

## 6. Business Rules

### 6.1 Dependency Rules

```javascript
// Subtask B phụ thuộc vào Subtask A
if (subtaskA.status !== 'Done') {
    subtaskB.canStart = false;
}
```

### 6.2 Progress Calculation

```javascript
progress = (completedSubtasks / totalRequiredSubtasks) * 100;
```

### 6.3 Status Auto-Update

```javascript
if (allRequiredSubtasksDone) {
    parentTask.status = 'Completed';
} else if (anySubtaskInProgress) {
    parentTask.status = 'In Progress';
} else if (anySubtaskBlocked) {
    parentTask.status = 'Blocked';
}
```

### 6.4 Deadline Calculation

```javascript
// Tính deadline cho subtask dựa trên order
subtask.dueDate = parentTask.startDate + sum(previousSubtasks.estimatedHours);
```

## 7. Các template mẫu

### 7.1 Template: Onboard nhân sự mới

**Thời gian dự kiến:** 5 ngày

1. **Chuẩn bị tài khoản & thiết bị** (4h)
    - Role: IT
    - Required: Yes
2. **Giới thiệu công ty & văn hóa** (2h)
    - Role: HR
    - Required: Yes
    - Depends on: #1

3. **Training sản phẩm/dự án** (8h)
    - Role: Team Leader
    - Required: Yes
    - Depends on: #2

4. **Giao việc đầu tiên** (1h)
    - Role: Team Leader
    - Required: Yes
    - Depends on: #3

5. **Review tuần đầu tiên** (1h)
    - Role: Manager
    - Required: No
    - Depends on: #4

### 7.2 Template: Triển khai tính năng mới

**Thời gian dự kiến:** 10 ngày

1. **Phân tích yêu cầu** (16h)
    - Role: BA
    - Required: Yes

2. **Thiết kế database** (8h)
    - Role: Backend Dev
    - Required: Yes
    - Depends on: #1

3. **Thiết kế UI/UX** (12h)
    - Role: Designer
    - Required: Yes
    - Depends on: #1

4. **Develop Backend API** (24h)
    - Role: Backend Dev
    - Required: Yes
    - Depends on: #2

5. **Develop Frontend** (24h)
    - Role: Frontend Dev
    - Required: Yes
    - Depends on: #3, #4

6. **Viết Unit Test** (8h)
    - Role: Developer
    - Required: Yes
    - Depends on: #4, #5

7. **Integration Test** (8h)
    - Role: QA
    - Required: Yes
    - Depends on: #6

8. **Deploy to Staging** (2h)
    - Role: DevOps
    - Required: Yes
    - Depends on: #7

9. **UAT Testing** (8h)
    - Role: QA + Client
    - Required: Yes
    - Depends on: #8

10. **Deploy to Production** (2h)
    - Role: DevOps
    - Required: Yes
    - Depends on: #9

### 7.3 Template: Dự án Marketing Campaign

**Thời gian dự kiến:** 15 ngày

1. **Nghiên cứu thị trường** (16h)
    - Role: Marketing
    - Required: Yes

2. **Lên concept campaign** (12h)
    - Role: Creative
    - Required: Yes
    - Depends on: #1

3. **Thiết kế creative materials** (24h)
    - Role: Designer
    - Required: Yes
    - Depends on: #2

4. **Viết nội dung** (16h)
    - Role: Content Writer
    - Required: Yes
    - Depends on: #2

5. **Review và approve** (4h)
    - Role: Marketing Manager
    - Required: Yes
    - Depends on: #3, #4

6. **Setup quảng cáo** (8h)
    - Role: Media Buyer
    - Required: Yes
    - Depends on: #5

7. **Launch campaign** (2h)
    - Role: Marketing
    - Required: Yes
    - Depends on: #6

8. **Theo dõi & optimize** (40h)
    - Role: Marketing
    - Required: Yes
    - Depends on: #7

9. **Báo cáo kết quả** (8h)
    - Role: Marketing
    - Required: Yes
    - Depends on: #8

## 8. Phân quyền

| Chức năng                  | Admin | Leader | Staff |
| -------------------------- | ----- | ------ | ----- |
| Tạo/Sửa Template           | ✓     | ✗      | ✗     |
| Xóa Template               | ✓     | ✗      | ✗     |
| Giao việc từ Template      | ✓     | ✓      | ✗     |
| Xem task được giao         | ✓     | ✓      | ✓     |
| Cập nhật subtask của mình  | ✓     | ✓      | ✓     |
| Xem timeline tất cả task   | ✓     | ✓      | ✗     |
| Xem timeline task của mình | ✓     | ✓      | ✓     |

## 9. UI/UX Flow

### 9.1 Màn hình chính (Leader/Admin)

```
┌─────────────────────────────────────────┐
│  Task Assignment Tool                    │
├─────────────────────────────────────────┤
│  [Template Library] [My Tasks] [Timeline]│
├─────────────────────────────────────────┤
│  ┌───────────────────────────────────┐  │
│  │ Task Templates                     │  │
│  │  📦 Onboard nhân sự (5 days)      │  │
│  │  ⚙️ Triển khai tính năng (10 days)│  │
│  │  📢 Marketing Campaign (15 days)   │  │
│  │  [+ New Template]                  │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

### 9.2 Dialog giao việc

```
┌─────────────────────────────────────────┐
│  Giao việc: Onboard nhân sự             │
├─────────────────────────────────────────┤
│  Người nhận: [Select User ▼]            │
│  Ngày bắt đầu: [2026-01-28]             │
│  Deadline: [2026-02-04] (5 days)        │
│  Priority: [High ▼]                     │
│                                          │
│  Subtasks (5):                          │
│  ☑ Chuẩn bị tài khoản (4h) - IT         │
│  ☑ Giới thiệu công ty (2h) - HR         │
│  ☑ Training sản phẩm (8h) - Leader      │
│  ☑ Giao việc đầu (1h) - Leader          │
│  ☐ Review tuần đầu (1h) - Manager       │
│                                          │
│  [Cancel] [Giao việc]                   │
└─────────────────────────────────────────┘
```

### 9.3 Timeline View

```
┌─────────────────────────────────────────┐
│  Timeline - Tháng 2/2026               │
├─────────────────────────────────────────┤
│  │ 01  02  03  04  05  06  07  08      │
│  │                                       │
│  │ Onboard Nguyễn Văn A                │
│  │ ████████████░░                       │
│  │   ├─ Chuẩn bị TK ██░                │
│  │   ├─ Giới thiệu ──██░               │
│  │   ├─ Training ────────████░         │
│  │   └─ Giao việc ────────────██░      │
│  │                                       │
│  │ Deploy Feature X                     │
│  │ ████████████████████████████         │
│  │   ├─ Backend API ████████░           │
│  │   ├─ Frontend ────────████████░      │
│  │   └─ Testing ──────────────████░     │
└─────────────────────────────────────────┘
```

## 10. Các tính năng nâng cao (Future)

1. **Smart Assignment**
    - Gợi ý người thực hiện dựa trên workload
    - Cân bằng công việc giữa các thành viên

2. **Template Analytics**
    - Thống kê template nào được dùng nhiều nhất
    - Thời gian thực tế vs dự kiến
    - Tỷ lệ hoàn thành đúng hạn

3. **Notification System**
    - Nhắc deadline sắp đến
    - Thông báo khi có task mới
    - Alert khi task bị block

4. **Comments & Collaboration**
    - Comment trên từng subtask
    - Tag người khác
    - Upload file đính kèm

5. **Mobile App**
    - Xem task trên mobile
    - Update trạng thái nhanh
    - Push notification

6. **Integration**
    - Slack notification
    - Calendar sync
    - Email digest

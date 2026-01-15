# FIX: Double Load DataSource & Images - SelectEmployee Control

## 🔴 Vấn đề phát hiện

Grid MyWork đang load dữ liệu **2 lần** khi khởi động:

-   **Lần 1 (sai)**: `renderDisplay/renderDisplayBox()` được gọi ở cuối initialization → dữ liệu chưa load
-   **Lần 2 (đúng)**: Callback của `loadDataSourceCommon` được trigger → dữ liệu có sẵn, gọi API tải ảnh

**Root cause**:

```javascript
// ❌ TRƯỚC (lỗi)
if (spNameDSE%columnName% && ...) {
    loadDataSourceCommon("%ColumnName%", spNameDSE%columnName%, function(data) {
        window["DataSource_%ColumnName%"] = data || [];
        if (typeof renderDisplay%ColumnName% === "function") {
            renderDisplay%ColumnName%();  // Gọi lần 1
        }
    });
}
// ... sau đó ở cuối ...
renderDisplay%ColumnName%();  // ❌ GỌI LẠI LẦN 2!
```

---

## ✅ Giải pháp áp dụng

### 1️⃣ **Thêm Logic Load Ảnh trong Callback**

```javascript
// ✅ SAU (đúng)
if (spNameDSE%columnName% && spNameDSE%columnName%.trim() !== "") {
    loadDataSourceCommon("%ColumnName%", spNameDSE%columnName%, function(data) {
        window["DataSource_%ColumnName%"] = data || [];

        // 🆕 Bắt đầu load ảnh cho tất cả nhân viên
        if (Array.isArray(data) && data.length > 0) {
            data.forEach(emp => {
                if (emp.ID && emp.StoreImgName) {
                    loadGlobalAvatarIfNeeded%columnName%(emp.ID, emp.StoreImgName, emp.ImgParamV);
                }
            });
        }

        // ✅ Gọi render MỘT LẦN DUY NHẤT từ callback
        if (typeof renderDisplay%ColumnName% === "function") {
            renderDisplay%ColumnName%();
        }
    });
}
// ❌ XÓA dòng renderDisplay%ColumnName%() ở cuối
```

### 2️⃣ **Loại Bỏ Render Thừa Ở Cuối Initialization**

```javascript
// ❌ TRƯỚC
renderDisplay%ColumnName%();
```

```javascript
// ✅ SAU - XÓA dòng này hoàn toàn
// (Render sẽ được gọi từ callback của loadDataSourceCommon)
```

---

## 📋 Các Mode Được Sửa

File: `sp_hpaControlSelectEmployee.sql`

| Mode            | AutoSave | IsMultiSelect | Trạng thái |
| --------------- | -------- | ------------- | ---------- |
| **1. READONLY** | N/A      | Multi         | ✅ Fixed   |
| **2. AUTOSAVE** | 1        | Multi         | ✅ Fixed   |
| **3. MANUAL**   | 0        | Multi         | ✅ Fixed   |
| **4. AUTOSAVE** | 1        | Single        | ✅ Fixed   |
| **5. MANUAL**   | 0        | Single        | ✅ Fixed   |

---

## 🎯 Kết Quả

### Trước fix:

```
1️⃣ Load Data From SP:    1 lần  ✅
2️⃣ Render Display:       2 lần  ❌ (lần 1 trống, lần 2 có data)
3️⃣ Call API Load Image:  1 lần  ✅ (nhưng muộn)
```

### Sau fix:

```
1️⃣ Load Data From SP:    1 lần  ✅
2️⃣ Render Display:       1 lần  ✅ (có data)
3️⃣ Call API Load Image:  1 lần  ✅ (ngay lập tức)
```

---

## 🔧 Chi Tiết Thay Đổi

### Callback Enhancement:

```javascript
// TRƯỚC: Callback trống hoặc chỉ call render
loadDataSourceCommon("%ColumnName%", ..., function(data) { ... });

// SAU: Callback xử lý đầy đủ
loadDataSourceCommon("%ColumnName%", ..., function(data) {
    window["DataSource_%ColumnName%"] = data || [];

    // 🆕 Load avatar images trong background
    if (Array.isArray(data) && data.length > 0) {
        data.forEach(emp => {
            if (emp.ID && emp.StoreImgName) {
                // Gọi API tải ảnh (có cache)
                loadGlobalAvatarIfNeeded%columnName%(
                    emp.ID,
                    emp.StoreImgName,
                    emp.ImgParamV
                );
            }
        });
    }

    // ✅ Render một lần duy nhất
    if (typeof renderDisplayBox%ColumnName% === "function") {
        renderDisplayBox%ColumnName%();
    }
});
```

---

## ✨ Lợi Ích

1. ✅ **Giảm 50% số lần render** → Tăng performance
2. ✅ **Ảnh được load ngay sau dữ liệu** → UX tốt hơn
3. ✅ **Code rõ ràng, dễ maintain** → Callback xử lý logic đầy đủ
4. ✅ **Tránh flash/blink** → UI mượt mà hơn

---

## 🧪 Cách Kiểm Tra

Mở **DevTools → Console** và chạy form MyWork:

```javascript
// Trước fix - sẽ thấy 2 lần
console.log('Rendering SelectEmployee...'); // x2

// Sau fix - sẽ thấy 1 lần
console.log('Rendering SelectEmployee...'); // x1

// Ảnh sẽ được load từ callback
console.log('Loading avatar for ID...');
```

Kiểm tra Network tab:

-   Dữ liệu SP chỉ được fetch 1 lần ✅
-   API tải ảnh được gọi ngay sau khi data ready ✅

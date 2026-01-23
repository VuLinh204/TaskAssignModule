USE Paradise_Dev
GO
if object_id('[dbo].[sp_hpaControlFile]') is null
	EXEC ('CREATE PROCEDURE [dbo].[sp_hpaControlFile] as select 1')
GO

ALTER PROCEDURE [dbo].[sp_hpaControlFile]
    @TableName VARCHAR(256) = ''
AS
BEGIN
    UPDATE #temptable SET loadUI = N'
    //Load thư viện
        (function() {
            if (window.__hpaFileLibsLoaded) return;
            window.__hpaFileLibsLoaded = true;
            const libs = [
                { check: () => typeof JSZip !== "undefined", url: "https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js" },
                { check: () => typeof docx !== "undefined", url: "https://unpkg.com/docx-preview@0.1.15/dist/docx-preview.js" },
                { check: () => typeof XLSX !== "undefined", url: "https://cdn.jsdelivr.net/npm/xlsx@0.18.5/dist/xlsx.full.min.js" },
                { check: () => typeof pdfjsLib !== "undefined", url: "https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.min.js" }
            ];
            libs.forEach(lib => {
                if (!lib.check()) {
                    const script = document.createElement("script");
                    script.src = lib.url;
                    script.async = true;
                    document.head.appendChild(script);
                }
            });
            setTimeout(() => {
                if (typeof pdfjsLib !== "undefined") {
                    pdfjsLib.GlobalWorkerOptions.workerSrc = "https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.worker.min.js";
                }
            }, 500);
        })();


    //Khởi tạo giao diện và Cache
        const colName = "%ColumnName%";
        const $container = $("#%UID%");
        let instanceUploader, timeOutSave;

        // --- CACHE URL (WEB): Lưu blob url ---
        const BlobCache_%ColumnName% = {};

        // --- CACHE BASE64 (MOBILE): Lưu chuỗi base64 để không phải tải lại ---
        const Base64Cache_%ColumnName% = {};
        // -----------------------------------------------------

        // Observer Lazy Load
        let _observer_%ColumnName%;
        function initObserver_%ColumnName%() {
            if (_observer_%ColumnName%) _observer_%ColumnName%.disconnect();

            _observer_%ColumnName% = new IntersectionObserver((entries, observer) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        const target = entry.target;
                        const f = $(target).data("file");
                        if (f) {
                            loadRealPreview_%ColumnName%(target, f);
                            observer.unobserve(target);
                        }
                    }
                });
            }, { rootMargin: "100px 0px" });
        }

        $container.html(`
            <div id="trigger_dropzone_${colName}" style="display: flex; align-items: center; margin-bottom: 8px; cursor: pointer; user-select: none;" title="Nhấn để hiện/ẩn vùng tải file">
                <i class="bi bi-file-earmark me-1 icon_Attachment"></i>
                <label class="date-text" style="margin-left: 4px; margin-bottom: 0; cursor: pointer;">%Attachment%</label>
            </div>
            <div id="dropzone_${colName}" class="hpa-dropzone-modern" style="display: none;">
                <div class="icon-cloud"><i class="bi bi-cloud-arrow-up-fill"></i></div>
                <div class="dz-content">
                    <span class="main-text">Kéo thả file hoặc nhấn để chọn</span>
                    <span class="sub-text">Hỗ trợ: PDF, Word, Excel, Ảnh, Video...</span>
                </div>
            </div>
            <div id="filelist_${colName}" class="hpa-file-grid"></div>
            <div id="uploader_${colName}"></div>
            <div id="modal_${colName}" class="glass-modal">
                <div class="glass-backdrop"></div>
                <div class="glass-container">
                    <div class="glass-toolbar">
                        <div class="file-info">
                            <i class="bi bi-file-earmark-text file-icon-type"></i>
                            <div class="file-meta">
                                <div class="file-name">Unknown File</div>
                                <div class="file-size">0 KB</div>
                            </div>
                        </div>
                        <div class="toolbar-actions">
                            <button class="glass-btn btn-download-modal primary"><i class="bi bi-download"></i> <span>Tải về</span></button>
                            <button class="glass-btn btn-close-modal danger"><i class="bi bi-x-lg"></i></button>
                        </div>
                    </div>
                    <div class="glass-viewport">
                        <div class="viewport-content"></div>
                        <div class="glass-loading">
                            <div class="spinner"></div>
                            <span>Đang tải file...</span>
                        </div>
                    </div>
                </div>
            </div>
        `);

        // --- Bắt sự kiện Click để Toggle Dropzone ---
        $("#trigger_dropzone_" + colName).on("click", function() {
            $("#dropzone_" + colName).slideToggle(100);
        });

        // --- FIX CSS GIAO DIỆN ---
        if ($("#hpa-file-style-unique").length === 0) {
            $(`<style id="hpa-file-style-unique">
                .hpa-file-grid {
                    display: grid;
                    grid-template-columns: repeat(auto-fill, minmax(100px, 1fr));
                    gap: 12px;
                    margin-top: 15px;
                    width: 100%;
                    box-sizing: border-box;
                }
                .hpa-dropzone-modern {
                    border: 2px dashed #e0e0e0;
                    border-radius: 16px;
                    padding: 12px;
                    text-align: center;
                    cursor: pointer;
                    background: #fafafa;
                    transition: all 0.3s ease;
                    position: relative;
                    overflow: hidden;
                    width: 100%;
                    box-sizing: border-box;
                }
                .hpa-dropzone-modern:hover, .hpa-dropzone-modern.drag-over { border-color: #004c39; background: #faffef; box-shadow: 0 4px 20px rgba(59, 130, 246, 0.1); }
                .hpa-dropzone-modern .icon-cloud { font-size: 36px; color: #9ca3af; margin-bottom: 8px; transition: 0.3s; }
                .hpa-dropzone-modern:hover .icon-cloud { color: #004c39; transform: translateY(-5px); }
                .hpa-dropzone-modern .dz-content { display: flex; flex-direction: column; }
                .hpa-dropzone-modern .main-text { font-weight: 600; color: #374151; font-size: 14px; }
                .hpa-dropzone-modern .sub-text { font-size: 12px; color: #9ca3af; margin-top: 4px; }
                .file-card {
                    background: #fff;
                    border: 1px solid #eee;
                    border-radius: 12px;
                    position: relative;
                    overflow: hidden;
                    transition: all 0.2s;
                    box-shadow: 0 2px 5px rgba(0,0,0,0.03);
                    box-sizing: border-box;
                }
                .file-card:hover { transform: translateY(-3px); border-color: #00673b; }
                .file-card .card-thumb { height: 80px; display: flex; align-items: center; justify-content: center; background: #f8f9fa; position: relative;}
                .file-card .card-thumb img { width: 100%; height: 100%; object-fit: cover; }
                .file-card .card-info { padding: 8px; font-size: 11px; text-align: center; border-top: 1px solid #f0f0f0; transition: background 0.2s ease;}
                .file-card .card-name { white-space: nowrap; overflow: hidden; text-overflow: ellipsis; font-weight: 500; color: #555; transition: color 0.2s ease;}
                .file-card:hover .card-info { background: #00673b; }
                .file-card:hover .card-name { color: #fff; }
                .file-card .btn-del { position: absolute; top: 5px; right: 5px; width: 22px; height: 22px; background: rgba(220, 53, 69, 0.9); color: white; border: none; border-radius: 50%; cursor: pointer; opacity: 0; transform: scale(0.8); transition: all 0.2s; display: flex; align-items: center; justify-content: center; z-index: 5; }
                .file-card:hover .btn-del { opacity: 1; transform: scale(1); }
                .thumb-loading-overlay { position: absolute; inset:0; background: rgba(255,255,255,0.8); display:flex; align-items:center; justify-content:center; font-size:10px; color:#666; }

                .glass-modal { display: none; position: fixed; inset: 0; z-index: 99999; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; justify-content: center; align-items: center; }
                .glass-backdrop { position: absolute; inset: 0; background: rgba(15, 23, 42, 0.85); backdrop-filter: blur(8px); -webkit-backdrop-filter: blur(8px); }
                .glass-container { position: relative; width: 80%; height: 80%; display: flex; flex-direction: column; background: rgba(255, 255, 255, 0.05); border: 1px solid rgba(255, 255, 255, 0.1); border-radius: 16px; box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5); overflow: hidden; }
                .glass-toolbar { height: 60px; flex-shrink: 0; display: flex; align-items: center; justify-content: space-between; padding: 0 20px; background: rgba(0, 0, 0, 0.4); border-bottom: 1px solid rgba(255, 255, 255, 0.1); }
                .file-info { display: flex; align-items: center; gap: 12px; overflow: hidden; }
                .file-icon-type { font-size: 24px; color: #fff; }
                .file-meta { display: flex; flex-direction: column; min-width: 0; }
                .file-name { color: #fff; font-size: 14px; font-weight: 600; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 100%; }
                .file-size { color: rgba(255, 255, 255, 0.6); font-size: 11px; }
                .toolbar-actions { display: flex; align-items: center; gap: 8px; }
                .glass-btn { background: rgba(255, 255, 255, 0.1); border: none; color: #fff; width: 36px; height: 36px; border-radius: 8px; cursor: pointer; display: flex; align-items: center; justify-content: center; transition: 0.2s; }
                .glass-btn:hover { background: rgba(255, 255, 255, 0.25); transform: translateY(-1px); }
                .glass-btn:active { transform: scale(0.95); }
                .glass-btn.primary { background: #004c39; width: auto; padding: 0 16px; gap: 8px; font-size: 13px; font-weight: 500; }
                .glass-btn.primary:hover { background: #2563eb; }
                .glass-btn.danger { background: rgba(239, 68, 68, 0.2); color: #fca5a5; }
                .glass-btn.danger:hover { background: #ef4444; color: white; }
                .glass-viewport { flex: 1; position: relative; overflow: hidden; background: rgba(0,0,0,0.2); display: flex; justify-content: center; align-items: center; }
                .viewport-content { width: 100%; height: 100%; overflow: auto; padding: 20px; box-sizing: border-box; display:flex; align-items:center; justify-content:center;}
                .viewport-content img { box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.3); border-radius: 4px; transition: transform 0.2s cubic-bezier(0,0,0.2,1); }
                .glass-loading { position: absolute; inset: 0; background: rgba(0,0,0,0.7); display: flex; flex-direction: column; align-items: center; justify-content: center; z-index: 10; color: white; gap: 15px; }
                .spinner { width: 40px; height: 40px; border: 3px solid rgba(255,255,255,0.3); border-radius: 50%; border-top-color: #004c39; animation: spin 1s linear infinite; }
                @media (max-width: 768px) {
                    .glass-container { width: 100%; height: 100%; border-radius: 0; border: none; }
                    .glass-btn.primary { width: 36px; padding: 0; }
                    .glass-btn.primary span { display: none; }
                    .glass-btn.primary i { margin: 0; }
                    .viewport-content { padding: 5px; }
                }
            </style>`).appendTo("head");
        }


    //Xác định loại thiết bị
        function getMobileOS() {
            var ua = navigator.userAgent || navigator.vendor || window.opera;
            if (/windows phone/i.test(ua)) return "Windows Phone";
            if (/android/i.test(ua)) return "Android";
            if (/iPad|iPhone|iPod/.test(ua) && !window.MSStream) return "iOS";
            return "unknown";
        }


    //Hàm chuẩn hóa đối tượng file
        function normalizeFile(f) {
            const url = f.UrlFile || f.Url || f.url || "";
            let name = f.FileName || f.fileName || f.name || "";
            if (!name && url) {
                name = url.split("/").pop().split("?")[0];
                try { name = decodeURIComponent(name); } catch(e){}
            }
            const ext = (name || "file").split(".").pop().toLowerCase();
            const isImg = ["jpg", "jpeg", "png", "gif", "bmp", "webp"].includes(ext);
            return { url, name, ext, isImg, data: f.data };
        }


    //Hàm lấy URL file (ĐÃ CẬP NHẬT CACHE)
        async function getFileUrl_%ColumnName%(f) {
            try {
                const cacheKey = f.url || f.name;
     if (BlobCache_%ColumnName%[cacheKey]) {
                    return BlobCache_%ColumnName%[cacheKey];
                }

                let blobUrl = null;
                if (f.data && f.data.length > 50) {
                    const b64 = f.data.indexOf(",") > -1 ? f.data.split(",")[1] : f.data;
                    const mime = f.ext === "pdf" ? "application/pdf" :
                                 f.ext === "mp4" ? "video/mp4" :
                                 f.isImg ? "image/" + f.ext : "application/octet-stream";
                    const blob = new Blob([Uint8Array.from(atob(b64), c => c.charCodeAt(0))], { type: mime });
                    blobUrl = URL.createObjectURL(blob);
                }
                else if (f.url) {
                    if (f.url.startsWith("http") || f.url.startsWith("blob:")) return f.url;
                    const response = await AjaxHPAParadiseAsync({
                        data: { name: "paradisefile_sp_GetFileAPI", param: ["FilePath", f.url.replace(/\\/g, "\\\\")] },
                        xhrFields: { responseType: "blob" }
                    });
                    let blob = response instanceof Blob ? response : (response?.data || response?.blob);
                    if (blob instanceof Blob) blobUrl = URL.createObjectURL(blob);
                }

                if (blobUrl) {
                    BlobCache_%ColumnName%[cacheKey] = blobUrl;
                }
                return blobUrl;

            } catch (e) { console.error(e); return null; }
        }


    //Hàm hỗ trợ chụp ảnh thumbnail từ video
        function getVideoCover(url, seekTo = 1.0) {
            return new Promise((resolve, reject) => {
                const video = document.createElement("video");
                video.setAttribute("src", url);
                video.setAttribute("crossOrigin", "anonymous");
                video.muted = true;
                video.playsInline = true;
                video.currentTime = seekTo;
                video.onloadeddata = () => {
                   setTimeout(() => {
                        try {
                            const canvas = document.createElement("canvas");
                            canvas.width = video.videoWidth;
                            canvas.height = video.videoHeight;
                     const ctx = canvas.getContext("2d");
                            ctx.drawImage(video, 0, 0, canvas.width, canvas.height);
                            const dataUrl = canvas.toDataURL("image/jpeg", 0.7);
                            resolve(dataUrl);
                        } catch (e) {
                            reject(e);
                        }
                   }, 100);
                };
                video.onerror = (e) => reject(e);
            });
        }


    //Hàm tạo và cache thumbnail xem trước
        const PreviewCache_%ColumnName% = {
            storage: sessionStorage,
            prefix: "file_preview_${colName}_",
            get(key) { try { return this.storage.getItem(this.prefix + key); } catch(e) { return null; } },
            set(key, val) { try { this.storage.setItem(this.prefix + key, val); } catch(e) {} },
            remove(key) { try { this.storage.removeItem(this.prefix + key); } catch(e) {} }
        };

        async function generatePreview_%ColumnName%(f) {
            const cacheKey = (f.url || f.name).replace(/[^a-zA-Z0-9]/g, "_");
            let cached = PreviewCache_%ColumnName%.get(cacheKey);
            if (cached) return cached;
            try {
                let ab = null;
                if (["mp4", "webm"].includes(f.ext)) {
                      const vidUrl = await getFileUrl_%ColumnName%(f);
                      if(vidUrl) {
                         const coverImg = await getVideoCover(vidUrl);
                         if(coverImg) {
                            PreviewCache_%ColumnName%.set(cacheKey, coverImg);
                            return coverImg;
                         }
                      }
                      return null;
                }

                if (f.data && f.data.length > 50) {
                    const b64 = f.data.indexOf(",") > -1 ? f.data.split(",")[1] : f.data;
                    const bin = atob(b64);
                    ab = new Uint8Array(bin.length);
                    for (let i = 0; i < bin.length; i++) ab[i] = bin.charCodeAt(i);
                    ab = ab.buffer;
                } else if (f.url) {
                    const blobUrl = await getFileUrl_%ColumnName%(f);
                    if (blobUrl) {
                        const blob = await fetch(blobUrl).then(r => r.blob());
                        ab = await blob.arrayBuffer();
                    }
                }
                if (!ab) return null;

                let previewUrl = null;
                const thumbStrategies = {
                    docx: async () => {
                        if (typeof JSZip === "undefined") return null;
                        const zip = await JSZip.loadAsync(ab);
                        const docFile = zip.file("word/document.xml");
                        let text = "";
                        if (docFile) {
                            const xmlContent = await docFile.async("string");
                            const textNodes = new DOMParser().parseFromString(xmlContent, "text/xml").getElementsByTagName("w:t");
                            for (let i = 0; i < Math.min(textNodes.length, 100); i++) text += (textNodes[i].textContent || "") + " ";
                        }
                        return await drawCanvasPreview(text, "DOCX", "#1d4ed8");
                    },
                    xlsx: async () => {
                        if (typeof XLSX === "undefined") return null;
                        const wb = XLSX.read(ab, {type: "array"});
                        const ws = wb.SheetNames?.length ? wb.Sheets[wb.SheetNames[0]] : null;
                        return await drawCanvasPreview(null, "XLSX", "#004c39", ws);
                    },
                    pdf: async () => {
                          if (typeof pdfjsLib === "undefined") return null;
                          const pdf = await pdfjsLib.getDocument({data: ab}).promise;
                          if (pdf.numPages > 0) {
                            const page = await pdf.getPage(1);
                            const vp = page.getViewport({scale: 1.5});
                            const c = document.createElement("canvas");
                            c.width = 280; c.height = Math.round(280 * (vp.height / vp.width));
                            const ctx = c.getContext("2d");
                            ctx.fillStyle = "#fff"; ctx.fillRect(0, 0, c.width, c.height);
                            await page.render({canvasContext: ctx, viewport: page.getViewport({scale: c.width / vp.width})}).promise;
                            return c.toDataURL("image/png");
                          }
                          return null;
                    },
                    txt: async () => {
                        const txt = new TextDecoder("utf-8").decode(new Uint8Array(ab));
                        return await drawCanvasPreview(txt);
 },
        image: async () => {
                        const blob = new Blob([ab]);
                        const url = URL.createObjectURL(blob);
                        const res = await drawCanvasPreview(null, null, null, null, url);
                        URL.revokeObjectURL(url);
                        return res;
                    }
                };

                // Hàm hỗ trợ vẽ Canvas (Giữ nguyên)
                async function drawCanvasPreview(text, fallbackLabel, fallbackColor, wsData, imgUrl) {
                    const c = document.createElement("canvas");
              const ctx = c.getContext("2d");
                    c.width = 280; c.height = 200;
                    ctx.fillStyle = "#fff"; ctx.fillRect(0, 0, c.width, c.height);

                    if (imgUrl) {
                        try {
                            const img = new Image();
                            img.src = imgUrl;
                            await new Promise((resolve, reject) => {
                                img.onload = resolve;
                                img.onerror = resolve;
                            });
                            const scale = Math.min(c.width / img.width, c.height / img.height);
                            const w = img.width * scale;
                            const h = img.height * scale;
                            const x = (c.width - w) / 2;
                            const y = (c.height - h) / 2;
                            ctx.drawImage(img, x, y, w, h);
                            return c.toDataURL("image/png");
                        } catch(e) {}
                    }

                    ctx.strokeStyle = "#e0e0e0"; ctx.strokeRect(5, 5, c.width - 10, c.height - 10);

                    if (wsData && wsData["!ref"]) {
                          const r = XLSX.utils.decode_range(wsData["!ref"]);
                          ctx.strokeStyle = "#f0f0f0";
                          const cw = 32, ch = 12, maxR = Math.min(r.e.r + 1, 15), maxC = Math.min(r.e.c + 1, 8);
                          for (let i = 1; i <= maxC; i++) { ctx.beginPath(); ctx.moveTo(10 + i * cw, 10); ctx.lineTo(10 + i * cw, c.height - 10); ctx.stroke(); }
                          for (let j = 1; j <= maxR; j++) { ctx.beginPath(); ctx.moveTo(10, 10 + j * ch); ctx.lineTo(c.width - 10, 10 + j * ch); ctx.stroke(); }
                          ctx.fillStyle = "#333"; ctx.font = "8px Arial"; ctx.textBaseline = "middle";
                          for (let rowIdx = 0; rowIdx < maxR; rowIdx++) {
                             for (let colIdx = 0; colIdx < maxC; colIdx++) {
                                 const cell = wsData[XLSX.utils.encode_cell({r: rowIdx, c: colIdx})];
                                 if (cell?.v != null) ctx.fillText(String(cell.v).substring(0, 10), 12 + colIdx * cw, 22 + rowIdx * ch);
                             }
                          }
        return c.toDataURL("image/png");
                    }



                    if (text && text.trim()) {
                        const maxCharsPerLine = 38;
                        const lineHeight = 11;
                        const startY = 12;
                        const maxLines = 16;
                        const words = text.trim().replace(/\\s+/g, " ").split(" ");
                        const lines = [];
                        let currentLine = "";
                        for (let i = 0; i < words.length; i++) {
                            const testLine = currentLine + (currentLine ? " " : "") + words[i];
                            if (testLine.length > maxCharsPerLine) {
                                if (currentLine) lines.push(currentLine);
                                currentLine = words[i].length > maxCharsPerLine ? words[i].substring(0, maxCharsPerLine - 3) + "..." : words[i];
                            } else { currentLine = testLine; }
            if (lines.length >= maxLines - 1) break;
                        }
                        if (currentLine && lines.length < maxLines) lines.push(currentLine);
                        ctx.fillStyle = "#333"; ctx.font = "9px Arial"; ctx.textBaseline = "top";
                        for (let i = 0; i < lines.length; i++) { ctx.fillText(lines[i], 10, startY + i * lineHeight); }
                        if (words.length > lines.join(" ").split(" ").length || lines.length >= maxLines) {
                            ctx.fillStyle = "#999"; ctx.font = "9px Arial"; ctx.fillText("...", 10, startY + lines.length * lineHeight);
                        }
                    } else if (fallbackLabel) {
                        ctx.fillStyle = fallbackColor || "#666"; ctx.font = "bold 32px Arial";
                        ctx.textAlign = "center"; ctx.textBaseline = "middle"; ctx.fillText(fallbackLabel, c.width / 2, c.height / 2);
                    }
                    return c.toDataURL("image/png");
                }

                const strategyKey = f.isImg ? "image" :
                                    ["docx","doc"].includes(f.ext) ? "docx" :
                                    ["xlsx","xls"].includes(f.ext) ? "xlsx" :
                                    f.ext;
                if (thumbStrategies[strategyKey]) previewUrl = await thumbStrategies[strategyKey]();
                if (previewUrl) PreviewCache_%ColumnName%.set(cacheKey, previewUrl);
                return previewUrl;
            } catch(e) { console.error("Preview error:", e); return null; }
        }


    //Hàm hiển thị Modal Preview (Web)
        let activeBlobUrl = null;
        async function preview_%ColumnName%(rawF) {
            const f = normalizeFile(rawF);
            const $m = $("#modal_" + colName);
            const $v = $m.find(".viewport-content");
            const $l = $m.find(".glass-loading");

            // Reset UI
            $m.fadeIn(200).css("display", "flex");
            $l.show(); $v.empty();
            $v.css({ "display": "flex", "align-items": "center", "justify-content": "center" });

            $m.find(".file-name").text(f.name);
            $m.find(".file-size").text("...");

            const renderStrategies = {
                image: async (url) => {
                    const $img = $(`<img src="${url}" style="max-width:100%; max-height:100%;">`);
                    $v.html($img);
                },
                pdf: async (url) => {
                      if (typeof pdfjsLib === "undefined") throw new Error("Thư viện PDF thiếu");
                      $v.css({ "display": "block", "text-align": "center", "background": "#525659" });
                      const $container = $(`<div style="padding: 10px; display: inline-block;"></div>`);
                      $v.html($container);
                      const loadingTask = pdfjsLib.getDocument(url);
                      const pdf = await loadingTask.promise;
                      for (let pageNum = 1; pageNum <= pdf.numPages; pageNum++) {
                        const page = await pdf.getPage(pageNum);
                        const desiredWidth = Math.min($v.width() - 40, 800);
                        const viewportBase = page.getViewport({ scale: 1 });
                        const scale = desiredWidth / viewportBase.width;
                        const viewport = page.getViewport({ scale: scale });
                        const canvas = document.createElement("canvas");
                        const context = canvas.getContext("2d");
                        canvas.height = viewport.height;
                        canvas.width = viewport.width;
                        canvas.style.marginBottom = "10px";
                        canvas.style.boxShadow = "0 2px 5px rgba(0,0,0,0.3)";
                        $container.append(canvas);
                        await page.render({ canvasContext: context, viewport: viewport }).promise;
                      }
                },
                video: async (url) => {
                    $v.html(`<video controls autoplay playsinline webkit-playsinline style="max-height:100%; max-width:100%; border-radius:8px;"><source src="${url}"></video>`);
                },
                docx: async (url) => {
                    if (typeof docx === "undefined") throw new Error("Thư viện DOCX thiếu");
                    $v.css({ "display": "block", "text-align": "left" });
                    $v.html(`<div id="docx-container" style="background:#fff; width:100%; min-height:100%; padding:40px; border-radius:8px; margin: 0 auto;"></div>`);
                    const blob = await fetch(url).then(r => r.blob());
                    await docx.renderAsync(blob, document.getElementById("docx-container"));
                },
                xlsx: async (url) => {
                    if (typeof XLSX === "undefined") throw new Error("Thư viện XLSX thiếu");
                    $v.css({ "display": "block", "text-align": "left" });
                    const ab = await fetch(url).then(r => r.arrayBuffer());
                    const wb = XLSX.read(ab, {type: "array"});
                    const html = XLSX.utils.sheet_to_html(wb.Sheets[wb.SheetNames[0]]);
                    $v.html(`<div style="background:#fff; width:100%; min-height:100%; overflow:auto; padding:10px; border-radius:8px;">${html}</div>`);
                    $v.find("table").css({width:"100%", borderCollapse:"collapse"}).find("td,th").css({border:"1px solid #ccc", padding:"4px"});
                },
                txt: async (url) => {
                    $v.css({ "display": "block", "text-align": "left" });
                    const txt = await fetch(url).then(r => r.text());
                    $v.html(`<div style="background:#fff; width:100%; min-height:100%; padding:20px; border-radius:8px; white-space: pre-wrap; font-family: monospace; font-size: 14px; color:#333; overflow:auto;">${$("<div>").text(txt).html()}</div>`);
                },
                fallback: async () => {
                    $v.html(`<div style="color:white; text-align:center;"><i class="bi bi-file-earmark-break" style="font-size:48px;"></i><p>Không hỗ trợ xem trước</p></div>`);
                }
            };
            const iconMap = { pdf: "bi-file-pdf", docx: "bi-file-word", xlsx: "bi-file-excel", txt: "bi-file-text" };
            $m.find(".file-icon-type").attr("class", `bi ${f.isImg ? "bi-file-image" : (iconMap[f.ext] || "bi-file-earmark")} file-icon-type`);

            try {
                activeBlobUrl = await getFileUrl_%ColumnName%(f);
                if (!activeBlobUrl) throw new Error("File not found");

                $m.find(".btn-download-modal").off("click").on("click", () => {
                    const a = document.createElement("a"); a.href = activeBlobUrl; a.download = f.name; a.click();
                });

      let type = "fallback";
                if (f.isImg) type = "image";
                else if (f.ext === "pdf") type = "pdf";
                else if (["mp4", "webm"].includes(f.ext)) type = "video";
                else if (["docx", "doc"].includes(f.ext)) type = "docx";
                else if (["xlsx", "xls"].includes(f.ext)) type = "xlsx";
                else if (f.ext === "txt") type = "txt";

                await renderStrategies[type](activeBlobUrl);

            } catch (e) {
                $v.css({ "display": "flex", "align-items": "center", "justify-content": "center" });
                $v.html(`<div style="color:#fca5a5; text-align:center;"><i class="bi bi-exclamation-circle" style="font-size:48px;"></i><p>${e.message}</p></div>`);
            } finally {
                $l.fadeOut(300);
            }
        }


    //Hàm đóng Modal
        function closeModal_%ColumnName%() {
            $("#modal_" + colName).fadeOut(200);
            setTimeout(() => {
  $("#modal_" + colName + " .viewport-content").empty();
            }, 100);
        }


    //Hàm mở file trên Mobile App (ĐÃ TỐI ƯU CACHE BASE64)
        async function openMobileFile_%ColumnName%(f) {

            try {
                let base64 = null;
                const cacheKey = f.url || f.name;

                // 1. Kiểm tra trong Cache Base64 trước
                if (Base64Cache_%ColumnName%[cacheKey]) {
                    base64 = Base64Cache_%ColumnName%[cacheKey];
                }
                // 2. Nếu không có cache, kiểm tra f.data (file vừa upload)
                else if (f.data && f.data.length > 50) {
                      base64 = f.data.indexOf(",") > -1 ? f.data.split(",")[1] : f.data;
                      Base64Cache_%ColumnName%[cacheKey] = base64; // Cache lại luôn
                }
                // 3. Nếu không có gì hết thì mới tải từ Server
                else if (f.url) {
                    const response = await AjaxHPAParadiseAsync({
                        data: { name: "paradisefile_sp_GetFileAPI", param: ["FilePath", f.url.replace(/\\/g, "\\\\")] },
                        xhrFields: { responseType: "blob" }
                    });
                    const blob = response instanceof Blob ? response : (response?.data || response?.blob);
                    if (blob) {
                        base64 = await new Promise((resolve, reject) => {
                            const reader = new FileReader();
                            reader.onloadend = () => {
                                const res = reader.result;
                                resolve(res.includes(",") ? res.split(",")[1] : res);
                            };
                            reader.onerror = reject;
                            reader.readAsDataURL(blob);
                        });
                        // 4. Lưu vào cache để lần sau dùng lại
                        if (base64) Base64Cache_%ColumnName%[cacheKey] = base64;
                    }
                }

                if (typeof HideLoadingByClassOrID === "function") HideLoadingByClassOrID("body");

                if (base64 && typeof getFileQlbeta === "function") {
                    getFileQlbeta(base64, f.name, f.isImg, 0);
                } else {
                    preview_%ColumnName%(f);
                }
            } catch (e) {
                if (typeof HideLoadingByClassOrID === "function") HideLoadingByClassOrID("body");
                console.error("Lỗi mở file mobile:", e);
                preview_%ColumnName%(f);
            }
        }

        $("#modal_" + colName).on("click", function(e) { if(e.target === this || $(e.target).hasClass("glass-backdrop")) closeModal_%ColumnName%(); });
        $("#modal_" + colName + " .btn-close-modal").on("click", closeModal_%ColumnName%);
        $(document).on("keydown", e => { if(e.key === "Escape") closeModal_%ColumnName%(); });


    //Hàm Lazy Load Preview
        async function loadRealPreview_%ColumnName%(targetElem, f) {
            const $thumbContainer = $(targetElem);
            if($thumbContainer.hasClass("loaded")) return;
            $thumbContainer.append(`<div class="thumb-loading-overlay"><div class="spinner" style="width:15px;height:15px;border-width:2px;"></div></div>`);
            try {
                let url = null;
                if (f.isImg && f.data && f.data.length > 50) {
                      url = f.data.indexOf("data:image") === 0 ? f.data : `data:image/${f.ext};base64,${f.data}`;
                }
                else if (f.isImg || ["mp4", "webm", "pdf", "docx", "doc", "xlsx", "xls", "txt"].includes(f.ext)) {
                      const cacheKey = (f.url || f.name).replace(/[^a-zA-Z0-9]/g, "_");
                      const cached = PreviewCache_%ColumnName%.get(cacheKey);
                      if(cached) url = cached;
              else url = await generatePreview_%ColumnName%(f);
                }
                if (url) {
                    $thumbContainer.html(`<img src="${url}" style="width:100%; height:100%; object-fit:cover;">`);
                } else {
                    $thumbContainer.find(".thumb-loading-overlay").remove();
                }
                $thumbContainer.addClass("loaded");
            } catch (e) {
                $thumbContainer.find(".thumb-loading-overlay").remove();
                console.warn("Lazy load error", e);
            }
        }

    //Hàm render danh sách file
        function render_%ColumnName%() {
            let files = [];
            if (typeof _localData_%ColumnName% !== "undefined") files = _localData_%ColumnName%;
            else if (window["DataSource_" + colName]) files = window["DataSource_" + colName];

            const $list = $("#filelist_" + colName).empty();
            if (!files || files.length === 0) return;

            initObserver_%ColumnName%();

            files.forEach(rawF => {
                const f = normalizeFile(rawF);

                const iconMap = {
                    pdf: {icon: "bi-file-pdf", color: "#ef4444"},
                    xlsx: {icon: "bi-file-excel", color: "#10b981"}, xls: {icon: "bi-file-excel", color: "#10b981"},
                    docx: {icon: "bi-file-word", color: "#004c39"}, doc: {icon: "bi-file-word", color: "#004c39"},
                    txt: {icon: "bi-file-text", color: "#6b7280"},
                    mp4: {icon: "bi-camera-video", color: "#9333ea"}, webm: {icon: "bi-camera-video", color: "#9333ea"}
                };
                let def = iconMap[f.ext] || {icon: "bi-file-earmark", color: "#6b7280"};
                if (f.isImg) { def.icon = "bi-file-image"; def.color = "#004c39"; }

                const $thumbContainer = $(`<div class="card-thumb"><i class="bi ${def.icon}" style="font-size:32px; color:${def.color};"></i></div>`);

                $thumbContainer.data("file", f);

                if(_observer_%ColumnName%) _observer_%ColumnName%.observe($thumbContainer[0]);

                const $item = $(`
                    <div class="file-card">
                        <div class="card-info">
                            <div class="card-name" title="${f.name}">${f.name}</div>
                        </div>
                        <button class="btn-del"><i class="bi bi-x"></i></button>
                    </div>
                `);

                $item.prepend($thumbContainer);

                $item.find(".card-thumb, .card-info").click(() => {
                    const isMobileApp = (typeof ParadiseOption !== "undefined" &&
                                         ParadiseOption.AppInfoVersionString &&
                                         ParadiseOption.AppInfoVersionString.length > 0);

                    if (isMobileApp) {
                        openMobileFile_%ColumnName%(f);
                    } else {
                        preview_%ColumnName%(f);
 }
   });

                $item.find(".btn-del").click((e) => {
                    e.stopPropagation();
                        AjaxHPAParadise({
                            data: {
                                name: "sp_Common_DeleteAttachment",
                                param: ["TableName", "%tableId%", "ColumnName", "%ColumnName%", "IDColumnName", "%ColumnIDName%", "IDValue", currentRecordID_%ColumnIDName%, "UrlFile", f.url, "LoginID", LoginID || 0]
                            },
                            success: () => {
                                // Xóa khỏi Cache URL (Web)
                                const cacheKey = f.url || f.name;
                                if (BlobCache_%ColumnName%[cacheKey]) {
                                    URL.revokeObjectURL(BlobCache_%ColumnName%[cacheKey]);
            delete BlobCache_%ColumnName%[cacheKey];
        }
                                // Xóa khỏi Cache Base64 (Mobile)
                                if (Base64Cache_%ColumnName%[cacheKey]) {
                                    delete Base64Cache_%ColumnName%[cacheKey];
                                }

                                const newData = files.filter(x => (x.UrlFile||x.Url||x.url) !== f.url);
              window["DataSource_" + colName] = newData;
                                _localData_%ColumnName% = newData;
                                render_%ColumnName%();
                                if(window.DevExpress) DevExpress.ui.notify("Đã xóa", "success", 1000);
                            }
                        });
                });
                $list.append($item);
            });
        }

        let _localData_%ColumnName% = window["DataSource_" + colName] || [];
        try {
            Object.defineProperty(window, "DataSource_" + colName, {
                configurable: true, get: function() { return _localData_%ColumnName%; },
                set: function(val) { _localData_%ColumnName% = val; render_%ColumnName%(); }
            });
        } catch(e) {
            let _checkInterval = setInterval(() => {
                if(window["DataSource_" + colName] && window["DataSource_" + colName].length > 0 && $("#filelist_" + colName).is(":empty")) {
                       render_%ColumnName%(); clearInterval(_checkInterval);
                }
            }, 500);
        }

        instanceUploader = $("#uploader_" + colName).dxFileUploader({
            multiple: true, uploadMode: "instantly", visible: false,
            dialogTrigger: "#dropzone_" + colName, dropZone: "#dropzone_" + colName,
            onValueChanged: () => { clearTimeout(timeOutSave); timeOutSave = setTimeout(save_%ColumnName%, 150); }
        }).dxFileUploader("instance");

        Instance%ColumnName%%UID% = instanceUploader;

        $("#dropzone_" + colName)
            .on("dragover dragenter", (e) => { e.preventDefault(); $(e.currentTarget).addClass("drag-over"); })
            .on("dragleave drop", (e) => { e.preventDefault(); $(e.currentTarget).removeClass("drag-over"); })
            .on("click", async function(e) {
                if ($(e.target).closest(".file-card").length > 0) return;
                const os = getMobileOS();
                const isMobileApp = (typeof ParadiseOption !== "undefined" && ParadiseOption.AppInfoVersionString && ParadiseOption.AppInfoVersionString.length > 0);
                if (isMobileApp && os === "Android") {
                    try {
                        const $dzText = $(this).find(".main-text");
                        const $dzSub = $(this).find(".sub-text");
                        const originalText = $dzText.text();
                        const originalSub = $dzSub.text();
                        $dzText.text("Đang mở file picker...");
                        $dzSub.text("Vui lòng chọn file");
                        const result = await apimobileAjaxAsync({}, {
                     "MethodName": "MobileFilePickerMultipleAsync",
                            "prs": [],
                        });
                        if (!result || result == "Object reference not set to an instance of an object") {
                            $dzText.text(originalText); $dzSub.text(originalSub); return;
                        }
                        instanceUploader.option("value", result.map((f, i) => ({
                            name: f.fileName, size: Math.round((f.data.length * 3) / 4), _customData: f.data
                        })));
                    } catch (err) {
                        if(window.DevExpress) DevExpress.ui.notify("Lỗi: " + err, "error", 2000);
                    }
                }
            });




    //Hàm lưu file
        async function save_%ColumnName%() {
            const files = instanceUploader.option("value");
            if (!files?.length) return;

            const $dzText = $("#dropzone_" + colName).find(".main-text");
            const $dzSub = $("#dropzone_" + colName).find(".sub-text");
            const originalText = $dzText.text();
            const originalSub = $dzSub.text();

            $dzText.text("Bắt đầu xử lý " + files.length + " file...");

            // Duyệt qua từng file và Gửi ngay lập tức
            for (let i = 0; i < files.length; i++) {
                const file = files[i];

                $dzText.text("Đang xử lý file " + (i + 1) + "/" + files.length);
                $dzSub.text(file.name);

                await new Promise(r => setTimeout(r, 10)); // UI Breath

                try {
                    let processedFileItem = null;

                    if (file._customData) {
                        // 1. Data từ Mobile App
                        processedFileItem = { fileName: file.name, data: file._customData };
                    } else {
                        if (file.type && file.type.indexOf("image") === 0) {
                            // Xử lý ảnh (Nén + Cắt header)
                            let fileData = await compressImage(file, 1280, 960, 0.7);
                            if(fileData.data && fileData.data.indexOf(",") > -1) {
                                fileData.data = fileData.data.split(",")[1];
                            }
                            processedFileItem = fileData;
                        } else {
                            // Xử lý file khác (Đọc Base64 + Cắt header)
                            const base64String = await new Promise((resolve, reject) => {
                                const reader = new FileReader();
                                reader.onload = () => resolve(reader.result);
                                reader.onerror = error => reject(error);
                                reader.readAsDataURL(file);
                            });
                            const rawData = base64String.indexOf(",") > -1 ? base64String.split(",")[1] : base64String;
                            processedFileItem = { fileName: file.name, data: rawData };
                        }
                    }

                    if (processedFileItem) {
                        $dzText.text("Đang tải lên server (" + (i + 1) + "/" + files.length + ")...");
                        let finalbase64 = processedFileItem.data
                        let finalfilename = processedFileItem.fileName
                        let parsedUpload
                        const uploadRes = await UploadMergeFileSplit(finalbase64, finalfilename);
                        parsedUpload = typeof uploadRes === "string" ? JSON.parse(uploadRes) : uploadRes;

                        await new Promise((resolve, reject) => {
                            AjaxHPAParadise({
                                data: {
                                    name: "sp_Common_SaveAttachment",
                                    param: ["TableName", "%tableId%", "ColumnName", "%ColumnName%", "IDColumnName", "%ColumnIDName%", "IDValue", currentRecordID_%ColumnIDName%, "JsonFile", parsedUpload.data, "LoginID", LoginID || 0]
                                },
                                success: (res) => {
                                    try {
                                        const data = JSON.parse(res);
                                        // Cập nhật lại list file hiển thị (Server trả về list mới nhất)
                                        window["DataSource_" + colName] = JSON.parse(data.data[0][0].ListFiles);
                                    } catch(e) {}
                                    resolve(); // Báo hiệu đã xong file này
                                },
                                error: () => {
                                    if(window.DevExpress) DevExpress.ui.notify("Lỗi tải file: " + file.name, "error", 2000);
                                    resolve(); // Vẫn resolve để chạy tiếp file sau (không dừng hẳn)
                                }
                            });
                        });
                    }

                } catch (err) {
                    console.error("Lỗi xử lý file:", file.name, err);
                }
            }

            // --- BƯỚC 3: KẾT THÚC TOÀN BỘ ---
            instanceUploader.reset();
            $dzText.text(originalText);
            $dzSub.text(originalSub);
            if(window.DevExpress) DevExpress.ui.notify("Hoàn tất tải lên", "success", 1500);
        }

        render_%ColumnName%();
    '
    WHERE [Type] = 'hpaControlFile' AND AutoSave = 1 AND ReadOnly = 0
END
GO
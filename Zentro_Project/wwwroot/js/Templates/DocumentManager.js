class DocumentUploadFlow {
    constructor() {
        this.addBtn = document.getElementById("addDocumentBtn");
        this.btnWrapper = document.getElementById("addDocumentWrapper");
        this.documentsList = document.getElementById("documentsList");
        this.modal = document.getElementById("extractedMetafieldsModal");
        this.fileInput = null;
        this.createBtn = null;
        this.selectedFile = null;
        this.init();
    }

    init() {
        // Setup modal close handlers ONCE
        this.setupModalCloseHandlers();

        this.addBtn?.addEventListener("click", (e) => {
            e.preventDefault();
            this.showUploadBox();
        });

    }

    async uploadMetafieldsToDatabase(rows) {
        const templateData = document.getElementById('template-data');
        let templateVersionId = parseInt(templateData?.dataset?.tempVersionId || '0');

        if (!templateVersionId) {
            alert('Template version not found. Please save template first.');
            return;
        }

        console.log("[DocumentManager] Before version change - templateVersionId:", templateVersionId);

        // ✅ Trigger version change before uploading metafields
        if (window.versionControl && typeof window.versionControl.requestVersionIfNeeded === 'function') {
            console.log("[DocumentManager] Triggering version change before bulk upload");
            const newVersionId = await window.versionControl.requestVersionIfNeeded();
            console.log("[DocumentManager] After version change - newVersionId:", newVersionId);

            // ✅ Use the returned version ID
            if (newVersionId && newVersionId !== templateVersionId) {
                templateVersionId = newVersionId;
                console.log("[DocumentManager] Version changed to:", templateVersionId);
            }
        }

        // ✅ Re-read from DOM to ensure we have the latest
        const updatedTemplateVersionId = parseInt(templateData?.dataset?.tempVersionId || '0');
        console.log("[DocumentManager] Final templateVersionId from DOM:", updatedTemplateVersionId);

        const payload = {
            templateVersionId: updatedTemplateVersionId,
            metafields: rows
        };

        try {
            const response = await fetch('/api/Metafield/BulkUploadExtracted', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(payload)
            });

            if (!response.ok) {
                throw new Error('Upload failed');
            }

            const result = await response.json();

            if (result.success) {
                // Close modal
                this.closeModal();

                // ✅ Properly reload metafields in UI
                if (window.formBuilderInstance?.metaFieldsManager) {
                    // Reload from database
                    window.formBuilderInstance.metaFieldsManager.loadMetafieldsFromDb();

                    // Update template status
                    window.formBuilderInstance.determineAndSetTemplateNewStatus();
                }

                // Re-enable button
                if (this.addBtn) {
                    this.addBtn.disabled = false;
                    this.addBtn.style.opacity = '1';
                    this.addBtn.style.cursor = 'pointer';
                }
            } else {
                alert('Failed to upload metafields: ' + result.message);
            }
        } catch (error) {
            console.error('Error uploading metafields:', error);
            alert('Failed to upload metafields to database.');
        }
    }



    getMetafieldsFromModal() {
        const body = document.getElementById('extractedMetafieldsBody');
        if (!body) return [];

        const table = body.querySelector('table');
        if (!table) return [];

        const rows = [];
        const tbody = table.querySelector('tbody');

        if (!tbody) return [];

        tbody.querySelectorAll('tr').forEach(row => {
            const cells = row.querySelectorAll('td');
            if (cells.length >= 4) {
                rows.push({
                    name: cells[0].textContent.trim(),
                    fieldType: cells[1].textContent.trim(),
                    tag: cells[2].textContent.trim(),
                    visibility: cells[3].textContent.trim()
                });
            }
        });

        return rows;
    }

    setupModalCloseHandlers() {
        const closeBtn = document.getElementById("closeExtractedMetafieldsModal");
        const cancelBtn = document.getElementById("cancelExtractedMetafieldsBtn");
        const uploadBtn = document.getElementById("uploadExtractedMetafieldsBtn");

        if (closeBtn) {
            closeBtn.onclick = () => this.closeModal();
        }

        if (cancelBtn) {
            cancelBtn.onclick = () => this.closeModal();
        }

        if (uploadBtn) {
            uploadBtn.onclick = () => {
                // Get current rows from modal table
                const rows = this.getMetafieldsFromModal();

                if (!rows || rows.length === 0) {
                    alert('No metafields to upload');
                    return;
                }

                // Upload to database
                this.uploadMetafieldsToDatabase(rows);
            };
        }
    }

    closeModal() {
        if (this.modal) {
            //this.modal.style.display = "none";
            this.modal.classList.remove("active");
        }
    }

    showUploadBox() {
        // Remove any existing input box
        const existing = this.documentsList.querySelector('.section-sub-box');
        if (existing) existing.remove();

        // Create the input box UI
        const subBox = document.createElement('section');
        subBox.className = 'section-sub-box';

        subBox.innerHTML = `
            <h2 class="section-subheading">Upload Document</h2>
            <div class="section-input-wrapper">
                <input type="file" class="section-input" id="documentFileInput" accept=".odt" />
            </div>
            <div class="subsection-actions">
                <button type="button" class="done-button create-button" style="margin-left:auto;" disabled>Create</button>
            </div>
        `;

        this.btnWrapper.parentNode.insertBefore(subBox, this.btnWrapper);

        this.fileInput = subBox.querySelector('#documentFileInput');
        this.createBtn = subBox.querySelector('.create-button');

        this.fileInput.addEventListener('change', () => {
            this.selectedFile = this.fileInput.files[0];
            this.createBtn.disabled = !this.selectedFile;
        });

        this.createBtn.addEventListener('click', () => this.handleCreate(subBox));
    }

    handleCreate(subBox) {
        if (!this.selectedFile) {
            alert("Please select a file.");
            return;
        }
        this.createBtn.disabled = true;
        this.uploadDocument(subBox, this.selectedFile);
    }

    uploadDocument(subBox, file) {
        const formData = new FormData();
        formData.append("file", file);
        const templateId = document.getElementById("templateIdHolder")?.value;
        if (templateId) formData.append("templateId", templateId);

        // Show loading FIRST
        this.showLoadingInExtractedMetafieldsModal();

        fetch("/api/TemplateDocument/UploadDocument", {
            method: "POST",
            body: formData
        })
            .then(res => {
                if (!res.ok) throw new Error("Upload failed");
                return res.json();
            })
            .then(data => {
                if (data.success) {
                    // Remove upload box
                    subBox.remove();
                    // Extract fields
                    this.extractFields(file.name);
                    loadUploadedDocument();
                } else {
                    this.showErrorInExtractedMetafieldsModal("Upload failed.");
                    this.createBtn.disabled = false;
                }
            })
            .catch(err => {
                console.error("Upload error:", err);
                this.showErrorInExtractedMetafieldsModal("Upload failed (network or server error).");
                this.createBtn.disabled = false;
            });
    }

    extractFields(fileName) {
        // Keep showing loading
        this.showLoadingInExtractedMetafieldsModal();

        fetch(`/api/TemplateDocument/extract-tags?fileName=${encodeURIComponent(fileName)}`)
            .then(res => {
                if (!res.ok) throw new Error("Extract failed");
                return res.json();
            })
            .then(data => {
                console.log("Extract response:", data);

                if (data.doubleBracketTags && Array.isArray(data.doubleBracketTags) && data.doubleBracketTags.length > 0) {
                    const rows = data.doubleBracketTags.map(tag => ({
                        name: tag,
                        type: "Text",
                        tag: tag,
                        visibility: "Admin only"
                    }));
                    this.showExtractedMetafieldsModal(rows);
                } else {
                    this.showErrorInExtractedMetafieldsModal("No fields found in document.");
                }
            })
            .catch((err) => {
                console.error("Extract error:", err);
                this.showErrorInExtractedMetafieldsModal("Failed to extract fields from document.");
            });
    }

    showLoadingInExtractedMetafieldsModal() {
        const body = document.getElementById("extractedMetafieldsBody");
        if (!body) {
            console.error("extractedMetafieldsBody not found!");
            return;
        }

        body.innerHTML = `
            <div style="text-align:center;padding:40px 0;">
                <div class="spinner-border" role="status">
                    <span class="sr-only">Loading...</span>
                </div>
                <div style="margin-top: 10px;">Loading...</div>
            </div>
        `;

        if (this.modal) {
            this.modal.classList.add("active");
            console.log("Modal opened - display:", this.modal.style.display, "classList:", this.modal.classList);
        } else {
            console.error("Modal element not found!");
        }
    }

    showErrorInExtractedMetafieldsModal(msg) {
        const body = document.getElementById("extractedMetafieldsBody");
        if (!body) return;

        body.innerHTML = `
            <div style="color:red;text-align:center;padding:40px 0;">
                ${msg}
            </div>
        `;

        if (this.modal) {
            this.modal.classList.add("active");
        }
    }

    showExtractedMetafieldsModal(rows) {
        const body = document.getElementById("extractedMetafieldsBody");
        if (!body) return;

        let html = `
            <table class="table table-bordered" style="width: 100%;">
                <thead>
                    <tr>
                        <th>Name</th>
                        <th>Type of Field</th>
                        <th>Tag</th>
                        <th>Visibility</th>
                    </tr>
                </thead>
                <tbody>
        `;

        for (const row of rows) {
            html += `
                <tr>
                    <td>${row.name}</td>
                    <td>${row.type}</td>
                    <td>${row.tag}</td>
                    <td>${row.visibility}</td>
                </tr>
            `;
        }

        html += `</tbody></table>`;
        body.innerHTML = html;

        if (this.modal) {
            this.modal.classList.add("active");
            console.log("Modal displayed with data");
        }
    }
}

async function loadUploadedDocument() {
    const templateId = document.getElementById("templateIdHolder")?.value;
    if (!templateId) return;

    try {
        const res = await fetch(`/api/TemplateDocument/GetDocumentByTemplateId?templateId=${templateId}`);
        if (!res.ok) throw new Error("Failed to fetch document");
        const data = await res.json();

        const grid = document.getElementById("uploadedDocumentsGrid");
        if (grid) {
            grid.innerHTML = "";
            if (data.name) {
                // Create the document box just like metafields
                const docDiv = document.createElement("div");
                docDiv.className = "saved-txt stored-overlay";
                docDiv.style.borderRadius = "6px 6px 0 0"; // Top corners rounded, like metafields
                docDiv.innerHTML = `
            <div class="main-value">
                <svg class="saved-svg" viewBox="0 0 20 20">
                    <circle cx="5" cy="5" r="1.5"></circle>
                    <circle cx="5" cy="10" r="1.5"></circle>
                    <circle cx="5" cy="15" r="1.5"></circle>
                    <circle cx="10" cy="5" r="1.5"></circle>
                    <circle cx="10" cy="10" r="1.5"></circle>
                    <circle cx="10" cy="15" r="1.5"></circle>
                </svg>
                <span>${data.name}</span>
            </div>
        `;
                grid.appendChild(docDiv);
            }
        }
    } catch (err) {
        console.error("Error loading document:", err);
    }
}

document.addEventListener("DOMContentLoaded", function () {
    window.documentUploadFlow = new DocumentUploadFlow();
    setTimeout(loadUploadedDocument, 500);
});
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
        this.setupModalCloseHandlers();

        this.addBtn?.addEventListener("click", (e) => {
            e.preventDefault();
            this.showUploadBox();
        });
    }

    async uploadMetafieldsToDatabase(rows) {
        const templateData = document.getElementById('template-data');
        const templateVersionId = parseInt(templateData?.dataset?.tempVersionId || '0');

        if (!templateVersionId) {
            alert('Template version not found. Please save template first.');
            return;
        }

        const payload = {
            templateVersionId: templateVersionId,
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
                this.closeModal();

                if (window.formBuilderInstance?.metaFieldsManager) {
                    window.formBuilderInstance.metaFieldsManager.loadMetafieldsFromDb();
                }

                this.addBtn.disabled = false;
                this.addBtn.style.opacity = '1';
                this.addBtn.style.cursor = 'pointer';
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

        const rows = [];
        const tableRows = body.querySelectorAll('tbody tr');

        tableRows.forEach(row => {
            const tag = row.querySelector('.metafield-tag')?.value?.trim();
            const name = row.querySelector('.metafield-name')?.value?.trim();
            const fieldType = row.querySelector('.metafield-type')?.value;
            const visibility = row.querySelector('.metafield-visibility')?.value;

            if (name) {
                rows.push({
                    tag: tag,
                    name: name,
                    fieldType: fieldType,
                    visibility: visibility
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
                const rows = this.getMetafieldsFromModal();

                if (!rows || rows.length === 0) {
                    alert('Please fill at least one metafield name before uploading');
                    return;
                }

                const body = document.getElementById('extractedMetafieldsBody');
                const tableRows = body.querySelectorAll('tbody tr');
                const emptyNames = [];

                tableRows.forEach((row, index) => {
                    const nameInput = row.querySelector('.metafield-name');
                    if (!nameInput.value.trim()) {
                        emptyNames.push(index + 1);
                        nameInput.style.borderColor = '#dc3545';
                    } else {
                        nameInput.style.borderColor = '#ddd';
                    }
                });

                if (emptyNames.length > 0) {
                    alert(`Please fill the Name field for row(s): ${emptyNames.join(', ')}`);
                    return;
                }

                this.uploadMetafieldsToDatabase(rows);
            };
        }
    }

    closeModal() {
        if (this.modal) {
            this.modal.classList.remove("active");
        }
    }

    showUploadBox() {
        const existing = this.documentsList.querySelector('.section-sub-box');
        if (existing) existing.remove();

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
                    subBox.remove();
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
        this.showLoadingInExtractedMetafieldsModal();

        fetch(`/api/TemplateDocument/extract-tags?fileName=${encodeURIComponent(fileName)}`)
            .then(res => {
                if (!res.ok) throw new Error("Extract failed");
                return res.json();
            })
            .then(data => {
                console.log("Extract response:", data);

                if (data.doubleBracketTags && Array.isArray(data.doubleBracketTags) && data.doubleBracketTags.length > 0) {
                    this.showExtractedMetafieldsModal(data.doubleBracketTags);
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

    showExtractedMetafieldsModal(tags) {
        const body = document.getElementById("extractedMetafieldsBody");
        if (!body) return;

        let html = `
            <table style="width: 100%; border-collapse: collapse; background: white;">
                <thead>
                    <tr style="background-color: #f8f9fa; border-bottom: 2px solid #dee2e6;">
                        <th style="padding: 12px; text-align: left; font-weight: 600; font-size: 13px; color: #495057; border-right: 1px solid #dee2e6;">Tag</th>
                        <th style="padding: 12px; text-align: left; font-weight: 600; font-size: 13px; color: #495057; border-right: 1px solid #dee2e6;">Name <span style="color: red;">*</span></th>
                        <th style="padding: 12px; text-align: left; font-weight: 600; font-size: 13px; color: #495057; border-right: 1px solid #dee2e6;">Type of Field</th>
                        <th style="padding: 12px; text-align: left; font-weight: 600; font-size: 13px; color: #495057; border-right: 1px solid #dee2e6;">Visibility</th>
                        <th style="padding: 12px; text-align: center; font-weight: 600; font-size: 13px; color: #495057; width: 60px;">Action</th>
                    </tr>
                </thead>
                <tbody>
        `;

        tags.forEach((tag, index) => {
            html += `
                <tr data-row-index="${index}" style="border-bottom: 1px solid #dee2e6;">
                    <td style="padding: 10px; border-right: 1px solid #dee2e6;">
                        <input type="text" 
                               class="metafield-tag" 
                               value="${tag}" 
                               readonly 
                               style="width: 100%; padding: 8px 10px; border: 1px solid #ddd; border-radius: 4px; font-size: 14px; background-color: #ffffff; cursor: text;">
                    </td>
                    <td style="padding: 10px; border-right: 1px solid #dee2e6;">
                        <input type="text" 
                               class="metafield-name" 
                            
                               style="width: 100%; padding: 8px 10px; border: 1px solid #ddd; border-radius: 4px; font-size: 14px;">
                    </td>
                    <td style="padding: 10px; border-right: 1px solid #dee2e6;">
                        <select class="metafield-type" 
                                style="width: 100%; padding: 8px 10px; border: 1px solid #ddd; border-radius: 4px; font-size: 14px; background-color: white; cursor: pointer;">
                            <option value="">Select Type</option>
                            <option value="Single Line Text">Single Line Text</option>
                        </select>
                    </td>
                    <td style="padding: 10px; border-right: 1px solid #dee2e6;">
                        <select class="metafield-visibility" 
                                style="width: 100%; padding: 8px 10px; border: 1px solid #ddd; border-radius: 4px; font-size: 14px; background-color: white; cursor: pointer;">
                            <option value="Admin only">Admin only</option>
                            <option value="Customer and Admin">Customer and Admin</option>
                        </select>
                    </td>
                    <td style="padding: 10px; text-align: center;">
                        <button type="button" 
                                class="remove-row-btn" 
                                data-row-index="${index}"
                                style="background: none; border: none; color: #dc3545; cursor: pointer; font-size: 20px; padding: 4px 8px; line-height: 1;">
                            ×
                        </button>
                    </td>
                </tr>
            `;
        });

        html += `
                </tbody>
            </table>
        `;

        body.innerHTML = html;

        // Add event listeners for remove buttons
        body.querySelectorAll('.remove-row-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                const rowIndex = e.target.dataset.rowIndex;
                const row = body.querySelector(`tr[data-row-index="${rowIndex}"]`);
                if (row) {
                    // Check if this is the last row
                    const tbody = row.parentElement;
                    if (tbody.querySelectorAll('tr').length === 1) {
                        alert('Cannot remove the last row');
                        return;
                    }
                    row.remove();
                }
            });
        });

        if (this.modal) {
            this.modal.classList.add("active");
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
                const docDiv = document.createElement("div");
                docDiv.className = "saved-txt stored-overlay";
                docDiv.style.borderRadius = "6px 6px 0 0";
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
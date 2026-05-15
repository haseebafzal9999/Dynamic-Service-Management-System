class IframeManager extends BaseBuilder {
    constructor() {
        super();
        this.init();
    }
    init() {
        this.defineElements();
        this.attatchEventListeners();
        this.loadIframes();
    }
    defineElements() {
        this.addIFrameBtn = document.getElementById("addIFrame");
        this.viewIFramesBtn = document.getElementById("viewIFrames");
        this.modal = document.getElementById("iFramesModal");
        this.viewModal = document.getElementById("ViewiFramesModal");
        this.viewModalCloseBtn = this.viewModal.querySelector(".cancel-button");
        this.viewModalCrossBtn = this.viewModal.querySelector(".cross-button-svg");
        this.closeBtn = this.modal.querySelector(".cross-button-svg");
        this.cancelBtn = this.modal.querySelector(".cancel-button");
        this.createBtn = document.getElementById("iframe-modal-create-button");
        this.websiteNameInput = document.getElementById("iFramesWebsiteNameInput");
        this.templateDataDiv = document.getElementById("template-data");
        this.noInfo = document.getElementById("noInfo");
    }
    attatchEventListeners() {
        this.addIFrameBtn.addEventListener('click', (e) => {
            e.preventDefault();
            this.openModal();
        });
        this.closeBtn.addEventListener('click', (e) => {
            e.preventDefault();
            this.closeModal();
        });
        this.cancelBtn.addEventListener('click', (e) => {
            e.preventDefault();
            this.closeModal();
        });
        this.createBtn.addEventListener('click', (e) => {
            this.handleCreateClick();
        });
        this.viewModalCloseBtn.addEventListener('click', (e) => {
            e.preventDefault();
            this.closeViewModal();
        });
        this.viewIFramesBtn.addEventListener('click', (e) => {
            e.preventDefault();
            this.openViewModal();
        });
        this.viewModalCrossBtn.addEventListener('click', (e) => {
            e.preventDefault();
            this.closeViewModal();
        });
    }
    openModal() {
        this.updateInputFields();
        this.modal.classList.add("active");
        this.checkCreateBtnStatus();
    }
    closeModal() {
        this.updateInputFields();
        this.modal.classList.remove("active");
    }
    openViewModal() {
        this.viewModal.classList.add("active");
    }
    closeViewModal() {
        this.viewModal.classList.remove("active");
    }
    checkCreateBtnStatus() {
        if (!this.websiteNameInput || !this.createBtn) return;

        const toggleButtonState = () => {
            const isEmpty = this.websiteNameInput.value.trim() === "";

            if (isEmpty) {
                this.createBtn.classList.add("btn-disable");
                this.createBtn.disabled = true;
            } else {
                this.createBtn.classList.remove("btn-disable");
                this.createBtn.disabled = false;
            }
        };

        // Run once when modal opens
        toggleButtonState();

        // Re-check on every input
        this.websiteNameInput.addEventListener("input", toggleButtonState);
    }
    updateInputFields() {
        this.websiteNameInput.value = "";
    }
    handleCreateClick() {
        const payload = {
            websiteName: this.websiteNameInput?.value.trim(),
            businessId: 0,
            templateVersionId: parseInt(this.templateDataDiv.dataset.tempVersionId) 
        };

        fetch("/api/IFrame/generate", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(payload)
        })
            .then(res => {
                if (!res.ok) throw new Error("Request failed");
                return res.json();
            })
            .then(newIframe => {
                // newIframe contains: id, websiteName, link, createdAt, status
                this.addIframeRow(newIframe);
                this.closeModal();
                this.noInfo.style.display = "none";
            })
            .catch(err => {
                console.error("Error creating Iframe:", err);
            });
    }

    async loadIframes() {
        const tbody = document.querySelector("#table tbody");
        tbody.innerHTML = ""; // clear existing rows

        const tempVersionID = parseInt(this.templateDataDiv.dataset.tempVersionId);

        try {
            const res = await fetch(`/api/IFrame/GetAllIframes?tempVersionID=${tempVersionID}`, {
                method: "GET"
            });

            const data = await res.json();
            console.log("loadiframe data: ", data);

            if (data.length === 0) {
                document.getElementById("noInfo").style.display = "block";
                return;
            } else {
                document.getElementById("noInfo").style.display = "none";
            }

            data.forEach(item => {
                const tr = document.createElement("tr");
                tr.setAttribute("data-itemid", item.id);
                tr.setAttribute("data-itemlink", item.link);

                tr.innerHTML = `
                <td style="min-width:50px; max-width:100px">
                    <div data-name="name" data-editable="true">
                        ${item.websiteName}
                    </div>
                </td>

                <!-- FIXED WIDTH TD -->
                <td style="width:300px; max-width:300px;">
                   <div
                        class="link-ellipsis iframe-link"
                        data-name="link"
                        data-editable="false"
                        title="Click to copy"
                        data-link="${item.link}">
                        ${item.link}
                    </div>
                </td>

                <td>
                    ${new Date(item.createdAt).toLocaleDateString('en-US', {
                    month: 'short',
                    day: 'numeric',
                    year: 'numeric'
                })}
                </td>

                <td style="cursor: pointer;">
                    <div style="display: flex; justify-content: center; width:90px;" class="status-badge">
                        <p class="status-text">${item.status}</p>
                    </div>
                </td>

                <td style="text-align:center;">
                    <div style="display:flex; justify-content:center; align-items:center; gap:10px;">
                        <button class="iframe-action-delete" title="Delete"
                            style="background:#fff; border:1px solid #e74c3c; color:#e74c3c; border-radius:50%; width:28px; height:28px; display:flex; align-items:center; justify-content:center; transition:background 0.2s, color 0.2s;">
                            <i class="bi bi-trash" style="font-size:14px;"></i>
                        </button>
                        <button class="iframe-action-deactivate hidden" title="Deactivate"
                            style="background:#fff; border:1px solid #f1c40f; color:#f1c40f; border-radius:50%; width:28px; height:28px; display:flex; align-items:center; justify-content:center; transition:background 0.2s, color 0.2s;">
                            <i class="bi bi-pause-circle" style="font-size:14px;"></i>
                        </button>
                    </div>
                </td>

            `;

                tbody.appendChild(tr);

                
                const statusText = tr.querySelector('.status-text');
                const badge = tr.querySelector('.status-badge');
                if (statusText.textContent.trim().toLowerCase() === 'inactive') {
                    statusText.style.color = '#e74c3c';
                    badge.style.background = '#fdeaea';
                    badge.style.border = '1px solid #e74c3c';
                }

                //  delete action
                tr.querySelector('.iframe-action-delete').addEventListener('click', async (e) => {
                    const iframeId = tr.getAttribute('data-itemid');
                    if (confirm('Are you sure you want to delete this iframe?')) {
                        const res = await fetch(`/api/IFrame/delete/${iframeId}`, { method: 'DELETE' });
                        if (res.ok) {
                            tr.remove();
                        } else {
                            alert('Failed to delete iframe.');
                        }
                    }
                });

                // pointer cursor and copy-to-clipboard functionality
                tr.querySelectorAll('.iframe-link').forEach(linkDiv => {
                    // Set pointer cursor on hover
                    linkDiv.style.cursor = "pointer";

                    // Click to copy
                    linkDiv.addEventListener('click', function () {
                        const link = this.getAttribute('data-link');
                        if (link) {
                            navigator.clipboard.writeText(link);
                            const originalTitle = this.title;
                            this.title = "Copied!";
                            const originalBg = this.style.backgroundColor;
                            this.style.backgroundColor = "#e0ffe0";
                            setTimeout(() => {
                                this.title = originalTitle;
                                this.style.backgroundColor = originalBg;
                            }, 1000);
                        }
                    });
                });

                //  hover effect for action buttons
                tr.querySelectorAll('.iframe-action-delete, .iframe-action-deactivate').forEach(btn => {
                    btn.addEventListener('mouseenter', function () {
                        if (this.classList.contains('iframe-action-delete')) {
                            this.style.background = '#e74c3c';
                            this.style.color = '#fff';
                        } else {
                            this.style.background = '#f1c40f';
                            this.style.color = '#fff';
                        }
                    });
                    btn.addEventListener('mouseleave', function () {
                        if (this.classList.contains('iframe-action-delete')) {
                            this.style.background = '#fff';
                            this.style.color = '#e74c3c';
                        } else {
                            this.style.background = '#fff';
                            this.style.color = '#f1c40f';
                        }
                    });
                });

                //  deactivate action
                tr.querySelector('.iframe-action-deactivate').addEventListener('click', async function (e) {
                    if (this.disabled) return; // 'this' is the button
                    const iframeId = tr.getAttribute('data-itemid');
                    if (confirm('Are you sure you want to deactivate this iframe?')) {
                        const res = await fetch(`/api/IFrame/deactivate/${iframeId}`, { method: 'POST' });
                        if (res.ok) {
                            // Update status text and badge
                            const statusText = tr.querySelector('.status-text');
                            const badge = tr.querySelector('.status-badge');
                            statusText.textContent = 'Inactive';
                            statusText.style.color = '#e74c3c';
                            badge.style.background = '#fdeaea';
                            badge.style.border = '1px solid #e74c3c';

                            // Immediately disable the button
                            this.disabled = true;
                            this.style.opacity = "0.5";
                            this.style.cursor = "not-allowed";
                        } else {
                            alert('Failed to deactivate iframe.');
                        }
                    }
                });

                const deactivateBtn = tr.querySelector('.iframe-action-deactivate');
                if (statusText.textContent.trim().toLowerCase() === 'inactive') {
                    statusText.style.color = '#e74c3c';
                    badge.style.background = '#fdeaea';
                    badge.style.border = '1px solid #e74c3c';

                    // Disable the deactivate button
                    deactivateBtn.disabled = true;
                    deactivateBtn.style.opacity = "0.5";
                    deactivateBtn.style.cursor = "not-allowed";
                }

            });

        } catch (err) {
            console.error("Error loading iFrames:", err);
        }
    }


    addIframeRow(item) {
        const tbody = document.querySelector("#table tbody");

        const tr = document.createElement("tr");
        tr.setAttribute("data-itemid", item.id);
        tr.setAttribute("data-itemlink", item.link);

        tr.innerHTML = `
        <td style="min-width:50px; max-width:100px">
            <div data-name="name" data-editable="true">${item.websiteName}</div>
        </td>

        <td style="width:300px; max-width:300px;">
            <div
                class="link-ellipsis iframe-link"
                data-name="link"
                data-editable="false"
                title="Click to copy"
                data-link="${item.link}">
                ${item.link}
            </div>
        </td>

        <td>${new Date(item.createdAt).toLocaleDateString('en-US', {
            month: 'short',
            day: 'numeric',
            year: 'numeric'
        })}</td>

        <td style="cursor: pointer;">
            <div style="display: flex; justify-content: center; width:90px;" class="status-badge">
                <p class="status-text">${item.status}</p>
            </div>
        </td>

        <td style="text-align:center;">
            <div style="display:flex; justify-content:center; align-items:center; gap:10px;">
                <button class="iframe-action-delete" title="Delete"
                    style="background:#fff; border:1px solid #e74c3c; color:#e74c3c; border-radius:50%; width:28px; height:28px; display:flex; align-items:center; justify-content:center; transition:background 0.2s, color 0.2s;">
                    <i class="bi bi-trash" style="font-size:14px;"></i>
                </button>
                <button class="iframe-action-deactivate hidden" title="Deactivate"
                    style="background:#fff; border:1px solid #f1c40f; color:#f1c40f; border-radius:50%; width:28px; height:28px; display:flex; align-items:center; justify-content:center; transition:background 0.2s, color 0.2s;">
                    <i class="bi bi-pause-circle" style="font-size:14px;"></i>
                </button>
            </div>
        </td>
    `;

        tbody.prepend(tr);

        const statusText = tr.querySelector('.status-text');
        const badge = tr.querySelector('.status-badge');
        if (statusText.textContent.trim().toLowerCase() === 'inactive') {
            statusText.style.color = '#e74c3c';
            badge.style.background = '#fdeaea';
            badge.style.border = '1px solid #e74c3c';
        }

        //  delete action
        tr.querySelector('.iframe-action-delete').addEventListener('click', async (e) => {
            const iframeId = tr.getAttribute('data-itemid');
            if (confirm('Are you sure you want to delete this iframe?')) {
                const res = await fetch(`/api/IFrame/delete/${iframeId}`, { method: 'DELETE' });
                if (res.ok) {
                    tr.remove();
                } else {
                    alert('Failed to delete iframe.');
                }
            }
        });

        // pointer cursor and copy-to-clipboard functionality
        tr.querySelectorAll('.iframe-link').forEach(linkDiv => {
            // Set pointer cursor on hover
            linkDiv.style.cursor = "pointer";

            // Click to copy
            linkDiv.addEventListener('click', function () {
                const link = this.getAttribute('data-link');
                if (link) {
                    navigator.clipboard.writeText(link);
                    const originalTitle = this.title;
                    this.title = "Copied!";
                  
                    const originalBg = this.style.backgroundColor;
                    this.style.backgroundColor = "#e0ffe0";
                    setTimeout(() => {
                        this.title = originalTitle;
                        this.style.backgroundColor = originalBg;
                    }, 1000);
                }
            });


        });

        tr.querySelectorAll('.iframe-action-delete, .iframe-action-deactivate').forEach(btn => {
            btn.addEventListener('mouseenter', function () {
                if (this.classList.contains('iframe-action-delete')) {
                    this.style.background = '#e74c3c';
                    this.style.color = '#fff';
                } else {
                    this.style.background = '#f1c40f';
                    this.style.color = '#fff';
                }
            });
            btn.addEventListener('mouseleave', function () {
                if (this.classList.contains('iframe-action-delete')) {
                    this.style.background = '#fff';
                    this.style.color = '#e74c3c';
                } else {
                    this.style.background = '#fff';
                    this.style.color = '#f1c40f';
                }
            });
        });

        //  deactivate action
        tr.querySelector('.iframe-action-deactivate').addEventListener('click', async function (e) {
            if (this.disabled) return; // 'this' is the button
            const iframeId = tr.getAttribute('data-itemid');
            if (confirm('Are you sure you want to deactivate this iframe?')) {
                const res = await fetch(`/api/IFrame/deactivate/${iframeId}`, { method: 'POST' });
                if (res.ok) {
                    // Update status text and badge
                    const statusText = tr.querySelector('.status-text');
                    const badge = tr.querySelector('.status-badge');
                    statusText.textContent = 'Inactive';
                    statusText.style.color = '#e74c3c';
                    badge.style.background = '#fdeaea';
                    badge.style.border = '1px solid #e74c3c';

                    // Immediately disable the button
                    this.disabled = true;
                    this.style.opacity = "0.5";
                    this.style.cursor = "not-allowed";
                } else {
                    alert('Failed to deactivate iframe.');
                }
            }
        });

        const deactivateBtn = tr.querySelector('.iframe-action-deactivate');
        if (statusText.textContent.trim().toLowerCase() === 'inactive') {
            statusText.style.color = '#e74c3c';
            badge.style.background = '#fdeaea';
            badge.style.border = '1px solid #e74c3c';

            // Disable the deactivate button
            deactivateBtn.disabled = true;
            deactivateBtn.style.opacity = "0.5";
            deactivateBtn.style.cursor = "not-allowed";
        }

    }


}
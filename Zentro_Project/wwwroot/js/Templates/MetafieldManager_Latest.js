class MetafieldsManager extends BaseBuilder {
    constructor(addMetafieldsBtn, metaFieldsModal, formBuilder) {
        super();
        this.addMetafieldsBtn = addMetafieldsBtn;
        this.metaFieldsModal = metaFieldsModal;
        this.formBuilder = formBuilder;

        // Inputs
        this.nameInput = document.getElementById("metaFieldNameInput");
        this.tagInput = document.getElementById("metaFieldTagsInput");
        this.fieldTypeDropdown = document.getElementById("fieldTypeDropdown");
        this.visibilityDropdown = document.getElementById("visibilityDropdown");

        // Button
        this.createBtn = document.getElementById("metafield-modal-create-button");
        this.cancelBtn = this.metaFieldsModal?.querySelector(".cancel-button") ||
            this.metaFieldsModal?.querySelector(".popup-actions-wrapper button:first-child");
        this.deleteBtn = this.metaFieldsModal?.querySelector(".delete-button");
        this.metafieldHeading = document.getElementById("metafieldModalHeading");

        // Template Version
        this.templateDataDiv = document.getElementById("template-data");

        // Prevent multiple bindings
        this.createEventAttached = false;
        this.init();
    }

    init() {
        this.attachEventListeners();
    }

    attachEventListeners() {
        if (!this.addMetafieldsBtn || !this.metaFieldsModal) return;

        this.addMetafieldsBtn.addEventListener("click", () => this.openMetafieldsModal());
        const closeBtn = this.metaFieldsModal.querySelector(".cross-button-svg");
        this.attachCreateEventListener();

        if (closeBtn) {
            closeBtn.addEventListener("click", () => {
                this.closeMetafieldsModal();
            });
        }

        const cancelBtnInActions = this.metaFieldsModal.querySelector(".popup-actions-wrapper .cancel-button");
        if (cancelBtnInActions) {
            cancelBtnInActions.addEventListener("click", () => {
                this.closeMetafieldsModal();
            });
        }

        this.metaFieldsModal.addEventListener("click", (e) => {
            if (e.target === this.metaFieldsModal) {
                this.closeMetafieldsModal();
            }
        });
    }

    openMetafieldsModal() {
        this.updateInputFields();
        this.metaFieldsModal.classList.add("active");
        this.checkCreateBtnStatus();
    }

    closeMetafieldsModal() {
        if (this.deleteBtn) {
            this.deleteBtn.classList.add("hidden-btn");
        }
        if (this.metaFieldsModal) {
            this.metaFieldsModal.classList.remove("active");
        }
        this.updateInputFields();
    }

    updateInputFields() {
        if (this.nameInput) this.nameInput.value = "";
        if (this.tagInput) this.tagInput.value = "";

        if (this.createBtn) {
            this.createBtn.classList.add("btn-disable");
            this.createBtn.disabled = true;
            this.createBtn.textContent = "Create";
        }

        if (this.cancelBtn) {
            this.cancelBtn.classList.remove("delete-button");
            this.cancelBtn.textContent = 'Cancel';
        }

        if (this.metafieldHeading) {
            this.metafieldHeading.textContent = "Add a new metafield";
        }

        if (this.fieldTypeDropdown) {
            this.fieldTypeDropdown.value = "Single Line Text";
        }

        if (this.visibilityDropdown) {
            this.visibilityDropdown.value = "Admin only";
        }
    }

    checkCreateBtnStatus() {
        if (!this.nameInput || !this.createBtn) return;

        const toggleButtonState = () => {
            const isEmpty = this.nameInput.value.trim() === "";

            if (isEmpty) {
                this.createBtn.classList.add("btn-disable");
                this.createBtn.disabled = true;
            } else {
                this.createBtn.classList.remove("btn-disable");
                this.createBtn.disabled = false;
            }
        };

        toggleButtonState();
        this.nameInput.addEventListener("input", toggleButtonState);
    }

    checkUpdateBtnStatus() {
        if (!this.nameInput || !this.createBtn) return;

        const originalName = this.nameInput.value.trim();
        const originalFieldType = this.fieldTypeDropdown?.value;
        const originalTag = this.tagInput?.value;
        const originalVisibility = this.visibilityDropdown?.value;

        const toggleButtonState = () => {
            const currentName = this.nameInput.value.trim();
            const currentFieldType = this.fieldTypeDropdown?.value;
            const currentTag = this.tagInput?.value;
            const currentVisibility = this.visibilityDropdown?.value;

            const hasChanged =
                currentName !== originalName ||
                currentFieldType !== originalFieldType ||
                currentTag !== originalTag ||
                currentVisibility !== originalVisibility;

            if (hasChanged && currentName.trim() !== "") {
                this.createBtn.classList.remove("btn-disable");
                this.createBtn.disabled = false;
            } else {
                this.createBtn.classList.add("btn-disable");
                this.createBtn.disabled = true;
            }
        };

        toggleButtonState();

        this.nameInput.addEventListener("input", toggleButtonState);
        this.fieldTypeDropdown?.addEventListener("change", toggleButtonState);
        this.tagInput?.addEventListener("input", toggleButtonState);
        this.visibilityDropdown?.addEventListener("change", toggleButtonState);
    }

    attachCreateEventListener() {
        if (!this.createBtn || this.createEventAttached) return;

        this.createBtn.addEventListener("click", (e) => {
            if (this.createBtn.disabled) return;

            if (this.createBtn.textContent.trim() === "Create") {
                this.handleCreateClick();
            } else {
                this.handleUpdateClick();
            }
        });

        this.createEventAttached = true;
    }

    attachDeleteEventListener() {
        if (!this.deleteBtn) return;

        this.deleteBtn.onclick = () => {
            this.handleDeleteClick();
        };
    }

    getLatestVersionNumber() {
        const buttons = document.querySelectorAll('#versionList .version-btn, #versionsDropDownForm .version-btn');

        let maxVersion = 0;

        buttons.forEach(btn => {
            const text = btn.textContent.trim();
            const number = parseInt(text.replace(/\D/g, ''), 10);

            if (number > maxVersion) {
                maxVersion = number;
            }
        });

        return maxVersion;
    }

    // ✅ SIMPLIFIED: Just delegate to versionControl - all logic is centralized there now
    async triggerVersionChangeIfNeeded() {
        // Use centralized version control (handles Version 1 logic internally)
        if (window.versionControl && typeof window.versionControl.requestVersionIfNeeded === 'function') {
            console.log("[MetafieldsManager] Triggering version change via versionControl");
            const newVersionId = await window.versionControl.requestVersionIfNeeded();
            return newVersionId || parseInt(this.templateDataDiv?.dataset?.tempVersionId) || 0;
        }

        // Fallback to formBuilder if versionControl not available
        if (this.formBuilder && typeof this.formBuilder.handleVersionChange === 'function') {
            console.log("[MetafieldsManager] Triggering version change via formBuilder");
            return await this.formBuilder.handleVersionChange();
        }

        return parseInt(this.templateDataDiv?.dataset?.tempVersionId) || 0;
    }

    async handleCreateClick() {
        console.log("[MetafieldsManager] handleCreateClick FIRED", Date.now());

        // Trigger version change (versionControl handles all logic including V1 check)
        await this.triggerVersionChangeIfNeeded();

        // Get the CURRENT templateVersionId (may have changed after version update)
        const currentTemplateVersionId = parseInt(this.templateDataDiv?.dataset?.tempVersionId);

        const payload = {
            name: this.nameInput?.value.trim(),
            tag: this.tagInput?.value.trim() || "",
            fieldType: this.fieldTypeDropdown?.value,
            visibility: this.visibilityDropdown?.value,
            templateVersionId: currentTemplateVersionId,
            metafieldGuid: null
        };

        try {
            const response = await fetch("/api/Metafield/AddMetaField", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(payload)
            });

            if (!response.ok) throw new Error("Request failed");

            const result = await response.json();
            console.log("[MetafieldsManager] Created metafield with GUID:", result.metafieldGuid);

            this.closeMetafieldsModal();
            this.renderSavedMetafield({
                id: result.metafieldId,
                metafieldGuid: result.metafieldGuid,
                name: payload.name,
                fieldType: payload.fieldType,
                tag: payload.tag,
                visibility: payload.visibility
            });

            if (this.formBuilder) {
                this.formBuilder.determineAndSetTemplateNewStatus();
            }
        } catch (err) {
            console.error("[MetafieldsManager] Error creating metafield:", err);
        }
    }

    async handleUpdateClick() {
        const metafieldGuid = this.metaFieldsModal?.dataset?.editGuid;
        if (!metafieldGuid) {
            console.error("[MetafieldsManager] No metafield GUID found for update.");
            return;
        }

        // Trigger version change (versionControl handles all logic including V1 check)
        await this.triggerVersionChangeIfNeeded();

        const currentTemplateVersionId = parseInt(this.templateDataDiv?.dataset?.tempVersionId);

        const payload = {
            metafieldGuid: metafieldGuid,
            name: this.nameInput?.value.trim(),
            tag: this.tagInput?.value.trim() || "",
            fieldType: this.fieldTypeDropdown?.value,
            visibility: this.visibilityDropdown?.value,
            templateVersionId: currentTemplateVersionId
        };

        console.log("[MetafieldsManager] Update Metafield payload:", payload);

        try {
            const response = await fetch(`/api/Metafield/UpdateMetaField`, {
                method: "PUT",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(payload)
            });

            if (!response.ok) throw new Error("Request failed");

            const result = await response.json();
            this.closeMetafieldsModal();

            const savedDiv = document.querySelector(`.saved-txt[data-metafield-guid="${metafieldGuid}"]`);
            if (savedDiv) {
                savedDiv.dataset.id = result.metafieldId;
                savedDiv.dataset.name = payload.name;
                savedDiv.dataset.fieldType = payload.fieldType;
                savedDiv.dataset.tag = payload.tag;
                savedDiv.dataset.visibility = payload.visibility;
                const spanEl = savedDiv.querySelector("span");
                if (spanEl) spanEl.textContent = payload.name;
            }

            console.log("[MetafieldsManager] Metafield updated successfully");
        } catch (err) {
            console.error("[MetafieldsManager] Error updating metafield:", err);
        }
    }

    async handleDeleteClick() {
        const metafieldGuid = this.metaFieldsModal?.dataset?.editGuid;
        if (!metafieldGuid) {
            console.error("[MetafieldsManager] No metafield GUID found for delete.");
            return;
        }

        if (!confirm('Are you sure you want to delete this metafield?')) {
            return;
        }

        // Trigger version change (versionControl handles all logic including V1 check)
        await this.triggerVersionChangeIfNeeded();

        const templateVersionId = parseInt(this.templateDataDiv?.dataset?.tempVersionId);
        console.log("[MetafieldsManager] Deleting Metafield GUID:", metafieldGuid);

        try {
            const response = await fetch(`/api/Metafield/DeleteMetaField`, {
                method: "DELETE",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    metafieldGuid: metafieldGuid,
                    templateVersionId: templateVersionId
                })
            });

            if (!response.ok) throw new Error("Request failed");

            await response.json();
            this.closeMetafieldsModal();

            const container = document.getElementById("metaFieldsList");
            if (container) {
                this.updateRoundedCornersGeneric(container, 'group');
            }

            const savedDiv = document.querySelector(`.saved-txt[data-metafield-guid="${metafieldGuid}"]`);
            if (savedDiv) {
                savedDiv.remove();
            }

            if (container) {
                this.updateRoundedCornersGeneric(container, 'group');
            }

            if (this.formBuilder) {
                this.formBuilder.determineAndSetTemplateNewStatus();
            }
            console.log("[MetafieldsManager] Metafield deleted successfully");
        } catch (err) {
            console.error("[MetafieldsManager] Error deleting metafield:", err);
        }
    }

    renderSavedMetafield({ id, metafieldGuid, name, fieldType, tag, visibility }) {
        const container = document.getElementById("metaFieldsList");
        const addBtnWrapper = document.getElementById("addMetaFieldsWrapper");

        if (!container || !addBtnWrapper) return;

        addBtnWrapper.style.display = "none";

        const order = container.querySelectorAll(".saved-txt").length + 1;

        const savedDiv = document.createElement("div");
        savedDiv.className = "saved-txt stored-overlay";
        savedDiv.setAttribute("data-id", id || "");
        savedDiv.setAttribute("data-metafield-guid", metafieldGuid || "");
        savedDiv.setAttribute("data-order", order);
        savedDiv.setAttribute("data-name", name || "");
        savedDiv.setAttribute("data-field-type", fieldType || "");
        savedDiv.setAttribute("data-tag", tag || "");
        savedDiv.setAttribute("data-visibility", visibility || "");
        savedDiv.setAttribute("draggable", "true");

        if (order === 1) {
            savedDiv.style.borderRadius = "6px 6px 0px 0px";
        }

        savedDiv.innerHTML = `
            <div class="main-value">
                <svg class="saved-svg" viewBox="0 0 20 20">
                    <circle cx="5" cy="5" r="1.5"></circle>
                    <circle cx="5" cy="10" r="1.5"></circle>
                    <circle cx="5" cy="15" r="1.5"></circle>
                    <circle cx="10" cy="5" r="1.5"></circle>
                    <circle cx="10" cy="10" r="1.5"></circle>
                    <circle cx="10" cy="15" r="1.5"></circle>
                </svg>
                <span>${name}</span>
            </div>
        `;

        container.appendChild(savedDiv);

        const oldMetaFieldWrapper = document.getElementById("addMetaFieldsWrapper");
        if (oldMetaFieldWrapper) oldMetaFieldWrapper.remove();

        const addMetaFieldsWrapper = document.createElement("div");
        addMetaFieldsWrapper.className = "btn-add-wrapper overlay";
        addMetaFieldsWrapper.id = "addMetaFieldsWrapper";

        addMetaFieldsWrapper.innerHTML = `
            <button class="btn-add" type="button" id="addMetaFieldsBtn">
                <img src="/images/plus-circle-svg.svg">
                <span class="btn-add-text">Add another Metafield</span>
            </button>
        `;

        container.appendChild(addMetaFieldsWrapper);

        if (this.formBuilder) {
            this.formBuilder.determineAndSetTemplateNewStatus();
        }

        const newBtn = document.getElementById("addMetaFieldsBtn");
        if (newBtn) {
            newBtn.addEventListener("click", () => {
                this.openMetafieldsModal();
            });
        }

        this.updateRoundedCornersGeneric(container, 'group');
        this.attachMetafieldClickEvents();
    }

    attachMetafieldClickEvents() {
        const metafields = document.querySelectorAll("#metaFieldsList .saved-txt");

        metafields.forEach(metafield => {
            const newMetafield = metafield.cloneNode(true);
            metafield.parentNode.replaceChild(newMetafield, metafield);

            newMetafield.addEventListener("click", () => {
                if (this.deleteBtn) {
                    this.deleteBtn.classList.remove("hidden-btn");
                }
                this.openEditMetafieldModal(newMetafield);
            });
        });
    }

    openEditMetafieldModal(metafieldEl) {
        if (!metafieldEl) return;

        const id = metafieldEl.dataset.id;
        const metafieldGuid = metafieldEl.dataset.metafieldGuid;
        const name = metafieldEl.dataset.name;
        const fieldType = metafieldEl.dataset.fieldType;
        const tag = metafieldEl.dataset.tag;
        const visibility = metafieldEl.dataset.visibility;

        const nameInput = document.getElementById("metaFieldNameInput");
        const fieldTypeDropdown = document.getElementById("fieldTypeDropdown");
        const tagsInput = document.getElementById("metaFieldTagsInput");
        const visibilityDropdown = document.getElementById("visibilityDropdown");

        if (nameInput) nameInput.value = name || "";
        if (fieldTypeDropdown) fieldTypeDropdown.value = fieldType || "Single Line Text";
        if (tagsInput) tagsInput.value = tag || "";
        if (visibilityDropdown) visibilityDropdown.value = visibility || "Admin only";

        if (this.metaFieldsModal) {
            this.metaFieldsModal.setAttribute("data-edit-id", id || "");
            this.metaFieldsModal.setAttribute("data-edit-guid", metafieldGuid || "");
        }

        if (this.createBtn) {
            this.createBtn.textContent = "Update";
            this.createBtn.classList.add("btn-disable");
            this.createBtn.disabled = true;
        }

        if (this.metafieldHeading) {
            this.metafieldHeading.textContent = "Edit a metafield";
        }

        if (this.deleteBtn) {
            this.deleteBtn.classList.remove("hidden-btn");
        }

        if (this.metaFieldsModal) {
            this.metaFieldsModal.classList.add("active");
        }

        this.attachDeleteEventListener();
        this.checkUpdateBtnStatus();
    }

    loadMetafieldsFromDb() {
        const container = document.getElementById("metaFieldsList");
        if (!container) return;

        //  Clear container completely
        container.innerHTML = "";

        const tempVersionId = parseInt(this.templateDataDiv?.dataset?.tempVersionId);
        if (!tempVersionId) return;

        fetch(`/api/Metafield/GetByTemplateVersion/${tempVersionId}`)
            .then(res => {
                if (!res.ok) throw new Error("Failed to load metafields");
                return res.json();
            })
            .then(metafields => {
                if (!Array.isArray(metafields) || metafields.length === 0) {
                    // No metafields - show original add button
                    this.createAddMetafieldButton(container, false);
                    return;
                }

                metafields.forEach((meta, index) => {
                    this.renderSavedMetafieldSimple(container, {
                        id: meta.id,
                        metafieldGuid: meta.metafieldGuid,
                        name: meta.name,
                        fieldType: meta.fieldType,
                        tag: meta.tag,
                        visibility: meta.visibility
                    }, index);
                });

                // ✅ Add the "Add another Metafield" button at the end
                this.createAddMetafieldButton(container, true);

                // Update corners
                this.updateRoundedCornersGeneric(container, 'group');

                // Attach click events
                this.attachMetafieldClickEvents();

                if (this.formBuilder) {
                    this.formBuilder.determineAndSetTemplateNewStatus();
                }
            })
            .catch(err => {
                console.error("[MetafieldsManager] Error loading metafields:", err);
            });
    }

    createAddMetafieldButton(container, hasMetafields) {
        // Remove existing wrapper if any
        const existingWrapper = document.getElementById("addMetaFieldsWrapper");
        if (existingWrapper) existingWrapper.remove();

        const addMetaFieldsWrapper = document.createElement("div");
        addMetaFieldsWrapper.className = hasMetafields ? "btn-add-wrapper overlay" : "btn-add-wrapper";
        addMetaFieldsWrapper.id = "addMetaFieldsWrapper";

        addMetaFieldsWrapper.innerHTML = `
        <button class="btn-add" type="button" id="addMetaFieldsBtn">
            <img src="/images/plus-circle-svg.svg">
            <span class="btn-add-text">${hasMetafields ? 'Add another Metafield' : 'Add Metafield'}</span>
        </button>
    `;

        container.appendChild(addMetaFieldsWrapper);

        // Attach click event
        const newBtn = document.getElementById("addMetaFieldsBtn");
        if (newBtn) {
            newBtn.addEventListener("click", () => {
                this.openMetafieldsModal();
            });
        }

        // ✅ Update the class reference for future use
        this.addMetafieldsBtn = newBtn;
    }

    // ✅ ADD THIS NEW METHOD: Simplified render for loading from DB
    renderSavedMetafieldSimple(container, { id, metafieldGuid, name, fieldType, tag, visibility }, index) {
        const order = index + 1;

        const savedDiv = document.createElement("div");
        savedDiv.className = "saved-txt stored-overlay";
        savedDiv.setAttribute("data-id", id || "");
        savedDiv.setAttribute("data-metafield-guid", metafieldGuid || "");
        savedDiv.setAttribute("data-order", order);
        savedDiv.setAttribute("data-name", name || "");
        savedDiv.setAttribute("data-field-type", fieldType || "");
        savedDiv.setAttribute("data-tag", tag || "");
        savedDiv.setAttribute("data-visibility", visibility || "");
        savedDiv.setAttribute("draggable", "true");

        if (order === 1) {
            savedDiv.style.borderRadius = "6px 6px 0px 0px";
        } else {
            savedDiv.style.borderRadius = "0";
            savedDiv.style.borderTop = "none";
        }

        savedDiv.innerHTML = `
        <div class="main-value">
            <svg class="saved-svg" viewBox="0 0 20 20">
                <circle cx="5" cy="5" r="1.5"></circle>
                <circle cx="5" cy="10" r="1.5"></circle>
                <circle cx="5" cy="15" r="1.5"></circle>
                <circle cx="10" cy="5" r="1.5"></circle>
                <circle cx="10" cy="10" r="1.5"></circle>
                <circle cx="10" cy="15" r="1.5"></circle>
            </svg>
            <span>${name}</span>
        </div>
    `;

        container.appendChild(savedDiv);
    }

    exportData() {
        const templateData = document.getElementById('template-data');

        const template = {
            templateVersionId: templateData?.dataset.tempVersionId || 0,
            name: document.getElementById('templateName')?.value || '',
            description: document.getElementById('templateDes')?.value || ''
        };

        const templateVersion = {
            tempVersion: this.getLatestVersionNumber()
        };

        const isNewTemplate = templateData?.dataset.isNewTemplate === 'true';

        const groups = Array.from(document.querySelectorAll('#groupsList .saved-txt')).map(g => ({
            id: parseInt(g.dataset.id || '0', 10),
            order: parseInt(g.dataset.order || '1', 10),
            name: g.querySelector('span')?.textContent || ''
        }));

        const questions = Array.from(document.querySelectorAll('#questionsList .saved-txt:not(.sub-value)')).map(q => {
            const answers = Array.from(q.querySelectorAll('.sub-value')).map((a, idx) => ({
                id: parseInt(a.dataset.id || '0', 10),
                order: parseInt(a.dataset.order || idx + 1, 10),
                option: a.querySelector('span')?.textContent || '',
                selectedOption: a.dataset.mainSelect || '',
                SelectedMatComId: a.dataset.dynamicSelect || 0,
                SelectedQuestionsList: (a.dataset.answerSelect ? a.dataset.answerSelect.split(',') : [])
            }));

            return {
                id: parseInt(q.dataset.id || '0', 10),
                order: parseInt(q.dataset.order || '1', 10),
                questionText: q.querySelector('.main-value span')?.textContent || '',
                questionGroup: q.dataset.group || '',
                fieldTypeId: q.dataset.fieldType || '',
                IsRequired: q.dataset.isRequired === 'true',
                answers: answers
            };
        });

        const metaFields = Array.from(document.querySelectorAll('#metaFieldsList .saved-txt')).map(m => ({
            id: parseInt(m.dataset.id || '0', 10),
            metafieldGuid: m.dataset.metafieldGuid || null,
            order: parseInt(m.dataset.order || '1', 10),
            name: m.querySelector('span')?.textContent || '',
            fieldType: m.dataset.fieldType || '',
            visibility: m.dataset.visibility || '',
            defaultValue: m.dataset.defaultValue || '',
            tag: m.dataset.tag || ''
        }));

        return {
            questionGroups: groups,
            questionAnswers: questions,
            metaFields: metaFields,
            templateVersion,
            template,
            isNewTemplate
        };
    }
}
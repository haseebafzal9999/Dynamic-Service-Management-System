// ================== BaseBuilder Class ==================
class BaseBuilder {
    constructor() {
        this.versionCall = 0;
        this.selectedValues = new Set();
        this.dropdownMemory = {};
    }

    // ================== Common Helper Methods ==================

    normalize(value) {
        if (!value || value === '[]' || value === 'Select') return '';
        return value.toString().trim();
    }

    getEventListenerCount(element, eventType) {
        let count = 0;
        const listeners = (element._events && element._events[eventType]) ||
            (element.$events && element.$events[eventType]);

        if (listeners) {
            if (Array.isArray(listeners)) {
                count = listeners.length;
            } else if (listeners.handlers) {
                count = listeners.handlers.length;
            }
        }

        if (window.jQuery && $(element).data('events')) {
            const jQueryEvents = $(element).data('events')[eventType];
            if (jQueryEvents) {
                count += jQueryEvents.length || 0;
            }
        }

        return count;
    }

    getSelectedValues(dropdown) {
        const hiddenInput = dropdown.querySelector('input.vscomp-hidden-input');
        return hiddenInput && hiddenInput.value ? hiddenInput.value.split(',') : [];
    }

    saveDropdownSelections(modalElement) {
        const modalId = modalElement.id || 'global';
        const dropdowns = modalElement.querySelectorAll('.multi-selectt-icon');

        this.dropdownMemory[modalId] = Array.from(dropdowns).map(dropdown => ({
            id: dropdown.dataset.id || dropdown.id,
            values: this.getSelectedValues(dropdown)
        }));
    }

    restoreDropdownSelections(modalElement) {
        const modalId = modalElement.id || 'global';
        const savedData = this.dropdownMemory[modalId];
        if (!savedData) return;

        savedData.forEach(({ id, values }) => {
            const dropdown = modalElement.querySelector(`[data-id="${id}"], #${id}`);
            if (!dropdown) return;

            const hiddenInput = dropdown.querySelector('input.vscomp-hidden-input');
            if (hiddenInput) hiddenInput.value = values.join(',');

            const options = dropdown.querySelectorAll('.vscomp-option');
            options.forEach(opt => {
                const val = opt.dataset.value;
                const selected = values.includes(val);
                opt.classList.toggle('selected', selected);
                opt.setAttribute('aria-selected', selected);
            });
        });
    }

    closeAllDropdowns() {
        document.querySelectorAll('.custom-dropdown-menu.dropdown-active').forEach(menu => {
            menu.classList.remove('dropdown-active');
            menu.previousElementSibling.classList.remove('dropdown-active');
        });
    }

    updateOrders(container, selector = '.saved-txt', attribute = 'order') {
        const items = container.querySelectorAll(selector);
        items.forEach((item, index) => item.dataset[attribute] = index + 1);
    }

    makeScrollable(container, maxChildren = 0, btnWrapperId = 'addbtnmodal1') {
        if (!container) return;

        const btnWrapper = document.getElementById(btnWrapperId);
        if (!btnWrapper) return;

        let scrollWrapper = container.parentElement;
        const isWrapped = scrollWrapper && scrollWrapper.classList.contains('scrollable-wrapper');

        if (container.children.length > maxChildren) {
            if (!isWrapped) {
                scrollWrapper = document.createElement('div');
                scrollWrapper.classList.add('scrollable-wrapper');

                container.parentNode.insertBefore(scrollWrapper, container);
                scrollWrapper.appendChild(container);
                scrollWrapper.appendChild(btnWrapper);
            }

            scrollWrapper.classList.add('scrollable');
        } else {
            if (isWrapped) {
                scrollWrapper.parentNode.insertBefore(container, scrollWrapper);
                scrollWrapper.parentNode.insertBefore(btnWrapper, scrollWrapper);
                scrollWrapper.remove();
            }
        }
    }

    updateRoundedCornersGeneric(container, mode = 'simple') {
        if (!container) return;

        let items;
        if (mode === 'group') {
            items = Array.from(container.querySelectorAll('.section-sub-box, .saved-txt'));
        } else if (mode === 'question-group') {
            const groupName = container.dataset.groupName;
            items = Array.from(container.querySelectorAll(`.saved-txt:not(.sub-value)[data-group="${groupName}"]`));
        } else {
            items = Array.from(container.children);
        }

        items.forEach((div, index) => {
            if (index === 0) {
                div.style.borderRadius = '6px 6px 0 0';
                div.style.borderTop = '';
            } else {
                div.style.borderRadius = '0';
                div.style.borderTop = 'none';
            }
        });

        if (items.length === 1) {
            items[0].style.borderRadius = '6px 6px 0 0';
            items[0].style.borderTop = '';
        }
    }
}

// ================== GroupManager Class ==================
class GroupManager extends BaseBuilder {
    constructor(container, groupSelect, questionsList) {
        super();
        this.container = container;
        this.groupSelect = groupSelect;
        this.questionsList = questionsList;
    }

    // ================== Public Methods ==================

    addNewGroup() {
        const subBox = this.createGroupInputBox();
        const btnWrapper = this.container.querySelector('.btn-add-wrapper');
        this.container.insertBefore(subBox, btnWrapper);

        this.updateWrapperStyles();
        this.updateRoundedCorners();

        this.attachInputBoxEvents(subBox);
    }

    filterGroupDropdown(selectedGroupName) {
        if (!this.groupSelect) return;

        if (!this.groupSelect.originalOptions) {
            this.groupSelect.originalOptions = Array.from(this.groupSelect.options);
        }

        this.groupSelect.innerHTML = '';
        const selectedOption = this.createOption(selectedGroupName, true);
        this.groupSelect.appendChild(selectedOption);
    }

    async testWithHardcodedId(groupName = "Test Group") {
        const testTemplateVersionId = 1;
        const savedWrapper = this.createSavedWrapper(groupName);
        this.renderSavedGroup(savedWrapper, groupName, true);

        const btnWrapper = this.container.querySelector('.btn-add-wrapper');
        this.container.insertBefore(savedWrapper, btnWrapper);

        try {
            const groupData = {
                Id: 0,
                Name: groupName,
                Order: parseInt(savedWrapper.dataset.order),
                TemplateVersionId: testTemplateVersionId
            };

            const response = await fetch('/api/Template/CreateGroup', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(groupData)
            });
            console.log('Metafield called :');

            const result = await response.json();

            if (response.ok && result.success) {
                savedWrapper.dataset.id = result.groupId;
                this.renderSavedGroup(savedWrapper, groupName, false);
                this.addGroupOption(groupName);
                if (this.makeDraggable) this.makeDraggable(savedWrapper, this.container);
                this.updateWrapperStyles();
                this.updateRoundedCorners();
                this.updateGroupOrders();
                this.createQuestionGroupStructure(groupName);
                this.updateGroupAddButtonOverlay(groupName);
            } else {
                console.error('Test failed:', result);
            }
        } catch (error) {
            console.error('Test error:', error);
            savedWrapper.remove();
        }
    }

    // ================== Group Creation / Deletion ==================

    async handleCreateGroup(subBox, input) {
        const value = input.value.trim();
        if (!value) return;

        if (this.handleVersionChange) {
            await this.handleVersionChange();
        }
        else {
            console.log("blahblah blah");
        }
        if (!this.isTemplateSaved()) {
            if (confirm('You need to save the template before creating groups. Save now?')) {
                document.querySelector('.save-btn')?.click();
            }
            return;
        }

        await this.createSavedGroup(value);
        subBox.remove();
        this.updateRoundedCorners();
    }

    handleDeleteGroup(subBox) {
        subBox.remove();
        this.updateWrapperStyles();
        this.updateRoundedCorners();
    }

    // ================== Input Box Event Handling ==================

    attachInputBoxEvents(subBox) {
        const input = subBox.querySelector('.section-input');
        const deleteBtn = subBox.querySelector('.delete-button');
        const doneBtn = subBox.querySelector('.done-button');

        deleteBtn.style.display = 'none';
        deleteBtn.addEventListener('click', () => this.handleDeleteGroup(subBox));
        doneBtn.addEventListener('click', () => this.handleCreateGroup(subBox, input));
    }

    // ================== Template / API Helpers ==================

    isTemplateSaved() {
        const templateData = document.getElementById('template-data');
        if (!templateData) return false;

        const templateVersionId = templateData.dataset.tempVersionId ||
            templateData.dataset.templateVersionId ||
            0;

        return templateVersionId && templateVersionId !== "0" && templateVersionId !== 0;
    }

    async createSavedGroup(value) {
        const savedWrapper = this.createSavedWrapper(value);
        this.renderSavedGroup(savedWrapper, value, true);

        const btnWrapper = this.container.querySelector('.btn-add-wrapper');
        this.container.insertBefore(savedWrapper, btnWrapper);

        try {
            const templateVersionId = await this.getTemplateVersionId();
            if (!templateVersionId) throw new Error('Template is not saved yet.');

            const groupData = {
                Id: 0,
                Name: value,
                Order: parseInt(savedWrapper.dataset.order),
                TemplateVersionId: templateVersionId,
                GroupGuid: savedWrapper.dataset.groupGuid || '' // ADD THIS
            };

            const response = await fetch('/api/Template/CreateGroup', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(groupData)
            });

            const result = await this.parseResponse(response);
            this.formBuilder?.determineAndSetTemplateNewStatus();

            // Store both ID and GUID
            savedWrapper.dataset.id = result.groupId;
            savedWrapper.dataset.groupGuid = result.groupGuid; // ADD THIS
            if (result.displayOrder !== undefined) savedWrapper.dataset.order = result.displayOrder;

            this.renderSavedGroup(savedWrapper, value, false);
            this.addGroupOption(value);
            if (this.makeDraggable) this.makeDraggable(savedWrapper, this.container);

            this.updateWrapperStyles();
            this.updateRoundedCorners();
            this.updateGroupOrders();
            this.createQuestionGroupStructure(value);
            this.updateGroupAddButtonOverlay(value);

        } catch (error) {
            console.error('Failed to save group:', error);
            savedWrapper.remove();
            this.updateWrapperStyles();
            this.updateRoundedCorners();
        }
    }

    async getTemplateVersionId() {
        const templateData = document.getElementById('template-data');
        if (!templateData) return 0;

        let templateVersionId = parseInt(
            templateData.dataset.tempVersionId ||
            templateData.dataset.templateVersionId ||
            templateData.dataset.versionId ||
            0
        );

        if (!templateVersionId || templateVersionId <= 0) {
            const hiddenField = document.querySelector('input[name="TemplateVersionId"], input[name="templateVersionId"]');
            if (hiddenField) templateVersionId = parseInt(hiddenField.value);
        }

        return templateVersionId > 0 ? templateVersionId : 0;
    }

    async parseResponse(response) {
        const text = await response.text();
        try {
            return JSON.parse(text);
        } catch {
            throw new Error('Server returned invalid JSON response');
        }
    }

    // ================== Rendering Methods ==================

    createGroupInputBox() {
        const subBox = document.createElement('section');
        subBox.className = 'section-sub-box';

        subBox.innerHTML = `
            <h2 class="section-subheading">Group Name</h2>
            <div class="section-input-wrapper">
                <input type="text" class="section-input">
            </div>
            <div class="subsection-actions">
                <button type="button" class="delete-button">Delete</button>
                <button type="button" class="done-button create-button" style="margin-left:auto;">Create</button>
            </div>
        `;

        const existingModals = this.container.querySelectorAll('.section-sub-box');
        if (existingModals.length > 0) subBox.classList.add('no-radius');

        return subBox;
    }

    createSavedWrapper(value) {
        const wrapper = document.createElement('div');
        wrapper.className = 'saved-txt stored-overlay';
        wrapper.dataset.order = this.container.querySelectorAll('.saved-txt').length + 1;
        return wrapper;
    }

    renderSavedGroup(wrapper, value, isLoading = false) {
        wrapper.classList.add('saved-txt', 'stored-overlay');
        if (isLoading) {
            wrapper.innerHTML = `
                <div class="main-value">
                    <svg class="saved-svg" viewBox="0 0 20 20">
                        <circle cx="5" cy="5" r="1.5"></circle>
                        <circle cx="5" cy="10" r="1.5"></circle>
                        <circle cx="5" cy="15" r="1.5"></circle>
                        <circle cx="10" cy="5" r="1.5"></circle>
                        <circle cx="10" cy="10" r="1.5"></circle>
                        <circle cx="10" cy="15" r="1.5"></circle>
                    </svg>
                    <span>Saving "${value}"...</span>
                </div>
            `;
            return;
        }

        wrapper.innerHTML = `
            <div class="main-value">
                <svg class="saved-svg" viewBox="0 0 20 20">
                    <circle cx="5" cy="5" r="1.5"></circle>
                    <circle cx="5" cy="10" r="1.5"></circle>
                    <circle cx="5" cy="15" r="1.5"></circle>
                    <circle cx="10" cy="5" r="1.5"></circle>
                    <circle cx="10" cy="10" r="1.5"></circle>
                    <circle cx="10" cy="15" r="1.5"></circle>
                </svg>
                <span>${value}</span>
            </div>
        `;
        console.log(`Setting click handler for group: ${value}`);
        this.container.addEventListener('click', (e) => {
            const wrapper = e.target.closest('.saved-txt');
            if (!wrapper) return;
            e.stopPropagation();
            const groupName = wrapper.querySelector('span')?.textContent;
            console.log('Clicked group:', groupName);
            this.renderEditGroup(wrapper, groupName);
        });
    }

    // ================== Edit / Update / Delete ==================

    async renderEditGroup(wrapper, oldValue) {
        wrapper.classList.remove('saved-txt', 'stored-overlay');
        wrapper.classList.add('section-sub-box');

        wrapper.innerHTML = `
        <h2 class="section-subheading">Group Name</h2>
        <div class="section-input-wrapper">
            <input type="text" class="section-input" value="${oldValue}">
        </div>
        <div class="subsection-actions">
            <button type="button" class="delete-button">Delete</button>
            <button type="button" class="done-button">Update</button>
        </div>
    `;

        const input = wrapper.querySelector('.section-input');
        const deleteBtn = wrapper.querySelector('.delete-button');
        const doneBtn = wrapper.querySelector('.done-button');
        const groupId = wrapper.dataset.id;

        input.focus();
        input.setSelectionRange(input.value.length, input.value.length);

        // disable delete if group contains questions
        deleteBtn.disabled = this.groupHasQuestions(oldValue);

        deleteBtn.onclick = () => {
            if (!deleteBtn.disabled) {
                this.deleteGroup(wrapper, oldValue, groupId);
            }
        };

        doneBtn.onclick = () => this.updateGroup(wrapper, oldValue, input.value.trim(), groupId);

    }
    groupHasQuestions(groupName) {
        const questions = Array.from(this.questionsList.querySelectorAll('.saved-txt:not(.sub-value)'));
        return questions.some(q => q.dataset.group === groupName);
    }
    async deleteGroup(wrapper, groupName) {
        if (this.handleVersionChange) {
            await this.handleVersionChange();
        }

        const groupGuid = wrapper.dataset.groupGuid;
        const templateVersionId = await this.getTemplateVersionId();

        if (!groupGuid || !templateVersionId) {
            alert('Unable to delete group: missing version info.');
            return;
        }

        // Confirm first; if canceled, exit early without touching UI
        const ok = window.confirm('Are you sure you want to delete this group?');
        if (!ok) {
            return;
        }

        // Call API and only proceed on success
            try {
                const response = await fetch(
                    `/api/Template/DeleteGroup?groupGuid=${groupGuid}&templateVersionId=${templateVersionId}`,
                    { method: 'DELETE' }
                );

                const result = await response.json();
                if (!response.ok || !result.success) {
                    throw new Error('Delete failed');
                }
            // Keep template new-status in sync
            this.formBuilder?.determineAndSetTemplateNewStatus();

            // UI cleanup ONLY after successful delete
            this.removeGroupOption(groupName);
            wrapper.remove();
            this.updateGroupOrders();
            this.updateWrapperStyles();
            this.updateRoundedCorners();
            this.removeQuestionGroupStructure(groupName);
            this.updateGroupAddButtonOverlay(groupName);
        } catch (error) {
            console.error('Error deleting group:', error);
            alert('Error deleting group. Please try again.');
        }
    }


    async updateGroup(wrapper, oldValue, newValue, groupId) {
        if (!newValue) return;
        let templateVersionId;

        if (this.handleVersionChange) {
            templateVersionId = await this.handleVersionChange(); // ⭐ USE RETURN
        }
        if (!templateVersionId) {
            const templateData = document.getElementById('template-data');
            templateVersionId = parseInt(templateData?.dataset.tempVersionId || 0);
        }
        if (newValue === oldValue) {
            this.renderSavedGroup(wrapper, newValue);
            return;
        }

        try {
            if (groupId) {
                const templateData = document.getElementById('template-data');
                const templateVersionId = parseInt(templateData?.dataset.tempVersionId || 0);
                const groupGuid = wrapper.dataset.groupGuid; // GET GUID

                const updateData = {
                    Id: parseInt(groupId),
                    Name: newValue,
                    Order: parseInt(wrapper.dataset.order || 1),
                    TemplateVersionId: templateVersionId,
                    GroupGuid: groupGuid // ADD THIS
                };

                const response = await fetch('/api/Template/CreateGroup', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(updateData)
                });

                const result = await response.json();
                if (!response.ok || !result.success) throw new Error('Failed to update group.');

                // Update GUID if returned
                if (result.groupGuid) {
                    wrapper.dataset.groupGuid = result.groupGuid;
                }
            }

            this.removeGroupOption(oldValue);
            this.addGroupOption(newValue);
            this.updateQuestionGroupName(oldValue, newValue);

            this.renderSavedGroup(wrapper, newValue);
            if (this.makeDraggable) this.makeDraggable(wrapper, this.container);
            this.updateRoundedCorners();

        } catch (error) {
            console.error('Error updating group:', error);
            alert('Failed to update group. Please try again.');
        }
    }

    // ================== Option / Wrapper / Order Helpers ==================

    createOption(value, selected = false) {
        const opt = document.createElement('option');
        opt.value = value;
        opt.textContent = value;
        opt.selected = selected;
        return opt;
    }

    addGroupOption(value) {
        this.groupSelect.appendChild(this.createOption(value, true));
        this.updateRoundedCorners();
    }

    removeGroupOption(value) {
        const option = Array.from(this.groupSelect.options).find(o => o.value === value);
        if (option) option.remove();
    }

    updateWrapperStyles() {
        const subBoxes = this.container?.querySelectorAll('.section-sub-box, .saved-txt');
        const btnWrapper = this.container?.querySelector('.btn-add-wrapper');
        if (btnWrapper && subBoxes) btnWrapper.classList.toggle('overlay', subBoxes.length > 0);
    }

    updateRoundedCorners() {
        this.updateRoundedCornersGeneric(this.container, 'group');
    }

    updateGroupOrders() {
        this.updateOrders(this.container, '.saved-txt', 'order');
    }

    // ================== Question Group Structure ==================

    createGroupHeader(groupName) {
        const header = document.createElement('div');
        header.className = 'question-group-header';
        header.dataset.groupName = groupName;
        header.innerHTML = `<h2 class="section-subheading group-subheading">${groupName}</h2>`;
        return header;
    }

    createGroupAddButton(groupName) {
        const wrapper = document.createElement('div');
        wrapper.className = 'btn-add-wrapper group-add-button';
        wrapper.dataset.groupName = groupName;
        wrapper.id = 'addbtnmodal';
        wrapper.innerHTML = `
            <button class="btn-add btn-add-question" type="button" data-group-name="${groupName}">
                <img src="/images/plus-circle-svg.svg" />
                <span class="btn-add-text">Add question</span>
            </button>
        `;
        return wrapper;
    }

    createQuestionGroupStructure(groupName) {
        if (!this.questionsList) return;
        if (this.questionsList.querySelector(`[data-group-name="${groupName}"]`)) return;

        this.questionsList.appendChild(this.createGroupHeader(groupName));
        this.questionsList.appendChild(this.createGroupAddButton(groupName));
    }

    removeQuestionGroupStructure(groupName) {
        if (!this.questionsList) return;

        const header = this.questionsList.querySelector(`[data-group-name="${groupName}"]`);
        const addButton = this.questionsList.querySelector(`.group-add-button[data-group-name="${groupName}"]`);

        header?.remove();
        addButton?.remove();
    }

    updateGroupAddButtonOverlay(groupName) {
        if (!this.questionsList) return;

        const groupAddButton = this.questionsList.querySelector(`.group-add-button[data-group-name="${groupName}"]`);
        if (!groupAddButton) return;

        const questionsInGroup = Array.from(this.questionsList.querySelectorAll('.saved-txt:not(.sub-value)'))
            .filter(q => q.dataset.group === groupName);

        groupAddButton.classList.toggle('overlay', questionsInGroup.length > 0);
    }

    updateQuestionGroupName(oldName, newName) {
        if (!this.questionsList) return;

        const groupHeader = this.questionsList.querySelector(`[data-group-name="${oldName}"]`);
        const groupAddButton = this.questionsList.querySelector(`.group-add-button[data-group-name="${oldName}"]`);

        if (groupHeader) {
            groupHeader.dataset.groupName = newName;
            groupHeader.querySelector('.group-subheading').textContent = newName;
        }

        if (groupAddButton) groupAddButton.dataset.groupName = newName;
        const questionElements = this.questionsList.querySelectorAll(`.saved-txt:not(.sub-value)[data-group="${oldName}"]`);
        questionElements.forEach(q => {
            q.dataset.group = newName;
        });
    }
}


// ================== QuestionManager Class ==================
class QuestionManager extends BaseBuilder {
    constructor(questionsList, answersContainer, groupSelect, fieldTypeSelect, modalOverlay) {
        super();
        this.questionsList = questionsList;
        this.answersContainer = answersContainer;
        this.groupSelect = groupSelect;
        this.fieldTypeSelect = fieldTypeSelect;
        this.modalOverlay = modalOverlay;
        this.editingDiv2 = null;
    }
    updateGroupAddButtonOverlay(groupName) {
        if (!this.questionsList) return;

        const addBtn = document.querySelector(`.group-add-button[data-group-name="${groupName}"]`);
        if (!addBtn) return;

        const questions = this.questionsList.querySelectorAll(
            `.saved-txt:not(.sub-value)[data-group="${groupName}"]`
        );

        if (questions.length === 0) {
            addBtn.classList.remove('overlay');
        } else {
            addBtn.classList.add('overlay');
        }
    }

    openQuestionModalForGroup(buttonWrapper) {
        const groupName = buttonWrapper.dataset.groupName;

        this.filterGroupDropdown(groupName);

        if (this.groupSelect && groupName) {
            if (![...this.groupSelect.options].some(opt => opt.value === groupName)) {
                const option = document.createElement('option');
                option.value = groupName;
                option.textContent = groupName;
                this.groupSelect.appendChild(option);
            }
            this.groupSelect.value = groupName;
            this.groupSelect.disabled = true;
        }

        this.inputField2.value = '';

        if (this.answersContainer) this.answersContainer.innerHTML = '';

        const modalHeading = this.modalOverlay.querySelector('.t1-pop-up-heading .bold-text');
        if (modalHeading) {
            modalHeading.textContent = "Add a new question";
        }

        const cancelButton = this.modalOverlay.querySelector('.cancel-button');
        const deleteButton = this.modalOverlay.querySelector('.delete-button');

        cancelButton.classList.remove('hidden');
        deleteButton.classList.add('hidden');

        // ✅ Set Create/Update button text
        const createBtn = this.modalOverlay.querySelector('.create-button');
        if (createBtn) createBtn.textContent = 'Create';

        document.getElementById('addbtnmodal1').classList.remove('overlay');
        this.modalOverlay.classList.add('active');
        this.isRequiredCheckbox.checked = false;

        this.editingDiv2 = null;
        if (this.answerManager && this.answerManager.cleanupDeletedAnswers) {
            this.answerManager.cleanupDeletedAnswers();
        }

        if (this.resetCreateButtonState) this.resetCreateButtonState();
        if (this.toggleQuestionValidation) this.toggleQuestionValidation();
    }

    // Replace the existing saveAnswersToQuestionElement method with this implementation
    // Replace the existing saveAnswersToQuestionElement method with this implementation
    saveAnswersToQuestionElement(questionElement, answersSource) {
        console.log('Question ID:', questionElement.dataset.id);
        console.log('Question GUID:', questionElement.dataset.questionGuid);

        const existingSubValues = questionElement.querySelectorAll('.sub-value');
        console.log('Existing sub-values count:', existingSubValues.length);

        // Remove existing sub-values first to prevent duplication
        existingSubValues.forEach(el => el.remove());

        let answerNodes = Array.isArray(answersSource) ? answersSource : Array.from(answersSource.children || []);

        // Only materialize answers that are NOT marked for deletion
        answerNodes = answerNodes.filter(a => a.dataset.isDeleted !== 'true');

        // ✅ FIX: Get QuestionGuid from the question element
        const questionGuid = (
            questionElement.dataset.questionGuid ||
            questionElement.getAttribute('data-question-guid') ||
            ''
        ).toString().trim();

        answerNodes.forEach((answerDiv, index) => {
            console.log(`Processing answer ${index + 1}:`);
            console.log('  - Text:', answerDiv.querySelector('span')?.textContent);
            console.log('  - dataset.id:', answerDiv.dataset.id);
            console.log('  - dataset.optionGuid:', answerDiv.dataset.optionGuid);

            const subWrapper = document.createElement('div');
            subWrapper.className = 'saved-txt stored-overlay sub-value';

            // Use database ID when available
            const dbId = answerDiv.dataset.id;
            const originalId = answerDiv.dataset.originalId;

            if (dbId && parseInt(dbId) > 0) {
                subWrapper.dataset.id = dbId;
                subWrapper.dataset.originalId = dbId;
            } else if (originalId && parseInt(originalId) > 0) {
                subWrapper.dataset.id = originalId;
                subWrapper.dataset.originalId = originalId;
            } else {
                subWrapper.dataset.id = answerDiv.dataset.tempId || '';
            }

            // ✅ FIX: Propagate OptionGuid - check all possible sources
            const optionGuid = (
                answerDiv.dataset.optionGuid ||
                answerDiv.dataset.OptionGuid ||
                answerDiv.dataset.answerGuid ||
                answerDiv.getAttribute('data-option-guid') ||
                ''
            ).toString().trim();

            if (optionGuid) {
                subWrapper.dataset.optionGuid = optionGuid;
                subWrapper.dataset.answerGuid = optionGuid;
            }

            // ✅ FIX: Propagate QuestionGuid
            subWrapper.dataset.questionGuid = questionGuid;

            subWrapper.dataset.mainSelect = answerDiv.dataset.mainSelect || '';

            // Copy ALL data attributes
            Object.keys(answerDiv.dataset).forEach(key => {
                if (answerDiv.dataset[key] !== undefined && answerDiv.dataset[key] !== '') {
                    // Don't overwrite questionGuid we just set
                    if (key === 'questionGuid' && subWrapper.dataset.questionGuid) return;
                    // Don't overwrite optionGuid we just set
                    if ((key === 'optionGuid' || key === 'answerGuid') && subWrapper.dataset.optionGuid) return;
                    subWrapper.dataset[key] = answerDiv.dataset[key];
                }
            });

            subWrapper.dataset.answerSelect = answerDiv.dataset.answerSelect || '';
            subWrapper.dataset.dynamicSelect = answerDiv.dataset.dynamicSelect || '';
            subWrapper.dataset.order = answerDiv.dataset.order || (index + 1);
            // ADD THIS: propagate OptionStatus from modal answer to question sub-value
            subWrapper.dataset.optionStatus = answerDiv.dataset.optionStatus || subWrapper.dataset.optionStatus || '';

            subWrapper.innerHTML = `<span>${answerDiv.querySelector('span') ? answerDiv.querySelector('span').textContent : ''}</span>`;

            questionElement.appendChild(subWrapper);

            // ✅ FIX: Log what was saved
            console.log('  - Saved with optionGuid:', subWrapper.dataset.optionGuid);
            console.log('  - Saved with questionGuid:', subWrapper.dataset.questionGuid);
        });
    }

    async createNewQuestion(value, groupSelect, fieldTypeSelect, isRequiredCheckbox, answersContainer) {
        // ✅ CRITICAL FIX: Handle version change FIRST before any API calls
        let templateVersionId;
        if (this.handleVersionChange) {
            templateVersionId = await this.handleVersionChange();
        }

        const templateData = document.getElementById('template-data');
        if (!templateVersionId) {
            templateVersionId = parseInt(
                templateData?.dataset.tempVersionId ||
                templateData?.dataset.templateVersionId ||
                '0'
            );
        }

        if (!templateVersionId || templateVersionId <= 0) {
            alert('Template is not saved yet. Please save the template first.');
            return;
        }

        console.log('✅ Creating question with templateVersionId:', templateVersionId);
        const savedWrapper = document.createElement('div');
        savedWrapper.className = 'saved-txt stored-overlay';

        savedWrapper.dataset.group = groupSelect.value;
        savedWrapper.dataset.fieldType = fieldTypeSelect.value;
        savedWrapper.dataset.isRequired = isRequiredCheckbox.checked.toString();
        // ✅ Initialize empty GUID for new questions (will be set after save)
        savedWrapper.dataset.questionGuid = '';
        console.log('✅ Initialized new question wrapper with empty GUID');

        const questionCount = this.questionsList ?
            this.questionsList.querySelectorAll('.saved-txt:not(.sub-value)').length : 0;
        savedWrapper.dataset.order = questionCount + 1;

        this.renderQuestionLoading(savedWrapper, value);

        const modalAnswersContainer = answersContainer || this.answersContainer || document.querySelector('#answersContainer');
        const modalAnswerNodes = Array.from(modalAnswersContainer.children);

        const answers = modalAnswerNodes
            .filter(answerDiv => answerDiv.dataset.isDeleted !== 'true')
            .map((answerDiv, index) => {
                // 🔥 ADD THESE LINES:
                console.log('=== DEBUG Answer #' + (index + 1) + ' ===');
                console.log('Answer Text:', answerDiv.querySelector('span') ? answerDiv.querySelector('span').textContent : '');
                console.log('RAW answerSelect from dataset:', answerDiv.dataset.answerSelect);
                console.log('Type of answerSelect:', typeof answerDiv.dataset.answerSelect);

                // Parse the IDs
                let selectedQuestionIds = [];
                if (answerDiv.dataset.answerSelect) {
                    selectedQuestionIds = answerDiv.dataset.answerSelect
                        .split(',')
                        .map(id => id.trim())
                        .filter(id => id !== '' && !isNaN(parseInt(id)))
                        .map(id => parseInt(id));
                }

                console.log('Parsed SelectedQuestionsList:', selectedQuestionIds);
                console.log('====================');
                let answerId = 0;
                if (answerDiv.dataset.id && parseInt(answerDiv.dataset.id) > 0) {
                    answerId = parseInt(answerDiv.dataset.id);
                } else if (answerDiv.dataset.originalId && parseInt(answerDiv.dataset.originalId) > 0) {
                    answerId = parseInt(answerDiv.dataset.originalId);
                }

                console.log(`Creating answer: "${answerDiv.querySelector('span').textContent}" with ID: ${answerId}`);
                return {
                    Id: answerId,
                    Text: answerDiv.querySelector('span') ? answerDiv.querySelector('span').textContent : '',
                    Order: parseInt(answerDiv.dataset.order || (index + 1)),
                    SelectedOption: answerDiv.dataset.mainSelect || '',
                    SelectedMatComId: answerDiv.dataset.dynamicSelect ? parseInt(answerDiv.dataset.dynamicSelect) : null,
                    SelectedQuestionsList: selectedQuestionIds,  // This is what goes to DB
                    IsDeleted: answerDiv.dataset.isDeleted === 'true',
                    OptionGuid: answerDiv.dataset.optionGuid || '',
                    //OptionStatus
                    OptionStatus: (answerDiv.dataset.optionStatus || (answerId > 0 ? 'updated' : 'new'))
                };
            });

        // 🔥 ADD THIS LINE to see all answers before sending:
        console.log('FULL ANSWERS ARRAY TO SEND:', JSON.stringify(answers, null, 2));


        try {
            const templateData = document.getElementById('template-data');
            if (!templateData) {
                throw new Error('Template data not found');
            }

            let templateVersionId =
                templateData.dataset.tempVersionId ||
                templateData.dataset.templateVersionId ||
                0;

            templateVersionId = parseInt(templateVersionId);
            if (!templateVersionId || isNaN(templateVersionId) || templateVersionId <= 0) {
                throw new Error('Template is not saved yet. Please save the template first.');
            }

            const groupName = groupSelect.value;
            const groupElement = document.querySelector(`.section-sub-box .saved-txt span, .saved-txt.stored-overlay span`);
            let groupId = 0;
            let groupGuid = '';

            if (groupElement && groupElement.textContent.includes(groupName)) {
                const groupWrapper = groupElement.closest('.saved-txt');
                groupId = parseInt(groupWrapper?.dataset.id || '0');
                groupGuid = groupWrapper?.dataset.groupGuid || '';
            }

            if (!groupId || groupId <= 0) {
                const groupsContainer = document.querySelector('.section-box');
                if (groupsContainer) {
                    const allGroups = groupsContainer.querySelectorAll('.saved-txt');
                    for (const groupDiv of allGroups) {
                        const span = groupDiv.querySelector('span');
                        if (span && span.textContent.includes(groupName)) {
                            groupId = parseInt(groupDiv.dataset.id || '0');
                            groupGuid = groupDiv.dataset.groupGuid || '';
                            break;
                        }
                    }
                }
            }

            if (!groupId || groupId <= 0) {
                throw new Error(`Could not find group ID for group: ${groupName}. Please make sure the group is saved first.`);
            }

            const questionData = {
                Id: 0,  // ✅ FIX: New question, so ID is 0
                Text: value,
                GroupId: groupId,
                GroupGuid: groupGuid,
                FieldTypeId: parseInt(fieldTypeSelect.value),  // ✅ FIX: Use parameter
                Order: parseInt(savedWrapper.dataset.order),  // ✅ FIX: Use savedWrapper
                IsRequired: isRequiredCheckbox.checked,  // ✅ FIX: Use parameter
                TemplateVersionId: templateVersionId,
                Answers: answers,
                QuestionGuid: savedWrapper.dataset.questionGuid || ''  // ✅ FIX: Use savedWrapper
            };
            console.log('DEBUG - Payload being sent to /api/Template/CreateQuestion:',
                JSON.stringify(questionData, null, 2));
            const response = await fetch('/api/Template/CreateQuestion', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(questionData)
            });
            console.log('metafield called create question', questionData.QuestionGuid);

            const responseText = await response.text();
            let result;
            try {
                result = JSON.parse(responseText);
            } catch (parseError) {
                throw new Error('Server returned invalid response');
            }

            if (response.ok && result.success !== false) {
                savedWrapper.dataset.id = result.questionId;

                // ✅ CRITICAL: Always store QuestionGuid from backend response
                if (result.questionGuid) {
                    savedWrapper.dataset.questionGuid = result.questionGuid;
                    // Also set as HTML attribute for reliability
                    savedWrapper.setAttribute('data-question-guid', result.questionGuid);
                    console.log('✅ Stored QuestionGuid in dataset and attribute:', result.questionGuid);
                } else {
                    console.error('❌ Backend did not return QuestionGuid for question:', result.questionId);
                }
                // 🔥🔥🔥 CRITICAL FIX: Update answer DIVs with REAL database IDs from server response
                if (result.answers && Array.isArray(result.answers)) {
                    const answerDivs = answersContainer ? Array.from(answersContainer.children) : [];
                    const modalAnswerDivs = this.answersContainer ? Array.from(this.answersContainer.children) : [];
                    const allAnswerDivs = [...answerDivs, ...modalAnswerDivs];

                    result.answers.forEach((serverAnswer, index) => {
                        // Find matching answer div by text and order
                        const matchingDiv = allAnswerDivs.find(div => {
                            const divText = div.querySelector('span')?.textContent.trim();
                            return divText === serverAnswer.text &&
                                (parseInt(div.dataset.order) === serverAnswer.order || index === serverAnswer.order - 1);
                        });

                        if (matchingDiv && serverAnswer.id > 0) {
                            // Store REAL database ID
                            matchingDiv.dataset.id = serverAnswer.id;
                            matchingDiv.dataset.originalId = serverAnswer.id;// Also store as backup
                            if (serverAnswer.optionGuid) {
                                matchingDiv.dataset.optionGuid = serverAnswer.optionGuid;
                            }
                            console.log(`✅ Updated answer "${serverAnswer.text}" with database ID: ${serverAnswer.id}`);
                        }
                    });
                }

                this.renderSavedQuestion(savedWrapper, value);
                this.saveAnswersToQuestionElement(savedWrapper, answersContainer);
                const selectedGroupName = groupSelect.value;
                const groupAddButton = this.questionsList.querySelector(`.group-add-button[data-group-name="${selectedGroupName}"]`);

                if (groupAddButton) {
                    groupAddButton.parentNode.insertBefore(savedWrapper, groupAddButton);
                } else {
                    this.questionsList.appendChild(savedWrapper);
                }

                if (this.makeDraggable) this.makeDraggable(savedWrapper, this.questionsList);
                this.wireQuestion(savedWrapper);

                this.updateQuestionOrders();
                //if (this.showSaveNotification) this.showSaveNotification();
                if (this.updateGroupAddButtonOverlay) this.updateGroupAddButtonOverlay(groupSelect.value);

                if (answersContainer) {
                    answersContainer.innerHTML = '';
                }
                this.updateAllQuestionGroupCorners();
                savedWrapper.dataset.group = groupSelect.value; // This should be set
                console.log('DEBUG: Setting question group to:', groupSelect.value);

            } else {
                const errorMessage = result.message || result.error || 'Failed to save question';
                throw new Error(errorMessage);
            }
        } catch (error) {
            savedWrapper.remove();

            let errorMsg = `Failed to save question: ${error.message}`;
            if (error.message.includes('Template is not saved')) {
                errorMsg += '\n\nPlease save the template first, then try adding questions again.';
            } else if (error.message.includes('Could not find group ID')) {
                errorMsg += '\n\nPlease make sure the group is saved before adding questions.';
            }
            alert(errorMsg);
        }
    }

    renderQuestionLoading(wrapper, value) {
        wrapper.innerHTML = `
        <div class="main-value">
            <svg class="saved-svg" viewBox="0 0 20 20">
                <circle cx="5" cy="5" r="1.5"></circle>
                <circle cx="5" cy="10" r="1.5"></circle>
                <circle cx="5" cy="15" r="1.5"></circle>
                <circle cx="10" cy="5" r="1.5"></circle>
                <circle cx="10" cy="10" r="1.5"></circle>
                <circle cx="10" cy="15" r="1.5"></circle>
            </svg>
            <span>Saving "${value}"...</span>
        </div>
    `;
    }

    renderSavedQuestion(wrapper, value) {
        let mainValue = wrapper.querySelector('.main-value');

        if (!mainValue) {
            mainValue = document.createElement('div');
            mainValue.className = 'main-value';
            wrapper.prepend(mainValue);
        }

        mainValue.innerHTML = `
        <svg class="saved-svg" viewBox="0 0 20 20">
            <circle cx="5" cy="5" r="1.5"></circle>
            <circle cx="5" cy="10" r="1.5"></circle>
            <circle cx="5" cy="15" r="1.5"></circle>
            <circle cx="10" cy="5" r="1.5"></circle>
            <circle cx="10" cy="10" r="1.5"></circle>
            <circle cx="10" cy="15" r="1.5"></circle>
        </svg>
        <span>${value}</span>
    `;
    }

    wireQuestion(savedWrapper) {
        // ✅ CRITICAL: Ensure questionGuid is always available in both dataset and attribute
        if (!savedWrapper.dataset.questionGuid || savedWrapper.dataset.questionGuid === 'undefined') {
            const attrGuid = savedWrapper.getAttribute('data-question-guid');
            if (attrGuid && attrGuid !== 'undefined') {
                savedWrapper.dataset.questionGuid = attrGuid;
                console.log('✅ Restored QuestionGuid from attribute:', attrGuid);
            }
        }

        // ✅ Ensure attribute matches dataset
        if (savedWrapper.dataset.questionGuid && savedWrapper.dataset.questionGuid !== 'undefined') {
            savedWrapper.setAttribute('data-question-guid', savedWrapper.dataset.questionGuid);
        }

        // ✅ Log warning if still missing
        if (!savedWrapper.dataset.questionGuid || savedWrapper.dataset.questionGuid === 'undefined') {
            console.error('⚠️ Question missing GUID after wire:', {
                questionId: savedWrapper.dataset.id,
                text: savedWrapper.querySelector('.main-value span')?.textContent
            });
        } else {
            console.log('✅ Question wired with GUID:', savedWrapper.dataset.questionGuid);
        }
        console.log('Wiring question', {
            id: savedWrapper.dataset.id,
            questionGuid: savedWrapper.dataset.questionGuid || '(missing)',
            group: savedWrapper.dataset.group
        });

        savedWrapper.addEventListener('click', () => {
            this.modalOverlay.classList.add('active');

            const modalHeading = this.modalOverlay.querySelector('.t1-pop-up-heading .bold-text');
            if (modalHeading) {
                modalHeading.textContent = "Edit a question";
            }

            this.inputField2.value = savedWrapper.querySelector('.main-value span').textContent;
            this.fieldTypeSelect.value = savedWrapper.dataset.fieldType || 'select';
            this.isRequiredCheckbox.checked = savedWrapper.dataset.isRequired === 'true';

            if (savedWrapper.dataset.group) {
                const groupName = savedWrapper.dataset.group;
                savedWrapper.dataset.groupGuid = savedWrapper.dataset.groupGuid || '';
                if (![...this.groupSelect.options].some(o => o.value === groupName)) {
                    const opt = document.createElement('option');
                    opt.value = groupName;
                    opt.text = groupName;
                    this.groupSelect.appendChild(opt);
                }
                this.groupSelect.value = groupName;
                this.groupSelect.disabled = true;
            } else {
                this.groupSelect.value = '';
            }

            this.editingDiv2 = savedWrapper;

            const cancelButton = this.modalOverlay.querySelector('.cancel-button');
            const deleteButton = this.modalOverlay.querySelector('.delete-button');

            // Hide Cancel, show Delete
            cancelButton.classList.add('hidden');
            deleteButton.classList.remove('hidden');

            deleteButton.onclick = async (e) => {
                e.stopPropagation();
                if (!confirm('Are you sure you want to delete this question?')) {
                    return;
                }
                try {
                    const templateData = document.getElementById('template-data');
                    const templateVersionId = parseInt(templateData?.dataset.tempVersionId || '0');
                    const questionId = parseInt(savedWrapper.dataset.id || '0');
                    // ✅ FIX: Properly check for null/undefined/empty string questionGuid
                    let questionGuid = savedWrapper.dataset.questionGuid;
                    if (!questionGuid || questionGuid === 'null' || questionGuid === 'undefined' || questionGuid === '') {
                        questionGuid = null;
                    }

                    // ✅ ADD DEBUG LOGGING
                    console.log('🗑️ DELETE QUESTION DEBUG:');
                    console.log('  - questionId:', questionId);
                    console.log('  - questionGuid:', questionGuid);
                    console.log('  - templateVersionId:', templateVersionId);
                    console.log('  - Full dataset:', JSON.stringify({ ...savedWrapper.dataset }, null, 2));

                    let deleted = false;
                    let lastError = '';

                    // ✅ Try GUID-based delete first (preferred)
                    if (questionGuid && questionGuid.length > 0 && templateVersionId > 0) {
                        console.log('Attempting GUID-based delete...');
                        try {
                            const res = await fetch(`/api/Template/DeleteQuestionByGuid?questionGuid=${encodeURIComponent(questionGuid)}&templateVersionId=${templateVersionId}`, {
                                method: 'DELETE',
                                headers: { 'Accept': 'application/json' }
                            });

                            console.log('GUID delete response status:', res.status);
                            const responseText = await res.text();
                            console.log('GUID delete response body:', responseText);

                            if (res.ok) {
                                try {
                                    const result = JSON.parse(responseText);
                                    deleted = result?.success !== false;
                                } catch {
                                    deleted = true; // If no JSON, assume success on 200
                                }
                            } else {
                                lastError = `GUID delete failed: ${res.status} - ${responseText}`;
                            }
                        } catch (err) {
                            lastError = `GUID delete error: ${err.message}`;
                            console.error(lastError);
                        }
                    } else {
                        console.log('Skipping GUID delete - missing GUID or templateVersionId');
                    }

                    // ✅ Fallback: delete by numeric ID
                    if (!deleted && questionId > 0) {
                        console.log('Attempting ID-based delete...');
                        try {
                            const res = await fetch(`/api/Template/DeleteQuestion/${questionId}`, {
                                method: 'DELETE',
                                headers: { 'Accept': 'application/json' }
                            });

                            console.log('ID delete response status:', res.status);

                            if (res.ok) {
                                const result = await res.json().catch(() => ({ success: true }));
                                deleted = result?.success !== false;
                            } else {
                                lastError = `ID delete failed: ${res.status}`;
                            }
                        } catch (err) {
                            lastError = `ID delete error: ${err.message}`;
                            console.error(lastError);
                        }
                    }

                    if (!deleted) {
                        throw new Error(lastError || 'Delete failed - no valid ID or GUID');
                    }

                    console.log('✅ Question deleted successfully');
                    savedWrapper.remove();
                    this.updateQuestionOrders();
                    this.updateAllQuestionGroupCorners();
                    this.modalOverlay.classList.remove('active');
                    this.updateGroupAddButtonOverlay(savedWrapper.dataset.group);

                    this.editingDiv2 = null;

                    if (this.showSaveNotification) this.showSaveNotification();
                    if (this.handleVersionChange) this.handleVersionChange();

                } catch (error) {
                    console.error('❌ Delete question error:', error);
                    alert(`Failed to delete question: ${error.message}`);
                }
            };
       
            // ✅ Change modal Create button to Update
            const createBtn = this.modalOverlay.querySelector('.create-button');
            if (createBtn) createBtn.textContent = 'Update';

            this.answersContainer.innerHTML = '';
            Array.from(savedWrapper.querySelectorAll('.sub-value')).forEach(subDiv => {
                const cloned = document.createElement('div');
                cloned.className = 'saved-txt stored-overlay';

                // 🔥🔥🔥 FIX #3: CRITICAL - PRESERVE DATABASE IDS WHEN LOADING EDIT MODAL
                Object.keys(subDiv.dataset).forEach(key => {
                    if (subDiv.dataset[key] !== undefined) {
                        cloned.dataset[key] = subDiv.dataset[key];
                    }
                });

                // 🔥 ALWAYS STORE THE DATABASE ID IN BOTH id AND originalId
                if (subDiv.dataset.id && parseInt(subDiv.dataset.id) > 0) {
                    // This is a database ID (not temp)
                    cloned.dataset.id = subDiv.dataset.id; // Store in id
                    cloned.dataset.originalId = subDiv.dataset.id; // ALSO store in originalId as backup
                    console.log(`✅ Loading saved answer ID: ${subDiv.dataset.id} for: ${subDiv.querySelector('span').textContent}`);
                } else if (subDiv.dataset.originalId && parseInt(subDiv.dataset.originalId) > 0) {
                    // Fallback to originalId
                    cloned.dataset.id = subDiv.dataset.originalId;
                    cloned.dataset.originalId = subDiv.dataset.originalId;
                }
                cloned.innerHTML = `
            <div class="main-value">
                <svg class="saved-svg" viewBox="0 0 20 20">
                    <circle cx="5" cy="5" r="1.5"></circle>
                    <circle cx="5" cy="10" r="1.5"></circle>
                    <circle cx="5" cy="15" r="1.5"></circle>
                    <circle cx="10" cy="5" r="1.5"></circle>
                    <circle cx="10" cy="10" r="1.5"></circle>
                    <circle cx="10" cy="15" r="1.5"></circle>
                </svg>
                <span>${subDiv.querySelector('span').textContent}</span>
            </div>
        `;

                this.answersContainer.appendChild(cloned);
                if (this.makeDraggable) this.makeDraggable(cloned, this.answersContainer);
                this.updateRoundedCornersGeneric(this.answersContainer);
                this.makeScrollable(this.answersContainer);

                cloned.addEventListener('click', () => {
                    if (this.loadAnswerIntoModal) this.loadAnswerIntoModal(cloned);
                });
            });

            setTimeout(() => {
                if (this.resetCreateButtonState) this.resetCreateButtonState();
                if (this.toggleQuestionValidation) this.toggleQuestionValidation();
            }, 100);

            if (this.answersContainer.children.length > 0) {
                document.getElementById('addbtnmodal1').classList.add('overlay');
            } else {
                document.getElementById('addbtnmodal1').classList.remove('overlay');
            }
        });
    }


    updateQuestionOrders() {
        if (!this.questionsList) return;

        const questions = this.questionsList.querySelectorAll('.saved-txt:not(.sub-value)');
        questions.forEach((q, index) => q.dataset.order = index + 1);
    }

    updateAllQuestionGroupCorners() {
        if (!this.questionsList) return;

        const groupNames = new Set();
        this.questionsList.querySelectorAll('.saved-txt:not(.sub-value)').forEach(q => {
            if (q.dataset.group) groupNames.add(q.dataset.group);
        });

        groupNames.forEach(groupName => {
            const groupQuestions = Array.from(
                this.questionsList.querySelectorAll(`.saved-txt:not(.sub-value)[data-group="${groupName}"]`)
            );

            groupQuestions.forEach((question, index) => {
                if (index === 0) {
                    question.style.borderRadius = '6px 6px 0 0';
                    question.style.borderTop = '';
                } else {
                    question.style.borderRadius = '0';
                    question.style.borderTop = 'none';
                }
            });

            if (groupQuestions.length === 1) {
                groupQuestions[0].style.borderRadius = '6px 6px 0 0';
                groupQuestions[0].style.borderTop = '';
            }
        });
    }

    loadQuestionsForGroup(currentGroup, currentQuestionText) {
        if (!this.questionsList) {
            console.log('DEBUG: questionsList not found');
            return [];
        }

        // Get all questions in the current group
        const allQuestions = Array.from(
            this.questionsList.querySelectorAll('.saved-txt.stored-overlay:not(.sub-value)')
        );

        console.log('DEBUG: Total questions found:', allQuestions.length);
        console.log('DEBUG: Looking for group:', currentGroup);

        // Get the current question being edited
        const currentQuestionElement = this.editingDiv2;
        const currentQuestionId = currentQuestionElement?.dataset.id;

        // ✅ IMPROVED: Find questions that CURRENTLY have the current question as their ACTIVE dependent
        const questionsWithCurrentAsDependency = new Set();

        if (currentQuestionElement && currentQuestionId) {
            // Check all questions to see if any of their options have current question as dependent
            allQuestions.forEach(q => {
                const qId = q.dataset.id;
                if (!qId || qId === currentQuestionId) return;

                // Check all sub-values (answers) of this question
                const subValues = q.querySelectorAll('.sub-value');
                subValues.forEach(sv => {
                    // ✅ IMPORTANT: Only check if the answer itself is NOT deleted
                    const isAnswerDeleted = sv.dataset.isDeleted === 'true';
                    const optionStatus = sv.dataset.optionStatus || '';

                    // Skip if this answer is deleted
                    if (isAnswerDeleted || optionStatus === 'deleted') {
                        return;
                    }

                    const answerSelect = sv.dataset.answerSelect || '';
                    if (answerSelect) {
                        const dependentIds = answerSelect.split(',')
                            .map(id => id.trim())
                            .filter(id => id !== '');

                        if (dependentIds.includes(currentQuestionId)) {
                            questionsWithCurrentAsDependency.add(qId);
                            console.log(`🚫 Question ${qId} has current question ${currentQuestionId} as ACTIVE dependent - will be filtered out`);
                        }
                    }
                });
            });
        }

        // Filter questions from the current group
        const groupQuestions = allQuestions.filter(q => {
            const hasGroup = q.dataset.group === currentGroup;
            const hasText = q.querySelector('.main-value span')?.textContent || '';
            const isCurrentQuestion = hasText === currentQuestionText;
            const qId = q.dataset.id;

            // ✅ Exclude questions that CURRENTLY have current question as their ACTIVE dependent
            const wouldCreateCircular = questionsWithCurrentAsDependency.has(qId);

            console.log(`DEBUG - Question: ${hasText}, Group: ${q.dataset.group}, IsCurrent: ${isCurrentQuestion}, WouldCreateCircular: ${wouldCreateCircular}`);

            return hasGroup && !isCurrentQuestion && !wouldCreateCircular;
        });

        console.log('DEBUG: Group questions after filter:', groupQuestions.length);

        // Map to dropdown options
        const options = groupQuestions.map(q => {
            const text = q.querySelector('.main-value span').textContent;
            const id = q.dataset.id || '0';
            console.log(`DEBUG - Option: ${text}, ID: ${id}`);
            return { text: text, id: id };
        });

        return options;
    }


    createGroupHeader(groupName) {
        const groupHeader = document.createElement('div');
        groupHeader.className = 'question-group-header';
        groupHeader.setAttribute('data-group-name', groupName);
        groupHeader.innerHTML = `<h2 class="section-subheading group-subheading">${groupName}</h2>`;
        return groupHeader;
    }

    createGroupAddButton(groupName) {
        const addButtonWrapper = document.createElement('div');
        addButtonWrapper.className = 'btn-add-wrapper group-add-button';
        addButtonWrapper.id = 'addbtnmodal';
        addButtonWrapper.setAttribute('data-group-name', groupName);
        addButtonWrapper.innerHTML = `
            <button class="btn-add btn-add-question" type="button" data-group-name="${groupName}">
                <img src="/images/plus-circle-svg.svg" />
                <span class="btn-add-text">Add question</span>
            </button>
        `;
        return addButtonWrapper;
    }
}

class AnswerManager extends BaseBuilder {
    constructor(answersContainer, modalOverlay, modalOverlay2) {
        super();
        this.answersContainer = answersContainer;
        this.modalOverlay = modalOverlay;
        this.modalOverlay2 = modalOverlay2;
        this.editingDiv = null;
    }

    async fetchDependentQuestions(optionId) {
        try {
            if (!optionId || optionId <= 0) {
                console.log('No valid optionId provided for fetching dependent questions');
                return [];
            }

            console.log(`📡 Fetching dependent questions for optionId: ${optionId}`);

            const response = await fetch(`/api/Template/dependent-questions?optionId=${optionId}`);

            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }

            const dependentQuestions = await response.json();
            console.log(`✅ Received ${dependentQuestions.length} dependent questions for option ${optionId}`);
            console.log('Dependent questions data:', dependentQuestions);

            return dependentQuestions;
        } catch (error) {
            console.error('❌ Error fetching dependent questions:', error);
            return [];
        }
    }

    openAnswerModal(groupSelect, inputField2) {
        const currentGroup = groupSelect.value;
        const currentQuestionText = inputField2.value.trim();

        console.log('DEBUG - openAnswerModal called');
        console.log('Current Group:', currentGroup);
        console.log('Current Question Text:', currentQuestionText);

        // Ensure the modal is properly referenced
        const modal = this.modalOverlay2;
        if (!modal) {
            console.error('Modal not found!');
            return;
        }

        // First, clear any existing options
        const dropdown = modal.querySelector('#dropdown');
        if (dropdown) {
            dropdown.innerHTML = '';
            dropdown.style.display = 'none'; // Hide initially
        }

        // Hide the search input wrapper initially
        const searchWrapper = modal.querySelector('#multiSelect');
        if (searchWrapper) {
            searchWrapper.classList.remove('active');
        }

        // Load questions for the current group
        let questions = [];
        if (this.questionManager) {
            questions = this.questionManager.loadQuestionsForGroup(currentGroup, currentQuestionText);
            console.log('Questions loaded:', questions.length);
        }

        // Make sure modal is visible first
        this.modalOverlay2.classList.add('active');

        // Small delay to ensure DOM is ready
        setTimeout(() => {
            // Now populate the dropdown (but keep it hidden)
            this.populateQuestionDropdown(questions, modal);
            this.setupDropdownInteractions(modal);

            // Initialize search input state
            const searchInput = modal.querySelector('#searchInput');
            if (searchInput) {
                searchInput.value = '';
                searchInput.placeholder = 'Search questions...';
            }
        }, 50);

        // Reset other fields
        const modalHeading2 = this.modalOverlay2.querySelector('.t1-pop-up-heading .bold-text');
        if (modalHeading2) {
            modalHeading2.textContent = "Add a new answer";
        }

        document.getElementById('quoteTemplate22').value = '';
        document.getElementById('mainSelect2').value = '';
        document.getElementById('answerSelect').value = '';
        this.selectedValues.clear();


        const cancelButton4 = this.modalOverlay2.querySelector('#cancel-button4');
        const deleteButton4 = this.modalOverlay2.querySelector('#modal-delete-button4');

        cancelButton4.classList.remove('hidden');
        deleteButton4.classList.add('hidden');


        // Disable/enable buttons
        const createButton4 = document.getElementById('create-button4');
        const modal1CreateButton = document.getElementById('modal1-create-button');

        if (createButton4) {
            createButton4.textContent = 'Create';
            createButton4.classList.add('btn-disable');
        }
        this.editingDiv = null;
        if (modal1CreateButton) modal1CreateButton.classList.remove('btn-disable');

        // Remove dynamic dropdown if exists
        const dynamicDropdownWrapper = document.getElementById('dynamic-wrapper')
            ?.nextElementSibling?.querySelector('.section-input-wrapper')?.parentElement;
        if (dynamicDropdownWrapper) dynamicDropdownWrapper.remove();

        
        this.cleanupDeletedAnswers();
        // Hide the question modal
        if (this.modalOverlay) {
            this.modalOverlay.classList.remove('active');
        }
    }
    populateQuestionDropdown(options, modal = this.modalOverlay2) {
        console.log('=== populateQuestionDropdown DEBUG ===');
        console.log('Options count:', options.length);
        console.log('Modal:', modal);
        console.log('this.selectedValues:', this.selectedValues ? Array.from(this.selectedValues) : 'undefined');


        if (!modal) {
            console.warn('populateQuestionDropdown: modal not provided');
            return;
        }

        const dropdown = modal.querySelector('#dropdown');
        const searchInput = modal.querySelector('#searchInput');
        const hiddenInput = modal.querySelector('#answerSelect');
        const searchWrapper = modal.querySelector('#multiSelect');
        console.log('🔍 Hidden input (#answerSelect) value:', hiddenInput?.value);
        console.log('🔍 Hidden input element:', hiddenInput);

        if (!dropdown) {
            console.error('ERROR: Dropdown element not found inside modal!');
            return;
        }

        // Clear previous contents
        dropdown.innerHTML = '';

        if (!Array.isArray(options) || options.length === 0) {
            const noQuestions = document.createElement('div');
            noQuestions.className = 'multiselect-option no-options';
            noQuestions.textContent = 'No other questions in this group';
            dropdown.appendChild(noQuestions);
            dropdown.style.display = 'none';
            return;
        }

        // Initialize selectedValues if it doesn't exist
        if (!this.selectedValues) {
            this.selectedValues = new Set();
        }

        // Build a Set of pre-selected ids from hidden input (if any)
        const preSelected = new Set();
        if (hiddenInput && hiddenInput.value) {
            const hidVal = hiddenInput.value.trim();
            if (hidVal) {
                hidVal.split(',').forEach(v => {
                    if (v.trim()) preSelected.add(v.trim());
                });
            }
        }

        // Merge with this.selectedValues
        if (this.selectedValues.size > 0) {
            this.selectedValues.forEach(v => preSelected.add(String(v)));
        }

        console.log('DEBUG - Final preSelected Set for checkbox initialization:',
            Array.from(preSelected));

        // create options with checkbox + label
        options.forEach((question) => {
            const option = document.createElement('div');
            option.className = 'multiselect-option';
            option.dataset.value = String(question.id);
            option.dataset.text = question.text;

            const checkbox = document.createElement('input');
            checkbox.type = 'checkbox';
            checkbox.tabIndex = -1;
            checkbox.className = 'multiselect-checkbox';
            checkbox.value = String(question.id);

            const labelSpan = document.createElement('span');
            labelSpan.className = 'multiselect-label';
            labelSpan.textContent = question.text;

            // CRITICAL FIX: Check if this question should be pre-selected
            const shouldBeChecked = preSelected.has(String(question.id));
            console.log(`DEBUG - Question ${question.id} (${question.text}): shouldBeChecked = ${shouldBeChecked}`);

            console.log(`  - Is in selectedValues? ${this.selectedValues?.has(String(question.id))}`);
            console.log(`  - Is in preSelected? ${preSelected.has(String(question.id))}`);
            console.log(`  - checkbox will be: ${shouldBeChecked ? 'CHECKED' : 'UNCHECKED'}`);

            if (shouldBeChecked) {
                checkbox.checked = true;
                option.classList.add('selected');
                // Ensure selectedValues contains it
                this.selectedValues.add(String(question.id));
            }

            // Clicking option toggles selection
            option.addEventListener('click', (e) => {
                e.stopPropagation();
                checkbox.checked = !checkbox.checked;

                const idStr = String(question.id);
                if (checkbox.checked) {
                    this.selectedValues.add(idStr);
                    option.classList.add('selected');
                } else {
                    this.selectedValues.delete(idStr);
                    option.classList.remove('selected');
                }

                // update hidden input
                if (hiddenInput) hiddenInput.value = Array.from(this.selectedValues).join(',');
                if (this.formBuilder?.toggleAnswerValidation) {
                    console.log("🔥 Calling FormBuilder.toggleAnswerValidation");
                    this.formBuilder.toggleAnswerValidation();
                } else {
                    console.error("❌ toggleAnswerValidation is UNDEFINED!");
                    // Fallback: try to call it from formBuilder
                    if (window.formBuilder && window.formBuilder.toggleAnswerValidation) {
                        console.log("✅ Found formBuilder.toggleAnswerValidation, calling it...");
                        window.formBuilder.toggleAnswerValidation();
                    }
                }
            });

            // Clicking checkbox itself
            checkbox.addEventListener('click', (e) => {
                e.stopPropagation();
                const idStr = String(question.id);
                if (checkbox.checked) {
                    this.selectedValues.add(idStr);
                    option.classList.add('selected');
                } else {
                    this.selectedValues.delete(idStr);
                    option.classList.remove('selected');
                }
                if (hiddenInput) hiddenInput.value = Array.from(this.selectedValues).join(',');
                if (this.formBuilder?.toggleAnswerValidation) {
                    console.log("🔥 Calling FormBuilder.toggleAnswerValidation");
                    this.formBuilder.toggleAnswerValidation();
                } else {
                    console.error("❌ toggleAnswerValidation is UNDEFINED!");
                    // Fallback: try to call it from formBuilder
                    if (window.formBuilder && window.formBuilder.toggleAnswerValidation) {
                        console.log("✅ Found formBuilder.toggleAnswerValidation, calling it...");
                        window.formBuilder.toggleAnswerValidation();
                    }
                }
            });

            option.appendChild(checkbox);
            option.appendChild(labelSpan);
            dropdown.appendChild(option);
        });

        // initial state hidden
        dropdown.style.display = 'none';

        // Update hidden input with current selectedValues
        if (hiddenInput) {
            hiddenInput.value = Array.from(this.selectedValues).join(',');
            console.log('DEBUG - Hidden input updated to:', hiddenInput.value);
        }

        console.log('Dropdown populated with', options.length, 'options');
    }




    setupDropdownInteractions(modal = this.modalOverlay2) {
        if (!modal) return;

        const dropdown = modal.querySelector('#dropdown');
        let searchInput = modal.querySelector('#searchInput');
        const searchWrapper = modal.querySelector('#multiSelect');
        const sectionInputWrapper = modal.querySelector('.section-input-wrapper');

        console.log('DEBUG setupDropdownInteractions elements:', {
            dropdown: !!dropdown,
            searchInput: !!searchInput,
            searchWrapper: !!searchWrapper,
            sectionInputWrapper: !!sectionInputWrapper
        });

        if (!dropdown || !searchWrapper) return;

        // If searchInput doesn't exist, check for other input elements
        if (!searchInput) {
            // Try to find any input inside the multiSelect container
            const anyInput = searchWrapper.querySelector('input');
            if (anyInput) {
                console.log('Found alternative input:', anyInput);
                // Use this input instead
                searchInput = anyInput;
            } else {
                console.error('No input element found in multiSelect container');
                return;
            }
        }

        searchWrapper.addEventListener('click', (e) => {
            // Only act if the click is directly on the input or a dropdown icon
            if (e.target === searchInput || e.target.closest('.dropdown-icon')) {
                e.stopPropagation();
                const isVisible = dropdown.style.display === 'block';
                if (!isVisible) {
                    dropdown.style.display = 'block';
                    searchWrapper.classList.add('active');

                    setTimeout(() => {
                        searchInput.focus();
                        searchInput.select();
                    }, 10);
                }
            }
        });


        // Also toggle on focus
        searchInput.addEventListener('focus', (e) => {
            e.stopPropagation();
            console.log('searchInput focused');
            dropdown.style.display = 'block';
            searchWrapper.classList.add('active');
        });

        // Handle search input
        searchInput.oninput = (e) => {
            const term = e.target.value.trim().toLowerCase();
            console.log('Searching for:', term);

            dropdown.querySelectorAll('.multiselect-option').forEach(opt => {
                // skip the "no-options" element
                if (opt.classList.contains('no-options')) {
                    opt.style.display = term ? 'none' : ''; // hide when searching
                    return;
                }

                const text = opt.dataset.text || (opt.querySelector('.multiselect-label')?.textContent || opt.textContent);
                const shouldShow = text.toLowerCase().includes(term);
                opt.style.display = shouldShow ? '' : 'none';

                // highlight matching text inside the label span only
                const label = opt.querySelector('.multiselect-label');
                if (label) {
                    if (term && shouldShow) {
                        const regex = new RegExp(`(${term})`, 'gi');
                        // escape the original text to avoid XSS — we can safely use replace because dataset.text is plain text
                        const safeText = (opt.dataset.text || '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
                        label.innerHTML = safeText.replace(regex, '<mark>$1</mark>');
                    } else {
                        label.textContent = text;
                    }
                }
            });
        };

        // Hide dropdown when clicking outside the multiSelect container
        const outsideClickHandler = (e) => {
            if (!searchWrapper.contains(e.target)) {
                dropdown.style.display = 'none';
                searchWrapper.classList.remove('active');
                // Clear search on close
                searchInput.value = '';
                // Reset options display
                dropdown.querySelectorAll('.multiselect-option').forEach(opt => {
                    opt.style.display = '';

                    const label = opt.querySelector('.multiselect-label');
                    if (label) {
                        const safeText = opt.dataset.text || '';
                        label.textContent = safeText;     // restore text but KEEP checkbox
                    }
                });
            }
        };

        // Remove previous listener if any (prevents duplicate handlers)
        document.removeEventListener('click', this._multiSelectOutsideHandler);
        this._multiSelectOutsideHandler = outsideClickHandler;
        document.addEventListener('click', this._multiSelectOutsideHandler);

        // Prevent dropdown click from closing (stop propagation)
        dropdown.addEventListener('click', (e) => {
            e.stopPropagation();
            // Don't close when clicking inside dropdown
        });

        // Handle Enter key to select first visible option
        searchInput.addEventListener('keydown', (e) => {
            if (e.key === 'Enter') {
                e.preventDefault();
                const firstVisible = dropdown.querySelector('.multiselect-option:not(.no-options)');
                if (firstVisible && firstVisible.style.display !== 'none') {
                    const questionId = firstVisible.dataset.value;
                    this.toggleQuestionSelection(questionId, firstVisible, modal);
                }
            } else if (e.key === 'Escape') {
                dropdown.style.display = 'none';
                searchWrapper.classList.remove('active');
            }
        });

        // Only toggle dropdown and focus when clicking the searchInput itself
        searchInput.addEventListener('click', (e) => {
            e.stopPropagation();
            console.log('searchInput clicked');

            const isVisible = dropdown.style.display === 'block';
            if (!isVisible) {
                dropdown.style.display = 'block';
                searchWrapper.classList.add('active');

                setTimeout(() => {
                    searchInput.focus();
                    searchInput.select();
                }, 10);
            }
        });

    }

    toggleQuestionSelection(questionId, optionElement, modal = this.modalOverlay2) {
        if (!this.selectedValues) this.selectedValues = new Set();

        const idStr = String(questionId);
        if (this.selectedValues.has(idStr)) {
            this.selectedValues.delete(idStr);
            optionElement.classList.remove('selected');
        } else {
            this.selectedValues.add(idStr);
            optionElement.classList.add('selected');
        }
        console.log('DEBUG - Selected Values:', Array.from(this.selectedValues));
        console.log('DEBUG - answerSelect value being set:', Array.from(this.selectedValues).join(','));

        // Update the hidden input INSIDE modal
        const hiddenInput = modal ? modal.querySelector('#answerSelect') : document.getElementById('answerSelect');
        if (hiddenInput) {
            hiddenInput.value = Array.from(this.selectedValues).join(',');
        }

        // call validation if present
        if (this.toggleAnswerValidation) this.toggleAnswerValidation();
    }


    async createNewAnswer(value, mainSelect, answerSelect, dynamicSelectWrapper) {
        const questionModalAnswersContainer = document.querySelector('#answersContainer') || this.answersContainer;

        const savedWrapper = document.createElement('div');
        savedWrapper.className = 'saved-txt stored-overlay';

        console.log('🎯🎯🎯 CREATING NEW ANSWER - DEBUG START 🎯🎯🎯');
        console.log('1. Value (answer text):', value);
        console.log('2. mainSelect.value:', mainSelect.value);
        console.log('3. answerSelect element:', answerSelect);
        console.log('4. answerSelect.value:', answerSelect.value);
        console.log('5. this.selectedValues:', this.selectedValues ? Array.from(this.selectedValues) : 'undefined');
        console.log('6. dynamicSelectWrapper:', dynamicSelectWrapper);

        // 🔥 ADD THIS DEBUG - Check all modal inputs
        const modal = this.modalOverlay2;
        const hiddenInput = modal.querySelector('#answerSelect');
        console.log('7. Hidden input value:', hiddenInput ? hiddenInput.value : 'no hidden input found');

        // Check all inputs in modal
        modal.querySelectorAll('input, select').forEach(input => {
            if (input.id) {
                console.log(`   Input ${input.id}:`, input.value);
            }
        });

        savedWrapper.dataset.order = questionModalAnswersContainer.querySelectorAll('.saved-txt').length + 1;
        savedWrapper.dataset.mainSelect = this.normalize(mainSelect.value);

        // 🔥 DEBUG: What are we saving?
        const selectedIds = Array.from(this.selectedValues).join(',');
        console.log('8. selectedIds from selectedValues:', selectedIds);
        console.log('9. answerSelect.value (raw):', answerSelect.value);

        savedWrapper.dataset.answerSelect = answerSelect.value || selectedIds;
        console.log('10. Final answerSelect saved to dataset:', savedWrapper.dataset.answerSelect);

        const dynamicSelectEl = dynamicSelectWrapper
        savedWrapper.dataset.dynamicSelect = dynamicSelectWrapper
        savedWrapper.dataset.dynamicSelect = dynamicSelectWrapper
        savedWrapper.dataset.tempId = 'temp_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
        savedWrapper.dataset.optionStatus = 'new';

        console.log('11. Full dataset being saved:');
        for (let key in savedWrapper.dataset) {
            console.log(`    ${key}: ${savedWrapper.dataset[key]}`);
        }
        console.log('🎯🎯🎯 DEBUG END 🎯🎯🎯');

        this.saveDropdownSelections(this.modalOverlay2);

        savedWrapper.innerHTML = `
    <div class="main-value">
        <svg class="saved-svg" viewBox="0 0 20 20">
            <circle cx="5" cy="5" r="1.5"></circle>
            <circle cx="5" cy="10" r="1.5"></circle>
            <circle cx="5" cy="15" r="1.5"></circle>
            <circle cx="10" cy="5" r="1.5"></circle>
            <circle cx="10" cy="10" r="1.5"></circle>
            <circle cx="10" cy="15" r="1.5"></circle>
        </svg>
        <span>${value}</span>
    </div>
    `;
        if (this.makeDraggable) this.makeDraggable(savedWrapper, questionModalAnswersContainer);
        questionModalAnswersContainer.appendChild(savedWrapper);
        this.updateAnswerOrders();
        this.makeScrollable(questionModalAnswersContainer);

        savedWrapper.addEventListener('click', () => {
            console.log('🔥 ANSWER CLICKED - DEBUG INFO 🔥');
            console.log('Answer Text:', savedWrapper.querySelector('span').textContent);
            console.log('Dataset ID:', savedWrapper.dataset.id);
            console.log('Dataset originalId:', savedWrapper.dataset.originalId);
            console.log('Dataset tempId:', savedWrapper.dataset.tempId);
            console.log('Full dataset:', { ...savedWrapper.dataset });
            this.loadAnswerIntoModal(savedWrapper);
        });

        if (questionModalAnswersContainer.children.length >= 4) {
            questionModalAnswersContainer.style.overflowY = 'auto';
        }

        const addButton = document.querySelector('#addbtnmodal1 .btn-add-text');
        if (addButton && questionModalAnswersContainer.children.length === 1) {
            addButton.textContent = 'Add answer';
        }

        this.updateRoundedCornersGeneric(questionModalAnswersContainer);

        if (this.questionManager) {
            this.questionManager.answersContainer = questionModalAnswersContainer;
        }
    }

    async loadAnswerIntoModal(answerDiv) {
        console.log('🔥🔥🔥 LOADING ANSWER INTO MODAL - FULL DEBUG 🔥🔥🔥');

        // Switch modals
        this.modalOverlay.classList.remove('active');
        this.modalOverlay2.classList.add('active');

        // Set modal heading
        const modalHeading2 = this.modalOverlay2.querySelector('.t1-pop-up-heading .bold-text');
        if (modalHeading2) modalHeading2.textContent = "Edit an answer";

        const createButton4 = document.getElementById('create-button4');
        if (createButton4) {
            createButton4.textContent = 'Update';
        }

        // Store editing reference
        this.editingDiv = answerDiv;

        // Load answer text
        document.getElementById('quoteTemplate22').value = answerDiv.querySelector('span').textContent;

        // ✅ CRITICAL: Force optionStatus to 'updated' for existing answers
        if (answerDiv.dataset.id && parseInt(answerDiv.dataset.id) > 0) {
            answerDiv.dataset.optionStatus = 'updated';
        }

        // Store original values
        answerDiv.dataset.originalValue = this.normalize(answerDiv.querySelector('span').textContent);
        answerDiv.dataset.originalMain = this.normalize(answerDiv.dataset.mainSelect);
        answerDiv.dataset.originalAnswer = answerDiv.dataset.answerSelect || '';
        answerDiv.dataset.originalDynamic = this.normalize(answerDiv.dataset.dynamicSelect);

        const originalId = answerDiv.dataset.id || answerDiv.dataset.originalId || '';
        answerDiv.dataset.originalId = originalId;
        answerDiv.dataset.currentId = answerDiv.dataset.id || answerDiv.dataset.tempId || '';

        // Initialize selectedValues
        if (!this.selectedValues) {
            this.selectedValues = new Set();
        }
        this.selectedValues.clear();

        // ✅ CRITICAL FIX: Get current template version
        const templateData = document.getElementById('template-data');
        const currentTemplateVersionId = parseInt(templateData?.dataset.tempVersionId || '0');

        console.log('🔍 Current Template Version:', currentTemplateVersionId);

        // ✅ Fetch dependent questions from API (this gets the CORRECT version's question IDs)
        const answerId = answerDiv.dataset.id || answerDiv.dataset.tempId;

        if (answerId && !isNaN(parseInt(answerId)) && parseInt(answerId) > 0) {
            console.log(`📡 Fetching dependent questions from API for answer ID: ${answerId}`);

            try {
                const dependentQuestions = await this.fetchDependentQuestions(parseInt(answerId));

                if (dependentQuestions && dependentQuestions.length > 0) {
                    console.log(`✅ Received ${dependentQuestions.length} dependent questions from API`);

                    dependentQuestions.forEach(question => {
                        this.selectedValues.add(String(question.questionId));
                        console.log(`➕ Added dependent question ID: ${question.questionId} (${question.questionText})`);
                    });

                    // Update the answerDiv dataset with resolved IDs
                    const allIds = Array.from(this.selectedValues)
                        .filter(id => id && id !== "undefined" && !isNaN(parseInt(id)));
                    answerDiv.dataset.answerSelect = allIds.join(',');

                    console.log('✅ Updated answerDiv.answerSelect:', answerDiv.dataset.answerSelect);
                } else {
                    console.log('ℹ️ No dependent questions found from API');
                }
            } catch (error) {
                console.error('❌ Error fetching dependent questions:', error);
            }
        } else {
            console.log('ℹ️ No valid answer ID, checking local dataset');

            // For new answers or if API fails, use local data
            let answerIds = answerDiv.dataset.answerSelect;
            if (answerIds && answerIds.trim()) {
                const cleanedIds = answerIds.split(',')
                    .map(id => id.trim())
                    .filter(id => id !== '' && id !== 'null' && id !== 'undefined' && !isNaN(parseInt(id)));

                cleanedIds.forEach(id => {
                    this.selectedValues.add(id);
                });
            }
        }

        console.log('✅ Final selectedValues:', Array.from(this.selectedValues));

        // Update hidden input immediately
        const hiddenInput = this.modalOverlay2.querySelector('#answerSelect');
        if (hiddenInput) {
            hiddenInput.value = Array.from(this.selectedValues).join(',');
            console.log('✅ Hidden input set to:', hiddenInput.value);
        }

        // Delete button handling
        const cancelButton4 = this.modalOverlay2.querySelector('#cancel-button4');
        const deleteButton4 = this.modalOverlay2.querySelector('#modal-delete-button4');

        cancelButton4.classList.add('hidden');
        deleteButton4.classList.remove('hidden');

        deleteButton4.onclick = (e) => {
            e.stopPropagation();
            this.editingDiv = answerDiv;

            if (confirm('Are you sure you want to delete this answer?')) {
                answerDiv.dataset.isDeleted = 'true';
                answerDiv.dataset.optionStatus = 'deleted';
                answerDiv.style.display = 'none';

                if (this.cleanupDeletedAnswers) {
                    this.cleanupDeletedAnswers();
                }

                this.modalOverlay2.classList.remove('active');
                this.modalOverlay.classList.add('active');

                if (this.formBuilder && typeof this.formBuilder.toggleQuestionValidation === 'function') {
                    this.formBuilder.toggleQuestionValidation();
                }
            }
        };

        // Load main select
        const mainSelect = document.getElementById('mainSelect2');
        const restored = this.normalize(answerDiv.dataset.mainSelect);
        mainSelect.value = (restored && restored !== 'Select') ? restored : '';

        // Remove existing dynamic dropdown
        const existing = document.getElementById('dynamic-wrapper')?.nextElementSibling;
        if (existing && existing.classList.contains('dynamic-dropdown')) {
            existing.remove();
        }

        // Restore dynamic dropdown
        (async () => {
            const mainVal = mainSelect.value;
            if (mainVal === 'Material' || mainVal === 'Component') {
                const newDropdown = await this.createDropdown?.(mainVal);
                if (newDropdown) {
                    document.getElementById('dynamic-wrapper')
                        .insertAdjacentElement('afterend', newDropdown);

                    const dynSel = newDropdown.querySelector('.dynamic-select');
                    const dynVal = this.normalize(answerDiv.dataset.dynamicSelect);
                    if (dynSel && dynVal) {
                        const match = dynSel.querySelector(`option[value="${dynVal}"]`);
                        if (match) dynSel.value = dynVal;
                    }
                }
            }
        })();

        // Rebuild dropdown with current version's questions
        const currentQuestionElement = this.questionManager?.editingDiv2;
        if (currentQuestionElement) {
            const currentGroup = currentQuestionElement.dataset.group;
            const currentQuestionText = currentQuestionElement.querySelector('.main-value span').textContent;

            console.log('🔄 Rebuilding dropdown for group:', currentGroup);

            const questions = this.questionManager?.loadQuestionsForGroup(currentGroup, currentQuestionText) || [];

            // Clear dropdown
            const dropdown = this.modalOverlay2.querySelector('#dropdown');
            if (dropdown) {
                dropdown.innerHTML = '';
                dropdown.style.display = 'none';
            }

            // Populate with current version's questions
            this.populateQuestionDropdown(questions, this.modalOverlay2);
            this.setupDropdownInteractions(this.modalOverlay2);

            // Force checkbox states after a delay
            setTimeout(() => {
                if (dropdown) {
                    const options = dropdown.querySelectorAll('.multiselect-option:not(.no-options)');
                    options.forEach(option => {
                        const value = option.dataset.value;
                        const checkbox = option.querySelector('.multiselect-checkbox');

                        if (value && checkbox && this.selectedValues.has(String(value))) {
                            checkbox.checked = true;
                            option.classList.add('selected');
                            console.log('✅ Checked checkbox for question ID:', value);
                        }
                    });
                }
            }, 100);
        }

        // Enable/disable create button
        setTimeout(() => {
            const createButton = document.getElementById('create-button4');
            if (createButton) createButton.classList.add('btn-disable');
            if (this.toggleAnswerValidation) this.toggleAnswerValidation();
        }, 100);

        // UI adjustments
        if (this.answersContainer && this.answersContainer.children.length > 0) {
            const addBtn = document.getElementById('addbtnmodal1');
            if (addBtn) addBtn.classList.add('overlay');
        }

        setTimeout(() => {
            const searchWrapper = this.modalOverlay2.querySelector('#multiSelect');
            if (searchWrapper && this.selectedValues.size > 0) {
                searchWrapper.classList.add('active');
            }
        }, 100);
    }

    async rebuildQuestionDropdown() {
        const currentQuestionElement = this.questionManager?.editingDiv2;
        if (!currentQuestionElement) return;

        const currentGroup = currentQuestionElement.dataset.group;
        const currentQuestionText = currentQuestionElement.querySelector('.main-value span').textContent;

        const questions = this.questionManager?.loadQuestionsForGroup(currentGroup, currentQuestionText) || [];

        // Clear and rebuild
        const dropdown = this.modalOverlay2.querySelector('#dropdown');
        if (dropdown) dropdown.innerHTML = '';

        this.populateQuestionDropdown(questions, this.modalOverlay2);
        this.setupDropdownInteractions(this.modalOverlay2);

        // Force UI update
        setTimeout(() => {
            const options = dropdown.querySelectorAll('.multiselect-option');
            options.forEach(option => {
                const value = option.dataset.value;
                if (this.selectedValues.has(String(value))) {
                    option.classList.add('selected');
                    const checkbox = option.querySelector('.multiselect-checkbox');
                    if (checkbox) checkbox.checked = true;
                }
            });
        }, 100);
    }

    updateAnswerOrders() {
        this.updateOrders(this.answersContainer, '.saved-txt', 'order');
    }
    cleanupDeletedAnswers() {
        if (!this.answersContainer) return;

        // Remove answers marked for deletion
        Array.from(this.answersContainer.children).forEach(answerDiv => {
            if (answerDiv.dataset.isDeleted === 'true') {
                answerDiv.classList.add('deleted-answer');
                answerDiv.style.display = 'none'; // UI hide only
            }
        });

        this.updateAnswerOrders();
        this.updateRoundedCornersGeneric(this.answersContainer);
        const addBtn = document.getElementById('addbtnmodal1');
        if (addBtn) {
            if (this.answersContainer.children.length === 0) {
                addBtn.classList.remove('overlay');
            }
        }
    }
}

class FormBuilder {
    constructor() {
        this.versionCall = 0;
        this.editingDiv = null;
        this.editingDiv2 = null;
        this.selectedValues = new Set();
        this.dropdownMemory = {};

        this.initializeElements();

        this.groupManager = new GroupManager(this.container, this.groupSelect, this.questionsList);
        this.questionManager = new QuestionManager(this.questionsList, this.answersContainer, this.groupSelect, this.fieldTypeSelect, this.modalOverlay);
        this.answerManager = new AnswerManager(this.answersContainer, this.modalOverlay, this.modalOverlay2);
        this.metaFieldsManager = new MetafieldsManager(this.addMetafieldsBtn, this.metaFieldsModal, this);
        this.iFramesManager = new IframeManager();
        this.connectManagers();
        this.setupEventListeners();
        this.hydrateExistingData();
        this.metaFieldsManager.loadMetafieldsFromDb();
        // Add this to your FormBuilder constructor
        console.log('Modal overlay 2 exists:', !!this.modalOverlay2);
        console.log('Modal overlay 2 ID:', this.modalOverlay2?.id);
        this.checkTemplateStatusOnLoad();
        this.determineAndSetTemplateNewStatus();
    }

    resetCreateButtonState() {
        $('#modal1-create-button').addClass('btn-disable');
        $('#create-button4').addClass('btn-disable');
    }

    async checkTemplateStatusOnLoad() {
        const templateData = document.getElementById('template-data');
        if (!templateData) return;

        const tempVersionId = templateData.dataset.tempVersionId;
        if (!tempVersionId || tempVersionId === '0') return;

        try {
            const response = await fetch(`/api/Template/GetStatus/${tempVersionId}`);
            if (!response.ok) throw new Error('Failed to get template status');

            const data = await response.json();
            if (data.isActive !== undefined) {
                updateTemplateStatusUI(data.isActive);
            }
        } catch (error) {
            console.error('Error fetching template status:', error);
        }
    }
    determineAndSetTemplateNewStatus() {
        const templateData = document.getElementById('template-data');
        if (!templateData) return;

        // Check for existing groups
        const hasGroups = this.container &&
            this.container.querySelectorAll('.saved-txt.stored-overlay').length > 0;

        // Check for existing questions
        const hasQuestions = this.questionsList &&
            this.questionsList.querySelectorAll('.saved-txt:not(.sub-value)').length > 0;

        // Check for existing metafields
        const hasMetaFields = this.checkIfMetaFieldsExist();

        // If template has NO content, it's new
        const isNewTemplate = !(hasGroups || hasQuestions || hasMetaFields);

        // Set the attribute
        templateData.dataset.isNewTemplate = isNewTemplate.toString();

        console.log(`📊 Template status determined:`, {
            hasGroups,
            hasQuestions,
            hasMetaFields,
            isNewTemplate
        });
    }

    checkIfMetaFieldsExist() {
        const metaFieldsContainer = document.getElementById('metaFieldsList');
        if (!metaFieldsContainer) return false;

        // Check for saved metafields (not the "Add another Metafield" button)
        const savedMetaFields = metaFieldsContainer.querySelectorAll('.saved-txt.stored-overlay');
        return savedMetaFields.length > 0;
    }
    connectManagers() {
        this.groupManager.showSaveNotification = () => this.showSaveNotification();
        this.groupManager.handleVersionChange = () => this.handleVersionChange();
        this.groupManager.makeDraggable = (element, container) => this.makeDraggable(element, container);

        this.questionManager.showSaveNotification = () => this.showSaveNotification();
        this.questionManager.handleVersionChange = () => this.handleVersionChange();
        this.questionManager.makeDraggable = (element, container) => this.makeDraggable(element, container);
        this.questionManager.inputField2 = this.inputField2;
        this.questionManager.isRequiredCheckbox = this.isRequiredCheckbox;
        this.questionManager.loadAnswerIntoModal = (cloned) => this.answerManager.loadAnswerIntoModal(cloned);
        this.questionManager.filterGroupDropdown = (name) => this.groupManager.filterGroupDropdown(name);
        this.questionManager.createGroupHeader = (name) => this.groupManager.createGroupHeader(name);
        this.questionManager.createGroupAddButton = (name) => this.groupManager.createGroupAddButton(name);
        this.questionManager.updateGroupAddButtonOverlay = (name) => this.groupManager.updateGroupAddButtonOverlay(name);
        this.questionManager.resetCreateButtonState = () => this.resetCreateButtonState();

        this.answerManager.loadQuestionsForGroup = (group, text) => this.questionManager.loadQuestionsForGroup(group, text);
        this.answerManager.createDropdown = (type) => this.createDropdown(type);
        this.answerManager.makeDraggable = (element, container) => this.makeDraggable(element, container);
        // Make sure AnswerManager has access to QuestionManager
        this.answerManager.questionManager = this.questionManager;

        // And QuestionManager has access to AnswerManager
        this.questionManager.answerManager = this.answerManager;
        this.answerManager.formBuilder = this;
    }


    initializeElements() {
        const questionGroupsContainer = Array.from(document.querySelectorAll(".section-container"))
            .find(c => c.querySelector(".section-heading")?.textContent.trim() === "Question Groups");

        if (!questionGroupsContainer) {
            console.error("Question Groups container not found!");
            return;
        }

        this.container = questionGroupsContainer.querySelector('.section-box');

        let addBtn = this.container.querySelector('.btn-add');
        let btnWrapper = this.container.querySelector('.btn-add-wrapper');

        if (!addBtn || !btnWrapper) {
            btnWrapper = document.createElement('div');
            btnWrapper.className = 'btn-add-wrapper';

            addBtn = document.createElement('button');
            addBtn.type = 'button';
            addBtn.className = 'btn-add';
            addBtn.innerHTML = `
                <img src="~/Theme/images/icons/plus-circle-svg.svg" />
                <span class="btn-add-text">Add group</span>
            `;

            btnWrapper.appendChild(addBtn);
            this.container.appendChild(btnWrapper);
        }

        this.groupAddBtn = addBtn;
        this.questionsList = document.getElementById('questionsList');
        this.answersContainer = this.createAnswersContainer();

        this.nameInput = document.getElementById('templateName');
        this.descInput = document.getElementById('templateDes');
        this.groupSelect = document.getElementById('groupSelect');
        this.fieldTypeSelect = document.getElementById('fieldTypeSelect');
        this.inputField2 = document.getElementById('modal1-input');

        this.modalOverlay = document.querySelector('.modal-overlay');
        this.modalOverlay2 = document.getElementById('ModalOverLay2');
        this.saveBtn = document.querySelector('.save-btn');
        this.discardBtn = document.querySelector('.discard-btn');
        this.isRequiredCheckbox = document.getElementById('isRequiredCheckbox');
        this.addMetafieldsBtn = document.getElementById('addMetaFieldsBtn');
        this.metaFieldsModal = document.getElementById('metaFieldsModal');

        this.originalValues = {
            name: this.nameInput.value.trim(),
            desc: this.descInput.value.trim()
        };

        setTimeout(() => {
            this.toggleQuestionValidation();
            this.toggleAnswerValidation();
        }, 500);
    }
    toggleQuestionValidation() {
        const HIDDEN_VALUES = ['5', '6', '7'];
        const ANSWERS_REQUIRED = ['1', '2', '3', '4'];

        const isHidden = HIDDEN_VALUES.includes(this.fieldTypeSelect.value);
        const displayStyle = isHidden ? 'none' : 'block';

        document.getElementById('addbtnmodal1').style.display = displayStyle;
        document.getElementById('subheadingbold').style.display = displayStyle;

        const nameFilled = this.inputField2.value.trim().length > 0;
        const fieldValue = this.fieldTypeSelect.value;

        // ✅ FIX: Count only visible (non-deleted) answers
        const visibleAnswers = Array.from(this.answersContainer.children)
            .filter(a => a.dataset.isDeleted !== 'true');
        const hasAnswers = visibleAnswers.length > 0;

        let canCreate = false;

        if (this.questionManager.editingDiv2) {
            const originalText = this.questionManager.editingDiv2.querySelector('.main-value span').textContent;
            const originalGroup = this.questionManager.editingDiv2.dataset.group;
            const originalFieldType = this.questionManager.editingDiv2.dataset.fieldType;
            const originalIsRequired = this.questionManager.editingDiv2.dataset.isRequired === 'true';

            const textChanged = this.inputField2.value.trim() !== originalText;
            const groupChanged = this.groupSelect.value !== originalGroup;
            const fieldTypeChanged = this.fieldTypeSelect.value !== originalFieldType;
            const isRequiredChanged = this.isRequiredCheckbox.checked !== originalIsRequired;

            // ✅ Count original answers from the question element (excluding deleted)
            const originalAnswerCount = Array.from(
                this.questionManager.editingDiv2.querySelectorAll('.sub-value')
            ).filter(div => div.dataset.isDeleted !== 'true').length;

            // ✅ Count current visible answers in modal
            const currentAnswerCount = visibleAnswers.length;

            // ✅ Check if any answers are marked for deletion in the modal
            const deletedAnswersInModal = Array.from(this.answersContainer.children)
                .filter(div => div.dataset.isDeleted === 'true');
            const hasDeletedAnswers = deletedAnswersInModal.length > 0;

            // ✅ Compare answer counts - if different, there's a change
            const answerCountChanged = originalAnswerCount !== currentAnswerCount;

            // ✅ Also check for content changes in remaining answers
            const originalAnswers = Array.from(this.questionManager.editingDiv2.querySelectorAll('.sub-value'))
                .filter(div => div.dataset.isDeleted !== 'true')
                .map(div => ({
                    text: div.querySelector('span')?.textContent || '',
                    mainSelect: div.dataset.mainSelect || '',
                    answerSelect: div.dataset.answerSelect || '',
                    dynamicSelect: div.dataset.dynamicSelect || '',
                    id: div.dataset.id || div.dataset.tempId || ''
                }));

            const currentAnswers = visibleAnswers.map(div => ({
                text: div.querySelector('span')?.textContent || '',
                mainSelect: div.dataset.mainSelect || '',
                answerSelect: div.dataset.answerSelect || '',
                dynamicSelect: div.dataset.dynamicSelect || '',
                id: div.dataset.id || div.dataset.tempId || ''
            }));

            const contentChanged = originalAnswers.length !== currentAnswers.length ||
                originalAnswers.some((orig, index) => {
                    const curr = currentAnswers[index];
                    if (!curr) return true;
                    return orig.text !== curr.text ||
                        orig.mainSelect !== curr.mainSelect ||
                        orig.answerSelect !== curr.answerSelect ||
                        orig.dynamicSelect !== curr.dynamicSelect;
                });

            // ✅ CRITICAL: hasDeletedAnswers OR answerCountChanged OR contentChanged = change detected
            const answersChanged = hasDeletedAnswers || answerCountChanged || contentChanged;

            const hasChanges = textChanged || groupChanged || fieldTypeChanged || isRequiredChanged || answersChanged;

            // ✅ For field types that require answers, check if we still have enough
            const isValid = nameFilled && (
                HIDDEN_VALUES.includes(fieldValue) ||
                (ANSWERS_REQUIRED.includes(fieldValue) && hasAnswers)
            );

            canCreate = isValid && hasChanges;

            console.log('🔍 toggleQuestionValidation DEBUG:', {
                hasDeletedAnswers,
                answerCountChanged,
                contentChanged,
                answersChanged,
                hasChanges,
                isValid,
                canCreate,
                originalAnswerCount,
                currentAnswerCount,
                deletedCount: deletedAnswersInModal.length
            });
        } else {
            canCreate = nameFilled && (
                HIDDEN_VALUES.includes(fieldValue) ||
                (ANSWERS_REQUIRED.includes(fieldValue) && hasAnswers)
            );
        }

        $('#modal1-create-button').toggleClass('btn-disable', !canCreate);
    }

    // Replace the existing toggleAnswerValidation method in FormBuilder with this implementation
    toggleAnswerValidation() {
        const $quoteTemplateModel2 = $('#quoteTemplate22');
        const $mainSelect2 = $('#mainSelect2');
        const $saveButtonModal2 = $('#create-button4');

        const hasText = $quoteTemplateModel2.val().trim().length > 0;
        const hasMainSelect = $mainSelect2.val() && $mainSelect2.val().trim() !== '' && $mainSelect2.val() !== 'Select';

        const $dyn = $('.dynamic-select');
        const hasDynamicSelect = $dyn.length > 0 ?
            ($dyn.val() && $dyn.val().trim() !== '' && $dyn.val() !== 'Select') : false;

        let canSave = false;

        if (this.answerManager.editingDiv) {
            const originalText = this.answerManager.editingDiv.dataset.originalValue || '';
            const originalMain = this.answerManager.editingDiv.dataset.originalMain || '';
            const originalAnswer = this.answerManager.editingDiv.dataset.originalAnswer || '';
            const originalDynamic = this.answerManager.editingDiv.dataset.originalDynamic || '';

            const currentText = $quoteTemplateModel2.val().trim();
            const currentMain = $mainSelect2.val() || '';
            const currentDynamic = $dyn.length > 0 ? $dyn.val() : '';

            const textChanged = currentText !== originalText;
            const mainChanged = currentMain !== originalMain;
            const dynamicChanged = currentDynamic !== originalDynamic;
            const answerListChanged = (this.modalOverlay2?.querySelector('#answerSelect')?.value || '') !== (originalAnswer || '');

            // any meaningful change in text / main / dynamic / linked-questions should count
            const hasChanges = textChanged || mainChanged || dynamicChanged || answerListChanged;

            // VALID if any of the inputs that matter have a value:
            // - free-text answers are allowed (hasText),
            // - or mainSelect/dynamicSelect can satisfy validity for material/component flows.
            const isValid = hasText || hasMainSelect || hasDynamicSelect;

            canSave = isValid && hasChanges;
        } else {
            // creating new answer: require at least text OR a main/dynamic selection
            canSave = hasText || hasMainSelect || hasDynamicSelect;
        }

        $saveButtonModal2.toggleClass('btn-disable', !canSave);

        if (!canSave) {
            $(document).trigger('answerModelChanged');
        }
    }

    createAnswersContainer() {
        const container = document.createElement('div');
        container.id = 'answers-answers';
        container.className = 'answers-container';

        const heading = document.getElementById('subheadingbold');
        heading.insertAdjacentElement('afterend', container);

        return container;
    }

    setupEventListeners() {
        this.setupSaveNotificationListeners();
        this.setupGroupEventListeners();
        this.setupModalEventListeners();
        this.setupQuestionEventListeners();
        this.setupDropdownEventListeners();
        this.setupDynamicDropdown();
        this.setupTemplateActions();
        this.setupValidationListeners();
        this.setupResizeListener();
    }

    setupSaveNotificationListeners() {
        this.nameInput.addEventListener('input', () => this.checkForChanges());
        this.descInput.addEventListener('input', () => this.checkForChanges());

        this.saveBtn?.addEventListener('click', (e) => {
            e.preventDefault();
            this.hideSaveNotification();
            this.saveForm();
        });

        this.discardBtn?.addEventListener('click', (e) => {
            e.preventDefault();
            this.hideSaveNotification();
        });
    }

    setupGroupEventListeners() {
        const addBtn = this.container?.querySelector('.btn-add');

        if (!addBtn) {
            console.error("Add group button not found!");
            return;
        }

        addBtn.addEventListener('click', (e) => {
            e.preventDefault();
            e.stopImmediatePropagation();
            this.groupManager.addNewGroup();
        });

        document.addEventListener('click', (e) => {
            const groupAddBtn = e.target.closest('.group-add-button .btn-add-question');
            if (groupAddBtn) {
                this.questionManager.openQuestionModalForGroup(e.target.closest('.group-add-button'));
            }
        });
    }

    setupModalEventListeners() {
        const cancelButton = this.modalOverlay?.querySelector('.cross-button-svg');
        const cancelButton2 = this.modalOverlay?.querySelector('.cancel-button');
        const createButton = document.getElementById('modal1-create-button');

        cancelButton?.addEventListener('click', () => this.modalOverlay.classList.remove('active'));
        cancelButton2?.addEventListener('click', () => this.handleModal1Cancel());
        createButton?.addEventListener('click', () => this.handleCreateQuestion());

        const addBtnModal2 = document.getElementById('addbtnmodal1');
        const cancelButton3 = this.modalOverlay2?.querySelector('#cancel-button3');
        const cancelButton4 = this.modalOverlay2?.querySelector('#cancel-button4');
        const createButton4 = document.getElementById('create-button4');

        addBtnModal2?.addEventListener('click', () => this.answerManager.openAnswerModal(this.groupSelect, this.inputField2));
        cancelButton3?.addEventListener('click', () => this.closeAnswerModal());
        cancelButton4?.addEventListener('click', () => this.handleModal2Cancel());
        createButton4?.addEventListener('click', () => this.handleCreateAnswer());
        this.addMetafieldsBtn.addEventListener('click', () => this.metaFieldsManager.openMetafieldsModal());
    }

    setupQuestionEventListeners() {
        document.addEventListener('click', (e) => {
            const wrapper = e.target.closest('.btn-add-wrapper');
            if (wrapper && !e.target.closest('button')) {
                wrapper.querySelector('button')?.click();
            }
        });
    }

    setupDropdownEventListeners() {
        document.querySelectorAll('.custom-dropdown-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                e.stopPropagation();
                const menu = btn.nextElementSibling;
                const isOpen = menu.classList.contains('dropdown-active');

                document.querySelectorAll('.custom-dropdown-menu.dropdown-active').forEach(otherMenu => {
                    if (otherMenu !== menu) {
                        otherMenu.classList.remove('dropdown-active');
                        otherMenu.previousElementSibling.classList.remove('dropdown-active');
                    }
                });

                if (isOpen) {
                    menu.classList.remove('dropdown-active');
                    btn.classList.remove('dropdown-active');
                } else {
                    menu.classList.add('dropdown-active');
                    btn.classList.add('dropdown-active');
                }
            });
        });

        document.addEventListener('click', (e) => {
            if (!e.target.matches('.custom-dropdown-btn')) {
                document.querySelectorAll('.custom-dropdown-menu.dropdown-active').forEach(menu => {
                    menu.classList.remove('dropdown-active');
                    menu.previousElementSibling.classList.remove('dropdown-active');
                });
            }
        });
    }

    setupDynamicDropdown() {
        const mainSelect = document.getElementById('mainSelect2');
        const wrapper = document.getElementById('dynamic-wrapper');

        if (!mainSelect || !wrapper) return;

        mainSelect.addEventListener('change', async (e) => {
            this.handleDynamicDropdownChange(e, wrapper);
        });
    }

    setupTemplateActions() {
        const deactivateBtn = document.getElementById('deactivateTemplate');
        if (deactivateBtn) {
            deactivateBtn.addEventListener('click', (e) => {
                const confirmed = window.confirm(
                    'This will deactivate the template and all associated iframe links. Continue?'
                );

                if (!confirmed) {
                    e.preventDefault();
                    return; // user clicked "No"
                }

                this.deactivateTemplate(e); // user clicked "Yes"
            });
        }


        document.getElementById('preview')?.addEventListener('click', () => {
            this.previewTemplate();
        });

        document.getElementById('aboutTemplate')?.addEventListener('click', (e) => {
            e.stopPropagation();
            document.getElementById('aboutTemplateModal')?.classList.add('active');
            this.closeAllDropdowns();
        });

        document.getElementById('closeAboutTemplate')?.addEventListener('click', () => {
            document.getElementById('aboutTemplateModal')?.classList.remove('active');
        });
    }

    setupValidationListeners() {
        const fTypeselect = document.getElementById('fieldTypeSelect');
        const $QuestionName = $('#modal1-input');
        const $createBtnModel1 = $('#modal1-create-button');

        fTypeselect?.addEventListener('change', () => this.toggleQuestionValidation());
        $QuestionName?.on('input', () => this.toggleQuestionValidation());
        this.groupSelect?.addEventListener('change', () => this.toggleQuestionValidation());
        this.isRequiredCheckbox?.addEventListener('change', () => this.toggleQuestionValidation());

        const answersContainer = this.answersContainer;
        if (answersContainer) {
            // Use a MutationObserver to detect changes in answers
            const observer = new MutationObserver(() => {
                setTimeout(() => this.toggleQuestionValidation(), 100);
            });

            observer.observe(answersContainer, {
                childList: true,
                subtree: true,
                attributes: true,
                attributeFilter: ['data-main-select', 'data-answer-select', 'data-dynamic-select']
            });

            // Also listen for click events on answers (when they're edited)
            answersContainer.addEventListener('click', () => {
                setTimeout(() => this.toggleQuestionValidation(), 100);
            });
        }
        const $quoteTemplateModel2 = $('#quoteTemplate22');
        const $mainSelect2 = $('#mainSelect2');

        $quoteTemplateModel2?.on('input', () => this.toggleAnswerValidation());
        $mainSelect2?.on('change', () => this.toggleAnswerValidation());
        $(document).on('change', '.dynamic-select', () => this.toggleAnswerValidation());
    }

    setupResizeListener() {
        window.addEventListener('resize', () => this.handleResize());
    }

    checkForChanges() {
        const currentName = this.nameInput.value.trim();
        const currentDesc = this.descInput.value.trim();
        const nameChanged = currentName !== this.originalValues.name;
        const descChanged = currentDesc !== this.originalValues.desc;

        if ((nameChanged && currentName !== '') || (descChanged && currentDesc !== '')) {
            this.showSaveNotification();
        } else {
            this.hideSaveNotification();
        }
    }

    showSaveNotification() {
        const wrapper = document.querySelector('.notification-banner-nav-save');
        const logo = document.querySelector('.logo-block');

        if (wrapper) {
            wrapper.classList.toggle('mobile-only', window.innerWidth <= 768);
            wrapper.style.display = 'flex';

            if (window.innerWidth <= 768 && logo) {
                logo.classList.add('hidden');
            }
        }
    }

    hideSaveNotification() {
        const wrapper = document.querySelector('.notification-banner-nav-save');
        const logo = document.querySelector('.logo-block');

        if (wrapper) {
            wrapper.style.display = 'none';
            if (logo) logo.classList.remove('hidden');
        }
    }

    handleResize() {
        const wrapper = document.querySelector('.notification-banner-nav-save');
        const logo = document.querySelector('.logo-block');

        if (!wrapper) return;

        if (window.innerWidth > 768) {
            wrapper.classList.remove('mobile-only');
            if (logo && wrapper.style.display === 'none') {
                logo.classList.remove('hidden');
            }
        } else {
            if (wrapper.style.display === 'flex') {
                wrapper.classList.add('mobile-only');
                if (logo) logo.classList.add('hidden');
            }
        }
    }

    handleCreateQuestion() {
        const value = this.inputField2.value.trim();
        if (!value) return;

        if (this.questionManager.editingDiv2) {
            this.updateExistingQuestion(value);
        } else {
            this.questionManager.createNewQuestion(value, this.groupSelect, this.fieldTypeSelect, this.isRequiredCheckbox, this.answersContainer);
        }

        const modalHeading = this.modalOverlay.querySelector('.t1-pop-up-heading .bold-text');
        if (modalHeading) {
            modalHeading.textContent = "Add a new question";
        }

        this.inputField2.value = '';
        this.modalOverlay.querySelector('.cancel-button').textContent = 'Cancel';
        this.modalOverlay.classList.remove('active');
    }

    async updateExistingQuestion(value) {
        console.log('🔄🔄🔄 UPDATING EXISTING QUESTION - DEBUG START 🔄🔄🔄');

        // Ensure we have a version id first
        let templateVersionId;
        if (this.handleVersionChange) {
            templateVersionId = await this.handleVersionChange();
        }

        const templateData = document.getElementById('template-data');
        if (!templateVersionId) {
            templateVersionId = parseInt(templateData?.dataset.tempVersionId || '0', 10);
        }

        // Update UI and dataset
        const qEl = this.questionManager.editingDiv2;
        if (!qEl) {
            alert('No question selected to update.');
            return;
        }

        const mainSpan = qEl.querySelector('.main-value span');
        if (mainSpan) mainSpan.textContent = value;

        if (this.answersContainer.children.length <= 0) {
            document.getElementById('addbtnmodal1').classList.remove('overlay');
        } else {
            document.getElementById('addbtnmodal1').classList.add('overlay');
        }

        qEl.dataset.group = this.groupSelect.value;
        qEl.dataset.fieldType = this.fieldTypeSelect.value;
        qEl.dataset.isRequired = this.isRequiredCheckbox.checked.toString();

        // Build answers array (include deletions to persist removals)
        const answers = Array.from(this.answersContainer.children).map((answerDiv, index) => {
            const isDeleted = answerDiv.dataset.isDeleted === 'true';

            // 🔥 FIX: For answers, set Id to 0 for new version - backend will resolve from OptionGuid
            let answerId = 0;
            const optionGuid = answerDiv.dataset.optionGuid || '';

            // Only use ID if it's a brand new answer (no GUID yet)
            if (!optionGuid && answerDiv.dataset.id && parseInt(answerDiv.dataset.id) > 0) {
                answerId = parseInt(answerDiv.dataset.id);
            }

            return {
                Id: answerId,  // 🔥 Set to 0 - backend resolves from OptionGuid
                Text: answerDiv.querySelector('span')?.textContent || '',
                Order: parseInt(answerDiv.dataset.order || (index + 1), 10),
                SelectedOption: answerDiv.dataset.mainSelect || '',
                SelectedMatComId: answerDiv.dataset.dynamicSelect
                    ? parseInt(answerDiv.dataset.dynamicSelect, 10)
                    : null,
                SelectedQuestionsList: answerDiv.dataset.answerSelect
                    ? answerDiv.dataset.answerSelect
                        .split(',')
                        .map(id => parseInt(id, 10))
                        .filter(id => !isNaN(id))
                    : [],
                IsDeleted: isDeleted,
                OptionGuid: optionGuid,  // 🔥 This is the key - GUID persists across versions
                OptionStatus: (answerDiv.dataset.optionStatus ||
                    (isDeleted ? 'deleted' :
                        (optionGuid ? 'updated' : 'new')))  // 🔥 Use GUID to determine status
            };
        });

        try {
            // 🔥🔥🔥 CRITICAL FIX: Only use GroupGuid - NEVER send GroupId from DOM 🔥🔥🔥
            const selectedGroupName = this.groupSelect.value.trim();
            let groupGuid = '';

            // Find groupGuid by group name
            const groupContainers = document.querySelectorAll('.saved-txt.group-container, .saved-txt.stored-overlay');
            for (const g of groupContainers) {
                const nameSpan = g.querySelector('.main-value span');
                if (nameSpan && nameSpan.textContent.trim() === selectedGroupName) {
                    groupGuid = (g.dataset.groupGuid || '').trim();
                    if (groupGuid) break;
                }
            }

            // Fallback: check groupManager container
            if (!groupGuid && this.groupManager?.container) {
                const allGroups = this.groupManager.container.querySelectorAll('.saved-txt');
                for (const groupDiv of allGroups) {
                    const span = groupDiv.querySelector('.main-value span');
                    if (span && span.textContent.trim() === selectedGroupName) {
                        groupGuid = groupDiv.dataset.groupGuid || '';
                        if (groupGuid) break;
                    }
                }
            }

            // Fallback: check question-group-header
            if (!groupGuid) {
                const header = document.querySelector(`.question-group-header[data-group-name="${selectedGroupName}"]`);
                if (header && header.dataset.groupGuid) {
                    groupGuid = header.dataset.groupGuid;
                }
            }

            if (!groupGuid) {
                throw new Error(`Could not find GroupGuid for group: ${selectedGroupName}. Please ensure the group exists.`);
            }

            // Retrieve QuestionGuid robustly
            let questionGuid = qEl.dataset.questionGuid || qEl.getAttribute('data-question-guid') || '';
            if (!questionGuid || questionGuid === 'undefined') {
                const guidAttr = qEl.querySelector('[data-question-guid]');
                if (guidAttr) questionGuid = guidAttr.dataset.questionGuid || '';
            }

            // 🔥🔥🔥 CRITICAL: Set GroupId to 0 and QuestionId to 0 🔥🔥🔥
            // Backend MUST resolve the correct IDs from GUIDs + TemplateVersionId
            const questionData = {
                Id: 0,  // 🔥 Set to 0 - backend resolves from QuestionGuid + TemplateVersionId
                Text: value,
                GroupId: 0,  // 🔥 Set to 0 - backend resolves from GroupGuid + TemplateVersionId
                GroupGuid: groupGuid,  // 🔥 This persists across versions
                FieldTypeId: parseInt(this.fieldTypeSelect.value, 10),
                Order: parseInt(qEl.dataset.order || '1', 10),
                IsRequired: this.isRequiredCheckbox.checked,
                TemplateVersionId: templateVersionId,
                Answers: answers,
                QuestionGuid: questionGuid  // 🔥 This persists across versions
            };

            console.log('📤 Full payload (IDs=0, using GUIDs):', JSON.stringify(questionData, null, 2));

            const response = await fetch('/api/Template/CreateQuestion', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(questionData)
            });

            if (!response.ok) {
                const errorText = await response.text();
                // ✅ Check for circular dependency error
                if (errorText.includes('circular dependency') || errorText.includes('infinite loop')) {
                    throw new Error('Cannot save: This would create a circular dependency where questions depend on each other. Please remove the conflicting dependency first.');
                }
                throw new Error('Failed to update question: ' + errorText);
            }

            const result = await response.json();

            // 🔥 Update DOM with new IDs from server response
            if (result.questionId) {
                qEl.dataset.id = result.questionId;
                qEl.dataset.originalId = result.questionId;
            }
            if (result.questionGuid) {
                qEl.dataset.questionGuid = result.questionGuid;
                qEl.setAttribute('data-question-guid', result.questionGuid);
            }

            // Update answer IDs/OptionGuid from server
            if (result.answers && Array.isArray(result.answers)) {
                Array.from(this.answersContainer.children).forEach(answerDiv => {
                    if (answerDiv.dataset.isDeleted === 'true') return;

                    const text = answerDiv.querySelector('span')?.textContent.trim();
                    const optGuid = answerDiv.dataset.optionGuid;

                    // Match by OptionGuid first, then by text+order
                    const match = result.answers.find(a => {
                        if (optGuid && (a.optionGuid === optGuid || a.OptionGuid === optGuid)) {
                            return true;
                        }
                        const order = parseInt(answerDiv.dataset.order || '0', 10);
                        return (a.text === text || a.Text === text) &&
                            (a.order === order || a.Order === order);
                    });

                    if (match) {
                        const dbId = match.id || match.Id || 0;
                        if (dbId > 0) {
                            answerDiv.dataset.id = dbId;
                            answerDiv.dataset.originalId = dbId;
                            delete answerDiv.dataset.tempId;
                        }
                        if (match.optionGuid || match.OptionGuid) {
                            answerDiv.dataset.optionGuid = match.optionGuid || match.OptionGuid;
                        }
                    }
                });
            }

            // Re-materialize visible answers under the question element
            if (this.questionManager.saveAnswersToQuestionElement) {
                this.questionManager.saveAnswersToQuestionElement(qEl, this.answersContainer);
            }

            this.questionManager.editingDiv2 = null;
            console.log('✅ Question updated.');
        } catch (error) {
            console.error('❌ Update question error:', error);
            alert(`Failed to update question: ${error.message}`);
        }
    }
    handleCreateAnswer() {
        const inputField = document.getElementById('quoteTemplate22');
        const value = this.normalize(inputField.value);
        if (!value) return;

        const mainSelect = document.getElementById('mainSelect2');
        const answerSelect = document.getElementById('answerSelect');
        const dynamicSelectWrapper = document.getElementById('dynamic-wrapper')
            ?.nextElementSibling?.querySelector('.dynamic-select')?.value;

        if (this.answerManager.editingDiv) {
            this.updateExistingAnswer(value, mainSelect, answerSelect, dynamicSelectWrapper);
        } else {
            this.answerManager.createNewAnswer(value, mainSelect, answerSelect, dynamicSelectWrapper);
        }

        const modalHeading2 = this.modalOverlay2.querySelector('.t1-pop-up-heading .bold-text');
        if (modalHeading2) {
            modalHeading2.textContent = "Add a new answer";
        }

        // Hide delete button after creating
        const deleteButton4 = this.modalOverlay2.querySelector('#modal-delete-button4');
        if (deleteButton4) deleteButton4.classList.add('hidden');

        inputField.value = '';
        this.modalOverlay2.querySelector('#cancel-button4').textContent = 'Cancel';
        this.modalOverlay.classList.add('active', 'no-transition');
        this.modalOverlay2.classList.remove('active');
        document.getElementById('addbtnmodal1').classList.add('overlay');
    }

    updateExistingAnswer(value, mainSelect, answerSelect, dynamicSelectWrapper) {
        const oldValue = this.normalize(this.answerManager.editingDiv.dataset.originalValue);
        const oldMain = this.normalize(this.answerManager.editingDiv.dataset.originalMain);
        const oldAnswer = this.normalize(this.answerManager.editingDiv.dataset.originalAnswer);
        const oldDynamic = this.normalize(this.answerManager.editingDiv.dataset.originalDynamic);

        const newMain = this.normalize(mainSelect.value);
        const newAnswer = this.normalize(answerSelect.value);
        const newDynamic = this.normalize(dynamicSelectWrapper);
        this.answerManager.editingDiv.dataset.optionStatus = 'updated';

        const hasChanged = value !== oldValue || newMain !== oldMain || newAnswer !== oldAnswer || newDynamic !== oldDynamic;

        if (hasChanged) {
            this.answerManager.editingDiv.querySelector('span').textContent = value;
            this.answerManager.editingDiv.dataset.mainSelect = newMain;
            this.answerManager.editingDiv.dataset.answerSelect = newAnswer;
            this.answerManager.editingDiv.dataset.dynamicSelect = newDynamic;
            this.handleVersionChange();
        }

        // Ensure button returns to Create on close of modal2
        const createButton4 = document.getElementById('create-button4');
        if (createButton4) createButton4.textContent = 'Create';
        this.answerManager.editingDiv = null;
        }
    handleModal1Cancel(){
        this.modalOverlay.classList.remove('active');

        const modalHeading = this.modalOverlay.querySelector('.t1-pop-up-heading .bold-text');
        if (modalHeading) {
            modalHeading.textContent = "Add a new question";
        }

        const cancelButton = this.modalOverlay.querySelector('.cancel-button');
        cancelButton.classList.remove('delete-button');

        if (this.questionManager.editingDiv2) {
            if (!this.questionManager.editingDiv2.dataset.id || this.questionManager.editingDiv2.dataset.id === "0") {
                this.questionManager.editingDiv2.remove();
                this.questionManager.editingDiv2 = null;
                this.questionManager.updateQuestionOrders();

                const groupName = this.groupSelect.value;
                this.groupManager.updateGroupAddButtonOverlay(groupName);
                this.questionManager.updateAllQuestionGroupCorners();

                // this.showSaveNotification();
                this.handleVersionChange();
            }
        }

        // Restore any deleted answers if canceling
        if (this.answersContainer) {
            Array.from(this.answersContainer.children).forEach(answerDiv => {
                if (answerDiv.dataset.isDeleted === 'true') {
                    answerDiv.dataset.isDeleted = 'false';
                    answerDiv.style.display = '';
                }
            });
        }

        this.inputField2.value = '';
        this.answersContainer.innerHTML = '';
        this.modalOverlay.querySelector('.cancel-button').textContent = 'Cancel';
        this.isRequiredCheckbox.checked = false;
        this.groupManager.updateRoundedCornersGeneric(this.answersContainer);
    }

    handleModal2Cancel() {
        this.modalOverlay.classList.add('active', 'no-transition');
        this.modalOverlay2.classList.remove('active');

        const modalHeading2 = this.modalOverlay2.querySelector('.t1-pop-up-heading .bold-text');
        if (modalHeading2) {
            modalHeading2.textContent = "Add a new answer";
        }
        const createButton4 = document.getElementById('create-button4');
        if (createButton4) {
            createButton4.textContent = 'Create';
        }
        this.answerManager.editingDiv = null;

        const cancelButton4 = this.modalOverlay2.querySelector('#cancel-button4');
        cancelButton4.classList.remove('delete-button');
        cancelButton4.textContent = 'Cancel';

        // Hide delete button when canceling
        const deleteButton4 = this.modalOverlay2.querySelector('#modal-delete-button4');
        if (deleteButton4) deleteButton4.classList.add('hidden');

        if (this.answerManager.editingDiv) {
            // Restore answer if it was marked for deletion
            const answerDiv = this.answerManager.editingDiv;
            if (answerDiv.dataset.isDeleted === 'true') {
                answerDiv.dataset.isDeleted = 'false';
                answerDiv.style.display = '';
            }
            this.answerManager.editingDiv = null;
            this.answerManager.updateAnswerOrders();
            this.groupManager.updateRoundedCornersGeneric(this.answersContainer);
        }

        if (this.answersContainer.children.length === 0) {
            document.querySelector('.btn-add-text').textContent = 'Add answer';
            document.getElementById('addbtnmodal1').classList.remove('overlay');
        }

        document.getElementById('quoteTemplate22').value = '';
        this.modalOverlay2.querySelector('#cancel-button4').textContent = 'Cancel';
    }

    closeAnswerModal() {
        this.modalOverlay.classList.add('active', 'no-transition');
        document.getElementById('quoteTemplate22').value = '';

        const modalHeading2 = this.modalOverlay2.querySelector('.t1-pop-up-heading .bold-text');
        if (modalHeading2) {
            modalHeading2.textContent = "Add a new answer";
        }
        const createButton4 = document.getElementById('create-button4');
        if (createButton4) {
            createButton4.textContent = 'Create';
        }
        this.answerManager.editingDiv = null;

        const cancelButton4 = this.modalOverlay2.querySelector('#cancel-button4');
        cancelButton4.classList.remove('delete-button');
        cancelButton4.textContent = 'Cancel';


        // Hide delete button when closing
        const deleteButton4 = this.modalOverlay2.querySelector('#modal-delete-button4');
        if (deleteButton4) deleteButton4.classList.add('hidden');

        this.modalOverlay2.classList.remove('active');
    }

    async handleDynamicDropdownChange(event, wrapper) {
        const next = wrapper.nextElementSibling;
        if (next && next.classList.contains('dynamic-dropdown')) {
            next.remove();
        }

        const value = event.target.value;
        if (value === 'Material' || value === 'Component') {
            const newDropdown = await this.createDropdown(value);
            wrapper.insertAdjacentElement('afterend', newDropdown);
            this.toggleAnswerValidation();
        }
    }

    async createDropdown(type) {
        if (!type || (type !== 'Material' && type !== 'Component')) {
            console.error('Invalid type provided to createDropdown:', type);
            return null;
        }

        const container = document.createElement('div');
        container.classList.add('dynamic-dropdown');

        const label = document.createElement('h2');
        label.classList.add('section-subheading');
        label.innerText = `Select ${type.toLowerCase()}`;

        const divWrapper = document.createElement('div');
        divWrapper.classList.add('section-input-wrapper');

        const select = document.createElement('select');
        select.classList.add('section-input', 'selectt', 'dynamic-select');

        try {
            const data = await this.loadOptions(type);

            const defaultOption = document.createElement('option');
            defaultOption.textContent = `Select ${type.toLowerCase()}`;
            defaultOption.value = '';
            select.appendChild(defaultOption);

            if (data && Array.isArray(data)) {
                data.forEach(item => {
                    const option = document.createElement('option');
                    option.value = item.value || item.id;
                    option.textContent = item.text || item.name;
                    select.appendChild(option);
                });
            }

            divWrapper.appendChild(select);
            container.appendChild(label);
            container.appendChild(divWrapper);

            select.addEventListener('change', () => this.toggleAnswerValidation());

            return container;
        } catch (error) {
            console.error('Failed to create dropdown:', error);
            return container;
        }
    }

    async loadOptions(type) {
        if (!type) return [];

        const url = type === 'Component'
            ? '/api/Question/GetComponents'
            : '/api/Question/GetMaterials';

        try {
            const response = await fetch(url);
            if (!response.ok) {
                console.error('Failed to load options:', response.status, response.statusText);
                return [];
            }
            return await response.json();
        } catch (error) {
            console.error('Network error loading options:', error);
            return [];
        }
    }

    makeDraggable(element, container) {
        element.draggable = true;

        element.addEventListener('dragstart', (e) => {
            e.dataTransfer.setData('text/plain', null);
            element.classList.add('dragging');
            this.groupManager.updateRoundedCorners();
        });

        element.addEventListener('dragend', () => {
            element.classList.remove('dragging');
            this.groupManager.updateGroupOrders();
            this.groupManager.updateRoundedCorners();
        });

        element.addEventListener('dragover', (e) => {
            e.preventDefault();
            const dragging = container.querySelector('.dragging');
            if (!dragging || dragging === element) return;

            const allItems = Array.from(container.querySelectorAll('.saved-txt'));
            const currentIndex = allItems.indexOf(element);
            const draggingIndex = allItems.indexOf(dragging);

            if (draggingIndex < currentIndex) {
                container.insertBefore(dragging, element.nextSibling);
            } else {
                container.insertBefore(dragging, element);
            }
            this.groupManager.updateRoundedCorners();
        });
    }


    // Replace the ENTIRE deactivateTemplate method in FormBuilder class:
    async deactivateTemplate(e) {
        e.stopPropagation();

        const templateData = document.getElementById('template-data');
        const tempVersionId = templateData?.dataset.tempVersionId || 0;

        try {
            const response = await fetch('/api/Template/ToggleActive', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ templateVersionId: Number(tempVersionId) })
            });

            if (!response.ok) throw new Error('Failed to update template status');

            const result = await response.json();
            if (result.success) {
                // Update UI without reloading
                updateTemplateStatusUI(result.isActive);

                // Optional: Show success message
                alert(`Template ${result.isActive ? 'activated' : 'deactivated'} successfully!`);
            }
        } catch (error) {
            console.error('Error:', error);
            alert('Failed to update template status');
        }
    }


    previewTemplate() {
        const templateVersionId =
            document.getElementById('template-data')?.dataset.tempVersionId;

        if (!templateVersionId || templateVersionId === '0') {
            alert('Please save template before preview');
            return;
        }

        window.open(
            `/page/template/preview/${templateVersionId}`,
            '_blank'
        );
    }



    saveForm() {
        // ✅ FIX: Get fresh values from input fields directly
        const nameInput = document.getElementById('templateName');
        const descInput = document.getElementById('templateDes');
        const templateData = document.getElementById('template-data');

        const name = nameInput?.value?.trim() || '';
        const description = descInput?.value?.trim() || '';
        const templateVersionId = parseInt(templateData?.dataset.tempVersionId || '0', 10);

        // ✅ FIX: Validate required fields BEFORE exportData
        if (!name) {
            alert('Template name is required.');
            nameInput?.focus();
            return;
        }

        if (!templateVersionId || templateVersionId <= 0) {
            alert('Template version ID is missing. Please refresh the page.');
            return;
        }

        const data = this.exportData();

        // ✅ FIX: Double-check the exported data has correct values
        if (!data.Template.name || data.Template.name !== name) {
            console.warn('⚠️ Fixing stale name in exported data');
            data.Template.name = name;
        }
        if (data.Template.description !== description) {
            data.Template.description = description;
        }

        this.ajaxSaveForm('SaveTemplate', data);
    }

    async handleVersionChange() {
        const templateData = document.getElementById('template-data');
        const currentId = parseInt(templateData?.dataset.tempVersionId || '0', 10) || 0;

        if (window.versionControl && typeof window.versionControl.requestVersionIfNeeded === 'function') {
            const newId = await window.versionControl.requestVersionIfNeeded();
            const effectiveId = newId || currentId;

            if (templateData && effectiveId && effectiveId > 0) {
                templateData.dataset.tempVersionId = String(effectiveId);
                templateData.dataset.templateVersionId = String(effectiveId);
            }

            return effectiveId;
        }

        return currentId;
    }



    exportData() {
        const templateData = document.getElementById('template-data');

        // ✅ FIX: Parse templateVersionId as integer, not string
        const templateVersionId = parseInt(
            templateData?.dataset.tempVersionId ||
            templateData?.dataset.templateVersionId ||
            '0',
            10
        );

        // ✅ FIX: Get fresh values from input fields
        const nameInput = document.getElementById('templateName');
        const descInput = document.getElementById('templateDes');

        const template = {
            templateVersionId: templateVersionId,  // ✅ Now an integer
            name: nameInput?.value?.trim() || '',
            description: descInput?.value?.trim() || ''
        };

        // ✅ FIX: Validate that name is not empty
        if (!template.name) {
            console.error('❌ Template name is empty!');
        }

        const templateVersion = {
            tempVersion: parseInt(
                document.getElementById('latestVersionHolder')?.value || '1',
                10
            )
        };

        const isNewTemplate = templateData?.dataset.isNewTemplate === 'true';

        const groups = Array.from(this.container?.querySelectorAll('.saved-txt') || []).map(g => ({
            id: parseInt(g.dataset.id || '0', 10),
            order: parseInt(g.dataset.order || '0', 10),
            name: g.querySelector('span')?.textContent?.trim() || ''
        }));

        const questions = this.questionsList ?
            Array.from(this.questionsList.querySelectorAll('.saved-txt:not(.sub-value)')).map(q => {
                const answers = Array.from(q.querySelectorAll('.sub-value')).map((a, idx) => ({
                    id: parseInt(a.dataset.id || '0', 10),
                    order: parseInt(a.dataset.order || '0', 10) || idx + 1,
                    option: a.querySelector('span')?.textContent?.trim() || '',
                    selectedOption: a.dataset.mainSelect || '',
                    SelectedMatComId: parseInt(a.dataset.dynamicSelect || '0', 10) || 0,
                    SelectedQuestionsList: (a.dataset.answerSelect ? a.dataset.answerSelect.split(',').filter(id => id.trim()) : [])
                }));

                return {
                    id: parseInt(q.dataset.id || '0', 10),
                    order: parseInt(q.dataset.order || '0', 10),
                    questionText: q.querySelector('.main-value span')?.textContent?.trim() || '',
                    questionGroup: q.dataset.group || '',
                    fieldTypeId: parseInt(q.dataset.fieldType || '1', 10),
                    IsRequired: q.dataset.isRequired === 'true',
                    answers: answers
                };
            }) : [];

        // ✅ DEBUG: Log the data being exported
        console.log('📦 exportData() - Template object:', template);
        console.log('📦 exportData() - Name:', template.name);
        console.log('📦 exportData() - Description:', template.description);

        return {
            Template: template,
            TemplateVersion: templateVersion,
            QuestionGroups: groups,
            QuestionAnswers: questions,
            IsNewTemplate: isNewTemplate
        };
    }

    ajaxSaveForm(action, data) {
        // ✅ FIX: Validate data before sending
        if (!data.Template || !data.Template.name) {
            console.error('❌ VALIDATION ERROR: Template name is missing!');
            console.error('Data object:', data);
            alert('Template name is required. Please enter a name and try again.');
            return;
        }

        console.log('📤 FRONTEND PAYLOAD →', {
            action,
            data: JSON.parse(JSON.stringify(data))
        });

        // ✅ FIX: Ensure templateVersionId is a number
        if (typeof data.Template.templateVersionId === 'string') {
            data.Template.templateVersionId = parseInt(data.Template.templateVersionId, 10);
        }

        $.ajax({
            url: `/api/Template/${action}`,
            type: 'POST',
            contentType: 'application/json',
            data: JSON.stringify(data),
            dataType: 'json',
            success: (response) => {
                if (response.success && response.isPreviewPage) {
                    this.hideSaveNotification();
                    window.open(response.redirectUrl, '_blank');
                } else if (response.success && action === 'SaveTemplate') {
                    this.handleSaveSuccess(response);
                } else {
                    window.location.href = response.redirectUrl;
                }
            },
            error: (xhr) => {
                console.error('❌ Backend error:', xhr.status, xhr.responseText);

                // ✅ FIX: Show more helpful error message
                let errorMessage = 'Failed to save template. Please try again.';
                try {
                    const errorData = JSON.parse(xhr.responseText);
                    if (errorData.message) {
                        errorMessage = errorData.message;
                    }
                } catch (e) { }

                alert(errorMessage);
            }
        });
    }

    // ✅ Add this new method to handle save success
    handleSaveSuccess(response) {
        // Hide the save notification banner
        this.hideSaveNotification();

        // Update template data on the page without redirect
        const templateData = document.getElementById('template-data');
        if (templateData && response.templateVersionId) {
            templateData.dataset.tempVersionId = response.templateVersionId;
            templateData.dataset.templateVersionId = response.templateVersionId;

            // Update the version in the UI if provided
            if (response.versionNumber) {
                const versionBtn = document.getElementById('versionDropdownBtn');
                if (versionBtn) {
                    versionBtn.textContent = `Version ${response.versionNumber}`;
                }
            }
        }

        // Update original values to prevent showing save notification again
        this.originalValues.name = this.nameInput.value.trim();
        this.originalValues.desc = this.descInput.value.trim();

        // Reset version call counter if needed
        this.versionCall = 0;

        console.log('Template saved successfully, staying on page');
    }

    

    hydrateExistingData() {
        this.hydrateExistingGroups();
        this.hydrateExistingQuestions();
        this.groupManager.updateWrapperStyles();
    this.groupManager.updateRoundedCorners();
    this.determineAndSetTemplateNewStatus();
    }

    hydrateExistingGroups() {
        const groups = this.container?.querySelectorAll('.saved-txt');
        groups?.forEach(g => {
            const name = g.querySelector('.main-value span')?.textContent?.trim() || '';
            if (name) this.groupManager.addGroupOption(name);
            this.groupManager.renderSavedGroup(g, name);
            this.makeDraggable(g, this.container);
        });

        this.groupManager.updateGroupOrders();
        this.groupManager.updateRoundedCorners();
    }

    hydrateExistingQuestions() {
        if (!this.questionsList) return;

        const existingQuestions = this.questionsList.querySelectorAll('.saved-txt:not(.sub-value)');
        existingQuestions.forEach(q => {
            // ✅ FIX: Ensure dataset.questionGuid is set from attribute if present
            const attrGuid = q.getAttribute('data-question-guid');
            if (attrGuid && attrGuid !== 'undefined' && attrGuid !== '') {
                q.dataset.questionGuid = attrGuid;
                console.log('✅ Hydrated question with GUID:', attrGuid, 'Text:', q.querySelector('.main-value span')?.textContent);
            } else {
                console.warn('⚠️ Question missing GUID during hydration:', q.querySelector('.main-value span')?.textContent);
            }

            // ✅ FIX: Also hydrate answer GUIDs
            const subValues = q.querySelectorAll('.sub-value');
            subValues.forEach(sv => {
                const optGuid = sv.getAttribute('data-option-guid');
                if (optGuid && optGuid !== 'undefined' && optGuid !== '') {
                    sv.dataset.optionGuid = optGuid;
                    sv.dataset.answerGuid = optGuid;
                }
                // Ensure questionGuid is propagated to answers
                if (q.dataset.questionGuid) {
                    sv.dataset.questionGuid = q.dataset.questionGuid;
                }
            });

            this.makeDraggable(q, this.questionsList);
            this.questionManager.wireQuestion(q);
        });

        this.questionManager.updateAllQuestionGroupCorners();

        document.querySelectorAll('.group-add-button').forEach(buttonWrapper => {
            const groupName = buttonWrapper.dataset.groupName;
            this.groupManager.updateGroupAddButtonOverlay(groupName);
        });

        this.questionManager.updateQuestionOrders();
    }

    normalize(value){
        if (!value || value === '[]' || value === 'Select') return '';
        return value.toString().trim();
    }
}


// ================== Initialization Functions ==================

function initializeBuilder() {
    console.log("=== initializeBuilder() called ===");

    // Check if already initialized
    if (window.formBuilderInstance) {
        console.warn("FormBuilder already initialized, returning existing instance");
        return window.formBuilderInstance;
    }

    console.trace("Stack trace for initializeBuilder call");

    // Move modals to body if needed
    appendModalsToLayoutBody();

    // Initialize the form builder and store the instance
    window.formBuilderInstance = new FormBuilder();
    return window.formBuilderInstance;
}

function appendModalsToLayoutBody() {
    const modal = document.querySelector('.modal-overlay');
    const answerModal = document.getElementById('ModalOverLay2');
    const aboutTemplate = document.getElementById('aboutTemplateModal');

    if (modal) document.body.appendChild(modal);
    if (answerModal) document.body.appendChild(answerModal);
    if (aboutTemplate) document.body.appendChild(aboutTemplate);
}
function updateTemplateStatusUI(isActive) {
    const textEl = document.getElementById('deactivateTemplate');
    const iconEl = document.getElementById('templateStatusIcon');

    if (!textEl || !iconEl) return;

    if (isActive) {
        // DEACTIVATE
        textEl.innerText = 'Deactivate Template';
    } else {
        // ACTIVATE
        textEl.innerText = 'Activate Template';

        iconEl.innerHTML = `
            <polyline points="4 10 8 14 16 6"></polyline>
        `;
    }
}
window.BaseBuilder = window.BaseBuilder || BaseBuilder;

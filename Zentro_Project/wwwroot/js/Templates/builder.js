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
                TemplateVersionId: templateVersionId
            };

            const response = await fetch('/api/Template/CreateGroup', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(groupData)
            });

            const result = await this.parseResponse(response);

            savedWrapper.dataset.id = result.groupId;
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
        wrapper.classList.remove('editing-wrapper');
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

        wrapper.onclick = (e) => {
            if (e.target.tagName.toLowerCase() === 'button') return;
            this.renderEditGroup(wrapper, value);
        };
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

    async deleteGroup(wrapper, groupName, groupId) {
        if (groupId && confirm('Are you sure you want to delete this group?')) {
            try {
                const response = await fetch(`/api/Template/DeleteGroup/${groupId}`, { method: 'DELETE' });
                const result = await response.json();
                if (!response.ok || !result.success) throw new Error('Failed to delete group from server.');
            } catch (error) {
                console.error('Error deleting group:', error);
                alert('Error deleting group. Please try again.');
                return;
            }
        }

        this.removeGroupOption(groupName);
        wrapper.remove();
        this.updateGroupOrders();
        this.updateWrapperStyles();
        this.updateRoundedCorners();
        this.removeQuestionGroupStructure(groupName);
        this.updateGroupAddButtonOverlay(groupName);
    }

    async updateGroup(wrapper, oldValue, newValue, groupId) {
        if (!newValue) return;

        if (newValue === oldValue) {
            this.renderSavedGroup(wrapper, newValue);
            return;
        }

        try {
            if (groupId) {
                const templateData = document.getElementById('template-data');
                const templateVersionId = parseInt(templateData?.dataset.tempVersionId || 0);
                const updateData = { Id: parseInt(groupId), Name: newValue, Order: parseInt(wrapper.dataset.order || 1), TemplateVersionId: templateVersionId };

                const response = await fetch('/api/Template/CreateGroup', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(updateData)
                });

                const result = await response.json();
                if (!response.ok || !result.success) throw new Error('Failed to update group.');
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

    saveAnswersToQuestionElement(questionElement, answersSource) {
        console.log('Question ID:', questionElement.dataset.id);

        const existingSubValues = questionElement.querySelectorAll('.sub-value');
        console.log('Existing sub-values count:', existingSubValues.length);

        const answerNodes = Array.isArray(answersSource) ? answersSource : Array.from(answersSource.children || []);

        answerNodes.forEach((answerDiv, index) => {
            console.log(`Processing answer ${index + 1}:`);
            console.log('  - Text:', answerDiv.querySelector('span')?.textContent);
            console.log('  - dataset.id:', answerDiv.dataset.id);
            console.log('  - dataset.originalId:', answerDiv.dataset.originalId);
            console.log('  - dataset.tempId:', answerDiv.dataset.tempId);
            const subWrapper = document.createElement('div');
            subWrapper.className = 'saved-txt stored-overlay sub-value';

            // 🔥🔥🔥 FIX #1: ALWAYS USE REAL DATABASE ID WHEN AVAILABLE
            const dbId = answerDiv.dataset.id; // Get the ID directly
            const originalId = answerDiv.dataset.originalId; // Get original ID if exists

            // Store the REAL database ID
            if (dbId && parseInt(dbId) > 0) {
                subWrapper.dataset.id = dbId;
            } else if (originalId && parseInt(originalId) > 0) {
                subWrapper.dataset.id = originalId;
            } else {
                subWrapper.dataset.id = answerDiv.dataset.tempId || '';
            }

            // 🔥🔥🔥 FIX #2: ALWAYS STORE ORIGINALID FROM DATABASE
            if (dbId && parseInt(dbId) > 0) {
                subWrapper.dataset.originalId = dbId;
            } else if (originalId && parseInt(originalId) > 0) {
                subWrapper.dataset.originalId = originalId;
            }

            subWrapper.dataset.mainSelect = answerDiv.dataset.mainSelect || '';

            // Copy ALL data attributes
            Object.keys(answerDiv.dataset).forEach(key => {
                if (answerDiv.dataset[key] !== undefined && answerDiv.dataset[key] !== '') {
                    subWrapper.dataset[key] = answerDiv.dataset[key];
                }
            });

            subWrapper.dataset.answerSelect = answerDiv.dataset.answerSelect || '';
            subWrapper.dataset.dynamicSelect = answerDiv.dataset.dynamicSelect || '';
            subWrapper.dataset.order = answerDiv.dataset.order || (index + 1);
            //propagate OptionStatus
            subWrapper.dataset.optionStatus = answerDiv.dataset.optionStatus || subWrapper.dataset.optionStatus || '';

            subWrapper.innerHTML = `<span>${answerDiv.querySelector('span') ? answerDiv.querySelector('span').textContent : ''}</span>`;

            questionElement.appendChild(subWrapper);
        });
    }

    async createNewQuestion(value, groupSelect, fieldTypeSelect, isRequiredCheckbox, answersContainer) {
        const savedWrapper = document.createElement('div');
        savedWrapper.className = 'saved-txt stored-overlay';

        savedWrapper.dataset.group = groupSelect.value;
        savedWrapper.dataset.fieldType = fieldTypeSelect.value;
        savedWrapper.dataset.isRequired = isRequiredCheckbox.checked.toString();

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
                const optionGuid = answerDiv.dataset.optionGuid || answerDiv.dataset.answerGuid || answerDiv.dataset.answerGuid || '';
                return {
                    Id: answerId,
                    Text: answerDiv.querySelector('span') ? answerDiv.querySelector('span').textContent : '',
                    Order: parseInt(answerDiv.dataset.order || (index + 1)),
                    SelectedOption: answerDiv.dataset.mainSelect || '',
                    SelectedMatComId: answerDiv.dataset.dynamicSelect ? parseInt(answerDiv.dataset.dynamicSelect) : null,
                    SelectedQuestionsList: selectedQuestionIds,  // This is what goes to DB
                    IsDeleted: answerDiv.dataset.isDeleted === 'true',
                    OptionGuid: optionGuid
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

            if (groupElement && groupElement.textContent.includes(groupName)) {
                const groupWrapper = groupElement.closest('.saved-txt');
                groupId = parseInt(groupWrapper?.dataset.id || '0');
            }

            if (!groupId || groupId <= 0) {
                const groupsContainer = document.querySelector('.section-box');
                if (groupsContainer) {
                    const allGroups = groupsContainer.querySelectorAll('.saved-txt');
                    for (const groupDiv of allGroups) {
                        const span = groupDiv.querySelector('span');
                        if (span && span.textContent.includes(groupName)) {
                            groupId = parseInt(groupDiv.dataset.id || '0');
                            break;
                        }
                    }
                }
            }

            if (!groupId || groupId <= 0) {
                throw new Error(`Could not find group ID for group: ${groupName}. Please make sure the group is saved first.`);
            }

            const questionData = {
                Id: 0,
                Text: value,
                GroupId: groupId,
                FieldTypeId: parseInt(fieldTypeSelect.value),
                Order: parseInt(savedWrapper.dataset.order),
                IsRequired: isRequiredCheckbox.checked,
                TemplateVersionId: templateVersionId,
                Answers: answers,
                QuestionGuid: savedWrapper.dataset.questionGuid || ''
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
            console.log('builder called create question', questionData.QuestionGuid);


            const responseText = await response.text();
            let result;
            try {
                result = JSON.parse(responseText);
            } catch (parseError) {
                throw new Error('Server returned invalid response');
            }

            if (response.ok && result.success !== false) {
                savedWrapper.dataset.id = result.questionId;

                // 🔥🔥🔥 CRITICAL FIX: Update answer DIVs with REAL database IDs from server response
                
                if (Array.isArray(result.answers)) {
                    const answerDivs = modalAnswersContainer ? Array.from(modalAnswersContainer.children) : [];
                    const modalAnswerDivs = this.answersContainer ? Array.from(this.answersContainer.children) : [];
                    const allAnswerDivs = [...answerDivs, ...modalAnswerDivs];

                    result.answers.forEach((serverAnswer, index) => {
                        // Normalize server fields (support both lower- and upper-case keys)
                        const serverText = serverAnswer.text ?? serverAnswer.Text ?? '';
                        const serverOrder = serverAnswer.order ?? serverAnswer.Order ?? (index + 1);
                        const serverId = serverAnswer.id ?? serverAnswer.Id ?? 0;

                        // Find matching answer div by text and order (defensive)
                        const matchingDiv = allAnswerDivs.find(div => {
                            const span = div.querySelector('span');
                            const divText = span ? span.textContent.trim() : '';
                            const divOrder = parseInt(div.dataset.order || '0', 10);
                            return divText === serverText && (divOrder === serverOrder || Math.abs(divOrder - serverOrder) <= 1);
                        });

                        if (matchingDiv && serverId > 0) {
                            matchingDiv.dataset.id = serverId;
                            matchingDiv.dataset.originalId = serverId; // backup
                            // preserve optionGuid if provided
                            if (serverAnswer.optionGuid || serverAnswer.OptionGuid) {
                                matchingDiv.dataset.optionGuid = serverAnswer.optionGuid || serverAnswer.OptionGuid;
                            }
                            console.log(`✅ Updated answer "${serverText}" with database ID: ${serverId}`);
                        } else {
                            console.log(`❌ No match found for server answer "${serverText}" (order ${serverOrder})`);
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
                if (confirm('Are you sure you want to delete this question?')) {
                    try {
                        const questionId = parseInt(savedWrapper.dataset.id || '0');
                        if (questionId > 0) {
                            const response = await fetch(`/api/Template/DeleteQuestion/${questionId}`, {
                                method: 'DELETE',
                                headers: {
                                    'Content-Type': 'application/json',
                                    'Accept': 'application/json'
                                }
                            });

                            if (!response.ok) {
                                throw new Error('Failed to delete question');
                            }

                            // Optional: Parse response
                            const result = await response.json();
                            if (!result.success) {
                                throw new Error(result.message || 'Failed to delete question');
                            }
                        }

                        savedWrapper.remove();
                        this.updateQuestionOrders();
                        this.updateAllQuestionGroupCorners();
                        this.modalOverlay.classList.remove('active');
                        this.updateGroupAddButtonOverlay(savedWrapper.dataset.group);

                        // Reset editing state
                        this.editingDiv2 = null;

                        // Show save notification
                        if (this.showSaveNotification) this.showSaveNotification();
                        if (this.handleVersionChange) this.handleVersionChange();

                    } catch (error) {
                        alert(`Failed to delete question: ${error.message}`);
                    }
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

        // Get all questions
        const allQuestions = Array.from(
            this.questionsList.querySelectorAll('.saved-txt.stored-overlay:not(.sub-value)')
        );

        console.log('DEBUG: Total questions found:', allQuestions.length);
        console.log('DEBUG: Looking for group:', currentGroup);

        // Filter questions from the current group
        const groupQuestions = allQuestions.filter(q => {
            const hasGroup = q.dataset.group === currentGroup;
            const hasText = q.querySelector('.main-value span')?.textContent || '';
            const isCurrentQuestion = hasText === currentQuestionText;

            console.log(`DEBUG - Question: ${hasText}, Group: ${q.dataset.group}, IsCurrent: ${isCurrentQuestion}`);

            return hasGroup && !isCurrentQuestion;
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

        if (createButton4) createButton4.classList.add('btn-disable');
        if (modal1CreateButton) modal1CreateButton.classList.remove('btn-disable');

        // Remove dynamic dropdown if exists
        const dynamicDropdownWrapper = document.getElementById('dynamic-wrapper')
            ?.nextElementSibling?.querySelector('.section-input-wrapper')?.parentElement;
        if (dynamicDropdownWrapper) dynamicDropdownWrapper.remove();

        this.editingDiv = null;
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

        const dynamicSelectEl = document.querySelector('#dynamicSelect2');
        savedWrapper.dataset.dynamicSelect = dynamicSelectEl ? dynamicSelectEl.value : '';
        savedWrapper.dataset.tempId = 'temp_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);

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
        console.log('=== Answer Div Element ===');
        console.log('Element:', answerDiv);
        console.log('Class:', answerDiv.className);

        console.log('=== Dataset Properties ===');
        for (let key in answerDiv.dataset) {
            console.log(`  ${key}: "${answerDiv.dataset[key]}" (type: ${typeof answerDiv.dataset[key]})`);
        }

        console.log('=== Specific Important Values ===');
        console.log('1. answerSelect:', answerDiv.dataset.answerSelect);
        console.log('2. id:', answerDiv.dataset.id);
        console.log('3. originalId:', answerDiv.dataset.originalId);
        console.log('4. tempId:', answerDiv.dataset.tempId);
        console.log('5. mainSelect:', answerDiv.dataset.mainSelect);
        if (answerDiv.dataset.id && !answerDiv.dataset.id.startsWith('temp_')) {
            console.log('✅ This is a SAVED answer from database with ID:', answerDiv.dataset.id);
        } else if (answerDiv.dataset.tempId) {
            console.log('⚠️ This is a TEMPORARY answer with tempId:', answerDiv.dataset.tempId);
        } else {
            console.log('❓ Unknown answer type - no ID found');
        }

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


        // Load answer text
        document.getElementById('quoteTemplate22').value =
            answerDiv.querySelector('span').textContent;

        // Store editing reference
        this.editingDiv = answerDiv;

        // Store original values
        answerDiv.dataset.originalValue = this.normalize(answerDiv.querySelector('span').textContent);
        answerDiv.dataset.originalMain = this.normalize(answerDiv.dataset.mainSelect);
        answerDiv.dataset.originalAnswer = answerDiv.dataset.answerSelect || '';
        answerDiv.dataset.originalDynamic = this.normalize(answerDiv.dataset.dynamicSelect);
        const originalId = answerDiv.dataset.id || answerDiv.dataset.originalId || '';
        answerDiv.dataset.originalId = originalId;
        answerDiv.dataset.currentId = answerDiv.dataset.id || answerDiv.dataset.tempId || '';

        // ================================================
        // CRITICAL FIX: Initialize and load selectedValues
        // ================================================

        // Initialize selectedValues if it doesn't exist
        if (!this.selectedValues) {
            this.selectedValues = new Set();
        }

        // Clear and repopulate selectedValues from answerDiv data
        this.selectedValues.clear();

        let answerIds = answerDiv.dataset.answerSelect;
        console.log('DEBUG - Loading answerSelect from dataset:', answerIds);

        if (answerIds && answerIds.trim()) {
            // Clean and parse IDs
            const cleanedIds = answerIds.split(',')
                .map(id => id.trim())
                .filter(id => {
                    return id !== '' &&
                        id !== 'null' &&
                        id !== 'undefined' &&
                        !isNaN(parseInt(id));
                });

            console.log('DEBUG - Cleaned IDs to add to selectedValues:', cleanedIds);

            cleanedIds.forEach(id => {
                this.selectedValues.add(id);
            });
        }

        console.log('DEBUG - selectedValues after loading:', Array.from(this.selectedValues));

        // 🔥🔥🔥 ADD THIS SECTION - Fetch dependent questions from API 🔥🔥🔥
        const answerId = answerDiv.dataset.id || answerDiv.dataset.tempId;

        // If it's a saved answer (has numeric ID), fetch from API
        if (answerId && !isNaN(parseInt(answerId)) && parseInt(answerId) > 0) {
            console.log(`📡 Answer has ID ${answerId}, fetching dependent questions from API`);

            try {
                const dependentQuestions = await this.fetchDependentQuestions(parseInt(answerId));

                // Add the dependent question IDs to selectedValues
                if (dependentQuestions && dependentQuestions.length > 0) {
                    dependentQuestions.forEach(question => {
                        this.selectedValues.add(String(question.questionId));
                        console.log(`➕ Added dependent question ID: ${question.questionId}`);
                    });

                    const allIds = Array.from(this.selectedValues)
                        .filter(id => id && id !== "undefined" && !isNaN(parseInt(id)));
                    answerDiv.dataset.answerSelect = allIds.join(',');
                    console.log('Updated answerDiv dataset.answerSelect with API data:', answerDiv.dataset.answerSelect);
                } else {
                    console.log('No dependent questions found from API');
                }
            } catch (error) {
                console.error('Error fetching dependent questions:', error);
            }
        } else {
            console.log('Answer has no valid ID, skipping API call');
        }
        // 🔥🔥🔥 END OF API FETCH SECTION 🔥🔥🔥

        // IMMEDIATELY update hidden input with selectedValues
        const hiddenInput = this.modalOverlay2.querySelector('#answerSelect');
        if (hiddenInput) {
            hiddenInput.value = Array.from(this.selectedValues).join(',');
            console.log('DEBUG - Hidden input immediately set to:', hiddenInput.value);
        }

        // Delete button handling
        const cancelButton4 = this.modalOverlay2.querySelector('#cancel-button4');
        const deleteButton4 = this.modalOverlay2.querySelector('#modal-delete-button4');

        cancelButton4.classList.add('hidden');
        deleteButton4.classList.remove('hidden');

        deleteButton4.onclick = (e) => {
            e.stopPropagation();

            // 🔥 FORCE correct editing reference
            this.editingDiv = answerDiv;

            if (confirm('Are you sure you want to delete this answer?')) {
                answerDiv.dataset.isDeleted = 'true';
                answerDiv.style.display = 'none';

                console.log('🗑️ DELETING ANSWER:', {
                    text: answerDiv.querySelector('span')?.textContent,
                    id: answerDiv.dataset.id,
                    originalId: answerDiv.dataset.originalId,
                    tempId: answerDiv.dataset.tempId
                });

                if (this.cleanupDeletedAnswers) {
                    this.cleanupDeletedAnswers();
                }

                this.modalOverlay2.classList.remove('active');
                this.modalOverlay.classList.add('active');

                if (this.toggleQuestionValidation) {
                    this.toggleQuestionValidation();
                }

                alert('Answer marked for deletion. Save the question to confirm.');
            }
        };


        const mainSelect = document.getElementById('mainSelect2');
        const restored = this.normalize(answerDiv.dataset.mainSelect);

        // if restored is falsy or equals the old literal 'Select', use empty string so the placeholder shows
        mainSelect.value = (restored && restored !== 'Select') ? restored : '';


        // Remove existing dynamic dropdown
        const existing = document.getElementById('dynamic-wrapper')?.nextElementSibling;
        if (existing && existing.classList.contains('dynamic-dropdown')) {
            existing.remove();
        }

        // Restore DYNAMIC dropdown (async)
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

        // =====================================================
        // 🔥 FIX: Rebuild dropdown IMMEDIATELY with selectedValues
        // =====================================================

        // Clear any existing dropdown content first
        const dropdown = this.modalOverlay2.querySelector('#dropdown');
        if (dropdown) {
            dropdown.innerHTML = '';
            dropdown.style.display = 'none';
        }

        // Rebuild the dropdown with current data
        const currentQuestionElement = this.questionManager?.editingDiv2;
        if (currentQuestionElement) {
            const currentGroup = currentQuestionElement.dataset.group;
            const currentQuestionText = currentQuestionElement.querySelector('.main-value span').textContent;

            console.log('DEBUG - Rebuilding dropdown for:', {
                currentGroup,
                currentQuestionText,
                selectedValues: Array.from(this.selectedValues)
            });

            const questions = this.questionManager?.loadQuestionsForGroup(currentGroup, currentQuestionText) || [];

            // Populate dropdown with questions
            this.populateQuestionDropdown(questions, this.modalOverlay2);

            // Setup interactions
            this.setupDropdownInteractions(this.modalOverlay2);

            // Force checkbox states to match selectedValues
            setTimeout(() => {
                if (dropdown) {
                    const options = dropdown.querySelectorAll('.multiselect-option:not(.no-options)');
                    options.forEach(option => {
                        const value = option.dataset.value;
                        const checkbox = option.querySelector('.multiselect-checkbox');

                        if (value && checkbox && this.selectedValues.has(String(value))) {
                            checkbox.checked = true;
                            option.classList.add('selected');
                            console.log('DEBUG - Checked checkbox for question ID:', value);
                        }
                    });
                }
            }, 100);
        }

        // Disabled create button initially
        setTimeout(() => {
            const createButton = document.getElementById('create-button4');
            if (createButton) createButton.classList.add('btn-disable');
            if (this.toggleAnswerValidation) this.toggleAnswerValidation();
        }, 100);

        // UI tweak
        if (this.answersContainer && this.answersContainer.children.length > 0) {
            const addBtn = document.getElementById('addbtnmodal1');
            if (addBtn) addBtn.classList.add('overlay');
        } else {
            const addBtn = document.getElementById('addbtnmodal1');
            if (addBtn) addBtn.classList.remove('overlay');
        }

        // Make sure multiSelect wrapper shows as active if we have selections
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
        this.metaFieldsManager = new MetafieldsManager(this.addMetafieldsBtn, this.metaFieldsModal);
        this.iFramesManager = new IframeManager();
        this.connectManagers();
        this.setupEventListeners();
        this.hydrateExistingData();
        this.metaFieldsManager.loadMetafieldsFromDb();
        // Add this to your FormBuilder constructor
        console.log('Modal overlay 2 exists:', !!this.modalOverlay2);
        console.log('Modal overlay 2 ID:', this.modalOverlay2?.id);
    }

    resetCreateButtonState() {
        $('#modal1-create-button').addClass('btn-disable');
        $('#create-button4').addClass('btn-disable');
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
        const hasAnswers = this.answersContainer.children.length > 0;

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

            const originalAnswers = Array.from(this.questionManager.editingDiv2.querySelectorAll('.sub-value')).map(div => ({
                text: div.querySelector('span').textContent,
                mainSelect: div.dataset.mainSelect,
                answerSelect: div.dataset.answerSelect,
                dynamicSelect: div.dataset.dynamicSelect
            }));

            const currentAnswers = Array.from(this.answersContainer.children).map(div => ({
                text: div.querySelector('span').textContent,
                mainSelect: div.dataset.mainSelect,
                answerSelect: div.dataset.answerSelect,
                dynamicSelect: div.dataset.dynamicSelect
            }));

            const answersChanged = JSON.stringify(originalAnswers) !== JSON.stringify(currentAnswers);

            const hasChanges = textChanged || groupChanged || fieldTypeChanged || isRequiredChanged || answersChanged;

            const isValid = nameFilled && (
                HIDDEN_VALUES.includes(fieldValue) ||
                (ANSWERS_REQUIRED.includes(fieldValue) && hasAnswers)
            );

            canCreate = isValid && hasChanges;
        } else {
            canCreate = nameFilled && (
                HIDDEN_VALUES.includes(fieldValue) ||
                (ANSWERS_REQUIRED.includes(fieldValue) && hasAnswers)
            );
        }

        $('#modal1-create-button').toggleClass('btn-disable', !canCreate);
    }

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

            const hasChanges = textChanged || mainChanged || dynamicChanged;

            const isValid = (hasText || currentText !== '') &&
                (hasMainSelect || currentMain !== 'Select' && currentMain !== '') &&
                (hasDynamicSelect || $dyn.length === 0 || currentDynamic !== 'Select' && currentDynamic !== '');

            canSave = isValid && hasChanges;
        } else {
            const mainSelectValid = hasMainSelect || $mainSelect2.val() !== 'Select';
            const dynamicSelectValid = $dyn.length === 0 || hasDynamicSelect || $dyn.val() !== 'Select';

            canSave = hasText && mainSelectValid && dynamicSelectValid;
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
        document.getElementById('deactivateTemplate')?.addEventListener('click', (e) => {
            this.deactivateTemplate(e);
        });

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
        console.log('🔄 DEBUG: Updating question with answers:');
        Array.from(this.answersContainer.children).forEach((answerDiv, idx) => {
            console.log(`  Answer ${idx + 1}:`, {
                id: answerDiv.dataset.id,
                originalId: answerDiv.dataset.originalId,
                tempId: answerDiv.dataset.tempId,
                text: answerDiv.querySelector('span').textContent,
                isDeleted: answerDiv.dataset.isDeleted
            });
        });
        const mainSpan = this.questionManager.editingDiv2.querySelector('.main-value span');
        if (mainSpan) mainSpan.textContent = value;

        if (this.answersContainer.children.length <= 0) {
            document.getElementById('addbtnmodal1').classList.remove('overlay');
        } else {
            document.getElementById('addbtnmodal1').classList.add('overlay');
        }

        this.questionManager.editingDiv2.dataset.group = this.groupSelect.value;

        this.questionManager.editingDiv2.dataset.fieldType = this.fieldTypeSelect.value;
        this.questionManager.editingDiv2.dataset.isRequired = this.isRequiredCheckbox.checked.toString();

        const answers = Array.from(this.answersContainer.children)
            .map((answerDiv, index) => {
                const isDeleted = answerDiv.dataset.isDeleted === 'true';

                let answerId = 0;
                if (answerDiv.dataset.id && parseInt(answerDiv.dataset.id) > 0) {
                    answerId = parseInt(answerDiv.dataset.id);
                } else if (answerDiv.dataset.originalId && parseInt(answerDiv.dataset.originalId) > 0) {
                    answerId = parseInt(answerDiv.dataset.originalId);
                }

                // include OptionGuid (supports several attribute names)
                const optionGuid = answerDiv.dataset.optionGuid || answerDiv.dataset.answerGuid || answerDiv.dataset.answerGuid || '';
                return {
                    Id: answerId,
                    Text: answerDiv.querySelector('span').textContent,
                    Order: parseInt(answerDiv.dataset.order || (index + 1)),
                    SelectedOption: answerDiv.dataset.mainSelect || '',
                    SelectedMatComId: answerDiv.dataset.dynamicSelect
                        ? parseInt(answerDiv.dataset.dynamicSelect)
                        : null,
                    SelectedQuestionsList: answerDiv.dataset.answerSelect
                        ? answerDiv.dataset.answerSelect
                            .split(',')
                            .map(id => parseInt(id))
                            .filter(id => !isNaN(id))
                        : [],
                    IsDeleted: isDeleted,
                    OptionGuid: optionGuid
                };
            });


        try {
            const templateData = document.getElementById('template-data');
            const templateVersionId = templateData?.dataset.tempVersionId || 0;

            const groupName = this.groupSelect.value;
            let groupId = 0;
            let groupGuid = '';

            if (this.groupManager && this.groupManager.container) {
                const allGroups = this.groupManager.container.querySelectorAll('.saved-txt');

                for (const groupDiv of allGroups) {
                    const span = groupDiv.querySelector('.main-value span');
                    if (span && span.textContent.trim() === groupName) {
                        groupId = parseInt(groupDiv.dataset.id || '0');
                        break;
                    }
                }
            }

            if (!groupId || groupId <= 0) {
                const groupElement = document.querySelector(`.saved-txt.stored-overlay span`);
                if (groupElement && groupElement.textContent.includes(groupName)) {
                    const groupWrapper = groupElement.closest('.saved-txt');
                    groupId = parseInt(groupWrapper?.dataset.id || '0');
                    groupGuid = groupDiv.dataset.groupGuid || '';
                    break;
                }
            }

            if (!groupId || groupId <= 0) {
                throw new Error(`Could not find group ID for group: ${groupName}. The group may have been deleted or not saved properly.`);
            }

            const questionData = {
                Id: parseInt(this.questionManager.editingDiv2.dataset.id || '0'),
                Text: value,
                GroupId: groupId,
                FieldTypeId: parseInt(this.fieldTypeSelect.value),
                Order: parseInt(this.questionManager.editingDiv2.dataset.order || '1'),
                IsRequired: this.isRequiredCheckbox.checked,
                TemplateVersionId: parseInt(templateVersionId),
                Answers: answers,
                QuestionGuid: this.questionManager.editingDiv2.dataset.questionGuid || ''
            };
            // 🔥🔥🔥 ADD DEBUG VALIDATION (Temporary - remove after fix is verified)
            console.log('=== DEBUG: Validating answer IDs before sending ===');
            answers.forEach((answer, idx) => {
                if (answer.Text === 'openans') {
                    console.log(`⚠️ WARNING: Answer "openans" has ID: ${answer.Id}`);
                    if (answer.Id === 0) {
                        console.error('❌ ERROR: openans has ID=0, will cause duplication!');
                    } else {
                        console.log(`✅ GOOD: openans has ID=${answer.Id}, will be UPDATED`);
                    }
                }
            });
            console.log('=== END DEBUG ===');
            const response = await fetch('/api/Template/CreateQuestion', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },

                body: JSON.stringify(questionData),
            });
                console.log(`Questionguid in builder:`, questionData.questionGuid);

            if (response.ok) {
                const result = await response.json();

                console.log('✅ Server response:', result);
                if (result.answers && Array.isArray(result.answers)) {
                    console.log('🔥 UPDATING ANSWER IDs FROM SERVER:');

                    result.answers.forEach(serverAnswer => {
                        console.log(`  Looking for: "${serverAnswer.text}" (ID: ${serverAnswer.id}, Order: ${serverAnswer.order})`);
                    });

                    Array.from(this.answersContainer.children).forEach(answerDiv => {
                        const text = answerDiv.querySelector('span').textContent.trim();
                        const order = parseInt(answerDiv.dataset.order || '0');

                        console.log(`  Checking UI answer: "${text}" (Order: ${order})`);

                        // Find matching server answer
                        const match = result.answers.find(a => {
                            // Try multiple matching strategies
                            return (a.text === text && a.order === order) ||
                                (a.Text === text && a.Order === order) ||
                                (a.text === text && !isNaN(a.order) && Math.abs(a.order - order) <= 1);
                        });

                        if (match && (match.id > 0 || match.Id > 0)) {
                            const dbId = match.id || match.Id;
                            answerDiv.dataset.id = dbId;
                            answerDiv.dataset.originalId = dbId; // Store as backup too
                            delete answerDiv.dataset.tempId;
                            console.log(`✅ Updated "${text}" with database ID: ${dbId}`);
                        } else {
                            console.log(`❌ No match found for "${text}"`);
                        }
                    });
                }

                if (this.questionManager.saveAnswersToQuestionElement) {
                    Array.from(this.questionManager.editingDiv2.querySelectorAll('.saved-txt.sub-value'))
                        .forEach(el => el.remove());

                    this.questionManager.saveAnswersToQuestionElement(
                        this.questionManager.editingDiv2,
                        this.answersContainer
                    );
                } else {
                    Array.from(this.questionManager.editingDiv2.querySelectorAll('.saved-txt.stored-overlay'))
                        .forEach(el => el.remove());

                    Array.from(this.answersContainer.children).forEach((answerDiv, index) => {
                        const subWrapper = document.createElement('div');
                        subWrapper.className = 'saved-txt stored-overlay sub-value';
                        subWrapper.dataset.id = answerDiv.dataset.id || '';
                        subWrapper.dataset.originalId = answerDiv.dataset.id || '';
                        subWrapper.dataset.mainSelect = answerDiv.dataset.mainSelect || '';
                        subWrapper.dataset.answerSelect = answerDiv.dataset.answerSelect || '';
                        subWrapper.dataset.dynamicSelect = answerDiv.dataset.dynamicSelect || '';
                        subWrapper.dataset.order = answerDiv.dataset.order || (index + 1);
                        subWrapper.innerHTML = `<span>${answerDiv.querySelector('span').textContent}</span>`;
                        this.questionManager.editingDiv2.appendChild(subWrapper);
                    });
                }

                // this.showSaveNotification();
                if (this.handleVersionChange) this.handleVersionChange();
                this.questionManager.editingDiv2 = null;
            } else {
                const errorText = await response.text();
                throw new Error('Failed to update question: ' + errorText);
            }
        } catch (error) {
            alert(`Failed to update question: ${error.message}`);
        }
        console.log('🔄🔄🔄 DEBUG END 🔄🔄🔄');
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

        const hasChanged = value !== oldValue || newMain !== oldMain || newAnswer !== oldAnswer || newDynamic !== oldDynamic;

        if (hasChanged) {
            this.answerManager.editingDiv.querySelector('span').textContent = value;
            this.answerManager.editingDiv.dataset.mainSelect = newMain;
            this.answerManager.editingDiv.dataset.answerSelect = newAnswer;
            this.answerManager.editingDiv.dataset.dynamicSelect = newDynamic;
            this.handleVersionChange();
        }

        this.answerManager.editingDiv = null;
    }

    handleModal1Cancel() {
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

    toggleQuestionValidation() {
        const HIDDEN_VALUES = ['5', '6', '7'];
        const ANSWERS_REQUIRED = ['1', '2', '3', '4'];

        const isHidden = HIDDEN_VALUES.includes(this.fieldTypeSelect.value);
        const displayStyle = isHidden ? 'none' : 'block';

        document.getElementById('addbtnmodal1').style.display = displayStyle;
        document.getElementById('subheadingbold').style.display = displayStyle;

        const nameFilled = this.inputField2.value.trim().length > 0;
        const fieldValue = this.fieldTypeSelect.value;
        const hasAnswers = this.answersContainer.children.length > 0;

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

            // Improved answer comparison logic
            const originalAnswers = Array.from(this.questionManager.editingDiv2.querySelectorAll('.sub-value')).map(div => ({
                text: div.querySelector('span').textContent,
                mainSelect: div.dataset.mainSelect,
                answerSelect: div.dataset.answerSelect,
                dynamicSelect: div.dataset.dynamicSelect,
                id: div.dataset.id || div.dataset.tempId
            }));

            const currentAnswers = Array.from(this.answersContainer.children).map(div => ({
                text: div.querySelector('span').textContent,
                mainSelect: div.dataset.mainSelect,
                answerSelect: div.dataset.answerSelect,
                dynamicSelect: div.dataset.dynamicSelect,
                id: div.dataset.id || div.dataset.tempId
            }));

            // Compare all properties, not just JSON string
            const answersChanged = originalAnswers.length !== currentAnswers.length ||
                originalAnswers.some((orig, index) => {
                    const curr = currentAnswers[index];
                    if (!curr) return true;
                    return orig.text !== curr.text ||
                        orig.mainSelect !== curr.mainSelect ||
                        orig.answerSelect !== curr.answerSelect ||
                        orig.dynamicSelect !== curr.dynamicSelect ||
                        orig.id !== curr.id;
                });

            const hasChanges = textChanged || groupChanged || fieldTypeChanged || isRequiredChanged || answersChanged;

            const isValid = nameFilled && (
                HIDDEN_VALUES.includes(fieldValue) ||
                (ANSWERS_REQUIRED.includes(fieldValue) && hasAnswers)
            );

            canCreate = isValid && hasChanges;
        } else {
            canCreate = nameFilled && (
                HIDDEN_VALUES.includes(fieldValue) ||
                (ANSWERS_REQUIRED.includes(fieldValue) && hasAnswers)
            );
        }

        $('#modal1-create-button').toggleClass('btn-disable', !canCreate);
    }

    toggleAnswerValidation() {
        const $quoteTemplateModel2 = $('#quoteTemplate22');
        const $mainSelect2 = $('#mainSelect2');
        const $saveButtonModal2 = $('#create-button4');

        const hasText = $quoteTemplateModel2.val().trim().length > 0;
        const hasMainSelect = $mainSelect2.val() && $mainSelect2.val().trim() !== '' && $mainSelect2.val() !== 'Select';

        const $dyn = $('.dynamic-select');
        const hasDynamicSelect = $dyn.length > 0 ?
            ($dyn.val() && $dyn.val().trim() !== '' && $dyn.val() !== 'Select') : false;

        const canSave = hasText || (hasMainSelect || hasDynamicSelect);
        const wasDisabled = $saveButtonModal2.hasClass('btn-disable');

        $saveButtonModal2.toggleClass('btn-disable', !canSave);

        if (wasDisabled && canSave) {
            $(document).trigger('answerModelChanged');
        }
    }

    deactivateTemplate(e) {
        e.stopPropagation();

        const templateData = document.getElementById('template-data');
        const tempVersionId = templateData?.dataset.tempVersionId || 0;

        $.ajax({
            url: '/api/Template/ToggleActive',
            type: 'POST',
            contentType: 'application/json',
            data: JSON.stringify({ id: tempVersionId }),
            dataType: 'json',
            success: function (response) {
                if (response.success) {
                    location.reload();
                }
            },
            error: function (error) {
                console.error('Error:', error);
                alert('Failed to update template status');
            }
        });

        this.closeAllDropdowns();
    }

    previewTemplate() {
        const data = this.exportData();

        const versionText = document.getElementById('versionDropdownBtn').textContent;
        const versionNumber = versionText.replace('Version', '').trim();

        data.templateVersion = {
            tempVersion: parseInt(versionNumber, 10) || 0
        };

        this.ajaxSaveForm('PreviewTemplate', data);
    }

    saveForm() {
        const data = this.exportData();
        this.ajaxSaveForm('SaveTemplate', data);
    }

    handleVersionChange() {
        if (this.versionCall === 0) {
            const isNew = $('#template-data').attr('data-is-new-template') === 'true';
            if (!isNew) {
                versions.bumpVersion();
                ++this.versionCall;
            }
        }
    }

    exportData() {
        const templateData = document.getElementById('template-data');

        const template = {
            templateVersionId: templateData?.dataset.tempVersionId || 0,
            name: document.getElementById('templateName')?.value || '',
            description: document.getElementById('templateDes')?.value || ''
        };

        const templateVersion = {
            tempVersion: document.getElementById('latestVersionHolder')?.value
        };

        const isNewTemplate = templateData?.dataset.isNewTemplate === 'true';

        const groups = Array.from(this.container?.querySelectorAll('.saved-txt') || []).map(g => ({
            id: parseInt(g.dataset.id || '0', 10),
            order: parseInt(g.dataset.order, 10),
            name: g.querySelector('span')?.textContent || ''
        }));

        const questions = this.questionsList ?
            Array.from(this.questionsList.querySelectorAll('.saved-txt:not(.sub-value)')).map(q => {
                const answers = Array.from(q.querySelectorAll('.sub-value')).map((a, idx) => ({
                    id: parseInt(a.dataset.id || '0', 10),
                    order: parseInt(a.dataset.order, 10) || idx + 1,
                    option: a.querySelector('span')?.textContent || '',
                    selectedOption: a.dataset.mainSelect || '',
                    SelectedMatComId: a.dataset.dynamicSelect || 0,
                    SelectedQuestionsList: (a.dataset.answerSelect ? a.dataset.answerSelect.split(',') : [])
                }));

                return {
                    id: parseInt(q.dataset.id || '0', 10),
                    order: parseInt(q.dataset.order, 10),
                    questionText: q.querySelector('.main-value span')?.textContent || '',
                    questionGroup: q.dataset.group,
                    fieldTypeId: q.dataset.fieldType,
                    IsRequired: q.dataset.isRequired === 'true',
                    answers: answers
                };
            }) : [];

        return {
            questionGroups: groups,
            questionAnswers: questions,
            templateVersion,
            template,
            isNewTemplate
        };
    }

    ajaxSaveForm(action, data) {
        $.ajax({
            url: `/api/Template/${action}`,
            type: 'POST',
            contentType: 'application/json',
            data: JSON.stringify(data),
            dataType: 'json',
            success: (response) => {
                if (response.success && response.isPreviewPage) {
                    // For preview, open in new tab
                    this.hideSaveNotification();
                    window.open(response.redirectUrl, '_blank');
                } else if (response.success && action === 'SaveTemplate') {
                    // ✅ CRITICAL FIX: For save, update the page without redirect
                    this.handleSaveSuccess(response);
                } else {
                    // For other cases, redirect as before
                    window.location.href = response.redirectUrl;
                }
            },
            error: (xhr) => {
                console.error('Backend error:', xhr.status, xhr.responseText);
                alert('Failed to save template. Please try again.');
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

        // Show success message
        this.showSaveSuccessNotification();

        // Reset version call counter if needed
        this.versionCall = 0;

        console.log('Template saved successfully, staying on page');
    }

    // ✅ Add this method to show a temporary success message
    showSaveSuccessNotification() {
        // You can implement a temporary success toast/notification
        // For now, just log and optionally show an alert
        console.log('Template saved successfully!');

        // Optionally show a small toast notification
        const toast = document.createElement('div');
        toast.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: #4CAF50;
        color: white;
        padding: 12px 20px;
        border-radius: 4px;
        z-index: 9999;
        box-shadow: 0 2px 10px rgba(0,0,0,0.2);
    `;
        toast.textContent = 'Template saved successfully!';
        document.body.appendChild(toast);

        setTimeout(() => {
            toast.remove();
        }, 3000);
    }

    hydrateExistingData() {
        this.hydrateExistingGroups();
        this.hydrateExistingQuestions();
        this.groupManager.updateWrapperStyles();
        this.groupManager.updateRoundedCorners();
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

    normalize(value) {
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


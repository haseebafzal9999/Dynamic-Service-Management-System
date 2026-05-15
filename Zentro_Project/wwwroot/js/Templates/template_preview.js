// ========================================
// 🏗️ MAIN CLASS: TemplatePreviewManager
// ========================================
class TemplatePreviewManager {
    constructor() {
        this.templateData = null;
        this.apiService = new TemplateApiService();
        this.renderer = new TemplateRenderer();
        this.eventManager = new EventManager();

        this.init();
    }
    logDataStructure(data) {
        console.log('📊 Data Structure Analysis:');
        console.log('Is Array:', Array.isArray(data));
        console.log('Number of groups:', data.length);

        data.forEach((group, groupIndex) => {
            console.log(`\n--- Group ${groupIndex + 1} ---`);
            console.log('Group Name:', group.questionGroupName);
            console.log('Group ID:', group.questionGroupId);
            console.log('Questions count:', group.questions ? group.questions.length : 0);

            if (group.questions && group.questions.length) {
                group.questions.forEach((question, qIndex) => {
                    console.log(`  Question ${qIndex + 1}:`, {
                        id: question.questionId,
                        text: question.questionText,
                        fieldType: question.fieldTypeName || question.fieldTypeDisplayName,
                        optionsCount: question.options ? question.options.length : 0,
                        options: question.options ? question.options.map(o => ({
                            id: o.qOptionId,
                            text: o.optionText
                        })) : 'No options'
                    });
                });
            }
        });
    }

    async init() {
        try {
            await this.loadTemplateData();
            this.setupEventDelegation();
        } catch (error) {
            this.handleError('Initialization failed', error);
        }
    }

    async loadTemplateData() {
        const templateVersionId = this.getTemplateVersionId();
        if (!templateVersionId) {
            throw new Error('TemplateVersionId not found');
        }

        this.templateData = await this.apiService.fetchRootQuestions(templateVersionId);
        this.logDataStructure(this.templateData);
        this.renderer.renderTemplate(this.templateData);

    }

    getTemplateVersionId() {
        const input = document.querySelector('input[name="TemplateVersionId"]');
        return input ? parseInt(input.value) : null;
    }

    setupEventDelegation() {
        this.eventManager.setupGlobalHandlers(this);
    }

    handleError(context, error) {
        console.error(`❌ ${context}:`, error);
        this.showUserError(`Failed to ${context.toLowerCase()}`);
    }

    showUserError(message) {
        alert(message);
    }
}

// ========================================
// 🌐 API SERVICE CLASS (fixed)
// ========================================
class TemplateApiService {
    async fetchRootQuestions(templateVersionId) {
        const url = this.buildUrl('/api/common/GetTemplateDetais', { templateVersionId });
        return this.makeRequest(url);
    }

    // NOTE: include templateVersionId and use the controller's param name `dependentQuestionId`
    async fetchDependentQuestions(templateVersionId, optionId) {
        const url = this.buildUrl('/api/common/GetDependentQuestionDetais', {
            templateVersionId,
            dependentQuestionId: optionId
        });
        return this.makeRequest(url);
    }

    buildUrl(endpoint, params) {
        const url = new URL(endpoint, window.location.origin);
        Object.entries(params).forEach(([key, value]) => {
            // ignore undefined/null
            if (value !== undefined && value !== null) {
                url.searchParams.set(key, value);
            }
        });
        return url;
    }

    async makeRequest(url, options = {}) {
        const config = {
            method: 'GET',
            credentials: 'same-origin',
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json'
            },
            ...options
        };

        const response = await fetch(url, config);

        if (!response.ok) {
            const error = await this.parseError(response);
            throw error;
        }

        return response.json();
    }

    async parseError(response) {
        try {
            const body = await response.json();
            return new Error(body.message || body.Message || `API returned ${response.status}`);
        } catch {
            return new Error(`Request failed with status ${response.status}`);
        }
    }
}


// ========================================
// 🎨 RENDERER CLASS
// ========================================
class TemplateRenderer {
    constructor() {
        this.container = document.getElementById('question-render-root');
    }

    // Add this method to TemplateRenderer class
    debugQuestionStructure(question) {
        console.log('🔍 Question Debug:', {
            questionId: question.questionId,
            questionText: question.questionText,
            fieldType: this.getFieldType(question),
            hasOptions: !!question.options,
            optionsCount: question.options ? question.options.length : 0,
            options: question.options ? question.options.map(opt => ({
                qOptionId: opt.qOptionId,
                optionText: opt.optionText,
                costPrice: opt.costPrice,
                sellPrice: opt.sellPrice
            })) : []
        });
    }

    renderQuestion(question, isDependent = false) {
        // Debug: log each question structure
        this.debugQuestionStructure(question);

        const questionDiv = this.createDOMElement('div', {
            className: 'question-bottom-margins-c',
            attributes: {
                'data-is-required': question.isRequired ? 'true' : 'false',
                'data-question-id': question.questionId
            }
        });

        questionDiv.innerHTML = this.createQuestionHTML(question);

        const fieldType = this.getFieldType(question);
        this.renderQuestionOptions(questionDiv, question);

        return questionDiv;
    }

    renderTemplate(data) {
        if (!this.container) {
            throw new Error('Question container not found');
        }

        this.setTemplateMetadata(data);
        this.renderQuestions(data);
        this.expandFirstGroup();
    }

    setTemplateMetadata(data) {
        this.setTextContent('#template-name', data.templateName || 'Template Preview');
        this.setInputValue('#TemplateId', data.templateId);
        this.setInputValue('#TemplateVersion', data.templateVersionId || data.templateVersion);

        if (data.optionPrices) {
            window.optionPrices = data.optionPrices;
        }
    }

    renderQuestions(data) {
        this.container.innerHTML = '';

        const questionGroups = Array.isArray(data) ? data : data.dbQuestionGroups;

        if (!questionGroups?.length) {
            this.container.innerHTML = '<p class="text-center">No question groups found.</p>';
            return;
        }

        questionGroups.forEach((group, index) => {
            const groupElement = this.createGroupElement(group, index);
            this.container.appendChild(groupElement);
        });
    }

    createGroupElement(group, index) {
        return this.createDOMElement('div', { className: 'item-c' }, [
            this.createGroupHeader(group, index),
            this.createGroupSection(group, index)
        ]);
    }

    createGroupHeader(group, index) {
        return this.createDOMElement('div', { className: 'section-container-c' }, [
            this.createDOMElement('header', {
                className: `dropdown-header-c parentToggler shadow-c ${index === 0 ? 'auto-open' : ''}`,
                id: `capsule-${group.questionGroupId}`
            }, [
                this.createDOMElement('span', { className: 'dropdown-header-text-c' }, group.questionGroupName),
                this.createCarrotIcon()
            ])
        ]);
    }

    createCarrotIcon() {
        const carrot = this.createDOMElement('span', { className: 'carrot-c', id: 'dropDownToggle' });
        carrot.innerHTML = `
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
                <path stroke-linecap="round" stroke-linejoin="round" d="m19.5 8.25-7.5 7.5-7.5-7.5" />
            </svg>
        `;
        return carrot;
    }

    createGroupSection(group, index) {
        const sectionDiv = this.createDOMElement('div', {
            className: `section-container-c shadow-c hidden ${index === 0 ? 'auto-open-target' : ''}`,
            id: `groupSection-${group.questionGroupId}`
        });

        const sectionBox = this.createDOMElement('section', {
            className: 'section-box-c top-corners-c less-padding-c'
        });

        if (group.questions && group.questions.length) {
            group.questions.forEach(question => {
                const questionElement = this.renderQuestion(question);
                sectionBox.appendChild(questionElement);
            });
        }

        sectionDiv.appendChild(sectionBox);
        return sectionDiv;
    }

    renderQuestion(question, isDependent = false) {
        // Debug: log each question structure
        this.debugQuestionStructure(question);

        const questionDiv = this.createDOMElement('div', {
            className: 'question-bottom-margins-c',
            attributes: {
                'data-is-required': question.isRequired ? 'true' : 'false',
                'data-question-id': question.questionId
            }
        });

        questionDiv.innerHTML = this.createQuestionHTML(question);

        // Always render question options - the method will handle different field types
        this.renderQuestionOptions(questionDiv, question);

        return questionDiv;
    }

    createQuestionHTML(question) {
        return `
        <h2 class="section-subheading-c no-margin-c">
            ${this.escapeHtml(question.questionText)}
            ${question.isRequired ? '<span class="required-asterisk-c">*</span>' : ''}
        </h2>
        <input type="hidden" name="Answers[${question.questionId}].QuestionId" value="${question.questionId}" />
    `;
    }

    renderQuestionOptions(container, question) {
        const fieldType = this.getFieldType(question);
        const sortedOptions = question.options ? [...question.options].sort((a, b) => a.optionDisplayOrder - b.optionDisplayOrder) : [];
        console.log(`🔍 Field type for question ${question.questionId}:`, fieldType);
        console.log(`🔍 Question data:`, question);

        switch (fieldType) {
            case 'checkboxes':
                this.renderCheckboxes(container, question, sortedOptions);
                break;
            case 'radio buttons':
                this.renderRadioButtons(container, question, sortedOptions);
                break;
            case 'table':
                this.renderTable(container, question, sortedOptions);
                break;
            case 'select list':
                this.renderSelectList(container, question, sortedOptions);
                break;
            case 'input':
                this.renderInput(container, question);
                break;
            default:
                container.innerHTML += `<p class="text-gray-500-c">Unsupported field type: ${fieldType}</p>`;
        }
    }

    renderCheckboxes(container, question, sortedOptions) {
        // create a dependent container for this question (append at the end of the question block)
        const dependentSelector = `.dependent-section-c[data-question="${question.questionId}"]`;
        const dependentDiv = this.createDOMElement('div', {
            className: `dependent-section-c hidden`,
            attributes: { 'data-question': question.questionId }
        });
        // append dependent container after options will be appended
        // we'll append it at the end of container

        sortedOptions.forEach((opt, index) => {
            // optimistic assumption: we'll let the backend tell us if there are items
            const hasDependents = true;

            const costPrice = opt.costPrice || opt.costPrice === 0 ? opt.costPrice : 0;
            const sellPrice = opt.sellPrice || opt.sellPrice === 0 ? opt.sellPrice : 0;

            const checkboxDiv = this.createDOMElement('div', {
                className: `checkbox-wrapper-c ${index > 0 ? 'less-top-margin-c' : ''}`
            });

            checkboxDiv.innerHTML = `
        <input type="checkbox"
               id="q-${question.questionId}-opt-${opt.qOptionId}"
               name="Answers[${question.questionId}].SelectedOptionId"
               value="${opt.qOptionId}"
               class="radio-style-c single-select-c"
               data-toggle="conditional"
               data-questionid="${question.questionId}"
               data-optionid="${opt.qOptionId}"
               data-costprice="${costPrice}"
               data-sellprice="${sellPrice}"
               data-target="${dependentSelector}"
               ${hasDependents ? 'data-has-dependents="true"' : ''} />
        <label class="checkbox-text-c" for="q-${question.questionId}-opt-${opt.qOptionId}">
            ${this.escapeHtml(opt.optionText)}
        </label>
    `;

            container.appendChild(checkboxDiv);
        });

        // append the dependent container once after the options
        container.appendChild(dependentDiv);
    }


    renderRadioButtons(container, question, sortedOptions) {
        const dependentSelector = `.dependent-section-c[data-question="${question.questionId}"]`;
        const dependentDiv = this.createDOMElement('div', {
            className: `dependent-section-c hidden`,
            attributes: { 'data-question': question.questionId }
        });

        sortedOptions.forEach((opt, index) => {
            const hasDependents = true;
            const costPrice = opt.costPrice || opt.costPrice === 0 ? opt.costPrice : 0;
            const sellPrice = opt.sellPrice || opt.sellPrice === 0 ? opt.sellPrice : 0;

            const radioDiv = this.createDOMElement('div', {
                className: `checkbox-wrapper-c ${index > 0 ? 'less-top-margin-c' : ''}`
            });

            radioDiv.innerHTML = `
        <input type="radio"
               id="q-${question.questionId}-opt-${opt.qOptionId}"
               name="Answers[${question.questionId}].SelectedOptionId"
               value="${opt.qOptionId}"
               class="radio-style-c single-select-c"
               data-toggle="conditional"
               data-questionid="${question.questionId}"
               data-optionid="${opt.qOptionId}"
               data-costprice="${costPrice}"
               data-sellprice="${sellPrice}"
               data-target="${dependentSelector}"
               ${hasDependents ? 'data-has-dependents="true"' : ''} />
        <label class="checkbox-text-c" for="q-${question.questionId}-opt-${opt.qOptionId}">
            ${this.escapeHtml(opt.optionText)}
        </label>
    `;

            container.appendChild(radioDiv);
        });

        container.appendChild(dependentDiv);
    }


    renderTable(container, question, sortedOptions) {
        const tableHTML = `
    <div class="section-container-c line-item-modal-c">
        <header class="popup-section-header-c no-top-margin-c custom-bg-c">
            <span class="popup-header-text-c">Type</span>
            <span class="popup-header-text-c line-modal-margin-c">Quantity</span>
            <span class="popup-header-text-c"></span>
        </header>
        <div class="line-item-modal-c popup-sub-box-c top-corners-c">
            <div class="selects-container-c" id="table-rows-${question.questionId}">
                <div class="selects-wrapper-c">
                    <div class="section-input-wrapper-c less-width-select2-c">
                        <select class="section-input-c selectt-c conditional-select"
                                name="Answers[${question.questionId}].LineItems[0].OptionId"
                                data-toggle="conditional"
                                data-questionid="${question.questionId}">
                            <option value="">Select</option>
                            ${sortedOptions.map(opt => {
            const hasDependents = true;
            return `
                                <option value="${opt.qOptionId}"
                                        data-sellprice="${opt.sellPrice || 0}"
                                        data-costprice="${opt.costPrice || 0}"
                                        data-questionid="${question.questionId}"
                                        data-optionid="${opt.qOptionId}"
                                        ${hasDependents ? 'data-has-dependents="true"' : ''}>
                                    ${this.escapeHtml(opt.optionText)}
                                </option>
                            `}).join('')}
                        </select>
                    </div>
                    <div class="section-input-wrapper-c less-width-select2-c">
                        <input type="number"
                               class="section-input-c"
                               name="Answers[${question.questionId}].LineItems[0].Quantity"
                               min="0" value="0" />
                    </div>
                    <div class="line-item-cross-container-c">
                        <button type="button" class="line-item-cross-btn-c" ${sortedOptions.length <= 1 ? 'disabled' : ''}>
                            <img src="/images/close-cancel.svg" alt="Remove">
                        </button>
                    </div>
                </div>
            </div>
            <div class="save-btn-container-c">
                <button type="button" class="btn-save-c add-line-c" data-question="${question.questionId}" 
                        ${sortedOptions.length <= 1 ? 'disabled' : ''}>
                    Add Line Item
                </button>
            </div>
        </div>
    </div>
    `;

        container.innerHTML += tableHTML;

        // Add dependent container for tables
        const dependentSelector = `.dependent-section-c[data-question="${question.questionId}"]`;
        const dependentDiv = this.createDOMElement('div', {
            className: `dependent-section-c hidden`,
            attributes: { 'data-question': question.questionId }
        });
        container.appendChild(dependentDiv);

        if (sortedOptions.length <= 1) {
            const addButton = container.querySelector(`.add-line-c[data-question="${question.questionId}"]`);
            if (addButton) {
                addButton.classList.add('btn-disabled-c');
            }
        }
    }

    renderSelectList(container, question, sortedOptions) {
        const selectHTML = `
    <div class="section-input-wrapper-c less-width-select-c">
        <select class="section-input-c selectt-c conditional-select"
                name="Answers[${question.questionId}].SelectedOptionId" 
                id="q-${question.questionId}"
                data-toggle="conditional"
                data-questionid="${question.questionId}">
            <option value="">Select</option>
            ${sortedOptions.map(opt => {
            const costPrice = opt.costPrice || 0;
            const sellPrice = opt.sellPrice || 0;
            const hasDependents = true; // Assuming all options might have dependents

            return `
                    <option value="${opt.qOptionId}"
                            data-questionid="${question.questionId}"
                            data-optionid="${opt.qOptionId}"
                            data-sellprice="${sellPrice}"
                            data-costprice="${costPrice}"
                            ${hasDependents ? 'data-has-dependents="true"' : ''}>
                        ${this.escapeHtml(opt.optionText)}
                    </option>
                `;
        }).join('')}
        </select>
    </div>
    `;

        container.innerHTML += selectHTML;

        // Add dependent container for select lists too
        const dependentSelector = `.dependent-section-c[data-question="${question.questionId}"]`;
        const dependentDiv = this.createDOMElement('div', {
            className: `dependent-section-c hidden`,
            attributes: { 'data-question': question.questionId }
        });
        container.appendChild(dependentDiv);
    }

    renderInput(container, question) {
        const prices = this.getPrices(question.questionId, window.optionPrices);
        const inputHTML = `
            <div class="section-input-wrapper-c less-width-select-c">
                <input type="number" 
                       class="section-input-c"
                       data-questionid="${question.questionId}"
                       data-sellprice="${prices.sellPrice}"
                       data-costprice="${prices.costPrice}"
                       name="Answers[${question.questionId}].AnswerInput" 
                       id="q-${question.questionId}" />
            </div>
        `;

        container.innerHTML += inputHTML;
    }

    getPrices(optionId, optionPrices) {
        let sellPrice = 0;
        let costPrice = 0;

        if (!optionId || !Array.isArray(optionPrices) || optionPrices.length === 0) {
            return { sellPrice, costPrice };
        }

        const matchedOption = optionPrices.find(x => x.optionId === optionId);
        if (matchedOption) {
            sellPrice = matchedOption.sellPrice || 0;
            costPrice = matchedOption.costPrice || 0;
        }

        return { sellPrice, costPrice };
    }

    expandFirstGroup() {
        const firstHeader = document.querySelector('.dropdown-header-c.auto-open');
        const firstSection = document.querySelector('.section-container-c.auto-open-target');

        if (firstHeader && firstSection) {
            this.toggleGroup(firstHeader, firstSection, true);
        }
    }

    toggleGroup(header, section, forceOpen = false) {
        const isHidden = section.classList.contains('hidden');
        const shouldOpen = forceOpen ? true : isHidden;

        section.classList.toggle('hidden', !shouldOpen);

        const carrotSvg = header.querySelector('.carrot-c svg');
        if (carrotSvg) {
            carrotSvg.classList.toggle('rotate-180-c', shouldOpen);
        }

        header.classList.toggle('bottom-corners-c', shouldOpen);
        header.classList.toggle('shadow-c', !shouldOpen);
        header.classList.toggle('shadow-toggle-c', shouldOpen);

        const breaker = header.querySelector('.section-line-breaker-c');
        if (breaker) {
            breaker.classList.toggle('hidden', !shouldOpen);
        }
    }

    // Utility methods
    createDOMElement(tag, { className, id, attributes = {} }, children = []) {
        const element = document.createElement(tag);

        if (className) element.className = className;
        if (id) element.id = id;

        Object.entries(attributes).forEach(([key, value]) => {
            element.setAttribute(key, value);
        });

        if (children) {
            if (Array.isArray(children)) {
                children.forEach(child => {
                    if (typeof child === 'string') {
                        element.innerHTML += child;
                    } else if (child instanceof Node) {
                        element.appendChild(child);
                    }
                });
            } else if (typeof children === 'string') {
                element.innerHTML = children;
            } else if (children instanceof Node) {
                element.appendChild(children);
            }
        }

        return element;
    }

    escapeHtml(text) {
        if (!text) return '';
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    setTextContent(selector, text) {
        const element = document.querySelector(selector);
        if (element) element.textContent = text;
    }

    setInputValue(selector, value) {
        const input = document.querySelector(selector);
        if (input) input.value = value || '';
    }

    getFieldType(question) {
        const fieldType = question.fieldTypeName || question.fieldTypeDisplayName;
        return fieldType ? fieldType.toLowerCase() : 'input';
    }
}

// ========================================
// 🎯 EVENT MANAGER CLASS
// ========================================
class EventManager {
    setupGlobalHandlers(templateManager) {
        this.templateManager = templateManager;
        this.setupGroupToggleHandlers();
        this.setupConditionalQuestionHandlers();
        this.setupTableHandlers();
    }

    setupGroupToggleHandlers() {
        document.addEventListener('click', (e) => {
            const header = e.target.closest('.dropdown-header-c');
            if (header) {
                this.handleGroupToggle(header);
            }
        });
    }
    setupTableHandlers() {
        document.addEventListener('click', (e) => {
            if (e.target.classList.contains('add-line-c')) {
                this.handleAddLineItem(e.target);
            }

            if (e.target.closest('.line-item-cross-btn-c')) {
                this.handleRemoveLineItem(e.target.closest('.line-item-cross-btn-c'));
            }
        });
    }
    handleAddLineItem(button) {
        const questionId = button.getAttribute('data-question');
        const tableContainer = document.getElementById(`table-rows-${questionId}`);
        const rowTemplate = tableContainer.querySelector('.selects-wrapper-c');

        if (!rowTemplate) return;

        const currentRowCount = tableContainer.querySelectorAll('.selects-wrapper-c').length;
        const availableOptions = this.getAvailableOptionsCount(questionId);

        if (currentRowCount >= availableOptions) {
            return;
        }

        const newRow = rowTemplate.cloneNode(true);
        const rowIndex = currentRowCount;
        this.updateRowIndex(newRow, rowIndex, questionId);

        const quantityInput = newRow.querySelector('input[type="number"]');
        const select = newRow.querySelector('select');
        if (quantityInput) quantityInput.value = 0;
        if (select) select.selectedIndex = 0;

        // Ensure the new select has the conditional attributes
        if (select) {
            select.setAttribute('data-toggle', 'conditional');
            select.setAttribute('data-questionid', questionId);
        }

        tableContainer.appendChild(newRow);

        this.updateAddButtonState(questionId);
    }

    updateRowIndex(row, index, questionId) {
        const select = row.querySelector('select');
        if (select) {
            select.name = `Answers[${questionId}].LineItems[${index}].OptionId`;
            select.id = `q-${questionId}-line-${index}-option`;
        }

        const quantityInput = row.querySelector('input[type="number"]');
        if (quantityInput) {
            quantityInput.name = `Answers[${questionId}].LineItems[${index}].Quantity`;
            quantityInput.id = `q-${questionId}-line-${index}-quantity`;
        }
    }
    handleRemoveLineItem(removeButton) {
        const row = removeButton.closest('.selects-wrapper-c');
        const tableContainer = row?.parentElement;

        if (tableContainer && tableContainer.querySelectorAll('.selects-wrapper-c').length > 1) {
            row.remove();
            this.reindexTableRows(tableContainer);

            const questionId = tableContainer.id.replace('table-rows-', '');
            this.updateAddButtonState(questionId);
        }
    }
    getAvailableOptionsCount(questionId) {
        const tableContainer = document.getElementById(`table-rows-${questionId}`);
        if (!tableContainer) return 0;

        const firstSelect = tableContainer.querySelector('select');
        if (!firstSelect) return 0;

        return firstSelect.querySelectorAll('option').length - 1;
    }

    updateAddButtonState(questionId) {
        const tableContainer = document.getElementById(`table-rows-${questionId}`);
        if (!tableContainer) return;

        const currentRowCount = tableContainer.querySelectorAll('.selects-wrapper-c').length;
        const availableOptions = this.getAvailableOptionsCount(questionId);
        const addButton = document.querySelector(`.add-line-c[data-question="${questionId}"]`);

        if (addButton) {
            const shouldDisable = currentRowCount >= availableOptions;
            addButton.disabled = shouldDisable;
            if (shouldDisable) {
                addButton.classList.add('btn-disabled-c');
                addButton.title = 'All available options have been added';
            } else {
                addButton.classList.remove('btn-disabled-c');
                addButton.title = 'Add another line item';
            }
        }
    }

    reindexTableRows(tableContainer) {
        const rows = tableContainer.querySelectorAll('.selects-wrapper-c');
        const questionId = tableContainer.id.replace('table-rows-', '');

        rows.forEach((row, index) => {
            this.updateRowIndex(row, index, questionId);
        });
        this.updateAddButtonState(questionId);
    }

    handleGroupToggle(header) {
        const groupId = header.id.replace('capsule-', '');
        const section = document.getElementById(`groupSection-${groupId}`);

        if (section) {
            this.templateManager.renderer.toggleGroup(header, section);
        }
    }

    setupConditionalQuestionHandlers() {
        // For checkboxes and radio buttons
        $(document).off("change", "input[data-toggle=conditional]").on("change", "input[data-toggle=conditional]", (e) => {
            this.handleConditionalQuestionChange(e.target);
        });

        // ADD THIS: For select elements
        $(document).off("change", "select[data-toggle=conditional]").on("change", "select[data-toggle=conditional]", (e) => {
            this.handleSelectConditionalChange(e.target);
        });
    }

    handleSelectConditionalChange(select) {
        const $select = $(select);
        const questionId = $select.attr("data-questionid");
        const selectedOptionId = $select.val();

        const targetSelector = `.dependent-section-c[data-question="${questionId}"]`;

        this.closeAllDependentSections(questionId);

        if (selectedOptionId) {
            this.loadAndRenderDependentQuestions(selectedOptionId, targetSelector);
        }
    }
    async handleConditionalQuestionChange(input) {
        const $input = $(input);
        let targetSelector = $input.attr("data-target");
        const questionId = $input.closest(".question-bottom-margins-c").attr("data-question-id");
        const optionId = $input.attr("data-optionid");

        const isChecked = $input.is(":checked");

        if (!targetSelector || !this.isValidSelector(targetSelector)) {
            targetSelector = `.dependent-section-c[data-question="${questionId}"]`;
        }

        this.closeAllDependentSections(questionId);

        if (isChecked) {

            await this.loadAndRenderDependentQuestions(optionId, targetSelector);
        }
    }
    isValidSelector(selector) {
        try {
            document.querySelector(selector);
            return true;
        } catch (e) {
            return false;
        }
    }


    closeAllDependentSections(questionId) {
        $(`.dependent-section-c[data-question="${questionId}"]`).addClass("hidden").empty();
    }


    async loadAndRenderDependentQuestions(optionId, targetSelector) {
        const $target = $(targetSelector);
        if (!$target.length) return;

        // $target.html('<div class="loading-c"></div>').removeClass("hidden");

        try {
            const templateVersionId = this.templateManager.getTemplateVersionId
                ? this.templateManager.getTemplateVersionId()
                : (document.querySelector('input[name="TemplateVersionId"]') ? parseInt(document.querySelector('input[name="TemplateVersionId"]').value) : 0);

            const dependentResponse = await this.templateManager.apiService.fetchDependentQuestions(templateVersionId, optionId);

            $target.empty();
            console.log("DEPENDENT RAW:", dependentResponse);

            const questionsToRender = [];
            dependentResponse.forEach(item => {
                if (item && Array.isArray(item.questions) && item.questions.length) {
                    // item is a group — push each child question
                    item.questions.forEach(q => questionsToRender.push(q));
                } else if (item && (item.questionId || item.fieldTypeName || item.questionText)) {

                    questionsToRender.push(item);
                } else {
                    console.warn('Unexpected dependent item shape:', item);
                }
            });
            const dependentOptionPrices = [];
            questionsToRender.forEach(question => {

                const opts = question.questionOptions ?? question.options ?? [];
                if (Array.isArray(opts) && opts.length) {
                    opts.forEach(opt => {

                        const qId = opt.qOptionId ?? opt.qoptionId ?? opt.optionId;
                        if (qId !== undefined) {
                            dependentOptionPrices.push({
                                optionId: qId,
                                costPrice: opt.costPrice ?? 0,
                                sellPrice: opt.sellPrice ?? 0
                            });
                        }
                    });
                }
            });


            questionsToRender.forEach(question => {

                question.questionId = question.questionId ?? question.id ?? question.QuestionId;

                if (!question.options && Array.isArray(question.questionOptions)) {
                    question.options = question.questionOptions;
                }
                const questionElement = this.templateManager.renderer.renderQuestion(question, true);

                $target.removeClass("hidden").append(questionElement);
            });

            this.setupConditionalQuestionHandlers();

            if (window.formManager && typeof window.formManager.reinitializeDropdowns === 'function') {
                window.formManager.reinitializeDropdowns();
            }

            if (dependentOptionPrices.length) {
                window.optionPrices = window.optionPrices ? window.optionPrices.concat(dependentOptionPrices) : dependentOptionPrices;
            }
        } catch (error) {
            console.error('❌ Error loading dependent questions:', error);
            $target.html(`<div class="error-c">Failed to load questions: ${error.message}</div>`);
        }
    }

}

// ========================================
// 🚀 APPLICATION BOOTSTRAP
// ========================================
document.addEventListener('DOMContentLoaded', () => {
    window.templatePreviewManager = new TemplatePreviewManager();
});

// ========================================
// 🔧 COMPATIBILITY: Initialize Form Manager for Preview
// ========================================
document.addEventListener('DOMContentLoaded', function () {
    if (typeof FormInteractionManager !== 'undefined') {
        window.formManager = new FormInteractionManager();

        if (window.formManager && window.formManager.setupRequiredFieldValidation) {
            window.formManager.setupRequiredFieldValidation = function () {
                console.log('🔸 Preview mode: Skipping required field validation');
            };
        }
    }
});

console.log('🚀 template_preview.js loaded with class-based architecture');
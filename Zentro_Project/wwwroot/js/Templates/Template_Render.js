// 🏗️ MAIN CLASS: TemplatePreviewManager
class TemplatePreviewManager {
    constructor() {
        this.templateData = null;
        this.apiService = new TemplatePreviewApiService();
        this.renderer = new TemplatePreviewRenderer();
        this.eventManager = new TemplatePreviewEventManager();
        this.setupBackButtonHandler();
        this.init();
    }

    async init() {
        try {
            await this.loadTemplateData();
            this.setupEventDelegation();
            console.log('✅ TemplatePreviewManager initialized');
        } catch (error) {
            this.handleError('Initialization failed', error);
        }
    }
    setupBackButtonHandler() {
        document.addEventListener('click', (e) => {
            const backButton = e.target.closest('#backButton, .back-button-c');
            if (backButton) {
                // PREVENT DEFAULT BEHAVIOR - This is crucial
                e.preventDefault();
                e.stopPropagation();
                e.stopImmediatePropagation();

                console.log('Back button clicked - navigating to templates');
                window.location.href = '/page/templates';
            }
        }, true); // Use capture phase to handle event first
    }


    async loadTemplateData() {
        const templateVersionId = this.getTemplateVersionId();
        if (!templateVersionId) {
            throw new Error('TemplateVersionId not found');
        }

        this.templateData = await this.apiService.fetchRootQuestions(templateVersionId);
        const nameResponse = await this.apiService.fetchTemplateName(templateVersionId);
        if (nameResponse.success && nameResponse.templateName) {
            document.querySelector('.main-heading-c').textContent = nameResponse.templateName;
        }
        console.log('📊 Template Data Loaded:', this.templateData);

        this.renderer.renderTemplate(this.templateData);

        // Build option prices map for dependent questions
        this.buildOptionPricesMap(this.templateData);

        await this.loadMetafields(templateVersionId);
    }

    buildOptionPricesMap(data) {
        window.optionPricesMap = {};

        const questionGroups = Array.isArray(data) ? data : (data.dbQuestionGroups || data.questionGroups || []);

        questionGroups.forEach(group => {
            if (group.questions) {
                group.questions.forEach(question => {
                    if (question.options) {
                        question.options.forEach(opt => {
                            window.optionPricesMap[opt.qOptionId] = {
                                costPrice: opt.costPrice || 0,
                                sellPrice: opt.sellPrice || 0
                            };
                        });
                    }
                });
            }
        });
    }

    // LoadMetaField
    async loadMetafields(templateVersionId) {
        try {
            const response = await this.apiService.makeRequest(
                '/api/Metafield/GetMetafieldsForPreview',
                {
                    method: 'POST',
                    credentials: 'same-origin',
                    headers: {
                        'Accept': 'application/json',
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({ templateVersionId })
                }
            );

            if (response.success && response.data && response.data.length > 0) {
                this.metafields = response.data;
                this.renderer.renderMetafields(this.metafields);
                console.log('✅ Metafields loaded:', this.metafields);
            } else {
                console.log('ℹ️ No metafields found');
            }
        } catch (error) {
            console.error('❌ Error loading metafields:', error);
        }
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
        alert(`Failed to ${context.toLowerCase()}`);
    }
}

// 🌐 API SERVICE CLASS
class TemplatePreviewApiService {
    async fetchRootQuestions(templateVersionId) {
        const url = this.buildUrl('/api/common/GetTemplateDetais', { templateVersionId });
        return this.makeRequest(url);
    }

    async fetchDependentQuestions(templateVersionId, optionId) {
        const url = this.buildUrl('/api/common/GetDependentQuestionDetais', {
            templateVersionId,
            dependentQuestionId: optionId
        });
        return this.makeRequest(url);
    }

    async fetchTemplateName(templateVersionId) {
        const url = this.buildUrl('/api/Template/GetTemplateName', { templateVersionId });
        return this.makeRequest(url);
    }
    buildUrl(endpoint, params) {
        const url = new URL(endpoint, window.location.origin);
        Object.entries(params).forEach(([key, value]) => {
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

// 🎨 RENDERER CLASS
class TemplatePreviewRenderer {
    constructor() {
        this.container = document.getElementById('question-render-root');
    }

    renderTemplate(data) {
        if (!this.container) {
            throw new Error('Question container not found');
        }

        this.renderQuestions(data);
        this.expandFirstGroup();
    }

    renderQuestions(data) {
        this.container.innerHTML = '';

        const questionGroups = Array.isArray(data) ? data : (data.dbQuestionGroups || data.questionGroups || []);

        if (!questionGroups || questionGroups.length === 0) {
            this.container.innerHTML = '<p class="text-center">No question groups found.</p>';
            return;
        }

        console.log(`📊 Rendering ${questionGroups.length} question groups`);
        questionGroups.forEach((group, index) => {
            const groupElement = this.createGroupElement(group, index);
            this.container.appendChild(groupElement);
        });
    }

    createGroupElement(group, index) {
        const itemDiv = this.createDOMElement('div', { className: 'item-c' });

        const headerWrapper = this.createDOMElement('div', { className: 'section-container-c' });
        const header = this.createGroupHeader(group, index);
        headerWrapper.appendChild(header);
        itemDiv.appendChild(headerWrapper);

        const sectionDiv = this.createGroupSection(group, index);
        itemDiv.appendChild(sectionDiv);

        return itemDiv;
    }

    createGroupHeader(group, index) {
        const header = this.createDOMElement('header', {
            className: `dropdown-header-c parentToggler shadow-c ${index === 0 ? 'auto-open' : ''}`,
            id: `capsule-${group.questionGroupId}`
        });

        header.innerHTML = `
            <span class="dropdown-header-text-c">${this.escapeHtml(group.questionGroupName)}</span>
            <span class="carrot-c">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
                    <path stroke-linecap="round" stroke-linejoin="round" d="m19.5 8.25-7.5 7.5-7.5-7.5" />
                </svg>
            </span>
            <div class="section-line-breaker-c hidden"></div>
        `;

        return header;
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

    renderQuestion(question) {
        const questionDiv = this.createDOMElement('div', {
            className: 'question-bottom-margins-c',
            attributes: {
                'data-is-required': question.isRequired ? 'true' : 'false',
                'data-question-id': question.questionId
            }
        });

        const headingHTML = `
            <h2 class="section-subheading-c no-margin-c">
                ${this.escapeHtml(question.questionText)}
                ${question.isRequired ? '<span class="required-asterisk-c">*</span>' : ''}
            </h2>
            <input type="hidden" name="Answers[${question.questionId}].QuestionId" value="${question.questionId}" />
        `;

        questionDiv.innerHTML = headingHTML;

        const fieldType = this.getFieldType(question);
        this.renderQuestionOptions(questionDiv, question, fieldType);

        return questionDiv;
    }

    renderQuestionOptions(container, question, fieldType) {
        const sortedOptions = question.options
            ? [...question.options].sort((a, b) => (a.optionDisplayOrder || 0) - (b.optionDisplayOrder || 0))
            : [];

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
        sortedOptions.forEach((opt, index) => {
            const checkboxDiv = this.createDOMElement('div', {
                className: `checkbox-wrapper-c ${index > 0 ? 'less-top-margin-c' : ''}`
            });

            checkboxDiv.innerHTML = `
                <input type="checkbox"
                    id="q-${question.questionId}-opt-${opt.qOptionId}"
                    name="Answers[${question.questionId}].SelectedOptionId"
                    value="${opt.qOptionId}"
                    class="radio-style-c single-select-c"
                    data-questionid="${question.questionId}"
                    data-optionid="${opt.qOptionId}"
                    data-toggle="conditional"
                />
                <label class="checkbox-text-c" for="q-${question.questionId}-opt-${opt.qOptionId}">
                    ${this.escapeHtml(opt.optionText)}
                </label>
            `;

            container.appendChild(checkboxDiv);
        });

        const dependentDiv = this.createDOMElement('div', {
            className: 'dependent-section-c hidden',
            attributes: { 'data-question': question.questionId }
        });
        container.appendChild(dependentDiv);
    }

    renderRadioButtons(container, question, sortedOptions) {
        sortedOptions.forEach((opt, index) => {
            const radioDiv = this.createDOMElement('div', {
                className: `checkbox-wrapper-c ${index > 0 ? 'less-top-margin-c' : ''}`
            });

            radioDiv.innerHTML = `
                <input type="radio"
                    id="q-${question.questionId}-opt-${opt.qOptionId}"
                    name="Answers[${question.questionId}].SelectedOptionId"
                    value="${opt.qOptionId}"
                    class="radio-style-c"
                    data-questionid="${question.questionId}"
                    data-optionid="${opt.qOptionId}"
                    data-toggle="conditional"
                />
                <label class="checkbox-text-c" for="q-${question.questionId}-opt-${opt.qOptionId}">
                    ${this.escapeHtml(opt.optionText)}
                </label>
            `;

            container.appendChild(radioDiv);
        });

        const dependentDiv = this.createDOMElement('div', {
            className: 'dependent-section-c hidden',
            attributes: { 'data-question': question.questionId }
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
                                    ${sortedOptions.map(opt => `
                                        <option value="${opt.qOptionId}"
                                            data-questionid="${question.questionId}"
                                            data-optionid="${opt.qOptionId}">
                                            ${this.escapeHtml(opt.optionText)}
                                        </option>
                                    `).join('')}
                                </select>
                            </div>
                            <div class="section-input-wrapper-c less-width-select2-c">
                                <input type="number"
                                    class="section-input-c"
                                    name="Answers[${question.questionId}].LineItems[0].Quantity"
                                    min="0"
                                    value="0"
                                />
                            </div>
                            <div class="line-item-cross-container-c">
                                <button type="button" class="line-item-cross-btn-c">
                                    <img src="/images/close-cancel.svg" alt="Remove">
                                </button>
                            </div>
                        </div>
                    </div>
                    <div class="save-btn-container-c">
                        <button type="button" class="btn-save-c add-line-c" data-question="${question.questionId}">
                            Add Line Item
                        </button>
                    </div>
                </div>
            </div>
        `;

        container.innerHTML += tableHTML;

        const dependentDiv = this.createDOMElement('div', {
            className: 'dependent-section-c hidden',
            attributes: { 'data-question': question.questionId }
        });
        container.appendChild(dependentDiv);
    }

    renderSelectList(container, question, sortedOptions) {
        const selectHTML = `
            <div class="section-input-wrapper-c less-width-select-c">
                <select class="section-input-c selectt-c conditional-select"
                    name="Answers[${question.questionId}].SelectedOptionId"
                    id="q-${question.questionId}"
                    data-questionid="${question.questionId}"
                    data-toggle="conditional">
                    <option value="">Select</option>
                    ${sortedOptions.map(opt => `
                        <option value="${opt.qOptionId}"
                            data-questionid="${question.questionId}"
                            data-optionid="${opt.qOptionId}">
                            ${this.escapeHtml(opt.optionText)}
                        </option>
                    `).join('')}
                </select>
            </div>
        `;

        container.innerHTML += selectHTML;

        const dependentDiv = this.createDOMElement('div', {
            className: 'dependent-section-c hidden',
            attributes: { 'data-question': question.questionId }
        });
        container.appendChild(dependentDiv);
    }

    renderInput(container, question) {
        const inputHTML = `
            <div class="section-input-wrapper-c less-width-select-c">
                <input type="text"
                    class="section-input-c"
                    name="Answers[${question.questionId}].AnswerText"
                    id="q-${question.questionId}"
                    value=""
                />
            </div>
        `;

        container.innerHTML += inputHTML;
    }

    // ✅ ADD THIS NEW METHOD
    renderMetafields(metafields) {
        const container = document.getElementById('metafields-render-root');
        const metafieldContainer = document.getElementById('metafields-container');

        if (!container || !metafieldContainer) {
            console.error('❌ Metafield containers not found');
            return;
        }

        if (!metafields || metafields.length === 0) {
            metafieldContainer.style.display = 'none';
            return;
        }

        // Show metafield section
        metafieldContainer.style.display = 'block';
        container.innerHTML = '';

        metafields.forEach(metafield => {
            const metafieldDiv = this.createDOMElement('div', {
                className: 'question-bottom-margins-c',
                attributes: {
                    'data-metafield-id': metafield.pid
                }
            });

            const headingHTML = `
            <h2 class="section-subheading-c no-margin-c">
                ${this.escapeHtml(metafield.name)}
            </h2>
        `;

            metafieldDiv.innerHTML = headingHTML;

            const inputHTML = `
            <div class="section-input-wrapper-c less-width-select-c">
                <input type="text"
                    class="section-input-c"
                />
            </div>
        `;

            metafieldDiv.innerHTML += inputHTML;
            container.appendChild(metafieldDiv);
        });

        console.log(`✅ Rendered ${metafields.length} metafields`);
    }
    expandFirstGroup() {
        const firstHeader = document.querySelector('.dropdown-header-c.auto-open');
        const firstSection = document.querySelector('.section-container-c.auto-open-target');

        if (firstHeader && firstSection) {
            // Open first group instantly WITHOUT transition
            firstSection.classList.remove('hidden');
            firstSection.style.display = '';
            firstSection.style.overflow = '';
            firstSection.style.maxHeight = '';

            const carrotSvg = firstHeader.querySelector('.carrot-c svg');
            if (carrotSvg) {
                carrotSvg.classList.add('rotate-180-c');
            }

            firstHeader.classList.add('bottom-corners-c');
            firstHeader.classList.remove('shadow-c');
            firstHeader.classList.add('shadow-toggle-c');

            const breaker = firstHeader.querySelector('.section-line-breaker-c');
            if (breaker) {
                breaker.classList.remove('hidden');
            }

            firstHeader.style.borderRadius = '0.75rem 0.75rem 0 0';
        }
    }

    toggleGroup(header, section, forceOpen = false) {
        const isHidden = section.classList.contains('hidden');
        const shouldOpen = forceOpen ? true : isHidden;

        if (shouldOpen) {
            section.style.display = 'block';
            section.style.overflow = 'hidden';
            section.style.maxHeight = '0px';
            section.classList.remove('hidden');
            header.style.borderRadius = '0.75rem 0.75rem 0 0';

            setTimeout(() => {
                section.style.transition = 'max-height 0.4s ease';
                section.style.maxHeight = section.scrollHeight + 'px';
            }, 70);

            setTimeout(() => {
                section.style.transition = '';
                section.style.maxHeight = '';
                section.style.overflow = '';
                section.style.display = '';
            }, 310);
        } else {
            header.style.borderRadius = '0.75rem 0.75rem 0 0';
            section.style.overflow = 'hidden';
            section.style.transition = 'max-height 0.4s ease';
            section.style.maxHeight = section.scrollHeight + 'px';

            setTimeout(() => {
                section.style.maxHeight = '0px';
            }, 70);

            setTimeout(() => {
                section.classList.add('hidden');
                section.style.transition = '';
                section.style.maxHeight = '';
                section.style.overflow = '';
                section.style.display = '';
                header.style.borderRadius = '0.75rem';
            }, 310);
        }

        const carrotSvg = header.querySelector('.carrot-c svg');
        if (carrotSvg) {
            carrotSvg.classList.toggle('rotate-180-c', shouldOpen);
        }

        header.classList.toggle('bottom-corners-c', shouldOpen);
        header.classList.toggle('shadow-c');
        header.classList.toggle('shadow-toggle-c');

        const breaker = header.querySelector('.section-line-breaker-c');
        if (breaker) {
            breaker.classList.toggle('hidden', !shouldOpen);
        }
    }

    getFieldType(question) {
        const fieldType = question.fieldTypeName || question.fieldTypeDisplayName || '';
        return fieldType.toLowerCase();
    }

    escapeHtml(text) {
        if (!text) return '';
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    createDOMElement(tag, { className, id, attributes = {} }) {
        const element = document.createElement(tag);
        if (className) element.className = className;
        if (id) element.id = id;
        Object.entries(attributes).forEach(([key, value]) => {
            element.setAttribute(key, value);
        });
        return element;
    }
}

// 🎯 EVENT MANAGER CLASS
class TemplatePreviewEventManager {
    setupGlobalHandlers(manager) {
        this.manager = manager;
        this.setupGroupToggleHandlers();
        this.setupConditionalQuestionHandlers();
        this.setupTableHandlers();
        this.setupSingleCheckboxEnforcement();
    }

    setupGroupToggleHandlers() {
        const container = document.querySelector('.capsule-containers-c');
        if (!container) return;

        container.addEventListener('click', (e) => {
            const header = e.target.closest('.dropdown-header-c.parentToggler');
            if (!header) return;

            e.preventDefault();
            e.stopPropagation();

            // ✅ CHECK: Is it metafield header?
            if (header.classList.contains('metafield-header')) {
                const headerWrapper = header.closest('.section-container-c');
                const metafieldSection = headerWrapper?.nextElementSibling;

                if (metafieldSection && metafieldSection.classList.contains('metafield-section')) {
                    this.manager.renderer.toggleGroup(header, metafieldSection);
                }
                return; // EXIT - don't process as question group
            }

            // ✅ REGULAR QUESTION GROUPS
            const sectionContainer = header.closest('.section-container-c');
            const dropDown = sectionContainer?.nextElementSibling;

            if (dropDown?.classList.contains('section-container-c')) {
                this.manager.renderer.toggleGroup(header, dropDown);
            }
        });

        console.log('✅ Group toggle handlers setup');
    }

    setupTableHandlers() {
        document.addEventListener('click', (e) => {
            if (e.target.closest('.add-line-c')) {
                this.handleAddLineItem(e.target.closest('.add-line-c'));
            }
            if (e.target.closest('.line-item-cross-btn-c')) {
                this.handleRemoveLineItem(e.target.closest('.line-item-cross-btn-c'));
            }
        });

        console.log('✅ Table handlers setup');
    }

    handleAddLineItem(button) {
        const questionId = button.getAttribute('data-question');
        const container = document.getElementById(`table-rows-${questionId}`);

        if (!container) return;

        const firstSelect = container.querySelector('select');
        if (!firstSelect) return;

        const maxRows = firstSelect.options.length - 1;
        const currentRows = container.querySelectorAll('.selects-wrapper-c').length;
        if (currentRows >= maxRows) return;

        const newIndex = currentRows;
        const newRow = document.createElement('div');
        newRow.className = 'selects-wrapper-c';

        newRow.innerHTML = `
            <div class="section-input-wrapper-c less-width-select2-c">
                <select class="section-input-c selectt-c conditional-select"
                        name="Answers[${questionId}].LineItems[${newIndex}].OptionId"
                        data-toggle="conditional"
                        data-questionid="${questionId}">
                    ${firstSelect.innerHTML}
                </select>
            </div>
            <div class="section-input-wrapper-c less-width-select2-c">
                <input type="number"
                       class="section-input-c"
                       name="Answers[${questionId}].LineItems[${newIndex}].Quantity"
                       min="0" value="0" />
            </div>
            <div class="line-item-cross-container-c">
                <button type="button" class="line-item-cross-btn-c">
                    <img src="/images/close-cancel.svg" alt="Remove">
                </button>
            </div>
        `;

        container.appendChild(newRow);
        console.log(`➕ Added line item for question ${questionId}`);
    }

    handleRemoveLineItem(removeButton) {
        const row = removeButton.closest('.selects-wrapper-c');
        const container = row?.closest('.selects-container-c');
        const wrappers = container ? container.querySelectorAll('.selects-wrapper-c') : [];

        if (container && wrappers.length > 1) {
            row.remove();
            console.log('➖ Removed line item');
        } else if (container && wrappers.length === 1) {
            const select = row.querySelector('select');
            const input = row.querySelector('input[type="number"]');
            if (select) select.selectedIndex = 0;
            if (input) input.value = 0;
            console.log('🔄 Reset last line item');
        }
    }

    setupConditionalQuestionHandlers() {
        document.addEventListener('change', async (e) => {
            if (!e.target.matches('[data-toggle=conditional]')) return;

            const input = e.target;
            const questionDiv = input.closest('.question-bottom-margins-c');
            const questionIdInput = questionDiv?.querySelector('input[type=hidden][name$=".QuestionId"]');
            const questionId = questionIdInput?.value;

            if (!questionId) return;

            const dependentContainer = questionDiv.querySelector('.dependent-section-c');
            if (dependentContainer) {
                dependentContainer.classList.add('hidden');
                dependentContainer.innerHTML = '';
            }

            if (input.checked || (input.tagName === 'SELECT' && input.value)) {
                const optionId = parseInt(input.value);
                const templateVersionId = this.manager.getTemplateVersionId();

                try {
                    const result = await this.manager.apiService.fetchDependentQuestions(templateVersionId, optionId);
                    if (result && Array.isArray(result) && result.length > 0) {
                        this.renderDependentQuestions(optionId, result, questionId, questionDiv);
                    }
                } catch (error) {
                    console.error('❌ Error fetching dependent questions:', error);
                }
            }
        });

        console.log('✅ Conditional question handlers setup');
    }

    renderDependentQuestions(optionId, dependentData, parentQuestionId, parentQuestionDiv) {
        const dependentSection = parentQuestionDiv.querySelector('.dependent-section-c');
        if (!dependentSection) return;

        dependentSection.classList.remove('hidden');
        dependentSection.innerHTML = '';

        const questionsToRender = [];
        dependentData.forEach(item => {
            if (item && Array.isArray(item.questions) && item.questions.length) {
                item.questions.forEach(q => questionsToRender.push(q));
            } else if (item && (item.questionId || item.fieldTypeName || item.questionText)) {
                questionsToRender.push(item);
            }
        });

        questionsToRender.forEach(question => {
            question.questionId = question.questionId ?? question.id ?? question.QuestionId;
            if (!question.options && Array.isArray(question.questionOptions)) {
                question.options = question.questionOptions;
            }

            const questionElement = this.manager.renderer.renderQuestion(question);
            dependentSection.appendChild(questionElement);

            // Add option prices to map
            if (question.options) {
                question.options.forEach(opt => {
                    const qId = opt.qOptionId ?? opt.qoptionId ?? opt.optionId;
                    if (qId !== undefined && window.optionPricesMap) {
                        window.optionPricesMap[qId] = {
                            costPrice: opt.costPrice ?? 0,
                            sellPrice: opt.sellPrice ?? 0
                        };
                    }
                });
            }
        });

        console.log(`✅ Rendered dependent questions for option ${optionId}`);
    }

    setupSingleCheckboxEnforcement() {
        document.addEventListener('change', function (e) {
            if (e.target.matches('input[type=checkbox].single-select-c')) {
                const groupName = e.target.name;
                if (groupName) {
                    document.querySelectorAll(`input[type=checkbox][name="${groupName}"]`).forEach(cb => {
                        if (cb !== e.target) cb.checked = false;
                    });
                }
            }
        });
    }
}

// 🚀 APPLICATION BOOTSTRAP
document.addEventListener('DOMContentLoaded', () => {
    window.templatePreviewManager = new TemplatePreviewManager();
});

console.log('🚀 template_preview.js loaded - Preview Only Mode');
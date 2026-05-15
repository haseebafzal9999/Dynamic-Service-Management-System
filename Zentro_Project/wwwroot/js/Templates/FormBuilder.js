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

        console.log(`?? Template status determined:`, {
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

        // ? FIX: Count only visible (non-deleted) answers
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

            // ? Count original answers from the question element (excluding deleted)
            const originalAnswerCount = Array.from(
                this.questionManager.editingDiv2.querySelectorAll('.sub-value')
            ).filter(div => div.dataset.isDeleted !== 'true').length;

            // ? Count current visible answers in modal
            const currentAnswerCount = visibleAnswers.length;

            // ? Check if any answers are marked for deletion in the modal
            const deletedAnswersInModal = Array.from(this.answersContainer.children)
                .filter(div => div.dataset.isDeleted === 'true');
            const hasDeletedAnswers = deletedAnswersInModal.length > 0;

            // ? Compare answer counts - if different, there's a change
            const answerCountChanged = originalAnswerCount !== currentAnswerCount;

            // ? Also check for content changes in remaining answers
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

            // ? CRITICAL: hasDeletedAnswers OR answerCountChanged OR contentChanged = change detected
            const answersChanged = hasDeletedAnswers || answerCountChanged || contentChanged;

            const hasChanges = textChanged || groupChanged || fieldTypeChanged || isRequiredChanged || answersChanged;

            // ? For field types that require answers, check if we still have enough
            const isValid = nameFilled && (
                HIDDEN_VALUES.includes(fieldValue) ||
                (ANSWERS_REQUIRED.includes(fieldValue) && hasAnswers)
            );

            canCreate = isValid && hasChanges;

            console.log('?? toggleQuestionValidation DEBUG:', {
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
        console.log('?????? UPDATING EXISTING QUESTION - DEBUG START ??????');

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

            let answerId = 0;
            if (answerDiv.dataset.id && parseInt(answerDiv.dataset.id) > 0) {
                answerId = parseInt(answerDiv.dataset.id);
            } else if (answerDiv.dataset.originalId && parseInt(answerDiv.dataset.originalId) > 0) {
                answerId = parseInt(answerDiv.dataset.originalId);
            }

            return {
                Id: answerId,
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
                OptionGuid: answerDiv.dataset.optionGuid || '',
                OptionStatus: (answerDiv.dataset.optionStatus ||
                    (isDeleted ? 'deleted' :
                        ((answerDiv.dataset.id && parseInt(answerDiv.dataset.id) > 0) ? 'updated' : 'new')))
            };
        });

        try {
            // Resolve groupId and groupGuid by current group name
            const selectedGroupName = this.groupSelect.value.trim();
            let groupId = 0;
            let groupGuid = '';

            const header = document.querySelector(`.question-group-header[data-group-name="${selectedGroupName}"]`);
            const addBtn = document.querySelector(`.group-add-button[data-group-name="${selectedGroupName}"]`);
            if (header && header.dataset.groupId) {
                groupId = parseInt(header.dataset.groupId || '0', 10);
            } else if (addBtn && addBtn.dataset.groupId) {
                groupId = parseInt(addBtn.dataset.groupId || '0', 10);
            }

            if (!groupId || groupId <= 0) {
                const groupContainers = document.querySelectorAll('.saved-txt.group-container, .saved-txt.stored-overlay');
                for (const g of groupContainers) {
                    const nameSpan = g.querySelector('.main-value span');
                    const matches = nameSpan && nameSpan.textContent.trim() === selectedGroupName;
                    if (matches) {
                        groupId = parseInt(g.dataset.id || '0', 10);
                        groupGuid = (g.dataset.groupGuid || '').trim();
                        if (groupId > 0) break;
                    }
                }
            }

            if ((!groupId || groupId <= 0) && this.groupManager?.container) {
                const allGroups = this.groupManager.container.querySelectorAll('.saved-txt');
                for (const groupDiv of allGroups) {
                    const span = groupDiv.querySelector('.main-value span');
                    if (span && span.textContent.trim() === selectedGroupName) {
                        groupId = parseInt(groupDiv.dataset.id || '0', 10);
                        groupGuid = groupDiv.dataset.groupGuid || '';
                        break;
                    }
                }
            }

            if (!groupId || groupId <= 0) {
                const groupElement = document.querySelector(`.saved-txt.stored-overlay span`);
                if (groupElement && groupElement.textContent.includes(selectedGroupName)) {
                    const groupWrapper = groupElement.closest('.saved-txt');
                    groupId = parseInt(groupWrapper?.dataset.id || '0', 10);
                    groupGuid = groupWrapper?.dataset.groupGuid || '';
                }
            }

            if (!groupId || groupId <= 0) {
                throw new Error(`Could not find group ID for group: ${selectedGroupName}.`);
            }

            // Retrieve QuestionGuid robustly
            let questionGuid = qEl.dataset.questionGuid || qEl.getAttribute('data-question-guid') || '';
            if (!questionGuid || questionGuid === 'undefined') {
                const guidAttr = qEl.querySelector('[data-question-guid]');
                if (guidAttr) questionGuid = guidAttr.dataset.questionGuid || '';
            }

            const questionData = {
                Id: parseInt(qEl.dataset.id || '0', 10),
                Text: value,
                GroupId: groupId,
                GroupGuid: groupGuid,
                FieldTypeId: parseInt(this.fieldTypeSelect.value, 10),
                Order: parseInt(qEl.dataset.order || '1', 10),
                IsRequired: this.isRequiredCheckbox.checked,
                TemplateVersionId: templateVersionId,
                Answers: answers,
                QuestionGuid: questionGuid
            };

            console.log('?? Full payload:', JSON.stringify(questionData, null, 2));

            const response = await fetch('/api/Template/CreateQuestion', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(questionData)
            });

            if (!response.ok) {
                const errorText = await response.text();
                throw new Error('Failed to update question: ' + errorText);
            }

            const result = await response.json();

            // Persist returned QuestionGuid
            if (result.questionGuid) {
                qEl.dataset.questionGuid = result.questionGuid;
                qEl.setAttribute('data-question-guid', result.questionGuid);
            }

            // Update answer IDs/OptionGuid from server
            if (result.answers && Array.isArray(result.answers)) {
                Array.from(this.answersContainer.children).forEach(answerDiv => {
                    if (answerDiv.dataset.isDeleted === 'true') return;

                    const text = answerDiv.querySelector('span')?.textContent.trim();
                    const order = parseInt(answerDiv.dataset.order || '0', 10);

                    const match = result.answers.find(a => (a.text === text || a.Text === text) &&
                        (a.order === order || a.Order === order)
                    );

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
            console.log('? Question updated.');
        } catch (error) {
            console.error('? Update question error:', error);
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

        handleModal1Cancel(); {
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

        handleModal2Cancel(); {
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

        closeAnswerModal(); {
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

        async; handleDynamicDropdownChange(event, wrapper); {
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

        async; createDropdown(type); {
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

        async; loadOptions(type); {
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

        makeDraggable(element, container); {
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

        //toggleQuestionValidation() {
        //    const HIDDEN_VALUES = ['5', '6', '7'];
        //    const ANSWERS_REQUIRED = ['1', '2', '3', '4'];
        //    const isHidden = HIDDEN_VALUES.includes(this.fieldTypeSelect.value);
        //    const displayStyle = isHidden ? 'none' : 'block';
        //    document.getElementById('addbtnmodal1').style.display = displayStyle;
        //    document.getElementById('subheadingbold').style.display = displayStyle;
        //    const nameFilled = this.inputField2.value.trim().length > 0;
        //    const fieldValue = this.fieldTypeSelect.value;
        //    const hasAnswers = this.answersContainer.children.length > 0;
        //    let canCreate = false;
        //    if (this.questionManager.editingDiv2) {
        //        const originalText = this.questionManager.editingDiv2.querySelector('.main-value span').textContent;
        //        const originalGroup = this.questionManager.editingDiv2.dataset.group;
        //        const originalFieldType = this.questionManager.editingDiv2.dataset.fieldType;
        //        const originalIsRequired = this.questionManager.editingDiv2.dataset.isRequired === 'true';
        //        const textChanged = this.inputField2.value.trim() !== originalText;
        //        const groupChanged = this.groupSelect.value !== originalGroup;
        //        const fieldTypeChanged = this.fieldTypeSelect.value !== originalFieldType;
        //        const isRequiredChanged = this.isRequiredCheckbox.checked !== originalIsRequired;
        //        // Improved answer comparison logic
        //        const originalAnswers = Array.from(this.questionManager.editingDiv2.querySelectorAll('.sub-value')).map(div => ({
        //            text: div.querySelector('span').textContent,
        //            mainSelect: div.dataset.mainSelect,
        //            answerSelect: div.dataset.answerSelect,
        //            dynamicSelect: div.dataset.dynamicSelect,
        //            id: div.dataset.id || div.dataset.tempId
        //        }));
        //        const currentAnswers = Array.from(this.answersContainer.children).map(div => ({
        //            text: div.querySelector('span').textContent,
        //            mainSelect: div.dataset.mainSelect,
        //            answerSelect: div.dataset.answerSelect,
        //            dynamicSelect: div.dataset.dynamicSelect,
        //            id: div.dataset.id || div.dataset.tempId
        //        }));
        //        // Compare all properties, not just JSON string
        //        const answersChanged = originalAnswers.length !== currentAnswers.length ||
        //            originalAnswers.some((orig, index) => {
        //                const curr = currentAnswers[index];
        //                if (!curr) return true;
        //                return orig.text !== curr.text ||
        //                    orig.mainSelect !== curr.mainSelect ||
        //                    orig.answerSelect !== curr.answerSelect ||
        //                    orig.dynamicSelect !== curr.dynamicSelect ||
        //                    orig.id !== curr.id;
        //            });
        //        const hasChanges = textChanged || groupChanged || fieldTypeChanged || isRequiredChanged || answersChanged;
        //        const isValid = nameFilled && (
        //            HIDDEN_VALUES.includes(fieldValue) ||
        //            (ANSWERS_REQUIRED.includes(fieldValue) && hasAnswers)
        //        );
        //        canCreate = isValid && hasChanges;
        //    } else {
        //        canCreate = nameFilled && (
        //            HIDDEN_VALUES.includes(fieldValue) ||
        //            (ANSWERS_REQUIRED.includes(fieldValue) && hasAnswers)
        //        );
        //    }
        //    $('#modal1-create-button').toggleClass('btn-disable', !canCreate);
        //}
        //toggleAnswerValidation() {
        //    const $quoteTemplateModel2 = $('#quoteTemplate22');
        //    const $mainSelect2 = $('#mainSelect2');
        //    const $saveButtonModal2 = $('#create-button4');
        //    const hasText = $quoteTemplateModel2.val().trim().length > 0;
        //    const hasMainSelect = $mainSelect2.val() && $mainSelect2.val().trim() !== '' && $mainSelect2.val() !== 'Select';
        //    const $dyn = $('.dynamic-select');
        //    const hasDynamicSelect = $dyn.length > 0 ?
        //        ($dyn.val() && $dyn.val().trim() !== '' && $dyn.val() !== 'Select') : false;
        //    const canSave = hasText || (hasMainSelect || hasDynamicSelect);
        //    const wasDisabled = $saveButtonModal2.hasClass('btn-disable');
        //    $saveButtonModal2.toggleClass('btn-disable', !canSave);
        //    if (wasDisabled && canSave) {
        //        $(document).trigger('answerModelChanged');
        //    }
        //}
        // Replace the ENTIRE deactivateTemplate method in FormBuilder class:
        async; deactivateTemplate(e); {
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


        previewTemplate(); {
            const templateVersionId = document.getElementById('template-data')?.dataset.tempVersionId;

            if (!templateVersionId || templateVersionId === '0') {
                alert('Please save template before preview');
                return;
            }

            window.open(
                `/page/template/preview/${templateVersionId}`,
                '_blank'
            );
        }



        saveForm(); {
            const data = this.exportData();
            this.ajaxSaveForm('SaveTemplate', data);
        }

        async; handleVersionChange(); {
            const templateData = document.getElementById('template-data');
            const currentId = parseInt(templateData?.dataset.tempVersionId || '0', 10) || 0;

            // Prefer centralized version control in version-manager
            if (window.versionControl && typeof window.versionControl.requestVersionIfNeeded === 'function') {
                const newId = await window.versionControl.requestVersionIfNeeded();
                const effectiveId = newId || currentId;

                // ? CRITICAL: persist new version id into DOM
                if (templateData && effectiveId && effectiveId > 0) {
                    templateData.dataset.tempVersionId = String(effectiveId);
                    templateData.dataset.templateVersionId = String(effectiveId);
                }

                return effectiveId;
            }

            return currentId;
        }



        exportData(); {
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
                Template: template,
                TemplateVersion: templateVersion,
                QuestionGroups: groups,
                QuestionAnswers: questions,
                IsNewTemplate: isNewTemplate
            };
        }

        ajaxSaveForm(action, data); {
            console.log('?? FRONTEND PAYLOAD ?', {
                action,
                data: JSON.parse(JSON.stringify(data))
            });

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
                        // ? CRITICAL FIX: For save, update the page without redirect
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

        // ? Add this new method to handle save success
        handleSaveSuccess(response); {
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

        // ? Add this method to show a temporary success message
        showSaveSuccessNotification(); {
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

        hydrateExistingData(); {
            this.hydrateExistingGroups();
            this.hydrateExistingQuestions();
            this.groupManager.updateWrapperStyles();
            this.groupManager.updateRoundedCorners();
            this.determineAndSetTemplateNewStatus();
        }

        hydrateExistingGroups(); {
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

        hydrateExistingQuestions(); {
            if (!this.questionsList) return;

            const existingQuestions = this.questionsList.querySelectorAll('.saved-txt:not(.sub-value)');
            existingQuestions.forEach(q => {
                // ? FIX: Ensure dataset.questionGuid is set from attribute if present
                const attrGuid = q.getAttribute('data-question-guid');
                if (attrGuid && attrGuid !== 'undefined' && attrGuid !== '') {
                    q.dataset.questionGuid = attrGuid;
                    console.log('? Hydrated question with GUID:', attrGuid, 'Text:', q.querySelector('.main-value span')?.textContent);
                } else {
                    console.warn('?? Question missing GUID during hydration:', q.querySelector('.main-value span')?.textContent);
                }

                // ? FIX: Also hydrate answer GUIDs
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

        normalize(value); {
            if (!value || value === '[]' || value === 'Select') return '';
            return value.toString().trim();
        }
    }
}

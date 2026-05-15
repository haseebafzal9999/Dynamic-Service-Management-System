
class TemplateBuilderManager {
    constructor() {
        this.templateDataEl = document.getElementById("template-data");
        if (!this.templateDataEl) return;

        this.tempVersionId = this.templateDataEl.dataset.tempVersionId;
        this.isInitialized = false;
        this.isBuilderInitialized = false; // ⚠️ ADD THIS FLAG
        this.init();
    }


    init() {
        this.registerEvents();
        this.loadTemplateData();
        this.fetchAndSetTemplateId();
        setTimeout(() => {
            this.checkQuotesOnCurrentVersion();
        }, 1000);

    }

    fetchAndSetTemplateId() {
        if (!this.tempVersionId) return;
        $.ajax({
            url: `/api/Template/GetTemplateIdByVersion`,
            type: "GET",
            data: { templateVersionId: this.tempVersionId },
            success: (result) => {
                if (result && result.success && result.templateId) {
                    $("#templateIdHolder").val(result.templateId);
                }
            },
            error: (err) => {
                console.error("Error fetching templateId:", err);
            }
        });
    }


    registerEvents() {
        $(document).on("click", ".version-btn", (e) => {
            e.preventDefault();
            const versionId = $(e.currentTarget).data("version-id");
            this.redirectToVersion(versionId);
        });
    }


    redirectToVersion(versionId) {
        window.location.href = `/page/template/${versionId}`;
    }


    loadTemplateData() {
        $.ajax({
            url: `/api/Template/TemplateDetail/GetData`,
            type: "GET",
            data: { id: this.tempVersionId },
            success: (result) => this.onDataLoaded(result),
            error: (err) => this.onError(err)
        });
    }
    // Normalize GUID property names coming from backend (supports PascalCase / camelCase)
    normalizeResponseGuids(result) {
        if (!result) return;
        if (Array.isArray(result.questionAnswers)) {
            result.questionAnswers.forEach(q => {
                // ✅ FIX: Normalize QuestionGuid
                q.questionGuid = q.questionGuid || q.QuestionGuid || q.QuestionGUID || q.questionGUID || "";

                // Normalize GroupGuid
                q.groupGuid = q.groupGuid || q.GroupGuid || q.GroupGUID || "";

                if (!q.questionGuid) {
                    console.warn('⚠️ Question missing GUID:', q.questionText || q.QuestionText || q.text);
                }

                // ✅ FIX: Process answers OUTSIDE the missing GUID check
                if (Array.isArray(q.answers)) {
                    q.answers.forEach(a => {
                        // Normalize OptionGuid/AnswerGuid
                        a.optionGuid = a.optionGuid || a.OptionGuid || a.optionGUID || a.OptionGUID || "";
                        a.answerGuid = a.answerGuid || a.AnswerGuid || a.optionGuid || "";

                        if (!a.optionGuid) {
                            console.warn('⚠️ Answer missing OptionGuid:', a.option || a.Option || a.text);
                        }

                        // ✅ CRITICAL FIX: Normalize SelectedQuestionsList - MOVED OUTSIDE the if block
                        let selectedQuestions = a.SelectedQuestionsList ||
                            a.selectedQuestionsList ||
                            a.SelectedQuestions ||
                            a.selectedQuestions ||
                            [];

                        // Convert string to array if needed
                        if (typeof selectedQuestions === 'string' && selectedQuestions.trim()) {
                            selectedQuestions = selectedQuestions.split(',').filter(id => id.trim());
                        }

                        // Ensure it's an array
                        if (!Array.isArray(selectedQuestions)) {
                            selectedQuestions = [];
                        }

                        // Store normalized value in BOTH cases
                        a.SelectedQuestionsList = selectedQuestions;
                        a.selectedQuestionsList = selectedQuestions;

                        console.log('✅ Normalized SelectedQuestionsList for answer:', a.option, selectedQuestions);
                    });
                }
            });
        }

        // Also normalize versions if necessary
        if (result.selectedVersion) {
            result.selectedVersion.tempVersion = result.selectedVersion.tempVersion ?? result.selectedVersion.TempVersion;
        }
        if (Array.isArray(result.allVersions)) {
            result.allVersions.forEach(v => v.tempVersion = v.tempVersion ?? v.TempVersion);
        }
    }

    onDataLoaded(result) {
        // Ensure GUID properties are normalized before DOM construction
        try {
            this.normalizeResponseGuids(result);
        } catch (err) {
            console.warn("normalizeResponseGuids error:", err);
        }
        const ajaxPromises = this.fetchAnswerMaterialData(result);

        $.when.apply($, ajaxPromises).always(() => {
            this.populateTemplateUI(result);
            this.updateFirstVersionFlag();

            // ⚠️ Initialize builder only once
            this.initializeBuilderOnce();
        });

        if (ajaxPromises.length === 0) {
            this.populateTemplateUI(result);
            this.updateFirstVersionFlag();

            // ⚠️ Initialize builder only once
            this.initializeBuilderOnce();
        }
    }
    initializeBuilderOnce() {
        if (!this.isBuilderInitialized && typeof initializeBuilder === "function") {
            console.log("Initializing FormBuilder...");
            initializeBuilder();
            this.isBuilderInitialized = true;
        } else {
            console.log("FormBuilder already initialized, skipping...");
        }
    }


    fetchAnswerMaterialData(result) {
        const ajaxPromises = [];

        if (result.questionAnswers && result.questionAnswers.length > 0) {
            result.questionAnswers.forEach((question) => {
                if (question.answers && question.answers.length > 0) {
                    question.answers.forEach((answer) => {
                        this.initializeAnswerProperties(answer);

                        const optionId = answer.id || answer.Id;
                        if (optionId) {
                            const promise = this.fetchMaterialDataForAnswer(answer, optionId);
                            ajaxPromises.push(promise);
                        }
                    });
                }
            });
        }

        return ajaxPromises;
    }

    initializeAnswerProperties(answer) {
        answer.SelectedMatComId = answer.SelectedMatComId ?? null;
        answer.SelectedOption = answer.SelectedOption ?? null;
        // ensure answer GUID properties exist (after normalization)
        answer.answerGuid = answer.answerGuid || answer.optionGuid || "";
        answer.optionGuid = answer.optionGuid || answer.answerGuid || "";
    }

    fetchMaterialDataForAnswer(answer, optionId) {
        return $.ajax({
            url: `/api/template/ByOptionId`,
            type: "GET",
            data: { optionId: optionId },
            dataType: "json"
        }).done((response) => {
            this.updateAnswerWithMaterialData(answer, response);
        }).fail(() => {
            answer._matCompType = answer._matCompType ?? null;
        });
    }


    updateAnswerWithMaterialData(answer, materialData) {
        answer.SelectedMatComId = materialData.materialCompId ?? materialData.MaterialCompId ?? null;
        answer.SelectedOption = materialData.name ?? materialData.Name ?? null;
        answer._matCompType = materialData.matCompName ?? materialData.MatCompName ?? null;
    }


    populateTemplateUI(result) {
        this.populateHeader(result);
        this.populateVersions(result);
        this.populateStatus(result);
        this.populateGeneralInfo(result);
        this.populateGroups(result);
        this.populateQuestions(result);
        this.populateFieldTypes(result);
        this.populateGroupDropdown(result);
        this.populateAboutTemplateModal(result);

    }


    onError(err) {
        console.error("Error fetching template data:", err);
    }


    populateHeader(result) {
        $("#templateHeading").text(result.template?.name || "Untitled Template");

        const latestVersion = result.latestVersion?.tempVersion || 0;
        document.getElementById('latestVersionHolder').value = latestVersion;

        const selectedVersion = result.selectedVersion?.tempVersion ||
            result.latestVersion?.tempVersion ||
            "N/A";

        $("#versionDropdownBtn").text(`Version ${selectedVersion}`);
        $("#versionsDropDownForm").attr("action", "/page/template/");
    }

    populateVersions(result) {
        const $versionList = $("#versionList");
        $versionList.empty();

        (result.allVersions || []).forEach(version => {
            const $item = $(this.buildVersionItem(version));
            $versionList.append($item);
        });
    }


    buildVersionItem(version) {
        return `
            <div class="dropdown-item">
                <img src="/images/template-versions.svg" class="dropdown-icon" />
                <button type="submit" data-version-id="${version.templateVersionId}" class="dropdown-text version-btn">
                    Version ${version.tempVersion}
                </button>
            </div>
        `;
    }


    populateStatus(result) {
        const isActive = result.isActive === true;

        const iconHtml = isActive
            ? `<path fill="red" d="M6 6l12 12M6 18L18 6" stroke="red" stroke-width="2" />`
            : `<path fill="green" d="M9 16.2l-3.5-3.5 1.4-1.4L9 13.4l7.1-7.1 1.4 1.4L9 16.2z" />`;

        $("#templateStatusIcon")
            .attr("xmlns", "http://www.w3.org/2000/svg")
            .attr("viewBox", "0 0 24 24")
            .html(iconHtml);

        $("#deactivateTemplate")
            .attr("data-active", isActive)
            .text(isActive ? "Deactivate Template" : "Activate Template");
    }

    populateGeneralInfo(result) {
        $("#templateName").val(result.template?.name || "");
        $("#templateDes").val(result.template?.description || "");
        $("#latestVersionNumber").val(result.latestVersion?.tempVersion || "");
    }

    populateGroups(result) {
        const $list = $("#groupsList");
        $list.empty();

        const groupsHtml = (result.questionGroups || [])
            .map(group => this.buildGroupHtml(group))
            .join("");

        $list.html(groupsHtml);
    }


    buildGroupHtml(group) {
        const groupGuid = (group.groupGuid || group.GroupGuid || '').toString().trim();
        return `
        <div class="saved-txt stored-overlay group-container"
            data-id="${group.id}"
            data-group-guid="${groupGuid}"
            data-order="${group.order}"
            draggable="true" style="border-radius: 10px 10px 0px 0px;">
            <div class="main-value">
                ${this.getDragIcon()}
                <span>${group.name}</span>
            </div>
        </div>
    `;
    }



    populateQuestions(result) {
        const $questionsList = $("#questionsList");
        $questionsList.empty();

        const groups = result.questionGroups || [];
        // 🔥 FIX: Create a map of GroupGuid -> Group for lookup
        const groupGuidMap = new Map();
        groups.forEach(group => {
            const gGuid = (group.groupGuid || group.GroupGuid || '').toString().trim();
            if (gGuid) {
                groupGuidMap.set(gGuid, group);
            }
            // Also map by ID as fallback
            groupGuidMap.set(String(group.id), group);
        });

        // 🔥 FIX: Group questions by GroupGuid instead of questionGrpId
        const groupedQuestions = this.groupQuestionsByGroupGuid(result.questionAnswers || [], groupGuidMap);

        groups.forEach(group => {
            const groupGuid = (group.groupGuid || group.GroupGuid || '').toString().trim();
            const groupId = group.id;

            // 🔥 FIX: Get questions by GroupGuid first, fallback to ID
            const questionsInGroup = groupedQuestions[groupGuid] || groupedQuestions[String(groupId)] || [];

            const groupHeader = $(`
            <div class="question-group-header" 
                data-group-id="${groupId}" 
                data-group-guid="${groupGuid}"
                data-group-name="${group.name}">
                <h2 class="section-subheading group-subheading">${group.name}</h2>
            </div>
        `);
            $questionsList.append(groupHeader);

            questionsInGroup.forEach(question => {
                $questionsList.append(this.buildQuestionHtml(question));
            });

            const addButtonWrapper = $(`
            <div class="btn-add-wrapper group-add-button" id="addbtnmodal" 
                data-group-id="${groupId}" 
                data-group-guid="${groupGuid}"
                data-group-name="${group.name}">
                <button class="btn-add btn-add-question" type="button" 
                    data-group-id="${groupId}" 
                    data-group-guid="${groupGuid}"
                    data-group-name="${group.name}">
                    <img src="/images/plus-circle-svg.svg" />
                    <span class="btn-add-text">Add question</span>
                </button>
            </div>
        `);
            $questionsList.append(addButtonWrapper);
        });
    }

    // 🔥 NEW METHOD: Group questions by GroupGuid instead of questionGrpId
    groupQuestionsByGroupGuid(questions, groupGuidMap) {
        const groupedQuestions = {};

        questions.forEach(question => {
            // 🔥 FIX: Prefer groupGuid over questionGrpId
            let groupKey = '';

            // Try to get GroupGuid from question
            const qGroupGuid = (question.groupGuid || question.GroupGuid || '').toString().trim();

            if (qGroupGuid) {
                groupKey = qGroupGuid;
            } else {
                // Fallback: use questionGrpId but try to find the GroupGuid
                const grpId = question.questionGrpId || question.QuestionGrpId || '';
                if (grpId && groupGuidMap.has(String(grpId))) {
                    const group = groupGuidMap.get(String(grpId));
                    groupKey = (group.groupGuid || group.GroupGuid || String(grpId)).toString().trim();
                } else {
                    groupKey = String(grpId);
                }
            }

            if (!groupedQuestions[groupKey]) {
                groupedQuestions[groupKey] = [];
            }
            groupedQuestions[groupKey].push(question);
        });

        return groupedQuestions;
    }


    groupQuestionsByGroup(questions) {
        const groupedQuestions = {};

        questions.forEach(question => {
            const groupId = question.questionGrpId || "";
            if (!groupedQuestions[groupId]) {
                groupedQuestions[groupId] = [];
            }
            groupedQuestions[groupId].push(question);
        });

        return groupedQuestions;
    }


    buildQuestionHtml(question) {
        // ✅ FIX: Ensure QuestionGuid is extracted from all possible property names
        const qGuid = (question.questionGuid || question.QuestionGuid || question.QuestionGUID || "").toString().trim();
        const gGuid = (question.groupGuid || question.GroupGuid || question.GroupGUID || "").toString().trim();

        // ✅ FIX: Store normalized values back to question object
        question.questionGuid = qGuid;
        question.groupGuid = gGuid;

        // ✅ FIX: Log for debugging
        console.log('Building question HTML:', {
            text: question.questionText,
            questionGuid: qGuid,
            groupGuid: gGuid
        });

        const answersHtml = (question.answers || [])
            .map((answer, index) => this.buildAnswerHtml(answer, question))
            .join("");

        return `
    <div class="saved-txt stored-overlay"
        data-id="${question.id || question.Id || 0}"
        data-question-guid="${qGuid}"
        data-group-guid="${gGuid}"
        data-order="${question.order || question.Order || question.displayOrder || 0}"
        data-group="${question.questionGroup || question.QuestionGroup || ''}"
        data-field-type="${question.fieldTypeId || question.FieldTypeId || ''}"
        data-is-required="${question.isRequired || question.IsRequired || false}"
        draggable="true"
        style="border-radius: 0px;">
        <div class="main-value">
            ${this.getDragIcon()}
            <span>${question.questionText || question.QuestionText || question.text || ''}</span>
        </div>
        ${answersHtml}
    </div>
`;
    }


    // In the buildAnswerHtml method, update to use question IDs correctly
    buildAnswerHtml(answer, question) {
        const mainSelectValue = answer._matCompType || answer.matCompType || '';
        const dynamicSelectValue = answer.SelectedMatComId || answer.selectedMatComId || '';

        // ✅ FIX: Properly extract SelectedQuestionsList from all possible sources
        let answerSelectValue = '';
        const selectedList = answer.SelectedQuestionsList ||
            answer.selectedQuestionsList ||
            answer.SelectedQuestions ||
            answer.selectedQuestions ||
            [];

        console.log('🔍 buildAnswerHtml - Raw SelectedQuestionsList:', selectedList, 'for answer:', answer.option);

        if (Array.isArray(selectedList) && selectedList.length > 0) {
            // ✅ Filter out invalid IDs and join
            answerSelectValue = selectedList
                .map(id => String(id).trim())
                .filter(id => id && id !== 'undefined' && id !== 'null' && id !== '' && !isNaN(parseInt(id)))
                .join(',');
        } else if (typeof selectedList === 'string' && selectedList.trim()) {
            // If it's already a string, clean it up
            answerSelectValue = selectedList
                .split(',')
                .map(id => id.trim())
                .filter(id => id && id !== 'undefined' && id !== 'null' && !isNaN(parseInt(id)))
                .join(',');
        }

        console.log('✅ buildAnswerHtml - Final answerSelectValue:', answerSelectValue, 'for answer:', answer.option);

        const materialName = answer.SelectedOption || answer.selectedOption || '';

        // Normalize OptionGuid
        const optGuid = (
            answer.optionGuid ||
            answer.OptionGuid ||
            answer.optionGUID ||
            answer.OptionGUID ||
            answer.answerGuid ||
            answer.AnswerGuid ||
            ''
        ).toString().trim();

        answer.optionGuid = optGuid;
        answer.answerGuid = optGuid;

        const qGuid = (question.questionGuid || question.QuestionGuid || '').toString().trim();

        return `
    <div class="saved-txt stored-overlay sub-value"
        data-id="${answer.id || answer.Id || 0}"
        data-question-guid="${qGuid}"
        data-option-guid="${optGuid}"
        data-answer-guid="${optGuid}"
        data-ans-group="${question.questionGroup || question.QuestionGroup || ''}"
        data-main-select="${mainSelectValue}"
        data-answer-select="${answerSelectValue}"
        data-dynamic-select="${dynamicSelectValue}"
        data-material-name="${materialName}"
        data-order="${answer.order || answer.Order || answer.displayOrder || ''}"
        data-option-status="updated">
        <span>${answer.option || answer.Option || answer.text || ''}</span>
    </div>
    `;
    }


    populateFieldTypes(result) {
        const options = (result.fieldTypes || [])
            .map(fieldType => `<option value="${fieldType.value}">${fieldType.text}</option>`)
            .join("");

        $("#fieldTypeSelect").html(options);
    }


    populateGroupDropdown(result) {
        const options = (result.questionGroups || [])
            .map(group => `<option value="${group.name}">${group.name}</option>`)
            .join("");

        $("#groupSelect").html(options);
    }


    populateAboutTemplateModal(data) {
        $("#aboutTemplateModal .modal-header h2").text(data.template?.name || "N/A");
        $("#aboutTemplateName").text(data.template?.name || "N/A");
        $("#aboutTemplateNameValue").text(data.template?.name || "N/A");

        const version = data.selectedVersion?.tempVersion ??
            data.latestVersion?.tempVersion ??
            "N/A";
        $("#aboutTemplateVersion").text(version);

        $("#aboutTemplateCreatedBy").text(data.template?.createdBy || "N/A");

        const createdOn = data.selectedVersion?.tempValidFrom ??
            data.latestVersion?.tempValidFrom ??
            "N/A";
        $("#aboutTemplateCreatedOn").text(createdOn);

        const lastSaved = data.selectedVersion
            ? (data.selectedVersion.tempValidTo ?? data.selectedVersion.tempValidFrom)
            : (data.latestVersion?.tempValidTo ?? data.latestVersion?.tempValidFrom ?? "N/A");

        $("#aboutTemplateLastSaved").text(lastSaved);
    }

    updateFirstVersionFlag() {
        const isEmpty = $("#groupsList").children().length === 0;
        this.templateDataEl.setAttribute("data-is-new-template", isEmpty ? "true" : "false");
    }


    getDragIcon() {
        return `
            <svg class="saved-svg" viewBox="0 0 20 20">
                <circle cx="5" cy="5" r="1.5"></circle>
                <circle cx="5" cy="10" r="1.5"></circle>
                <circle cx="5" cy="15" r="1.5"></circle>
                <circle cx="10" cy="5" r="1.5"></circle>
                <circle cx="10" cy="10" r="1.5"></circle>
                <circle cx="10" cy="15" r="1.5"></circle>
            </svg>
        `;
    }

    async checkQuotesOnCurrentVersion() {
        // 1. Get current version text (e.g. "Version 1")
        const currentVersionText = document
            .getElementById("versionDropdownBtn")
            .innerText
            .trim();

        // 2. Find matching version button in dropdown
        const versionButtons = document.querySelectorAll(
            "#versionList .version-btn"
        );

        let currentVersionId = null;

        versionButtons.forEach(btn => {
            if (btn.innerText.trim() === currentVersionText) {
                currentVersionId = btn.getAttribute("data-version-id");
            }
        });

        // Safety check
        if (!currentVersionId) {
            console.warn("Current version not found in dropdown.");
            return;
        }

        // 3. Call API with versionId
        try {
            const response = await fetch(
                `/api/Template/CheckQuotesOnVersion?versionId=${currentVersionId}`,
                {
                    method: "GET",
                    headers: {
                        "Content-Type": "application/json"
                    }
                }
            );

            const hasQuotes = await response.json();

            // 4. If API returns true → disable template action
            if (hasQuotes === true) {
                document
                    .getElementById("templateStatusWrapper")
                    .classList.add("btn-disable");
            }
        } catch (error) {
            console.error("Error checking quotes on version:", error);
        }
    }

}

document.addEventListener("DOMContentLoaded", () => {

    new TemplateBuilderManager();
});
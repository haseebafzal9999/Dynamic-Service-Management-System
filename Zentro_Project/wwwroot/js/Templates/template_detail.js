
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


    onDataLoaded(result) {
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

        // ⚠️ REMOVE initializeBuilder() call from here
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
        return `
        <div class="saved-txt stored-overlay group-container"
            data-id="${group.id}"
            data-group-guid="${group.groupGuid}"
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
        const groupedQuestions = this.groupQuestionsByGroup(result.questionAnswers || []);

        groups.forEach(group => {
            const groupId = group.id;
            const questionsInGroup = groupedQuestions[groupId] || [];

            const groupHeader = $(`
            <div class="question-group-header" data-group-id="${groupId}" data-group-name="${group.name}">
                <h2 class="section-subheading group-subheading">${group.name}</h2>
            </div>
        `);
            $questionsList.append(groupHeader);

            questionsInGroup.forEach(question => {
                $questionsList.append(this.buildQuestionHtml(question));
            });

            const addButtonWrapper = $(`
            <div class="btn-add-wrapper group-add-button" id="addbtnmodal" data-group-id="${groupId}" data-group-name="${group.name}">
                <button class="btn-add btn-add-question" type="button" data-group-id="${groupId}" data-group-name="${group.name}">
                    <img src="/images/plus-circle-svg.svg" />
                    <span class="btn-add-text">Add question</span>
                </button>
            </div>
        `);
            $questionsList.append(addButtonWrapper);
        });
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
        const answersHtml = (question.answers || [])
            .map((answer, index) => this.buildAnswerHtml(answer, question))
            .join("");

        return `
    <div class="saved-txt stored-overlay"
        data-id="${question.id}"
        data-order="${question.order}"
        data-group="${question.questionGroup}"
        data-field-type="${question.fieldTypeId}"
        data-is-required="${question.isRequired}"
        draggable="true"
        style="border-radius: 0px;">
        <div class="main-value">
            ${this.getDragIcon()}
            <span>${question.questionText || ''}</span>
        </div>
        ${answersHtml}
    </div>
    `;
    }


    buildAnswerHtml(answer, question) {
        const mainSelectValue = answer._matCompType || '';
        const dynamicSelectValue = answer.SelectedMatComId || '';
        const answerSelectValue = answer.SelectedQuestionsList || '';
        const materialName = answer.SelectedOption || '';

        return `
        <div class="saved-txt stored-overlay sub-value"
            data-id="${answer.id || 0}"
            data-ans-group="${question.questionGroup}"
            data-main-select="${mainSelectValue}"
            data-answer-select="${answerSelectValue}"
            data-dynamic-select="${dynamicSelectValue}"
            data-material-name="${materialName}">
            <span>${answer.option || ''}</span>
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
            .map(group => `<option value="${group.id}">${group.name}</option>`)
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
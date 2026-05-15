const versionManager = (() => {
    const templateData = document.getElementById("template-data");
    if (!templateData) {
        console.warn("template-data element not found");
        return {
            register: () => ({ bumpVersion: () => { }, resetFlag: () => { } }),
            checkNewTemplate: () => true,
            isThisVersionChange: () => false,
            requestVersionIfNeeded: async () => 0,
            get isVersionUpdated() { return false; },
            set isVersionUpdated(_) { },
            get hasModifiedInSession() { return false; },
            set hasModifiedInSession(_) { }
        };
    }

    // Track only-once-per-page version creation
    let isVersionUpdated = false;
    let isNavigating = false;

    // ✅ NEW: Track if we've made changes in this session (for Version 1 handling)
    let hasModifiedInSession = false;

    function register(versionContainerSelector, hiddenInputSelector) {
        const versionTitle = document.querySelector(versionContainerSelector);
        const hiddenInput = document.querySelector(hiddenInputSelector);
        const versionDropDownMenu = document.querySelector("#versionsDropDownForm");
        let changed = false;

        function bumpVersion(newVersionId) {
            if (changed) return; // already bumped this cycle
            changed = true;

            let version = getLatestVersionNumber();
            console.log('latest version rn is:', version);
            version++;

            if (hiddenInput) hiddenInput.value = version;
            if (versionTitle) versionTitle.textContent = `Version ${version}`;

            if (versionDropDownMenu) {
                const div = document.createElement('div');
                div.classList.add('dropdown-item');
                div.innerHTML = `
<img src="/images/template-versions.svg" class="dropdown-icon" />
<button type="submit"
        name="tempVersionId"
        value="${newVersionId}"
        class="dropdown-text version-btn"
        data-version-id="${newVersionId}">
    Version ${version}
</button>`;
                versionDropDownMenu.append(div);
                // Unselect previous selection in UI
                versionDropDownMenu.querySelectorAll('.version-btn.selected').forEach(btn => {
                    if (parseInt(btn.dataset.versionId, 10) !== newVersionId) {
                        btn.classList.remove('selected');
                    }
                });
            }

            // Sync template-data for completeness
            const td = document.getElementById('template-data');
            if (td) {
                td.dataset.tempVersionId = String(newVersionId);
                td.dataset.isNewTemplate = "false";
            }
        }
        function resetFlag() {
            changed = false; // allow bumping again
        }

        return {
            bumpVersion,
            resetFlag
        };
    }

    // Scan UI to determine if template has any content (groups or metafields)
    function checkNewTemplate() {
        const hasGroups =
            !!document.querySelector('#groupsList .group-container') ||
            !!document.querySelector('.section-box .saved-txt.stored-overlay');
        const hasMetaFields =
            !!document.querySelector('#metaFieldsList .saved-txt.stored-overlay');

        const isNew = !(hasGroups || hasMetaFields);
        templateData.dataset.isNewTemplate = isNew ? "true" : "false";
        return isNew;
    }

    // ✅ NEW: Get total count of versions in dropdown
    function getTotalVersionCount() {
        const buttons = document.querySelectorAll('#versionsDropDownForm .version-btn');
        return buttons.length;
    }

    // Check if we should skip version cloning for Version 1
    function shouldSkipVersionCloneForV1() {
        const currentVersion = getLatestVersionNumber();
        const totalVersions = getTotalVersionCount();
        const isNewTemplate = templateData.dataset.isNewTemplate === 'true';

        // Only apply special logic if Version 1 is the only version
        if (currentVersion === 1 && totalVersions === 1) {
            // If template is still marked as new, this is first change - skip clone
            if (isNewTemplate) {
                console.log("[versionManager] First change on new template - no clone needed");
                return true;
            }

            // If we've already modified in this session, skip cloning
            if (hasModifiedInSession) {
                console.log("[versionManager] Already modified in this session on V1 - skip clone");
                return true;
            }

            // This is first change after page reload on existing V1 template
            // Allow clone check (will clone to V2)
            console.log("[versionManager] First change after reload on V1 - allow clone");
            return false;
        }

        // Not Version 1 only - proceed with normal logic
        return false;
    }

    // Decide if we need to create a new version now
    function isThisVersionChange() {
        // Check Version 1 special case first
        if (shouldSkipVersionCloneForV1()) {
            return false;
        }

        const isNew = (templateData.dataset.isNewTemplate === "true") || checkNewTemplate();
        if (isNew) return false;
        if (isVersionUpdated) return false;
        return true;
    }

    // First mutation on page triggers version clone, later saves use the same new version
    async function requestVersionIfNeeded() {
        checkNewTemplate();

        const currentId = parseInt(templateData.dataset.tempVersionId || "0", 10) || 0;
        if (!currentId) return 0;

        if (!isThisVersionChange()) {
            //Mark that we've modified in this session
            hasModifiedInSession = true;
            return currentId;
        }

        try {
            const res = await fetch('/api/Template/CloneTemplateVersion', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(currentId)
            });

            const payload = await res.json();
            if (!res.ok || !payload || !payload.newTemplateVersionId) {
                throw new Error(payload?.message || 'Failed to clone template version');
            }

            const newId = payload.newTemplateVersionId;
            templateData.dataset.tempVersionId = String(newId);
            templateData.dataset.isNewTemplate = "false"; // critical: unblock bump
            isVersionUpdated = true;

            // Mark that we've modified in this session
            hasModifiedInSession = true;

            // Update UI dropdown/version button
            if (window.versions && typeof window.versions.bumpVersion === 'function') {
                window.versions.bumpVersion(newId);
            }

            return newId;
        } catch (e) {
            console.error('Version clone failed:', e);
            return currentId;
        }
    }

    return {
        register,
        checkNewTemplate,
        isThisVersionChange,
        requestVersionIfNeeded,
        getTotalVersionCount,
        shouldSkipVersionCloneForV1,
        get isVersionUpdated() { return isVersionUpdated; },
        set isVersionUpdated(v) { isVersionUpdated = !!v; },
        // Expose hasModifiedInSession
        get hasModifiedInSession() { return hasModifiedInSession; },
        set hasModifiedInSession(v) { hasModifiedInSession = !!v; }
    };
})();

function getLatestVersionNumber() {
    const buttons = document.querySelectorAll('#versionsDropDownForm .version-btn');

    let maxVersion = 0;
    let maxVersionId = 0;

    buttons.forEach(btn => {
        const text = btn.textContent.trim();
        const number = parseInt(text.replace(/\D/g, ''), 10);
        const versionId = parseInt(btn.dataset.versionId, 10);

        if (number > maxVersion) {
            maxVersion = number;
            maxVersionId = versionId;
        }
    });

    return maxVersion;
}

(function initVersionManager() {
    const init = () => {
        const versions = versionManager.register("#versionDropdownBtn", "#latestVersionHolder");
        window.versions = versions;
        window.versionControl = versionManager;
    };
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init, { once: true });
    } else {
        init();
    }
})();
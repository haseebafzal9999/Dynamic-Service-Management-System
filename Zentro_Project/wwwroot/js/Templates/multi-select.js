let options = [];

const searchInput = document.getElementById("searchInput");
const dropdown = document.getElementById("dropdown");
let hiddenInput = document.getElementById("answerSelect");
let selectedValues = new Set();




function renderDropdown(filteredOptions) {
    dropdown.innerHTML = "";
    if (filteredOptions.length === 0) {
        dropdown.innerHTML = `<div class="multiselect-option">No options found</div>`;
    } else {
        filteredOptions.forEach(opt => {
            const div = document.createElement("div");
            div.className = "multiselect-option";
            div.dataset.id = opt.id;

            const checkbox = document.createElement("input");
            checkbox.type = "checkbox";
            checkbox.value = opt.id;
            checkbox.checked = selectedValues.has(String(opt.id)); // ✅ check from Set
            const label = document.createElement("span");
            label.textContent = opt.text;

            div.appendChild(checkbox);
            div.appendChild(label);

            div.addEventListener("click", (e) => {
                e.stopPropagation();
                toggleSelection(opt.id);
            });

            dropdown.appendChild(div);
        });
    }
    dropdown.style.display = "block";
}



function toggleSelection(id) {
    id = String(id).trim();

    if (selectedValues.has(id)) {
        selectedValues.delete(id);
    } else {
        selectedValues.add(id);
    }

    hiddenInput.value = Array.from(selectedValues).join(",");

    // ✅ No need to re-render whole dropdown, just sync checkbox
    const checkbox = dropdown.querySelector(`input[value="${id}"]`);
    if (checkbox) {
        checkbox.checked = selectedValues.has(id);
    }
}


function getFilteredOptions(term) {
    return options.filter(opt =>
        opt.text.toLowerCase().includes(term.toLowerCase())
    );
}

searchInput.addEventListener("input", () => {
    renderDropdown(getFilteredOptions(searchInput.value));
});

searchInput.addEventListener("focus", () => {
    renderDropdown(options);
});

document.addEventListener("click", (e) => {
    if (!e.target.closest("#multiSelect")) {
        dropdown.style.display = "none";
    }
});

document.addEventListener("click", (e) => {
    if (!e.target.closest("#multiSelect")) {
        dropdown.style.display = "none";
    }
});


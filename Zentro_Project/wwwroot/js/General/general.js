class commonFunc {
    constructor() {
    }

    generateDDLists(list, appendElement, selectedValue) {

        var element = "";
        for (var i = 0; i < list.length; i++) {
            var selected = "";
            if (selectedValue == list[i].value) {
                selected = "selected";
            }

            element += `<option ${selected} value="${list[i].value}">${list[i].name}</option>`
        }

        $(appendElement).append(element)

    }
}

$(function () {
    new commonFunc();
});


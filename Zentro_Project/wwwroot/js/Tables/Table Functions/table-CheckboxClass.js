class checkBox {
    constructor(param, target, tableType) {
        this.count = 0;
        this.inputCountFalse = 0;
        this.inputCountTrue = 0;
        this.array = param;
        this.target = target;
        this.tableType = tableType;
        this.events();
        this.checkBoxCenter();
    }

    events() {
        var self = this
        $(`${self.tableType} ${self.target}`).off('click').on('click', (e) => {
            if ($(e.target).hasClass('selectAll')) {
                if ($(`${self.tableType} ${self.target}`).hasClass('allchecked') == true) {
                    self.selectAll(false, false);
                    self.count++
                }
                else {
                    self.selectAll(true, false);
                    self.count = 0;
                }
            }
            else {
                self.selectAll(false, true)
            }

            $(e.target).closest("tr").attr("data-row", e.currentTarget.checked)
            $(`${self.tableType} .selectAll`).closest("tr").removeAttr("data-row")
        });

        $(window).resize(function () {
            setTimeout(() => {
                self.checkBoxCenter();
            }, "0")
        });

        $('td').on('click', (e) => {
            if ($(e.target).data('id') == "saveRow" || $(e.target).data('id') == "editBtn") {
                self.checkBoxCenter();
            }
        })
    };

    selectAll(allCheck, singleCheck) {
        var self = this;
        var bodyInputs = $(`${self.tableType} tbody input`);
        if (singleCheck == true) {
            self.inputCountFalse = 0;
            self.inputCountTrue = 0;
            for (var i = 0; i < bodyInputs.length; i++) {
                if (bodyInputs[i].checked == false) {
                    $(bodyInputs[i]).closest("tr").removeClass('selectedRow').addClass('hover:bg-[#f1f2f3]')
                    self.inputCountFalse++
                }
                else if (bodyInputs[i].checked == true) {
                    self.inputCountTrue++
                    $(bodyInputs[i]).closest("tr").addClass('selectedRow').removeClass('hover:bg-[#f1f2f3]')
                }
            }

            if (self.inputCountFalse == bodyInputs.length) {
                $(`${self.tableType} #TableHead input`)[0].checked = false;
                $(`${self.tableType} #TableHead input`).removeClass('allchecked')
            }

            if (self.inputCountTrue == bodyInputs.length) {
                $(`${self.tableType} #TableHead input`)[0].checked = true;
                $(`${self.tableType} #TableHead input`).addClass('allchecked')
            }
        }
        else {
            self.inputCountTrue = 0;
            for (var i = 0; i < bodyInputs.length; i++) {
                bodyInputs[i].checked = allCheck
                $(bodyInputs[i]).closest("tr").attr("data-row", allCheck)
                self.inputCountTrue++
                if (allCheck == true) {
                    $(bodyInputs[i]).closest("tr").addClass('selectedRow').removeClass('hover:bg-[#f1f2f3]')
                }
                else {
                    $(bodyInputs[i]).closest("tr").removeClass('selectedRow').addClass('hover:bg-[#f1f2f3]')
                }

            }

            if (allCheck == true) {
                $(`${self.tableType} #TableHead input`).addClass('allchecked')
            }
            else {
                $(`${self.tableType} #TableHead input`).removeClass('allchecked')
                self.inputCountTrue = 0;
            }
        }

        if (self.inputCountTrue > 0) {
            $(`#${self.array[0].name}`).text(`${self.inputCountTrue} selected`).addClass('text-black font-bold text-[12px] whitespace-pre max-w-[70px]')
            for (var i = 1; i < self.array.length; i++) {
                $(`#${self.array[i].name}`).text('')
            };
        }
        else {
            $(`#${self.array[0].name}`).text(self.array[0].value).removeClass('text-black font-bold text-[12px] whitespace-pre max-w-[70px]')
            for (var i = 1; i < self.array.length; i++) {
                $(`#${self.array[i].name}`).text(self.array[i].value)
            };
        }
    };

    checkBoxCenter() {
        var self = this
        var addressCol = $(`${self.tableType} [data-col]`);
        for (var i = 0; i < addressCol.length; i++) {
            $(`${self.tableType} .selectInnerTableContainer .container`).closest('td')[i].style.height = 0 + 'px'
            $(`${self.tableType} .selectInnerTableContainer .container`).closest('td')[i].style.height = addressCol[i].offsetHeight + 'px'
        };
    };

};
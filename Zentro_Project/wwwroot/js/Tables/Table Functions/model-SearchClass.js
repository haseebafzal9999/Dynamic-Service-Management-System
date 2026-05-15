//table search
class tableSearch {
    constructor(tabId) {
        this.row,
            this.value,
            this.tabId = tabId
        this.events()
    }

    events() {
        var self = this;

        //get the users input and do a search
        $(`${self.tabId} #tableSearch`).off('keyup').on('keyup', (e) => {
            var value = $(`${self.tabId} #tableSearch`).val().toUpperCase().trim();
            var row = $(`${self.tabId} [data-row]`);
            if (value.length > 0) {
                $(`${self.tabId} #crossSearch`).removeClass('hidden');
            }
            else {
                $(`${self.tabId} #crossSearch`).addClass('hidden');
            }
            setTimeout(self.search(row, value), 500);
        })

        //cross on search bar
        $(`${self.tabId} #crossSearch`).off('click').on('click', (e) => {
            var value = $(`${self.tabId} #tableSearch`).val("")
            var row = $(`${self.tabId} [data-row]`);
            $(`${self.tabId} #crossSearch`).addClass('hidden');
            setTimeout(self.search(row, value[0].value), 500);
        })

    }

    //search the table
    search(loop, value) {
        var self = this;
        var counter = 0
        for (var i = 0; i < loop.length; i++) {
            var txtContent = loop[i].textContent || loop[i].innerText
            if (txtContent.toLocaleUpperCase().indexOf(value) > -1) {
                $(loop[i]).removeClass('hidden');
                $(`${self.tabId} thead`)[0].style.display = "";
                counter++
            }
            else {
                $(loop[i]).addClass('hidden');
                $(`${self.tabId} thead`)[0].style.display = "none";
            }
        };

        if (counter > 0) {
            $(`${self.tabId} thead`)[0].style.display = "";
            $(`${self.tabId} #sort`).removeClass('hidden');
            $(`${self.tabId} #searchBox`).removeClass('w-full').addClass('mr-[5px]').addClass('w-[95%]').removeClass('mr-[16px]');
            $(`${self.tabId} #noInfo`).addClass('hidden')
            $(`${self.tabId} #tableContainer`).addClass('h-auto md:max-h-[73vh]')
        }
        else {
            $(`${self.tabId} #sort`).addClass('hidden');
            $(`${self.tabId} #searchBox`).removeClass('w-[95%]').addClass('w-full').removeClass('mr-[5px]').addClass('mr-[16px]');
            $(`${self.tabId} #noInfo`).removeClass('hidden')
            $(`${self.tabId} #tableContainer`).removeClass('h-auto md:max-h-[73vh]')
        }
    };
};
class startup{
    constructor() {
        this.currencyIdentity;
        this.currency;
        this.init();
        this.events();
    }

    init() {
        const storedCurrencyIdentity = localStorage.getItem('currencyIdentity');
        const storedCurrency = localStorage.getItem('currency');
        const lastUpdated = localStorage.getItem('currencyLastUpdated');

        if (storedCurrencyIdentity && storedCurrency && lastUpdated && this.isRecent(lastUpdated)) {
            this.currencyIdentity = storedCurrencyIdentity;
            this.currency = storedCurrency;
        } else {
            this.fetchCurrencyIdentity();
        }
    }

    events() {
        // Handle click on the button to toggle the menu
        $('#account-menu-btn').off('click').on('click', (e) => {
            e.stopPropagation(); // Prevent click from propagating to body
            this.openAccountMenu();
        });

        // Handle click inside the account menu (to prevent closing)
        $('#account-menu').off('click').on('click', (e) => {
            e.stopPropagation(); // Prevent click from propagating to body
        });

        // Handle click anywhere else in the body to close the menu
        $('body').off('click').on('click', () => {
            this.closeAccountMenu(); // Ensure this is called on clicks anywhere else
        });

        //Log the user out
        $('#logout').off('click').on('click', () => { this.logout() })
        $('.back-button-c').off('click').on('click', function (e) {
            e.preventDefault();
            if (window.history.length > 1) {
                window.history.back();
            } else {
               // window.location.href = '/Home/Dashboard';
                window.location.href = '/Home';
            }
        });

    }

    openAccountMenu() {
        var status = $('#account-menu').hasClass('--menu-open');

        if (status) {
            this.closeAccountMenu(); // Use a helper to close the menu
        } else {
            $('#account-menu').addClass('--menu-open');
            $('#account-menu').css('display', 'block');
        }
    }

    closeAccountMenu() {
        $('#account-menu').removeClass('--menu-open');
        $('#account-menu').css('display', 'none');
    }

    logout() {
        $.ajax({
            url: '/api/UserAuth/logout',
            type: 'POST',
            contentType: '',
            success: function (result, status, jqXHR) {
                window.location.href = '/';
                localStorage.clear();
            },
            error: function (error) {
                console.log(error);
            }
        });
    }

    //helper functions

    isRecent(lastUpdated) {
        const lastUpdatedTime = new Date(parseInt(lastUpdated, 10));
        const now = new Date();
        return (now - lastUpdatedTime) < 24 * 60 * 60 * 1000;
    }

    fetchCurrencyIdentity() {

        $.ajax({
            url: '/Api/Business/GetBusinessCurrency', 
            method: 'GET',
            dataType: 'json',
            success: (data) => {
                this.currencyIdentity = data.currencyIdentity;
                this.currency = data.currency;

                localStorage.setItem('currencyIdentity', this.currencyIdentity);
                localStorage.setItem('currency', this.currency);
                localStorage.setItem('currencyLastUpdated', Date.now().toString());

            },
            error: (xhr, status, error) => {
                console.error('Error fetching currency identity:', error);
            }
        });
    }

    convertDateFormat(dateStr) {
        const parts = dateStr.split('/');
        if (parts.length === 3) {
            const day = parts[0];
            const month = parts[1];
            const year = parts[2];
            return `${year}-${month}-${day}`;
        }
        return '';
    }

    capitaliseFirstLetter(str) {
        if (!str) return '';
        str = str.toLowerCase();
        return str.charAt(0).toUpperCase() + str.slice(1);
    }

    popupGenerator(path, parentContainer, callback = null) {
        var self = this;
        var randomQuery = Math.random().toString(36).substr(2, 6);
        var url = path + "?" + randomQuery;

        return new Promise((resolve, reject) => {
            $('.modal-v').fadeIn().css('display', 'flex');
            $.get(url).done(function (data) {
                $(parentContainer).html(data);

                if (self.count == 0) {
                    localStorage.removeItem('filterMenuResults');
                }

                self.count = 1;

                $('.model-content').css('margin-bottom', '-200px');

                $('.model-content').animate({
                    marginBottom: window.innerWidth < 768 ? '0px' : '50px'
                }, 200);

                if (typeof callback === "function") {
                    callback();
                }

                $('.model-content .cross-button, .cancel-btn-model').on('click', (e) => {
                    $('.model-content').css('margin-bottom', '-200px');
                    $('.modal-v').fadeOut(300);
                    $('.model-content').remove();
                });

                resolve();
            })

        }).catch((error) => reject(error));
    };
}

$(function () {
    window.startupClass = new startup();
});
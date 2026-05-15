class Menu {
    constructor(menu) {
        this.baseUrl = 'https://localhost:7250';
        this.menuInfo = menu;
        this.isSelectedMenu = '';
        this.addChild = '';
        this.children = '';
        this.childrenItem = '';
        this.isActive = '';
        this.subMenuState = '';
        this.pageInfo = $('[data-page]').data('page'); // Assuming pageInfo represents the current page path
        this.localStorageKey = 'menuData'; // Key for localStorage
        this.timestampKey = 'menuTimestamp'; // Key for storing the timestamp
        this.initialiseMenu();
        this.events();
    }

    events() {
        $('#menu_close_btn').off('click').on('click', () => {
            $('#section_main').css('position', 'relative');
        });

        $('#menu_open_btn').off('click').on('click', () => {
            $('#section_main').css('position', 'fixed');
        });

        $('.submenu-list-item').on('mouseenter', function () {
            const arrow = $(this).find('.submenu-list-arrow');
            $(arrow).css('opacity', '1');
        });

        $('.submenu-list-item').on('mouseleave', function () {
            const arrow = $(this).find('.submenu-list-arrow');
            $(arrow).css('opacity', '0');
        });
    }

    initialiseMenu() {
        const storedMenu = localStorage.getItem(this.localStorageKey);
        const storedTimestamp = localStorage.getItem(this.timestampKey);

        const currentTime = new Date().getTime(); // Get current time in milliseconds
        const twoMinutes = 2 * 60 * 1000; // Convert 2 minutes to milliseconds

        // Check if the stored timestamp exists and if it's older than 2 minutes
        if (storedTimestamp && (currentTime - parseInt(storedTimestamp)) < twoMinutes) {
            // If the menu is found in localStorage and is not older than 2 minutes, parse and use it
            this.menuInfo = JSON.parse(storedMenu);
            this.generateMenu();
        } else {
            // If not found or older than 2 minutes, fetch it from the server
            this.fetchMenu();
        }
    }

    fetchMenu() {
        $.ajax({
            url: `/api/common/MenuItems`,
            type: 'GET',
            contentType: 'application/json',
            success: (result) => {
                this.menuInfo = result;
                // Save the fetched menu into localStorage
                localStorage.setItem(this.localStorageKey, JSON.stringify(result));
                // Save the current timestamp in localStorage
                localStorage.setItem(this.timestampKey, new Date().getTime());
                this.generateMenu();
            },
            error: (error) => {
            }
        });
    }

    generateMenu() {
        this.children = ''; // Reset the entire menu content

        this.menuInfo.menu.forEach(menuItem => {
            let hasActiveChild = false; // Track if any child is active
            let showHideArrow = '';
            this.addChild = ''; // Reset for each menu item
            this.isActive = ''; // Reset active class for each menu item
            this.subMenuState = '--close-menu'; // Reset submenu state for each item


            // Generate children items if they exist
            if (menuItem.children && menuItem.children.length > 0) {
                menuItem.children.forEach(childItem => {
                    let childIsActive = this.pageInfo === childItem.name ? 'active-item' : '';
                    showHideArrow = '';

                    // If a child is active, we also mark the parent menu item as active
                    if (childIsActive) {
                        hasActiveChild = true;
                        this.subMenuState = '--open-menu'; // Open the submenu if any child is active
                        showHideArrow = 'opacity-fixed'
                    }

                    this.childrenItem = `
                    <div class="submenu-list-item-inner-wrapper ${childIsActive}">
                        <a href="${childItem.link}" class="submenu-list-item w-inline-block">
                            <img src="/images/menu_arrow.svg" loading="lazy" alt="Arrow" class="submenu-list-arrow ${showHideArrow}">
                            <div class="submenu-item-text">${childItem.name}</div>
                        </a>
                    </div>
                `;
                    this.addChild += this.childrenItem; // Append child items to the parent
                });
            }

            // Check if the main menu item is the active one (or any child is active)
            if (this.pageInfo === menuItem.optionName || hasActiveChild) {
                this.isActive = 'active-item';
                this.subMenuState = '--open-menu'; // Show submenu if parent or child is active
            }

            // Generate main menu item and append children if applicable
            this.children += `
            <div class="menu-list-item-wrapper">
                <div class="menu-list-item-inner-wrapper ${this.isActive}">
                    <a href="${menuItem.optionLink}" class="menu-list-item w-inline-block">
                        <div class="menu-list-icons w-embed">${menuItem.optionSVG}</div>
                        <div class="menu-item-text">${menuItem.optionName}</div>
                    </a>
                </div>
                <div class="submenu ${this.subMenuState}">
                    ${this.addChild}
                </div>
            </div>
        `;
        });

        // Append generated menu items to the DOM
        $('#menu').append(this.children);
    }
}

// Initialise the menu
$(function () {
    new Menu();
});

class UserAuth {
    constructor() {
        this.init();
        this.events();
    }

    init() {
        localStorage.clear();
    }

    events() {
        $('#login').on('click', () => this.login());
        $('#email, #password').on('keyup', (event) => {
            var validInput = this.validateInput(event);

            // Check if the pressed key is "Enter"
            if (event.key === 'Enter' && validInput) {
                this.login(); // Call the login method
            }
        });

        $('.forgotten-password-link').on('click', (event) => {
            event.preventDefault();
            this.showForgotPanel();
        });

        $('.login-link').on('click', (event) => {
            event.preventDefault();
            this.showLoginPanel();
        });
    }

    login() {
        var userInput = {
            Email: $('#email').val(),
            Password: $('#password').val()
        };

        $.ajax({
            url: '/api/UserAuth/login',
            type: 'POST',
            contentType: 'application/json', // Set content type to match the form data
            data: JSON.stringify(userInput), 
            headers: {
                RequestVerificationToken: $('input[name="__RequestVerificationToken"]').val()
            },
            success: function (result, status, jqXHR) {

                if (result.status == 'Pass') {
                    location.href = "/";
                }
                else {
                    $('#general-error .text-danger').remove();
                    $('#general-error').append('<span id="label-error" class="text-danger invalid-error">Invalid email or password. Please check your email and password and try again.</span>');
                }
            },
            error: function (error) {
                console.log(error);
            }
        });
    }

    register() {

        var email = $('#emailR').val();
        var emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

        if (emailRegex.test(email)) {
            var userInput = {
                FirstName: $('#firstNameR').val(),
                LastName: $('#lastNameR').val(),
                AccountNumber: $('#accountNumberR').val(),
                Email: email,
                Password: $('#passwordR').val()
            };

            $.ajax({
                url: '/UserAuth/Register',
                type: 'POST',
                contentType: 'application/x-www-form-urlencoded', // Set content type to match the form data
                data: $.param(userInput), // Serialize the data
                headers: {
                    RequestVerificationToken: $('input[name="__RequestVerificationToken"]').val()
                },
                success: function (result, status, jqXHR) {


                    if (Object.keys(result.error).length > 0) {
                        $('.reg-error').text(result.error[0].description);
                    }

                    if (result.status == true) {
                        location.href = "/identity/account";
                    }

                },
                error: function (error) {
                    console.log(error);
                }
            });
        }
        else {
            $('.reg-error').text('Please enter a valid email address');
        }
    }

    resetPassword() {

        var email = $('#emailReset').val();
        var emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

        if (emailRegex.test(email)) {

            $.ajax({
                url: '/UserAuth/ResetPassword',
                type: 'POST',
                contentType: 'application/json',
                data: JSON.stringify(email),
                headers: {
                    RequestVerificationToken: $('input[name="__RequestVerificationToken"]').val()
                },
                success: function (result, status, jqXHR) {

                    $('.confirmM').text('A password reset link has been sent to your email ')
                    $('.reset-error').text('');
                    $('#sendLink').css('opacity', '0.6').attr('disabled', true)
                    $('.close-model-btn').on('click', (e) => {
                        location.reload();
                    });

                },
                error: function (error) {
                    console.log(error);
                }
            });
        }
        else {
            $('.reset-error').text('Please enter a valid email address');
        }
    }

    validateInput() {
        $('#general-error .text-danger').remove(); // Remove existing error messages

        // Get the values of email and password
        var email = $('#email').val();
        var password = $('#password').val();

        // Validate email and password
        var re = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
        var emailVaild = re.test(String(email).toLowerCase());
        

        if (emailVaild == false) {
            $('#general-error').append('<span class="text-danger">Invalid email format.</span>');
            $('#login').addClass('btn-disable'); // Disable the login button if email is invalid
            return false; // Exit the function early if email is invalid
        }

        // If both fields are filled, enable the button; otherwise, disable it
        if (email.length > 0 && password.length > 0) {
            $('#login').removeClass('btn-disable');
            return true;
        } else {
            $('#login').addClass('btn-disable');
            return false;
        }
    }

    showForgotPanel() {
        $('#login-panel').addClass('hidden').attr('aria-hidden', 'true');
        $('#forgot-panel').removeClass('hidden').attr('aria-hidden', 'false');
    }

    showLoginPanel() {
        $('#forgot-panel').addClass('hidden').attr('aria-hidden', 'true');
        $('#login-panel').removeClass('hidden').attr('aria-hidden', 'false');
    }
}

$(function () {
    new UserAuth();
});
document.addEventListener("DOMContentLoaded", () => {
    const loginForm = document.getElementById("login-form");
    const signupForm = document.getElementById("signup-form");
    const forgotForm = document.getElementById("forgot-form");

    const showSignup = document.getElementById("show-signup");
    const showLogin = document.getElementById("show-login");
    const passwordLink = document.querySelector(".password-link-c");
    const backToLogin = document.getElementById("back-to-login");

    showSignup.addEventListener("click", (e) => {
        e.preventDefault();
        loginForm.classList.add("hidden");
        signupForm.classList.remove("hidden");
        forgotForm.classList.add("hidden");
    });

    showLogin.addEventListener("click", (e) => {
        e.preventDefault();
        signupForm.classList.add("hidden");
        forgotForm.classList.add("hidden");
        loginForm.classList.remove("hidden");
    });

    passwordLink.addEventListener("click", (e) => {
        e.preventDefault();
        loginForm.classList.add("hidden");
        signupForm.classList.add("hidden");
        forgotForm.classList.remove("hidden");
    });

    backToLogin.addEventListener("click", (e) => {
        e.preventDefault();
        signupForm.classList.add("hidden");
        forgotForm.classList.add("hidden");
        loginForm.classList.remove("hidden");
    });
});

document.addEventListener("DOMContentLoaded", function () {
    //var isAuthenticated = @User.Identity.IsAuthenticated.ToString().ToLower();
    //if (isAuthenticated)
        if (window.isUserAuthenticated)
    {
        let modal = document.getElementById("authModal");
        if (modal) {
            modal.style.display = "none";
        }
    }
});
// disable back button

export const initBackButton = () => {
    history.pushState(null, document.title, location.href);
};

export const preventBackButton = () => {
    window.addEventListener("popstate", blockBack);
};

export const enableBackButton = () => {
    window.removeEventListener("popstate", blockBack);
};

function blockBack(event) {
    history.pushState(null, document.title, location.href);
}

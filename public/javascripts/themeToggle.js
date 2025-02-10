document.addEventListener("DOMContentLoaded", function () {
  const themeToggle = document.querySelector(".switch input");
  const currentTheme = localStorage.getItem("theme");

  // Apply stored theme
  if (currentTheme === "dark") {
    document.documentElement.setAttribute("data-theme", "dark");
    themeToggle.checked = true;
  } else {
    document.documentElement.setAttribute("data-theme", "light");
  }

  // Toggle theme on switch change
  themeToggle.addEventListener("change", function () {
    if (this.checked) {
      document.documentElement.setAttribute("data-theme", "dark");
      localStorage.setItem("theme", "dark");
    } else {
      document.documentElement.setAttribute("data-theme", "light");
      localStorage.setItem("theme", "light");
    }
  });
});

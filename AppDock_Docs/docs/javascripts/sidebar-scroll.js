(() => {
  const storageKey = "appdock-docs-nav-scroll";

  const getNavScrollContainer = () =>
    document.querySelector(".wy-side-scroll");

  const saveScroll = (container) => {
    try {
      window.sessionStorage.setItem(storageKey, String(container.scrollTop));
    } catch (error) {
      // Ignore storage failures to avoid breaking navigation.
    }
  };

  const restoreScroll = (container) => {
    try {
      const value = window.sessionStorage.getItem(storageKey);
      if (value !== null) {
        const scrollTop = Number.parseInt(value, 10);
        if (!Number.isNaN(scrollTop)) {
          container.scrollTop = scrollTop;
        }
      }
    } catch (error) {
      // Ignore storage failures to avoid breaking navigation.
    }
  };

  const init = () => {
    const container = getNavScrollContainer();
    if (!container) {
      return;
    }

    // Defer restore to override theme auto-scrolling to the active item.
    requestAnimationFrame(() => restoreScroll(container));
    window.addEventListener(
      "load",
      () => {
        setTimeout(() => restoreScroll(container), 0);
      },
      { once: true }
    );
    container.addEventListener("scroll", () => saveScroll(container), {
      passive: true,
    });
    window.addEventListener("beforeunload", () => saveScroll(container));
  };

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init, { once: true });
  } else {
    init();
  }
})();

import { x as attr, y as ensure_array_like, z as attr_class, F as stringify, G as bind_props } from "../../chunks/index.js";
import { a as ssr_context, e as escape_html } from "../../chunks/context.js";
import "clsx";
function html(value) {
  var html2 = String(value ?? "");
  var open = "<!---->";
  return open + html2 + "<!---->";
}
function onDestroy(fn) {
  /** @type {SSRContext} */
  ssr_context.r.on_destroy(fn);
}
const STATUS = {
  READY: "READY",
  LOADING: "LOADING",
  COMPLETE: "COMPLETE",
  ERROR: "ERROR"
};
class LoaderState {
  isFirstLoad = true;
  status = STATUS.READY;
  mounted = false;
  loaded = () => {
    if (this.isFirstLoad) this.isFirstLoad = false;
    this.status = STATUS.READY;
  };
  complete = () => {
    if (this.isFirstLoad) this.isFirstLoad = false;
    this.status = STATUS.COMPLETE;
  };
  reset = () => {
    this.isFirstLoad = true;
    this.status = STATUS.READY;
  };
  error = () => {
    this.status = STATUS.ERROR;
  };
}
function InfiniteLoader($$renderer, $$props) {
  $$renderer.component(($$renderer2) => {
    const {
      triggerLoad,
      loopTimeout = 3e3,
      loopDetectionTimeout = 2e3,
      loopMaxCalls = 5,
      loaderState,
      children,
      loading: loadingSnippet,
      noResults: noResultsSnippet,
      noData: noDataSnippet,
      coolingOff: coolingOffSnippet,
      error: errorSnippet
    } = $$props;
    const ERROR_INFINITE_LOOP = `Attempted to execute load function ${loopMaxCalls} or more times within a short period. Please wait before trying again..`;
    class LoopTracker {
      coolingOff = false;
      #coolingOffTimer = null;
      #timer = null;
      #count = 0;
      // On each call, increment the count and reset the timer
      track() {
        this.#count += 1;
        clearTimeout(this.#timer);
        this.#timer = setTimeout(
          () => {
            this.#count = 0;
          },
          loopDetectionTimeout
        );
        if (this.#count >= loopMaxCalls) {
          console.error(ERROR_INFINITE_LOOP);
          this.coolingOff = true;
          this.#coolingOffTimer = setTimeout(
            () => {
              this.coolingOff = false;
              this.#count = 0;
            },
            loopTimeout
          );
        }
      }
      destroy() {
        if (this.#timer) {
          clearTimeout(this.#timer);
        }
        if (this.#coolingOffTimer) {
          clearTimeout(this.#coolingOffTimer);
        }
      }
    }
    const loopTracker = new LoopTracker();
    let showLoading = loaderState.status === STATUS.LOADING;
    let showError = loaderState.status === STATUS.ERROR;
    let showNoResults = loaderState.status === STATUS.COMPLETE && loaderState.isFirstLoad;
    let showNoData = loaderState.status === STATUS.COMPLETE && !loaderState.isFirstLoad;
    let showCoolingOff = loaderState.status !== STATUS.COMPLETE && loopTracker.coolingOff;
    async function attemptLoad() {
      if (loaderState.status === STATUS.COMPLETE || loaderState.status !== STATUS.READY && loaderState.status !== STATUS.ERROR) {
        return;
      }
      loaderState.status = STATUS.LOADING;
      if (!loopTracker.coolingOff) {
        await triggerLoad();
        loopTracker.track();
      }
      if (loaderState.status !== STATUS.ERROR && loaderState.status !== STATUS.COMPLETE) {
        if (loaderState.status === STATUS.LOADING) {
          loaderState.isFirstLoad = false;
          loaderState.status = STATUS.READY;
        }
      }
    }
    onDestroy(() => {
      if (loaderState.mounted) {
        if (loopTracker) {
          loopTracker.destroy();
        }
      }
    });
    $$renderer2.push(`<div class="infinite-loader-wrapper svelte-10v88vw">`);
    children($$renderer2);
    $$renderer2.push(`<!----> <div class="infinite-intersection-target svelte-10v88vw">`);
    if (showLoading) {
      $$renderer2.push("<!--[-->");
      if (loadingSnippet) {
        $$renderer2.push("<!--[-->");
        loadingSnippet($$renderer2);
        $$renderer2.push(`<!---->`);
      } else {
        $$renderer2.push("<!--[!-->");
        $$renderer2.push(`<div class="infinite-loading svelte-10v88vw">Loading...</div>`);
      }
      $$renderer2.push(`<!--]-->`);
    } else {
      $$renderer2.push("<!--[!-->");
    }
    $$renderer2.push(`<!--]--> `);
    if (showNoResults) {
      $$renderer2.push("<!--[-->");
      if (noResultsSnippet) {
        $$renderer2.push("<!--[-->");
        noResultsSnippet($$renderer2);
        $$renderer2.push(`<!---->`);
      } else {
        $$renderer2.push("<!--[!-->");
        $$renderer2.push(`<div class="infinite-no-results svelte-10v88vw">No results</div>`);
      }
      $$renderer2.push(`<!--]-->`);
    } else {
      $$renderer2.push("<!--[!-->");
    }
    $$renderer2.push(`<!--]--> `);
    if (showNoData) {
      $$renderer2.push("<!--[-->");
      if (noDataSnippet) {
        $$renderer2.push("<!--[-->");
        noDataSnippet($$renderer2);
        $$renderer2.push(`<!---->`);
      } else {
        $$renderer2.push("<!--[!-->");
        $$renderer2.push(`<div class="infinite-no-data svelte-10v88vw">No more data</div>`);
      }
      $$renderer2.push(`<!--]-->`);
    } else {
      $$renderer2.push("<!--[!-->");
    }
    $$renderer2.push(`<!--]--> `);
    if (showCoolingOff) {
      $$renderer2.push("<!--[-->");
      if (coolingOffSnippet) {
        $$renderer2.push("<!--[-->");
        coolingOffSnippet($$renderer2);
        $$renderer2.push(`<!---->`);
      } else {
        $$renderer2.push("<!--[!-->");
        $$renderer2.push(`<div class="infinite-cooling-off svelte-10v88vw">Potential loop detected, please wait and try again..</div>`);
      }
      $$renderer2.push(`<!--]-->`);
    } else {
      $$renderer2.push("<!--[!-->");
    }
    $$renderer2.push(`<!--]--> `);
    if (showError) {
      $$renderer2.push("<!--[-->");
      if (errorSnippet) {
        $$renderer2.push("<!--[-->");
        errorSnippet($$renderer2, attemptLoad);
        $$renderer2.push(`<!---->`);
      } else {
        $$renderer2.push("<!--[!-->");
        $$renderer2.push(`<div class="infinite-error svelte-10v88vw"><div class="infinite-error__label svelte-10v88vw">Oops, something went wrong</div> <button class="infinite-error__btn svelte-10v88vw"${attr("disabled", loaderState.status === STATUS.COMPLETE, true)}>Retry</button></div>`);
      }
      $$renderer2.push(`<!--]-->`);
    } else {
      $$renderer2.push("<!--[!-->");
    }
    $$renderer2.push(`<!--]--></div></div>`);
  });
}
function _defineProperty(obj, key, value) {
  if (key in obj) {
    Object.defineProperty(obj, key, {
      value,
      enumerable: true,
      configurable: true,
      writable: true
    });
  } else {
    obj[key] = value;
  }
  return obj;
}
var FEATURE_FLAG_NAMES = Object.freeze({
  // This flag exists as a workaround for issue 454 (basically a browser bug) - seems like these rect values take time to update when in grid layout. Setting it to true can cause strange behaviour in the REPL for non-grid zones, see issue 470
  USE_COMPUTED_STYLE_INSTEAD_OF_BOUNDING_RECT: "USE_COMPUTED_STYLE_INSTEAD_OF_BOUNDING_RECT"
});
_defineProperty({}, FEATURE_FLAG_NAMES.USE_COMPUTED_STYLE_INSTEAD_OF_BOUNDING_RECT, false);
var _ID_TO_INSTRUCTION;
var INSTRUCTION_IDs$1 = {
  DND_ZONE_ACTIVE: "dnd-zone-active",
  DND_ZONE_DRAG_DISABLED: "dnd-zone-drag-disabled"
};
_ID_TO_INSTRUCTION = {}, _defineProperty(_ID_TO_INSTRUCTION, INSTRUCTION_IDs$1.DND_ZONE_ACTIVE, "Tab to one the items and press space-bar or enter to start dragging it"), _defineProperty(_ID_TO_INSTRUCTION, INSTRUCTION_IDs$1.DND_ZONE_DRAG_DISABLED, "This is a disabled drag and drop list"), _ID_TO_INSTRUCTION;
function MealSelectionModal($$renderer, $$props) {
  $$renderer.component(($$renderer2) => {
    let { isOpen = void 0, onSelectMeal } = $$props;
    const availableMeals = [
      {
        name: "Spaghetti Bolognese",
        time: "45 min",
        icon: "utensils",
        color: "green"
      },
      {
        name: "Chicken Stir-Fry",
        time: "30 min",
        icon: "utensils",
        color: "green"
      },
      {
        name: "Fish and Chips",
        time: "40 min",
        icon: "utensils",
        color: "teal"
      },
      {
        name: "Vegetable Curry",
        time: "35 min",
        icon: "utensils",
        color: "yellow"
      },
      {
        name: "Roast Chicken",
        time: "90 min",
        icon: "chef-hat",
        color: "green"
      },
      {
        name: "Beef Tacos",
        time: "25 min",
        icon: "utensils",
        color: "teal"
      },
      {
        name: "Salmon Teriyaki",
        time: "20 min",
        icon: "utensils",
        color: "green"
      },
      {
        name: "Mushroom Risotto",
        time: "35 min",
        icon: "chef-hat",
        color: "yellow"
      }
    ];
    let searchTerm = "";
    const filteredMeals = availableMeals.filter((meal) => meal.name.toLowerCase().includes(searchTerm.toLowerCase()));
    if (isOpen) {
      $$renderer2.push("<!--[-->");
      $$renderer2.push(`<div class="fixed inset-0 z-50 bg-black/50 flex items-center justify-center p-4" role="presentation"><div role="dialog" aria-labelledby="meal-modal-title" aria-describedby="meal-modal-description" class="fixed left-[50%] top-[50%] z-50 grid w-full max-w-lg translate-x-[-50%] translate-y-[-50%] gap-4 border bg-white p-6 shadow-lg duration-200 data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95 data-[state=closed]:slide-out-to-left-1/2 data-[state=closed]:slide-out-to-top-[48%] data-[state=open]:slide-in-from-left-1/2 data-[state=open]:slide-in-from-top-[48%] sm:rounded-lg sm:max-w-md" tabindex="-1" style="pointer-events: auto;"><div class="flex flex-col space-y-1.5 text-center sm:text-left"><div class="flex items-center justify-between"><h2 id="meal-modal-title" class="text-lg font-semibold leading-none tracking-tight">Add a Meal</h2> <button type="button" class="absolute right-4 top-4 rounded-sm opacity-70 ring-offset-background transition-opacity hover:opacity-100 focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 disabled:pointer-events-none" aria-label="Close"><svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-x h-4 w-4"><path d="M18 6 6 18"></path><path d="m6 6 12 12"></path></svg> <span class="sr-only">Close</span></button></div></div> <div class="space-y-3"><input type="text" class="flex h-9 rounded-md border border-gray-300 bg-white px-3 py-1 text-base shadow-xs transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-blue-500 disabled:cursor-not-allowed disabled:opacity-50 md:text-sm w-full" placeholder="Search recipes..."${attr("value", searchTerm)}/></div> <div class="space-y-2 h-[400px] overflow-y-auto mt-4"><!--[-->`);
      const each_array = ensure_array_like(filteredMeals);
      for (let $$index = 0, $$length = each_array.length; $$index < $$length; $$index++) {
        let meal = each_array[$$index];
        $$renderer2.push(`<button class="w-full flex items-center gap-3 p-3 rounded-lg hover:bg-gray-50 transition-colors border border-gray-100 text-left"><div class="w-10 h-10 bg-gray-100 rounded-lg flex items-center justify-center flex-shrink-0"><svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"${attr_class(`lucide lucide-${stringify(meal.icon)} w-5 h-5 text-gray-600`)}>`);
        if (meal.icon === "utensils") {
          $$renderer2.push("<!--[-->");
          $$renderer2.push(`<path d="M3 2v7c0 1.1.9 2 2 2h4a2 2 0 0 0 2-2V2"></path><path d="M7 2v20"></path><path d="M21 15V2a5 5 0 0 0-5 5v6c0 1.1.9 2 2 2h3Zm0 0v7"></path>`);
        } else {
          $$renderer2.push("<!--[!-->");
          if (meal.icon === "chef-hat") {
            $$renderer2.push("<!--[-->");
            $$renderer2.push(`<path d="M17 21a1 1 0 0 0 1-1v-5.35c0-.457.316-.844.727-1.041a4 4 0 0 0-2.134-7.589 5 5 0 0 0-9.186 0 4 4 0 0 0-2.134 7.588c.411.198.727.585.727 1.041V20a1 1 0 0 0 1 1Z"></path><path d="M6 17h12"></path>`);
          } else {
            $$renderer2.push("<!--[!-->");
          }
          $$renderer2.push(`<!--]-->`);
        }
        $$renderer2.push(`<!--]--></svg></div> <div class="flex-1 text-left"><div class="font-medium text-gray-900">${escape_html(meal.name)}</div> <div class="text-sm text-gray-500">${escape_html(meal.time)}</div></div></button>`);
      }
      $$renderer2.push(`<!--]--> `);
      if (filteredMeals.length === 0) {
        $$renderer2.push("<!--[-->");
        $$renderer2.push(`<div class="text-center text-gray-500 py-8">No meals found matching "${escape_html(searchTerm)}"</div>`);
      } else {
        $$renderer2.push("<!--[!-->");
      }
      $$renderer2.push(`<!--]--></div></div></div>`);
    } else {
      $$renderer2.push("<!--[!-->");
    }
    $$renderer2.push(`<!--]-->`);
    bind_props($$props, { isOpen });
  });
}
function WeekSection($$renderer, $$props) {
  $$renderer.component(($$renderer2) => {
    const { week, onAddActivity } = $$props;
    const formatDate = (dateStr) => {
      const date = new Date(dateStr);
      return date.toLocaleDateString("en-US", { day: "numeric", month: "short" });
    };
    const formatYear = (dateStr) => {
      const date = new Date(dateStr);
      return date.getFullYear();
    };
    const formatDayName = (dateStr) => {
      const date = new Date(dateStr);
      return date.toLocaleDateString("en-US", { weekday: "short" });
    };
    const getBorderColor = (color) => {
      switch (color) {
        case "green":
          return "border-l-green-500";
        case "teal":
          return "border-l-teal-500";
        case "yellow":
          return "border-l-yellow-500";
        default:
          return "border-l-green-500";
      }
    };
    const getIconSvg = (icon) => {
      switch (icon) {
        case "utensils":
          return '<path d="M3 2v7c0 1.1.9 2 2 2h4a2 2 0 0 0 2-2V2"></path><path d="M7 2v20"></path><path d="M21 15V2a5 5 0 0 0-5 5v6c0 1.1.9 2 2 2h3Zm0 0v7"></path>';
        case "chef-hat":
          return '<path d="M17 21a1 1 0 0 0 1-1v-5.35c0-.457.316-.844.727-1.041a4 4 0 0 0-2.134-7.589 5 5 0 0 0-9.186 0 4 4 0 0 0-2.134 7.588c.411.198.727.585.727 1.041V20a1 1 0 0 0 1 1Z"></path><path d="M6 17h12"></path>';
        default:
          return '<path d="M3 2v7c0 1.1.9 2 2 2h4a2 2 0 0 0 2-2V2"></path><path d="M7 2v20"></path><path d="M21 15V2a5 5 0 0 0-5 5v6c0 1.1.9 2 2 2h3Zm0 0v7"></path>';
      }
    };
    let isModalOpen = false;
    let selectedDate = "";
    const handleSelectMeal = (meal) => {
      onAddActivity(selectedDate, meal);
    };
    let $$settled = true;
    let $$inner_renderer;
    function $$render_inner($$renderer3) {
      $$renderer3.push(`<section class="bg-white border-b border-gray-200"><div class="bg-white border-b border-gray-200 px-4 py-3 sticky top-0 z-20"><div class="flex items-center justify-between"><div class="flex items-center gap-3"><h2 class="text-lg font-semibold text-gray-900">${escape_html(formatDate(week.startDate))} - ${escape_html(formatDate(week.endDate))} ${escape_html(formatYear(week.startDate))}</h2> <span class="bg-black text-white text-xs font-semibold px-3 py-1 rounded-full">WEEK ${escape_html(week.weekNumber)}</span></div> <button class="flex items-center gap-2 text-sm text-gray-600 hover:text-gray-900 transition-colors"><svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-rotate-ccw w-4 h-4"><path d="M3 12a9 9 0 1 0 9-9 9.75 9.75 0 0 0-6.74 2.74L3 8"></path><path d="M3 3v5h5"></path></svg> Reset</button></div> <p class="text-sm text-gray-500 mt-1">Total: ${escape_html(week.totalActivities)} activity${escape_html(week.totalActivities !== 1 ? "ies" : "y")}</p></div> <div><!--[-->`);
      const each_array = ensure_array_like(week.days);
      for (let dayIndex = 0, $$length = each_array.length; dayIndex < $$length; dayIndex++) {
        let day = each_array[dayIndex];
        $$renderer3.push(`<div class="flex border-b border-gray-200 min-h-[80px] transition-colors"><div class="sticky left-0 z-10 bg-white flex flex-col justify-center items-center w-20 min-w-[80px] border-r border-gray-100 py-3"><div class="text-xs text-gray-400 font-medium mb-1">${escape_html(formatDayName(day.date))}</div> <div${attr_class(`flex items-center justify-center w-10 h-10 rounded-full font-semibold text-lg ${stringify(dayIndex === 0 ? "bg-black text-white" : "text-gray-900")}`)}>${escape_html(new Date(day.date).getDate())}</div></div> <div class="flex-1 min-w-0"><div class="flex gap-3 px-3 py-2 overflow-x-auto" style="scroll-snap-type: x mandatory;"><div class="flex gap-3 min-h-[88px] w-full"${attr("data-date", day.date)}><!--[-->`);
        const each_array_1 = ensure_array_like(day.meals || []);
        for (let $$index = 0, $$length2 = each_array_1.length; $$index < $$length2; $$index++) {
          let meal = each_array_1[$$index];
          $$renderer3.push(`<div role="button" tabindex="0" aria-disabled="false" aria-roledescription="draggable"${attr_class(`flex-shrink-0 w-52 p-4 bg-white rounded-xl shadow-sm border border-gray-100 ${stringify(getBorderColor(meal.color))} border-l-4 cursor-move transition-all hover:shadow-md active:scale-[0.98] scroll-snap-align-start`, "svelte-1668vul")}><div class="flex items-start justify-between"><div class="flex-1 min-w-0"><div class="flex items-center gap-2 mb-2"><svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"${attr_class(`lucide lucide-${stringify(meal.icon)} w-4 h-4 text-gray-500 flex-shrink-0`, "svelte-1668vul")}>${html(getIconSvg(meal.icon))}</svg> <h3 class="font-semibold text-sm text-gray-900 truncate">${escape_html(meal.name)}</h3></div> <div class="flex items-center gap-2"><p class="text-xs text-gray-500">${escape_html(meal.time)}</p></div></div> <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-zap w-4 h-4 text-gray-400 flex-shrink-0 ml-2"><path d="M4 14a1 1 0 0 1-.78-1.63l9.9-10.2a.5.5 0 0 1 .86.46l-1.92 6.02A1 1 0 0 0 13 10h7a1 1 0 0 1 .78 1.63l-9.9 10.2a.5.5 0 0 1-.86-.46l1.92-6.02A1 1 0 0 0 11 14z"></path></svg></div></div>`);
        }
        $$renderer3.push(`<!--]--> <button class="flex-shrink-0 w-36 h-[88px] rounded-xl border flex items-center gap-1 text-gray-500 hover:bg-white hover:border-white hover:text-gray-700 transition-colors scroll-snap-align-start" style="background-color: rgb(249, 250, 251); border-color: rgb(249, 250, 251); justify-content: flex-start; padding-left: 0.75rem;"><svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-plus w-4 h-4 flex-shrink-0"><path d="M5 12h14"></path><path d="M12 5v14"></path></svg> <span class="font-medium text-sm whitespace-nowrap">Add</span></button></div></div></div></div>`);
      }
      $$renderer3.push(`<!--]--></div> `);
      MealSelectionModal($$renderer3, {
        onSelectMeal: handleSelectMeal,
        get isOpen() {
          return isModalOpen;
        },
        set isOpen($$value) {
          isModalOpen = $$value;
          $$settled = false;
        }
      });
      $$renderer3.push(`<!----></section>`);
    }
    do {
      $$settled = true;
      $$inner_renderer = $$renderer2.copy();
      $$render_inner($$inner_renderer);
    } while (!$$settled);
    $$renderer2.subsume($$inner_renderer);
  });
}
function getUKWeekNumber(date) {
  const d = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
  const dayNum = d.getUTCDay() || 7;
  d.setUTCDate(d.getUTCDate() + 4 - dayNum);
  const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
  const weekNo = Math.ceil(((d.getTime() - yearStart.getTime()) / 864e5 + 1) / 7);
  return weekNo;
}
function getStartOfUKWeek(date) {
  const d = new Date(date);
  const day = d.getDay();
  const diff = d.getDate() - day + (day === 0 ? -6 : 1);
  return new Date(d.setDate(diff));
}
function generateWeekData(startDate, weekNumber) {
  const days = [];
  const endDate = new Date(startDate);
  endDate.setDate(startDate.getDate() + 6);
  let totalActivities = 0;
  for (let i = 0; i < 7; i++) {
    const currentDate = new Date(startDate);
    currentDate.setDate(startDate.getDate() + i);
    const activities = 0;
    days.push({
      date: currentDate.toISOString().split("T")[0],
      // YYYY-MM-DD format
      dayName: currentDate.toLocaleDateString("en-US", { weekday: "long" }),
      activities,
      meals: []
    });
  }
  return {
    startDate: startDate.toISOString().split("T")[0],
    endDate: endDate.toISOString().split("T")[0],
    weekNumber,
    totalActivities,
    days
  };
}
function generateCalendarWeeks(startDate, count) {
  const weeks = [];
  let currentDate = new Date(startDate);
  for (let i = 0; i < count; i++) {
    const weekStart = getStartOfUKWeek(currentDate);
    const weekNumber = getUKWeekNumber(weekStart);
    weeks.push(generateWeekData(weekStart, weekNumber));
    currentDate.setDate(currentDate.getDate() + 7);
  }
  return weeks;
}
function generateCalendarWeeksFromCurrent(count) {
  const today = /* @__PURE__ */ new Date();
  const currentWeekStart = getStartOfUKWeek(today);
  return generateCalendarWeeks(currentWeekStart, count);
}
function _page($$renderer, $$props) {
  $$renderer.component(($$renderer2) => {
    const loaderState = new LoaderState();
    let calendarWeeks = [];
    let pageNumber = 1;
    calendarWeeks = generateCalendarWeeksFromCurrent(4);
    const addActivity = (date, meal) => {
      const weekIndex = calendarWeeks.findIndex((week) => week.days.some((day) => day.date === date));
      if (weekIndex !== -1) {
        const dayIndex = calendarWeeks[weekIndex].days.findIndex((day) => day.date === date);
        if (dayIndex !== -1) {
          if (!calendarWeeks[weekIndex].days[dayIndex].meals) {
            calendarWeeks[weekIndex].days[dayIndex].meals = [];
          }
          calendarWeeks[weekIndex].days[dayIndex].meals.push(meal);
          calendarWeeks[weekIndex].days[dayIndex].activities += 1;
          calendarWeeks[weekIndex].totalActivities += 1;
          calendarWeeks[weekIndex] = { ...calendarWeeks[weekIndex] };
          calendarWeeks[weekIndex].days = [...calendarWeeks[weekIndex].days];
          calendarWeeks = [...calendarWeeks];
        }
      }
    };
    const loadMore = async () => {
      try {
        pageNumber += 1;
        const lastWeek = calendarWeeks[calendarWeeks.length - 1];
        const lastDate = new Date(lastWeek.endDate);
        lastDate.setDate(lastDate.getDate() + 1);
        const newWeeks = generateCalendarWeeks(lastDate, 2);
        if (newWeeks.length > 0) {
          calendarWeeks.push(...newWeeks);
          loaderState.loaded();
        } else {
          if (pageNumber > 10) {
            loaderState.complete();
          } else {
            loaderState.loaded();
          }
        }
      } catch (error) {
        console.error(error);
        loaderState.error();
        pageNumber -= 1;
      }
    };
    $$renderer2.push(`<div class="flex flex-col h-screen bg-gray-50"><div class="flex-1 overflow-y-auto">`);
    {
      let loading = function($$renderer3) {
        $$renderer3.push(`<div class="flex justify-center py-6 text-gray-400 text-sm">Loading more weeks...</div>`);
      };
      InfiniteLoader($$renderer2, {
        loaderState,
        triggerLoad: loadMore,
        loopDetectionTimeout: 7500,
        loading,
        children: ($$renderer3) => {
          $$renderer3.push(`<!--[-->`);
          const each_array = ensure_array_like(calendarWeeks);
          for (let $$index = 0, $$length = each_array.length; $$index < $$length; $$index++) {
            let week = each_array[$$index];
            WeekSection($$renderer3, { week, onAddActivity: addActivity });
          }
          $$renderer3.push(`<!--]-->`);
        }
      });
    }
    $$renderer2.push(`<!----></div></div>`);
  });
}
export {
  _page as default
};

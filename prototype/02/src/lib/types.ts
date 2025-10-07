export type ActivityIcon = "utensils" | "cookie" | "chef-hat" | "soup" | "salad";

export type AccentColor = "green" | "yellow" | "teal" | "orange" | "purple";

export type Activity = {
  id: string;
  title: string;
  prepTime?: string;
  distance?: string;
  icon: ActivityIcon;
  accentColor: AccentColor;
  thumbnail?: string;
};

export type CalendarDay = {
  date: string;
  dayLabel: string;
  dayNumber: number;
  activities: Activity[];
};

export type WeekSummary = {
  weekNumber: number;
  startDate: string;
  endDate: string;
  totalActivities: number;
  days: CalendarDay[];
};

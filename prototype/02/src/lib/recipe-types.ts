export type UcumUnit =
  | "cup_us"
  | "cup_m"
  | "cup_imp"
  | "tbsp_us"
  | "tbsp_m"
  | "tbsp_imp"
  | "tsp_us"
  | "tsp_m"
  | "tsp_imp";

export type MetricUnit = "ml" | "g";

export type AllergenCode =
  | "GLUTEN"
  | "CRUSTACEAN"
  | "EGG"
  | "FISH"
  | "PEANUT"
  | "SOY"
  | "MILK"
  | "NUT"
  | "CELERY"
  | "MUSTARD"
  | "SESAME"
  | "SULPHITE"
  | "LUPIN"
  | "MOLLUSC"
  | "SHELLFISH"
  | "TREENUT"
  | "WHEAT";

export interface Ingredient {
  name: string;
  "ucum-unit": UcumUnit;
  "ucum-amount": number;
  "metric-unit": MetricUnit;
  "metric-amount": number;
  notes: string;
  "allergen-code"?: AllergenCode;
}

export interface Recipe {
  title: string;
  image_url: string;
  description: string;
  notes: string;
  pre_reqs: string[];
  total_time: number;
  ingredients: Ingredient[];
  steps: string[];
}

// Data-access layer for IC: Home. Table names (homes, home_assets,
// maintenance_tasks) are unchanged from the original schema — only the
// product-facing vocabulary (SITREP, Resources, Action Items, Incident
// Log) changed. This keeps the DB stable while the UI language evolves.
import { supabase } from "./supabase";

export type AssetCategory =
  | "hvac"
  | "water_heater"
  | "pool"
  | "roof"
  | "appliance"
  | "vehicle"
  | "electrical"
  | "plumbing"
  | "other";

export interface HomeAsset {
  id: string;
  home_id: string;
  category: AssetCategory;
  manufacturer: string | null;
  model_number: string | null;
  serial_number: string | null;
  install_date: string | null;
  specs: Record<string, unknown> | null;
  created_at: string;
}

export async function listHomes() {
  const { data, error } = await supabase.from("homes").select("*").order("created_at");
  if (error) throw error;
  return data;
}

export async function listAssets(homeId: string) {
  const { data, error } = await supabase
    .from("home_assets")
    .select("*")
    .eq("home_id", homeId)
    .order("created_at");
  if (error) throw error;
  return data as HomeAsset[];
}

export async function createAsset(asset: Partial<HomeAsset>) {
  const { data, error } = await supabase.from("home_assets").insert(asset).select().single();
  if (error) throw error;
  return data as HomeAsset;
}

export async function listUpcomingTasks(homeId: string) {
  const { data, error } = await supabase
    .from("maintenance_tasks")
    .select("*, home_assets!inner(home_id, category)")
    .eq("home_assets.home_id", homeId)
    .neq("status", "completed")
    .order("due_date");
  if (error) throw error;
  return data;
}

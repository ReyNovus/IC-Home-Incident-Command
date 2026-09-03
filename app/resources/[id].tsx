import { useEffect, useState } from "react";
import { View, Text, Pressable, StyleSheet, ActivityIndicator } from "react-native";
import { router, useLocalSearchParams } from "expo-router";
import { SafeAreaView } from "react-native-safe-area-context";
import { supabase } from "../../src/lib/supabase";
import { HomeAsset, listAssetTasks, createTask } from "../../src/lib/homeData";

const C = { void: "#0A0D0F", panel: "#12171A", hairline: "#232B2F", text: "#E7ECEE", textDim: "#7C8A8F", cyan: "#4FB8C4", red: "#D65B4A", amber: "#D9A431" };

type Suggestion = { title: string; due_date: string; description: string };

export default function ResourceDetail() {
const { id } = useLocalSearchParams<{ id: string }>();
const [asset, setAsset] = useState<HomeAsset | null>(null);
const [tasks, setTasks] = useState<any[]>([]);
const [suggestions, setSuggestions] = useState<Suggestion[]>([]);
const [suggesting, setSuggesting] = useState(false);
const [addingIndex, setAddingIndex] = useState<number | null>(null);
const [error, setError] = useState<string | null>(null);

async function load() {
const { data } = await supabase.from("home_assets").select("*").eq("id", id).single();
setAsset(data);
if (data) setTasks(await listAssetTasks(data.id));
}

useEffect(() => {
load();
}, [id]);

async function getSuggestions() {
setSuggesting(true);
setError(null);
setSuggestions([]);
try {
const { data, error } = await supabase.functions.invoke("suggest-maintenance", {
body: { assetId: id },
});
if (error) throw error;
setSuggestions(data.suggestions ?? []);
} catch (e) {
setError("Couldn't get suggestions — try again.");
} finally {
setSuggesting(false);
}
}

async function acceptSuggestion(s: Suggestion, index: number) {
if (!asset) return;
setAddingIndex(index);
try {
await createTask({
asset_id: asset.id,
title: s.title,
due_date: s.due_date,
description: s.description,
});
setSuggestions((prev) => prev.filter((_, i) => i !== index));
setTasks(await listAssetTasks(asset.id));
} catch (e) {
setError("Couldn't add that task — try again.");
} finally {
setAddingIndex(null);
}
}

return (
<SafeAreaView style={styles.container} edges={["top"]}>
<View style={styles.topBar}>
<Pressable onPress={() => router.back()}>
<Text style={styles.backText}>← BACK</Text>
</Pressable>
</View>

<View style={{ padding: 16 }}>
{!asset ? (
<Text style={styles.meta}>Loading…</Text>
) : (
<>
<Text style={styles.title}>{asset.category.toUpperCase().replace("_", " ")}</Text>
<View style={styles.card}>
{[
["Manufacturer", asset.manufacturer ?? "—"],
["Model", asset.model_number ?? "—"],
["Serial", asset.serial_number ?? "—"],
["Installed", asset.install_date ?? "—"],
].map(([label, val]) => (
<View key={label} style={styles.row}>
<Text style={styles.rowLabel}>{label.toUpperCase()}</Text>
<Text style={styles.rowVal}>{val}</Text>
</View>
))}
</View>

<View style={styles.sectionHeader}>
<Text style={styles.eyebrow}>OPERATIONAL PERIOD</Text>
<Pressable
style={styles.addBtn}
onPress={() =>
router.push(
`/resources/new-task?assetId=${asset.id}&assetName=${encodeURIComponent(asset.category)}`
)
}
>
<Text style={styles.addBtnText}>+ ADD TASK</Text>
</Pressable>
</View>

{tasks.length === 0 ? (
<Text style={styles.meta}>No tasks logged for this resource yet.</Text>
) : (
tasks.map((t) => (
<View key={t.id} style={styles.taskCard}>
<View style={{ flex: 1 }}>
<Text style={styles.taskTitle}>{t.title}</Text>
{t.due_date && <Text style={styles.meta}>Due {t.due_date}</Text>}
</View>
<View
style={[
styles.dot,
{ backgroundColor: t.status === "completed" ? C.textDim : t.status === "overdue" ? C.red : C.amber },
]}
/>
</View>
))
)}

<Pressable style={styles.suggestBtn} onPress={getSuggestions} disabled={suggesting}>
{suggesting ? (
<ActivityIndicator size="small" color={C.cyan} />
) : (
<Text style={styles.suggestBtnText}>🤖 SUGGEST MAINTENANCE</Text>
)}
</Pressable>

{error && <Text style={styles.error}>{error}</Text>}

{suggestions.length > 0 && (
<View style={{ marginTop: 12 }}>
<Text style={styles.eyebrow}>SUGGESTED — REVIEW &amp; ADD</Text>
{suggestions.map((s, i) => (
<View key={i} style={styles.suggestionCard}>
<View style={{ flex: 1 }}>
<Text style={styles.taskTitle}>{s.title}</Text>
<Text style={styles.meta}>Suggested due {s.due_date}</Text>
<Text style={styles.suggestionDesc}>{s.description}</Text>
</View>
<Pressable
style={styles.acceptBtn}
onPress={() => acceptSuggestion(s, i)}
disabled={addingIndex === i}
>
<Text style={styles.acceptBtnText}>{addingIndex === i ? "…" : "+ ADD"}</Text>
</Pressable>
</View>
))}
</View>
)}
</>
)}
</View>
</SafeAreaView>
);

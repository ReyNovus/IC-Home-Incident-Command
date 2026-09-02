#!/bin/bash
set -e
# Run this from the root of your ic-home repo checkout in the Codespace terminal.
# It removes anything currently at the repo root and rebuilds the correct # expo-router folder structure, then commits and pushes.

# --- clean slate: remove everything except .git --- find . -mindepth 1 -maxdepth 1 ! -name ".git" -exec rm -rf {} +

# --- create folders ---
mkdir -p "app/(auth)" "app/(tabs)" "app/resources" "src/lib" "supabase/migrations"

# --- .env.example ---
cat > ".env.example" << 'FILEEOF'
EXPO_PUBLIC_SUPABASE_URL=
EXPO_PUBLIC_SUPABASE_ANON_KEY=

FILEEOF

# --- README.md ---
cat > "README.md" << 'FILEEOF'
# IC: Home — Phase 1 scaffold

"Every home is an incident waiting to happen. Now you have an Incident Commander."

Expo (React Native + expo-router) + Supabase (Postgres + Auth + Storage), RLS-isolated per user. IBM Plex Mono for readouts/status, IBM Plex Sans for plain-language explanation — the design system mirrors an ops-room console, not a lifestyle app.

## Vocabulary → structure

| Product language     | Screen / table                          |
|-----------------------|------------------------------------------|
| SITREP                | `app/(tabs)/index.tsx` (dashboard)       |
| Resources             | `app/(tabs)/resources.tsx` → `home_assets` |
| Incident Log          | `app/resources/[id].tsx` (per-resource)  |
| Operational Period    | upcoming tasks in `maintenance_tasks`    |
| IC Assistant          | `app/(tabs)/assistant.tsx`               |
| Home Status (G/Y/R)   | status light component, driven by task/asset status |

## Structure

```
app/
  (auth)/onboarding.tsx   "Welcome to IC: Home" — first screen, no session
  (auth)/sign-in.tsx      email/password
  (tabs)/                 SITREP, Resources, IC Assistant
  resources/[id].tsx      resource detail (incident log, docs, record)
src/lib/supabase.ts       Supabase client
src/lib/homeData.ts       typed data-access functions
supabase/migrations/      SQL schema + RLS policies (table names unchanged)
```

## Setup

1. `npm install`
2. Create a Supabase project, run `supabase/migrations/0001_init.sql`
3. Copy `.env.example` to `.env`, fill in project URL + anon key 4. `npm run start`

Fonts (`@expo-google-fonts/ibm-plex-mono`, `ibm-plex-sans`) load via `expo-font` in `app/_layout.tsx` before any screen renders.

## Not yet built (by design — see Phase plan)

- `supabase/functions/ic-assistant` edge function (Phase 4: RAG over
  home_assets + documents, called from `app/(tabs)/assistant.tsx`)
- AI vision resource identification (Phase 3)
- Document upload + extraction into the Incident Log (Phase 6)
- Push notifications for Critical Issues (Phase 5)
- Session gating on `(auth)` vs `(tabs)` in `app/_layout.tsx` — currently
  a stub comment; wire to `supabase.auth.onAuthStateChange`

Each screen reads/writes real Supabase tables where wired, and is left as a clearly-marked stub where a later phase owns the logic — nothing here fakes data silently.

FILEEOF

# --- app.json ---
cat > "app.json" << 'FILEEOF'
{
  "expo": {
    "name": "IC: Home",
    "slug": "ic-home",
    "scheme": "ichome",
    "version": "0.1.0",
    "orientation": "portrait",
    "userInterfaceStyle": "dark",
    "backgroundColor": "#0A0D0F",
    "plugins": ["expo-router"],
    "ios": { "supportsTablet": false, "bundleIdentifier": "com.ichome.app" },
    "android": { "package": "com.ichome.app" },
    "web": { "bundler": "metro" }
  }
}

FILEEOF

# --- app/(auth)/onboarding.tsx ---
cat > "app/(auth)/onboarding.tsx" << 'FILEEOF'
import { View, Text, Pressable, StyleSheet } from "react-native"; import { router } from "expo-router";

const C = {
  void: "#0A0D0F",
  text: "#E7ECEE",
  textDim: "#7C8A8F",
  green: "#35A667",
  cyan: "#4FB8C4",
  hairline: "#232B2F",
};

export default function Onboarding() {
  return (
    <View style={styles.container}>
      <View style={styles.statusRow}>
        <View style={styles.dot} />
        <Text style={styles.statusText}>CHANNEL OPEN</Text>
      </View>

      <Text style={styles.wordmark}>IC: HOME</Text>

      <Text style={styles.tagline}>
        Every home is an incident waiting to happen.{"\n"}Now you have an
        Incident Commander.
      </Text>

      <View style={styles.divider} />

      <Text style={styles.body}>
        IC: Home keeps a live operational picture of your house — every
        system, every document, every job that's due — so you're never
        the one holding it all in your head.
      </Text>

      <Pressable style={styles.primaryBtn} onPress={() => router.push("/(auth)/sign-in")}>
        <Text style={styles.primaryBtnText}>ESTABLISH COMMAND</Text>
      </Pressable>

      <Pressable onPress={() => router.push("/(auth)/sign-in")}>
        <Text style={styles.secondaryText}>Already have an account? Sign in</Text>
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: C.void, padding: 28, justifyContent: "center" },
  statusRow: { flexDirection: "row", alignItems: "center", gap: 8, marginBottom: 28 },
  dot: { width: 8, height: 8, borderRadius: 4, backgroundColor: C.green },
  statusText: {
    fontFamily: "IBMPlexMono_600SemiBold",
    fontSize: 11,
    letterSpacing: 1.5,
    color: C.textDim,
  },
  wordmark: {
    fontFamily: "IBMPlexMono_700Bold",
    fontSize: 34,
    letterSpacing: 1,
    color: C.text,
    marginBottom: 16,
  },
  tagline: {
    fontFamily: "IBMPlexSans_500Medium",
    fontSize: 17,
    lineHeight: 24,
    color: C.text,
    marginBottom: 24,
  },
  divider: { height: 1, backgroundColor: C.hairline, marginBottom: 24 },
  body: {
    fontFamily: "IBMPlexSans_400Regular",
    fontSize: 13,
    lineHeight: 20,
    color: C.textDim,
    marginBottom: 40,
  },
  primaryBtn: {
    backgroundColor: C.cyan,
    borderRadius: 4,
    paddingVertical: 14,
    alignItems: "center",
    marginBottom: 16,
  },
  primaryBtnText: {
    fontFamily: "IBMPlexMono_700Bold",
    fontSize: 12,
    letterSpacing: 1,
    color: "#0A0D0F",
  },
  secondaryText: {
    fontFamily: "IBMPlexSans_400Regular",
    fontSize: 13,
    color: C.textDim,
    textAlign: "center",
  },
});

FILEEOF

# --- app/(auth)/sign-in.tsx ---
cat > "app/(auth)/sign-in.tsx" << 'FILEEOF'
import { useState } from "react";
import { View, Text, TextInput, Pressable, StyleSheet } from "react-native"; import { router } from "expo-router"; import { supabase } from "../../src/lib/supabase";

const C = {
  void: "#0A0D0F",
  panel: "#12171A",
  text: "#E7ECEE",
  textDim: "#7C8A8F",
  cyan: "#4FB8C4",
  red: "#D65B4A",
  hairline: "#232B2F",
};

export default function SignIn() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);

  async function signIn() {
    const { error } = await supabase.auth.signInWithPassword({ email, password });
    if (error) setError(error.message);
    else router.replace("/(tabs)");
  }

  return (
    <View style={styles.container}>
      <Text style={styles.eyebrow}>ACCESS — COMMAND CONSOLE</Text>
      <Text style={styles.heading}>Sign in to IC: Home</Text>

      <TextInput
        style={styles.input}
        placeholder="Email"
        placeholderTextColor={C.textDim}
        autoCapitalize="none"
        value={email}
        onChangeText={setEmail}
      />
      <TextInput
        style={styles.input}
        placeholder="Password"
        placeholderTextColor={C.textDim}
        secureTextEntry
        value={password}
        onChangeText={setPassword}
      />
      {error && <Text style={styles.error}>{error}</Text>}

      <Pressable style={styles.button} onPress={signIn}>
        <Text style={styles.buttonText}>OPEN CHANNEL</Text>
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: C.void, padding: 24, justifyContent: "center" },
  eyebrow: {
    fontFamily: "IBMPlexMono_600SemiBold",
    fontSize: 11,
    letterSpacing: 1.5,
    color: C.textDim,
    marginBottom: 8,
  },
  heading: {
    fontFamily: "IBMPlexMono_700Bold",
    fontSize: 22,
    color: C.text,
    marginBottom: 28,
  },
  input: {
    backgroundColor: C.panel,
    borderRadius: 4,
    padding: 14,
    marginBottom: 12,
    borderWidth: 1,
    borderColor: C.hairline,
    color: C.text,
    fontFamily: "IBMPlexSans_400Regular",
  },
  button: {
    backgroundColor: C.cyan,
    borderRadius: 4,
    padding: 14,
    alignItems: "center",
    marginTop: 8,
  },
  buttonText: {
    fontFamily: "IBMPlexMono_700Bold",
    fontSize: 12,
    letterSpacing: 1,
    color: "#0A0D0F",
  },
  error: { color: C.red, marginBottom: 8, fontFamily: "IBMPlexSans_400Regular", fontSize: 12 }, });

FILEEOF

# --- app/(tabs)/_layout.tsx ---
cat > "app/(tabs)/_layout.tsx" << 'FILEEOF'
import { Tabs } from "expo-router";

const C = { void: "#0A0D0F", panel: "#171D21", cyan: "#4FB8C4", textDim: "#7C8A8F", hairline: "#232B2F" };

export default function TabsLayout() {
  return (
    <Tabs
      screenOptions={{
        headerShown: false,
        tabBarActiveTintColor: C.cyan,
        tabBarInactiveTintColor: C.textDim,
        tabBarStyle: { backgroundColor: C.panel, borderTopColor: C.hairline },
        tabBarLabelStyle: { fontFamily: "IBMPlexMono_600SemiBold", fontSize: 10, letterSpacing: 0.5 },
      }}
    >
      <Tabs.Screen name="index" options={{ title: "SITREP" }} />
      <Tabs.Screen name="resources" options={{ title: "RESOURCES" }} />
      <Tabs.Screen name="assistant" options={{ title: "IC" }} />
    </Tabs>
  );
}

FILEEOF

# --- app/(tabs)/assistant.tsx ---
cat > "app/(tabs)/assistant.tsx" << 'FILEEOF'
import { useState } from "react";
import { View, Text, TextInput, Pressable, FlatList, StyleSheet } from "react-native"; import { supabase } from "../../src/lib/supabase";

const C = { void: "#0A0D0F", panel: "#12171A", cyan: "#4FB8C4", text: "#E7ECEE", textDim: "#7C8A8F", hairline: "#232B2F" };

type Message = { role: "user" | "assistant"; content: string };

// IC ASSISTANT — same retrieval-backed chat as before (calls the // "ic-assistant" edge function, renamed from ask-my-home), restyled // as an open comms channel.
export default function Assistant() {
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState("");

  async function send() {
    if (!input.trim()) return;
    const question = input;
    setMessages((m) => [...m, { role: "user", content: question }]);
    setInput("");

    const { data, error } = await supabase.functions.invoke("ic-assistant", {
      body: { question },
    });

    setMessages((m) => [
      ...m,
      { role: "assistant", content: error ? "Channel error — try again." : data.answer },
    ]);
  }

  return (
    <View style={styles.container}>
      <Text style={styles.eyebrow}>IC ASSISTANT — CHANNEL OPEN</Text>
      <FlatList
        data={messages}
        keyExtractor={(_, i) => String(i)}
        renderItem={({ item }) => (
          <View style={[styles.bubble, item.role === "user" ? styles.userBubble : styles.assistantBubble]}>
            <Text style={item.role === "user" ? styles.userText : styles.assistantText}>{item.content}</Text>
          </View>
        )}
      />
      <View style={styles.inputRow}>
        <TextInput
          value={input}
          onChangeText={setInput}
          placeholder="Transmit a question…"
          placeholderTextColor={C.textDim}
          style={styles.input}
          onSubmitEditing={send}
        />
        <Pressable onPress={send} style={styles.sendBtn}>
          <Text style={styles.sendText}>SEND</Text>
        </Pressable>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: C.void, padding: 16 },
  eyebrow: { fontFamily: "IBMPlexMono_600SemiBold", fontSize: 11, color: C.textDim, letterSpacing: 1, marginBottom: 12 },
  bubble: { padding: 12, borderRadius: 8, marginBottom: 8, maxWidth: "85%", borderWidth: 1 },
  userBubble: { backgroundColor: C.panel, borderColor: C.hairline, alignSelf: "flex-end" },
  assistantBubble: { backgroundColor: "#4FB8C412", borderColor: "#4FB8C444", alignSelf: "flex-start" },
  userText: { color: C.text, fontFamily: "IBMPlexSans_400Regular", fontSize: 13 },
  assistantText: { color: C.text, fontFamily: "IBMPlexSans_400Regular", fontSize: 13, lineHeight: 19 },
  inputRow: { flexDirection: "row", gap: 8, marginTop: 8 },
  input: { flex: 1, backgroundColor: C.panel, borderRadius: 6, paddingHorizontal: 16, paddingVertical: 10, borderWidth: 1, borderColor: C.hairline, color: C.text, fontFamily: "IBMPlexSans_400Regular" },
  sendBtn: { backgroundColor: C.cyan, borderRadius: 6, paddingHorizontal: 16, justifyContent: "center" },
  sendText: { color: "#0A0D0F", fontFamily: "IBMPlexMono_700Bold", fontSize: 11, letterSpacing: 0.5 }, });

FILEEOF

# --- app/(tabs)/index.tsx ---
cat > "app/(tabs)/index.tsx" << 'FILEEOF'
import { useEffect, useState } from "react"; import { View, Text, FlatList, StyleSheet } from "react-native"; import { listHomes, listUpcomingTasks } from "../../src/lib/homeData";

const C = {
  void: "#0A0D0F",
  panel: "#12171A",
  panelHi: "#171D21",
  hairline: "#232B2F",
  text: "#E7ECEE",
  textDim: "#7C8A8F",
  green: "#35A667",
  amber: "#D9A431",
  red: "#D65B4A",
};

// SITREP — the home tab. Pulls live open tasks from maintenance_tasks // (via homeData.ts) rather than mock data; empty state assumes no // resources have been added yet.
export default function Sitrep() {
  const [tasks, setTasks] = useState<any[]>([]);

  useEffect(() => {
    (async () => {
      const homes = await listHomes();
      if (homes?.[0]) {
        const upcoming = await listUpcomingTasks(homes[0].id);
        setTasks(upcoming ?? []);
      }
    })();
  }, []);

  const critical = tasks.filter((t) => t.status === "overdue");

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.headerLabel}>SITREP</Text>
        <View style={styles.statusRow}>
          <View style={[styles.dot, { backgroundColor: critical.length ? C.red : C.green }]} />
          <Text style={[styles.statusText, { color: critical.length ? C.red : C.green }]}>
            HOME STATUS: {critical.length ? "ATTENTION NEEDED" : "STABLE"}
          </Text>
        </View>
      </View>

      <Text style={styles.eyebrow}>CRITICAL ISSUES</Text>
      <FlatList
        data={tasks}
        keyExtractor={(t) => t.id}
        renderItem={({ item }) => (
          <View style={styles.card}>
            <View style={styles.cardRow}>
              <View
                style={[
                  styles.smallDot,
                  { backgroundColor: item.status === "overdue" ? C.red : C.amber },
                ]}
              />
              <View style={{ flex: 1 }}>
                <Text style={styles.title}>{item.title}</Text>
                <Text style={styles.meta}>Due {item.due_date}</Text>
              </View>
            </View>
          </View>
        )}
        ListEmptyComponent={
          <Text style={styles.meta}>No open action items — add resources to populate the SITREP.</Text>
        }
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: C.void, padding: 16 },
  header: {
    backgroundColor: C.panelHi,
    borderWidth: 1,
    borderColor: C.hairline,
    borderRadius: 6,
    padding: 14,
    marginBottom: 20,
  },
  headerLabel: { fontFamily: "IBMPlexMono_600SemiBold", fontSize: 11, color: C.textDim, letterSpacing: 1, marginBottom: 8 },
  statusRow: { flexDirection: "row", alignItems: "center", gap: 8 },
  dot: { width: 10, height: 10, borderRadius: 5 },
  statusText: { fontFamily: "IBMPlexMono_700Bold", fontSize: 14, letterSpacing: 0.5 },
  eyebrow: { fontFamily: "IBMPlexMono_600SemiBold", fontSize: 11, color: C.textDim, letterSpacing: 1, marginBottom: 8 },
  card: { backgroundColor: C.panel, borderRadius: 6, padding: 12, marginBottom: 8, borderWidth: 1, borderColor: C.hairline },
  cardRow: { flexDirection: "row", alignItems: "center", gap: 10 },
  smallDot: { width: 8, height: 8, borderRadius: 4 },
  title: { fontFamily: "IBMPlexMono_600SemiBold", fontSize: 12, color: C.text },
  meta: { fontFamily: "IBMPlexSans_400Regular", fontSize: 12, color: C.textDim, marginTop: 4 }, });

FILEEOF

# --- app/(tabs)/resources.tsx ---
cat > "app/(tabs)/resources.tsx" << 'FILEEOF'
import { useEffect, useState } from "react"; import { View, Text, FlatList, Pressable, StyleSheet } from "react-native"; import { router } from "expo-router"; import { listHomes, listAssets, HomeAsset } from "../../src/lib/homeData";

const C = { void: "#0A0D0F", panel: "#12171A", hairline: "#232B2F", text: "#E7ECEE", textDim: "#7C8A8F", green: "#35A667" };

// RESOURCES — equipment, appliances, vehicles. Backed by the same // home_assets table as before; only the label and framing changed.
export default function Resources() {
  const [assets, setAssets] = useState<HomeAsset[]>([]);

  useEffect(() => {
    (async () => {
      const homes = await listHomes();
      if (homes?.[0]) setAssets(await listAssets(homes[0].id));
    })();
  }, []);

  return (
    <View style={styles.container}>
      <Text style={styles.eyebrow}>RESOURCES</Text>
      <FlatList
        data={assets}
        keyExtractor={(a) => a.id}
        renderItem={({ item }) => (
          <Pressable style={styles.card} onPress={() => router.push(`/resources/${item.id}`)}>
            <View style={{ flex: 1 }}>
              <Text style={styles.title}>{item.category.toUpperCase().replace("_", " ")}</Text>
              <Text style={styles.meta}>{item.manufacturer ?? "Manufacturer unknown"}</Text>
            </View>
            <View style={styles.dot} />
          </Pressable>
        )}
        ListEmptyComponent={<Text style={styles.meta}>No resources on record. Tap + to log your first one.</Text>}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: C.void, padding: 16 },
  eyebrow: { fontFamily: "IBMPlexMono_600SemiBold", fontSize: 11, color: C.textDim, letterSpacing: 1, marginBottom: 12 },
  card: { flexDirection: "row", alignItems: "center", backgroundColor: C.panel, borderRadius: 6, padding: 12, marginBottom: 8, borderWidth: 1, borderColor: C.hairline },
  title: { fontFamily: "IBMPlexMono_600SemiBold", fontSize: 12, color: C.text },
  meta: { fontFamily: "IBMPlexSans_400Regular", fontSize: 12, color: C.textDim, marginTop: 4 },
  dot: { width: 8, height: 8, borderRadius: 4, backgroundColor: C.green }, });

FILEEOF

# --- app/_layout.tsx ---
cat > "app/_layout.tsx" << 'FILEEOF'
import { Stack } from "expo-router";
import { useFonts, IBMPlexMono_400Regular, IBMPlexMono_600SemiBold, IBMPlexMono_700Bold } from "@expo-google-fonts/ibm-plex-mono";
import { IBMPlexSans_400Regular, IBMPlexSans_500Medium, IBMPlexSans_600SemiBold } from "@expo-google-fonts/ibm-plex-sans";

export default function RootLayout() {
  const [fontsLoaded] = useFonts({
    IBMPlexMono_400Regular,
    IBMPlexMono_600SemiBold,
    IBMPlexMono_700Bold,
    IBMPlexSans_400Regular,
    IBMPlexSans_500Medium,
    IBMPlexSans_600SemiBold,
  });

  if (!fontsLoaded) return null;

  // Phase 1 stub: gate on Supabase session once auth is wired up.
  // No session -> (auth)/onboarding. Session -> (tabs).
  return (
    <Stack screenOptions={{ headerShown: false }}>
      <Stack.Screen name="(auth)/onboarding" />
      <Stack.Screen name="(auth)/sign-in" />
      <Stack.Screen name="(tabs)" />
      <Stack.Screen name="resources/[id]" options={{ headerShown: true, title: "" }} />
    </Stack>
  );
}

FILEEOF

# --- app/resources/[id].tsx ---
cat > "app/resources/[id].tsx" << 'FILEEOF'
import { useLocalSearchParams } from "expo-router"; import { View, Text, StyleSheet } from "react-native";

const C = { void: "#0A0D0F", text: "#E7ECEE" };

// Resource detail — incident log, resource record, documents.
// Fetch the single asset by id (+ documents and service_records) // via src/lib/homeData.ts once wired to real data.
export default function ResourceDetail() {
  const { id } = useLocalSearchParams<{ id: string }>();
  return (
    <View style={styles.container}>
      <Text style={styles.text}>Resource record for asset {id}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: C.void, padding: 16 },
  text: { color: C.text, fontFamily: "IBMPlexSans_400Regular" }, });

FILEEOF

# --- package.json ---
cat > "package.json" << 'FILEEOF'
{
  "name": "ic-home",
  "version": "0.1.0",
  "private": true,
  "main": "expo-router/entry",
  "scripts": {
    "start": "expo start",
    "ios": "expo start --ios",
    "android": "expo start --android",
    "web": "expo start --web"
  },
  "dependencies": {
    "expo": "~51.0.0",
    "expo-router": "~3.5.0",
    "expo-status-bar": "~1.12.0",
    "expo-image-picker": "~15.0.0",
    "expo-document-picker": "~12.0.0",
    "react": "18.2.0",
    "react-native": "0.74.0",
    "react-native-safe-area-context": "4.10.1",
    "react-native-screens": "3.31.1",
    "@supabase/supabase-js": "^2.45.0",
    "react-native-url-polyfill": "^2.0.0",
    "@react-native-async-storage/async-storage": "1.23.1",
    "@expo-google-fonts/ibm-plex-mono": "^0.2.3",
    "@expo-google-fonts/ibm-plex-sans": "^0.2.3",
    "expo-font": "~12.0.0"
  },
  "devDependencies": {
    "@babel/core": "^7.24.0",
    "typescript": "^5.3.0",
    "@types/react": "~18.2.0"
  }
}

FILEEOF

# --- src/lib/homeData.ts ---
cat > "src/lib/homeData.ts" << 'FILEEOF'
// Data-access layer for IC: Home. Table names (homes, home_assets, // maintenance_tasks) are unchanged from the original schema — only the // product-facing vocabulary (SITREP, Resources, Action Items, Incident // Log) changed. This keeps the DB stable while the UI language evolves.
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

FILEEOF

# --- src/lib/supabase.ts ---
cat > "src/lib/supabase.ts" << 'FILEEOF'
import "react-native-url-polyfill/auto"; import AsyncStorage from "@react-native-async-storage/async-storage";
import { createClient } from "@supabase/supabase-js";

// Populate these from your Supabase project settings.
// Never commit real values — use app.config.ts + env vars in production.
const SUPABASE_URL = process.env.EXPO_PUBLIC_SUPABASE_URL as string; const SUPABASE_ANON_KEY = process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY as string;

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
  auth: {
    storage: AsyncStorage,
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: false,
  },
});

FILEEOF

# --- supabase/migrations/0001_init.sql --- cat > "supabase/migrations/0001_init.sql" << 'FILEEOF'
-- IC: Home — Phase 1 schema
-- Table names stay generic (homes, home_assets, maintenance_tasks) even
-- though the product surface speaks in incident-command language
-- (Resources, Action Items, Incident Log) — the schema shouldn't have to
-- be renamed every time the product's voice changes.
-- Every table is scoped to auth.uid() via homes.user_id, either directly
-- or through a join, and RLS is enabled everywhere. Users only ever see
-- their own data; the AI layer inherits the same restriction because it
-- reads through the same Supabase client with the user's session.

create table if not exists homes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  address text not null,
  year_built int,
  square_footage int,
  bedrooms int,
  bathrooms numeric,
  created_at timestamptz not null default now() );

create type asset_category as enum (
  'hvac','water_heater','pool','roof','appliance','vehicle','electrical','plumbing','other'
);

create table if not exists home_assets (
  id uuid primary key default gen_random_uuid(),
  home_id uuid not null references homes(id) on delete cascade,
  category asset_category not null,
  manufacturer text,
  model_number text,
  serial_number text,
  install_date date,
  estimated_age_years numeric,
  specs jsonb default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now() );

create table if not exists asset_photos (
  id uuid primary key default gen_random_uuid(),
  asset_id uuid not null references home_assets(id) on delete cascade,
  storage_path text not null,
  ai_extracted_data jsonb default '{}'::jsonb,
  uploaded_at timestamptz not null default now() );

create table if not exists documents (
  id uuid primary key default gen_random_uuid(),
  home_id uuid not null references homes(id) on delete cascade,
  asset_id uuid references home_assets(id) on delete set null,
  doc_type text not null check (doc_type in ('warranty','receipt','manual','inspection','insurance','other')),
  storage_path text not null,
  ai_extracted_data jsonb default '{}'::jsonb,
  expiry_date date,
  uploaded_at timestamptz not null default now() );

create table if not exists maintenance_tasks (
  id uuid primary key default gen_random_uuid(),
  asset_id uuid not null references home_assets(id) on delete cascade,
  title text not null,
  description text,
  status text not null default 'upcoming' check (status in ('today','this_week','this_month','upcoming','overdue','completed')),
  due_date date,
  completed_date date,
  completed_by text,
  cost numeric,
  recurrence_interval_days int
);

create table if not exists service_records (
  id uuid primary key default gen_random_uuid(),
  asset_id uuid not null references home_assets(id) on delete cascade,
  performed_date date not null,
  performed_by text,
  cost numeric,
  notes text
);

create table if not exists notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  asset_id uuid references home_assets(id) on delete cascade,
  message text not null,
  type text,
  sent_at timestamptz default now(),
  read_at timestamptz
);

-- ---------- Row Level Security ----------

alter table homes enable row level security; alter table home_assets enable row level security; alter table asset_photos enable row level security; alter table documents enable row level security; alter table maintenance_tasks enable row level security; alter table service_records enable row level security; alter table notifications enable row level security;

create policy "homes: owner full access" on homes
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "home_assets: owner full access" on home_assets
  for all using (exists (select 1 from homes h where h.id = home_id and h.user_id = auth.uid()))
  with check (exists (select 1 from homes h where h.id = home_id and h.user_id = auth.uid()));

create policy "asset_photos: owner full access" on asset_photos
  for all using (exists (
    select 1 from home_assets a join homes h on h.id = a.home_id
    where a.id = asset_id and h.user_id = auth.uid()
  ));

create policy "documents: owner full access" on documents
  for all using (exists (select 1 from homes h where h.id = home_id and h.user_id = auth.uid()))
  with check (exists (select 1 from homes h where h.id = home_id and h.user_id = auth.uid()));

create policy "maintenance_tasks: owner full access" on maintenance_tasks
  for all using (exists (
    select 1 from home_assets a join homes h on h.id = a.home_id
    where a.id = asset_id and h.user_id = auth.uid()
  ));

create policy "service_records: owner full access" on service_records
  for all using (exists (
    select 1 from home_assets a join homes h on h.id = a.home_id
    where a.id = asset_id and h.user_id = auth.uid()
  ));

create policy "notifications: owner full access" on notifications
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

FILEEOF

# --- commit and push ---
git add -A
git commit -m "Fix folder structure — rebuild correct expo-router layout"
git push

echo "Done. Repo structure fixed and pushed."

import { useEffect, useState } from "react";
import { View, Text, FlatList, StyleSheet } from "react-native";
import { listHomes, listUpcomingTasks } from "../../src/lib/homeData";

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

// SITREP — the home tab. Pulls live open tasks from maintenance_tasks
// (via homeData.ts) rather than mock data; empty state assumes no
// resources have been added yet.
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
  meta: { fontFamily: "IBMPlexSans_400Regular", fontSize: 12, color: C.textDim, marginTop: 4 },
});

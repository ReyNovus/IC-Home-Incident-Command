import { useEffect, useState } from "react";
import { View, Text, FlatList, Pressable, StyleSheet } from "react-native";
import { router } from "expo-router";
import { listHomes, listAssets, HomeAsset } from "../../src/lib/homeData";

const C = { void: "#0A0D0F", panel: "#12171A", hairline: "#232B2F", text: "#E7ECEE", textDim: "#7C8A8F", green: "#35A667" };

// RESOURCES — equipment, appliances, vehicles. Backed by the same
// home_assets table as before; only the label and framing changed.
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
  dot: { width: 8, height: 8, borderRadius: 4, backgroundColor: C.green },
});

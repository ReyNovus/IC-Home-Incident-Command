import { useLocalSearchParams } from "expo-router";
import { View, Text, StyleSheet } from "react-native";

const C = { void: "#0A0D0F", text: "#E7ECEE" };

// Resource detail — incident log, resource record, documents.
// Fetch the single asset by id (+ documents and service_records)
// via src/lib/homeData.ts once wired to real data.
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
  text: { color: C.text, fontFamily: "IBMPlexSans_400Regular" },
});

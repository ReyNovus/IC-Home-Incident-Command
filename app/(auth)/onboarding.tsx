import { View, Text, Pressable, StyleSheet } from "react-native";
import { router } from "expo-router";

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

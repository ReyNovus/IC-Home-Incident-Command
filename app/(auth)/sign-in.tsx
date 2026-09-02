import { useState } from "react";
import { View, Text, TextInput, Pressable, StyleSheet } from "react-native";
import { router } from "expo-router";
import { supabase } from "../../src/lib/supabase";

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
  error: { color: C.red, marginBottom: 8, fontFamily: "IBMPlexSans_400Regular", fontSize: 12 },
});

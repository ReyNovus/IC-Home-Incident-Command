import { useState } from "react";
import { View, Text, TextInput, Pressable, FlatList, StyleSheet } from "react-native";
import { supabase } from "../../src/lib/supabase";

const C = { void: "#0A0D0F", panel: "#12171A", cyan: "#4FB8C4", text: "#E7ECEE", textDim: "#7C8A8F", hairline: "#232B2F" };

type Message = { role: "user" | "assistant"; content: string };

// IC ASSISTANT — same retrieval-backed chat as before (calls the
// "ic-assistant" edge function, renamed from ask-my-home), restyled
// as an open comms channel.
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
  sendText: { color: "#0A0D0F", fontFamily: "IBMPlexMono_700Bold", fontSize: 11, letterSpacing: 0.5 },
});

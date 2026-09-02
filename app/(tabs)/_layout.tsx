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

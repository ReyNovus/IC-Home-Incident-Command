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
